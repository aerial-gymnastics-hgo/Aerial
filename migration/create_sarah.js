const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function createSarah() {
    console.log('🔧 Creando usuaria Sarah en Firebase Auth y Firestore...\n');

    const email = 'sarah@aerial.com';
    const password = '123456';
    const name = 'Sarah';

    try {
        // Crear (o recuperar) la cuenta en Firebase Auth
        let userRecord;
        try {
            userRecord = await admin.auth().createUser({
                email,
                password,
                displayName: name
            });
            console.log(`✅ Auth creado: ${email} (UID: ${userRecord.uid})`);
        } catch (err) {
            if (err.code === 'auth/email-already-exists') {
                userRecord = await admin.auth().getUserByEmail(email);
                console.log(`ℹ️ ${email} ya existía en Auth (UID: ${userRecord.uid}) - actualizando Firestore`);
            } else {
                throw err;
            }
        }

        // Escribir documento en Firestore
        await db.collection('users').doc(userRecord.uid).set({
            uid: userRecord.uid,
            email,
            name,
            role: 'coach',
            active: true,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        }, { merge: true });

        console.log(`✅ Firestore users/${userRecord.uid} listo (role: coach)`);
        console.log('\n✅ Sarah creada exitosamente');
    } catch (error) {
        console.error(`❌ Error creando a Sarah:`, error.message);
        process.exit(1);
    }
}

createSarah().catch(err => {
    console.error(err);
    process.exit(1);
});
