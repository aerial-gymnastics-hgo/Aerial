const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Renombrados. Cada colección usa su propia convención de casing:
//  - groups (doc ID) y users.group: Capitalizado  (ej. "Panditas")
//  - rotations.groupId:             minúsculas     (ej. "panditas")
const renames = [
    { groupCap: 'Panditas', groupCapNew: 'Pumitas', groupLow: 'panditas', groupLowNew: 'pumitas' },
    { groupCap: 'Dragonas', groupCapNew: 'Leonas',  groupLow: 'dragonas', groupLowNew: 'leonas'  },
    { groupCap: 'Conejas',  groupCapNew: 'Cisnes',  groupLow: 'conejas',  groupLowNew: 'cisnes'  }
];

// 1) Renombra el documento de la colección "groups" (copiar con nuevo ID + borrar viejo).
//    Busca el doc origen probando el ID capitalizado y, defensivamente, el minúsculo.
async function renameGroupDocs() {
    console.log('📁 Renombrando documentos en colección "groups"...');
    let renamed = 0;

    for (const r of renames) {
        const candidates = [r.groupCap, r.groupLow];
        let srcSnap = null;
        let srcId = null;

        for (const id of candidates) {
            const snap = await db.collection('groups').doc(id).get();
            if (snap.exists) {
                srcSnap = snap;
                srcId = id;
                break;
            }
        }

        if (!srcSnap) {
            console.log(`   ⚠️ groups/{${r.groupCap}|${r.groupLow}} no existe - omitido`);
            continue;
        }

        // El nuevo ID respeta el casing del que se encontró (Capitalizado o minúsculas)
        const newId = srcId === r.groupLow ? r.groupLowNew : r.groupCapNew;

        const batch = db.batch();
        batch.set(db.collection('groups').doc(newId), srcSnap.data());
        batch.delete(db.collection('groups').doc(srcId));
        await batch.commit();

        console.log(`   ✅ groups/${srcId} → groups/${newId}`);
        renamed++;
    }

    return renamed;
}

// 2) Actualiza el campo "group" (Capitalizado) en la colección "users".
async function renameUsersGroupField() {
    console.log('\n👧 Actualizando campo "group" en colección "users"...');
    let updated = 0;

    for (const r of renames) {
        const snap = await db.collection('users').where('group', '==', r.groupCap).get();
        if (snap.empty) {
            console.log(`   ⚠️ users con group="${r.groupCap}": 0 - omitido`);
            continue;
        }

        const batch = db.batch();
        snap.docs.forEach(doc => batch.update(doc.ref, { group: r.groupCapNew }));
        await batch.commit();

        console.log(`   ✅ users "${r.groupCap}" → "${r.groupCapNew}" (${snap.size} docs)`);
        updated += snap.size;
    }

    return updated;
}

// 3) Actualiza el campo "groupId" (minúsculas) en la colección "rotations".
async function renameRotationsGroupId() {
    console.log('\n🔄 Actualizando campo "groupId" en colección "rotations"...');
    let updated = 0;

    for (const r of renames) {
        const snap = await db.collection('rotations').where('groupId', '==', r.groupLow).get();
        if (snap.empty) {
            console.log(`   ⚠️ rotations con groupId="${r.groupLow}": 0 - omitido`);
            continue;
        }

        const batch = db.batch();
        snap.docs.forEach(doc => batch.update(doc.ref, { groupId: r.groupLowNew }));
        await batch.commit();

        console.log(`   ✅ rotations "${r.groupLow}" → "${r.groupLowNew}" (${snap.size} docs)`);
        updated += snap.size;
    }

    return updated;
}

async function renameGroups() {
    console.log('🚀 Iniciando renombrado de grupos...\n');

    const groupsRenamed = await renameGroupDocs();
    const usersUpdated = await renameUsersGroupField();
    const rotationsUpdated = await renameRotationsGroupId();

    console.log('\n──────────── RESUMEN ────────────');
    console.log(`  Docs "groups" renombrados : ${groupsRenamed}`);
    console.log(`  Docs "users" actualizados : ${usersUpdated}`);
    console.log(`  Docs "rotations" actualizados: ${rotationsUpdated}`);
    console.log('─────────────────────────────────');
    console.log('✅ Renombrado completado');
    process.exit(0);
}

renameGroups().catch(err => {
    console.error('❌ Error en el renombrado:', err);
    process.exit(1);
});
