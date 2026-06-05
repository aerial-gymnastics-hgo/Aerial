/**
 * SCRIPT DE VALIDACIÓN POST-MIGRACIÓN
 * 
 * Propósito: Verifica que los documentos en Firestore cumplan con el esquema
 * requerido por los parsers de la aplicación GymManager.
 * 
 * Requisitos: nodejs, npm install firebase-admin
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function validateMigration() {
  console.log('--- Iniciando Validación de Datos ---');

  // 1. Validar Usuarios
  const usersSnap = await db.collection('users').get();
  usersSnap.forEach(doc => {
    const data = doc.data();
    if (!data.name || typeof data.name !== 'string') console.error(`[ERROR] User ${doc.id}: Campo 'name' faltante o inválido.`);
    if (!data.role || !['admin', 'coach', 'parent', 'student', 'viewer'].includes(data.role)) {
      console.error(`[ERROR] User ${doc.id}: Campo 'role' inválido (${data.role}).`);
    }
    if (data.role === 'coach' && (data.colorHex !== undefined && typeof data.colorHex !== 'number')) {
      console.error(`[ERROR] Coach ${doc.id}: 'colorHex' debe ser número (int).`);
    }
  });

  // 2. Validar Assignments (Horarios)
  const assignmentsSnap = await db.collection('assignments').get();
  assignmentsSnap.forEach(doc => {
    const data = doc.data();
    if (!data.startTime || !data.startTime.includes(':')) console.error(`[ERROR] Assignment ${doc.id}: 'startTime' mal formateado.`);
    if (!data.endTime || !data.endTime.includes(':')) console.error(`[ERROR] Assignment ${doc.id}: 'endTime' mal formateado.`);
  });

  // 3. Validar Estructura Unificada
  const studentsSnap = await db.collection('students').limit(1).get();
  if (!studentsSnap.empty) {
    console.warn('[ADVERTENCIA] La colección obsoleta "students" aún contiene datos.');
  }

  const coachesSnap = await db.collection('coaches').limit(1).get();
  if (!coachesSnap.empty) {
    console.warn('[ADVERTENCIA] La colección obsoleta "coaches" aún contiene datos.');
  }

  console.log('--- Validación Finalizada ---');
}

validateMigration().catch(console.error);
