const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function cleanupStudents() {
  // Eliminar SOLO usuarios con role: 'student'
  const studentsSnap = await db.collection('users').where('role', '==', 'student').get();
  
  const batch = db.batch();
  studentsSnap.forEach(doc => {
    batch.delete(doc.ref);
  });
  
  await batch.commit();
  console.log(`✅ Eliminados ${studentsSnap.size} registros de alumnas`);
  
  // Eliminar assignments anteriores
  const assignmentsSnap = await db.collection('assignments').get();
  const batchAssignments = db.batch();
  assignmentsSnap.forEach(doc => {
    batchAssignments.delete(doc.ref);
  });
  
  await batchAssignments.commit();
  console.log(`✅ Eliminados ${assignmentsSnap.size} horarios antiguos`);
}

cleanupStudents().catch(console.error);
