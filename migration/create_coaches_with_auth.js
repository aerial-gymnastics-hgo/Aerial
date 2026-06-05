const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

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

async function createCoachesWithAuth() {
    console.log('🔧 Creando coaches en Firebase Auth y Firestore...\n');

    for (const coach of coaches) {
        try {
            // Crear usuario en Firebase Auth con contraseña 1234
            const userRecord = await admin.auth().createUser({
                email: coach.email,
                password: '123456',
                displayName: coach.name
            });

            // Crear documento en Firestore
            await db.collection('users').doc(userRecord.uid).set({
                name: coach.name,
                email: coach.email,
                role: 'coach',
                group: 'General',
                colorHex: coach.colorHex
            });

            console.log(`✅ ${coach.name} creado - UID: ${userRecord.uid}`);

        } catch (error) {
            console.error(`❌ Error con ${coach.email}:`, error.message);
        }
    }

    console.log('\n✅ Coaches creados exitosamente');
}

createCoachesWithAuth().catch(console.error);