const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Coaches según tu lista
const coaches = [
    { email: 'luis@aerial.com', name: 'Luis', colorHex: 4280391411 },
    { email: 'ingrid@aerial.com', name: 'Ingrid', colorHex: 4283215696 },
    { email: 'bruno@aerial.com', name: 'Bruno', colorHex: 4294901760 },
    { email: 'alexis@aerial.com', name: 'Alexis', colorHex: 4288423856 },
    { email: 'ivan@aerial.com', name: 'Ivan', colorHex: 4293467747 },
    { email: 'mia@aerial.com', name: 'Mia', colorHex: 4294198070 },
    { email: 'adriana@aerial.com', name: 'Adriana', colorHex: 4291611852 },
    { email: 'monitor1@aerial.com', name: 'Monitor 1', colorHex: 4286611584 },
    { email: 'monitor2@aerial.com', name: 'Monitor 2', colorHex: 4284513675 }
];

async function createCoaches() {
    console.log('🔍 Buscando coaches en Firebase Auth...\n');

    for (const coach of coaches) {
        try {
            // Buscar el usuario en Firebase Auth por email
            const userRecord = await admin.auth().getUserByEmail(coach.email);

            // Crear documento en Firestore usando el UID de Auth
            await db.collection('users').doc(userRecord.uid).set({
                name: coach.name,
                email: coach.email,
                role: 'coach',
                group: 'General',
                colorHex: coach.colorHex
            });

            console.log(`✅ Coach creado: ${coach.name} (UID: ${userRecord.uid})`);

        } catch (error) {
            if (error.code === 'auth/user-not-found') {
                console.log(`⚠️ ${coach.email} NO existe en Firebase Auth - créalo primero`);
            } else {
                console.error(`❌ Error con ${coach.email}:`, error.message);
            }
        }
    }

    console.log('\n✅ Proceso completado');
}

createCoaches().catch(console.error);