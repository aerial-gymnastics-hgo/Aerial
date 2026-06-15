const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function archiveTestPayments() {
    console.log('🗄️  Archivando pagos de prueba...\n');

    const snap = await db.collection('payments').get();

    if (snap.empty) {
        console.log('ℹ️  No hay documentos en "payments". Nada que archivar.');
        process.exit(0);
    }

    console.log(`📦 ${snap.size} pagos encontrados. Moviendo a "payments_archive"...\n`);

    // Firestore batch acepta máx 500 ops; usamos lotes de 200 (write + delete = 2 ops por doc)
    const BATCH_SIZE = 200;
    const docs = snap.docs;
    let archived = 0;

    for (let i = 0; i < docs.length; i += BATCH_SIZE) {
        const chunk = docs.slice(i, i + BATCH_SIZE);
        const batch = db.batch();

        for (const doc of chunk) {
            const archiveRef = db.collection('payments_archive').doc(doc.id);
            batch.set(archiveRef, {
                ...doc.data(),
                archivedAt: admin.firestore.FieldValue.serverTimestamp(),
                archivedReason: 'datos_prueba',
            });
            batch.delete(doc.ref);
        }

        await batch.commit();
        archived += chunk.length;
        console.log(`   ✅ Lote ${Math.ceil((i + 1) / BATCH_SIZE)}: ${chunk.length} docs archivados`);
    }

    console.log('\n──────────── RESUMEN ────────────');
    console.log(`  Pagos archivados : ${archived}`);
    console.log(`  Colección origen : payments (ahora vacía)`);
    console.log(`  Colección destino: payments_archive`);
    console.log('─────────────────────────────────');
    console.log('✅ Archivo completado');
    process.exit(0);
}

archiveTestPayments().catch(err => {
    console.error('❌ Error:', err);
    process.exit(1);
});
