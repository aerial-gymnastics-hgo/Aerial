const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
const data = require('./production_students.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function injectStudents() {
  // Inyectar alumnas
  for (const [uid, userData] of Object.entries(data.users)) {
    await db.collection('users').doc(uid).set(userData);
    console.log(`✅ Agregada: ${userData.name}`);
  }
  
  // Inyectar assignments
  for (const assignment of data.assignments) {
    await db.collection('assignments').add(assignment);
  }
  
  console.log(`\n✅ Total: ${Object.keys(data.users).length} alumnas inyectadas`);
  console.log(`✅ Total: ${data.assignments.length} horarios inyectados`);
}

injectStudents().catch(console.error);
