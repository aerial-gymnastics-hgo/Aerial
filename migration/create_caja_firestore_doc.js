const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// IMPORTANTE: Reemplaza con el UID generado en Firebase Auth
const CAJA_UID = 'rQhgyvFX1Ng6vUrqsKXf9CIKcl32';

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function createCajaProfile() {
    console.log('🔧 Creando perfil de Caja en Firestore...');

    if (CAJA_UID === 'PONER_AQUI_EL_UID') {
        console.error('❌ ERROR: Debes poner el UID real generado en Paso 1');
        process.exit(1);
    }

    try {
        await db.collection('users').doc(CAJA_UID).set({
            name: 'Caja - Casa Pädi',
            email: 'caja@aerial.com',
            role: 'caja',
            group: 'General',
            active: true,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        });

        console.log(`✅ Perfil de Caja creado exitosamente para UID: ${CAJA_UID}`);
    } catch (error) {
        console.error(`❌ Error al crear perfil:`, error.message);
    }
}

createCajaProfile().catch(console.error);
