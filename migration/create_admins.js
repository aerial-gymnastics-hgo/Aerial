const admin = require('firebase-admin');

process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = '127.0.0.1:9099';

admin.initializeApp({
    projectId: "demo-gymmanager" // Or whatever project ID they use
});

const db = admin.firestore();

const adminsToCreate = [
    {
        email: 'admin@gym.com',
        password: '4eri4l',
        name: 'Administrador Principal',
        role: 'admin'
    },
    {
        email: 'caja@gym.com',
        password: '4eri4l2026',
        name: 'Caja Casa Pädi',
        role: 'caja'
    }
];

async function createOrUpdateAdminUsers() {
    console.log('🔧 Creando/Actualizando admins en Firebase Auth y Firestore (EMULATOR)...\n');

    for (const userData of adminsToCreate) {
        try {
            let userRecord;
            
            try {
                userRecord = await admin.auth().getUserByEmail(userData.email);
                console.log(`ℹ️ Usuario ${userData.email} ya existe. Actualizando contraseña...`);
                userRecord = await admin.auth().updateUser(userRecord.uid, {
                    password: userData.password,
                    displayName: userData.name
                });
            } catch (err) {
                if (err.code === 'auth/user-not-found') {
                    console.log(`ℹ️ Usuario ${userData.email} no existe. Creando...`);
                    userRecord = await admin.auth().createUser({
                        email: userData.email,
                        password: userData.password,
                        displayName: userData.name
                    });
                } else {
                    throw err;
                }
            }

            // Actualizar documento en Firestore
            await db.collection('users').doc(userRecord.uid).set({
                name: userData.name,
                email: userData.email,
                role: userData.role,
                group: 'General',
                active: true,
                createdAt: admin.firestore.FieldValue.serverTimestamp()
            }, { merge: true });

            console.log(`✅ ${userData.role.toUpperCase()} listo - UID: ${userRecord.uid} (${userData.email})`);

        } catch (error) {
            console.error(`❌ Error con ${userData.email}:`, error.message);
        }
    }

    console.log('\n✅ Usuarios admin creados/actualizados exitosamente');
    process.exit(0);
}

createOrUpdateAdminUsers().catch(err => {
    console.error(err);
    process.exit(1);
});
