const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Alumnas de prueba SOLO para los 3 grupos nuevos (aún sin alumnas reales).
//  group   = nombre mostrado (Capitalizado, con acento) → coincide con doc de "groups"
//  groupId = identificador sin acento/minúsculas         → coincide con "rotations"
const students = [
    { email: 'alumna.luciernagas@aerial.temp', name: 'Alumna Luciérnagas', group: 'Luciérnagas', groupId: 'luciernagas' },
    { email: 'alumna.colibri@aerial.temp',     name: 'Alumna Colibrí',     group: 'Colibrí',     groupId: 'colibri'     },
    { email: 'alumna.fenix@aerial.temp',       name: 'Alumna Fénix',       group: 'Fénix',       groupId: 'fenix'       }
];

async function createTestStudents() {
    console.log('🔧 Creando alumnas de prueba en los grupos nuevos...\n');

    let created = 0;
    let skipped = 0;

    for (const s of students) {
        try {
            // Crear (o recuperar) la cuenta en Firebase Auth
            let userRecord;
            try {
                userRecord = await admin.auth().createUser({
                    email: s.email,
                    password: '123456',
                    displayName: s.name
                });
                console.log(`✅ Auth creado: ${s.email} (UID: ${userRecord.uid})`);
            } catch (err) {
                if (err.code === 'auth/email-already-exists') {
                    userRecord = await admin.auth().getUserByEmail(s.email);
                    console.log(`ℹ️ ${s.email} ya existía en Auth (UID: ${userRecord.uid}) - actualizando Firestore`);
                } else {
                    throw err;
                }
            }

            // Escribir documento en Firestore
            await db.collection('users').doc(userRecord.uid).set({
                uid: userRecord.uid,
                email: s.email,
                name: s.name,
                role: 'student',
                group: s.group,
                groupId: s.groupId,
                active: true,
                createdAt: admin.firestore.FieldValue.serverTimestamp()
            }, { merge: true });

            console.log(`   ✅ Firestore users/${userRecord.uid} (grupo: ${s.group})`);
            created++;
        } catch (error) {
            console.error(`   ❌ Error con ${s.email}:`, error.message);
            skipped++;
        }
    }

    console.log('\n──────────── RESUMEN ────────────');
    console.log(`  Alumnas creadas/actualizadas: ${created}`);
    console.log(`  Con error                   : ${skipped}`);
    console.log('─────────────────────────────────');
    console.log('✅ Proceso completado');
    process.exit(0);
}

createTestStudents().catch(err => {
    console.error(err);
    process.exit(1);
});
