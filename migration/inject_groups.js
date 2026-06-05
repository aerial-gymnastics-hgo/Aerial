const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const groups = [
  {
    "id": "Oruguitas",
    "shortCode": "ORU",
    "type": "Formativo",
    "ageRange": "2a6m - 3a10m",
    "days": "M,J",
    "schedule": "17:30-18:15",
    "monthlyFee": 1000,
    "inscriptionFee": 500,
    "requiresTutor": true,
    "requiresFMG": false,
    "description": "Introducción a la práctica de una disciplina deportiva con un enfoque formativo. Desarrollo de motricidad gruesa.",
    "dresscode": "Leotardo o playera ajustada sin botones o aplicaciones, lycra corta o larga. Cabello recogido (bien sujetado). NO collares, aretes largos o arracadas, pulseras o anillos. Tenis SIN AGUJETAS. Botella de agua. Peluche pequeño de apego (no nuevo/no valor sentimental)."
  },
  {
    "id": "Abejitas",
    "shortCode": "ABE",
    "type": "Formativo",
    "ageRange": "4 - 6 años",
    "days": "M,J",
    "schedule": "16:00-17:30",
    "monthlyFee": 950,
    "inscriptionFee": 500,
    "requiresTutor": true,
    "requiresFMG": false,
    "description": "Introducción a la práctica de una disciplina deportiva con un enfoque formativo. En este grupo es necesario la presencia en el área de espera de un TUTOR para acompañamiento al sanitario o asistencia que pueda requerir por la edad.",
    "dresscode": "Leotardo o playera ajustada sin botones o aplicaciones, lycra corta o larga. Cabello recogido (bien sujetado). NO collares, aretes largos o grandes, pulseras o anillos. Tenis. Botella de agua. Peluche pequeño (no nuevo/uso general)."
  },
  {
    "id": "Mariposas",
    "shortCode": "MAR",
    "type": "Formativo",
    "ageRange": "6/7 - 13 años",
    "days": "M,J",
    "schedule": "17:30-19:00",
    "monthlyFee": 950,
    "inscriptionFee": 500,
    "requiresTutor": false,
    "requiresFMG": false,
    "description": "Introducción a la práctica de una disciplina deportiva con un enfoque FORMATIVO. Fortalecimiento de motricidad gruesa. Mejora de las cualidades físicas. Desarrollo de habilidades cognitivas y sociales.",
    "dresscode": "Leotardo o playera ajustada sin botones o aplicaciones, lycra corta o larga. Cabello recogido (bien sujetado). NO collares, aretes largos o grandes, pulseras o anillos. Tenis. Botella de agua. Peluche pequeño (no nuevo/uso general)."
  },
  {
    "id": "Dragonas",
    "shortCode": "DRA",
    "type": "Formativo",
    "ageRange": "5 - 8 años",
    "days": "L,M,V",
    "schedule": "16:30-18:00",
    "monthlyFee": 1150,
    "inscriptionFee": 500,
    "requiresTutor": false,
    "requiresFMG": false,
    "description": "Desarrollo de esta disciplina deportiva con un enfoque formativo. Fortalecimiento y especialización de motricidad gruesa. Mejora de las cualidades físicas. Desarrollo de habilidades cognitivas y sociales.",
    "dresscode": "Leotardo o playera ajustada sin botones o aplicaciones, lycra corta o larga. Cabello recogido (bien sujetado). NO collares, aretes largos o grandes, pulseras o anillos. Tenis. Botella de agua. Peluche pequeño (no nuevo/uso general)."
  },
  {
    "id": "Panteras",
    "shortCode": "PAN",
    "type": "Formativo",
    "ageRange": "8 - 14 años",
    "days": "L,M,V",
    "schedule": "16:30-18:00",
    "monthlyFee": 1150,
    "inscriptionFee": 500,
    "requiresTutor": false,
    "requiresFMG": false,
    "description": "Desarrollo de esta disciplina deportiva con un enfoque formativo. Fortalecimiento y especialización de motricidad gruesa. Mejora de las cualidades físicas. Desarrollo de habilidades cognitivas y sociales.",
    "dresscode": "Leotardo o playera ajustada sin botones o aplicaciones, lycra corta o larga. Cabello recogido (bien sujetado). NO collares, aretes largos o grandes, pulseras o anillos. Tenis. Botella de agua. Peluche pequeño (no nuevo/uso general)."
  },
  {
    "id": "Tigresas",
    "shortCode": "TIG",
    "type": "Competitivo",
    "ageRange": "12 - 17 años",
    "days": "L,M,V",
    "schedule": "17:30-19:30",
    "monthlyFee": 1250,
    "inscriptionFee": 500,
    "requiresTutor": false,
    "requiresFMG": false,
    "description": "Desarrollo de esta disciplina deportiva con un enfoque formativo y competitivo. Fortalecimiento y especialización de motricidad gruesa. Mejora de las cualidades físicas. Desarrollo de habilidades cognitivas y sociales.",
    "dresscode": "Leotardo o playera ajustada sin botones o aplicaciones, lycra corta o larga. Cabello recogido (bien sujetado). NO collares, aretes largos o grandes, pulseras o anillos. Tenis. Botella de agua. Peluche pequeño (no nuevo/uso general)."
  },
  {
    "id": "Panditas",
    "shortCode": "PND",
    "type": "Competitivo",
    "ageRange": "8 - 14 años",
    "days": "L,M,V",
    "schedule": "17:30-19:30",
    "monthlyFee": 1250,
    "inscriptionFee": 500,
    "requiresTutor": false,
    "requiresFMG": true,
    "description": "Desarrollo de esta disciplina deportiva con un enfoque competitivo. Fortalecimiento y especialización de motricidad gruesa. Mejora de las cualidades físicas. Desarrollo de habilidades cognitivas y sociales.",
    "dresscode": "Leotardo, lycra corta o larga. Cabello recogido (bien sujetado). NO collares, aretes largos o grandes, pulseras o anillos. Tenis. Botella de agua. Peluche pequeño (no nuevo/uso general). Afiliación a la FMG."
  },
  {
    "id": "Conejas",
    "shortCode": "CON",
    "type": "Competitivo",
    "ageRange": "7 - 13 años",
    "days": "L-V",
    "schedule": "16:30-18:30",
    "monthlyFee": 1350,
    "inscriptionFee": 500,
    "requiresTutor": false,
    "requiresFMG": true,
    "description": "Desarrollo intensivo de esta disciplina deportiva con un enfoque competitivo. Fortalecimiento y especialización de motricidad gruesa. Mejora de las cualidades físicas. Desarrollo de habilidades cognitivas y sociales.",
    "dresscode": "Leotardo, lycra corta o larga. Cabello recogido (bien sujetado). NO collares, aretes largos o grandes, pulseras o anillos. Tenis. Botella de agua. Peluche pequeño (no nuevo/uso general). Afiliación a la FMG."
  },
  {
    "id": "Halconas",
    "shortCode": "HAL",
    "type": "Competitivo",
    "ageRange": "9 - 16 años",
    "days": "L-V",
    "schedule": "16:30-19:30",
    "monthlyFee": 1450,
    "inscriptionFee": 500,
    "requiresTutor": false,
    "requiresFMG": true,
    "description": "Desarrollo intensivo de esta disciplina deportiva con un enfoque competitivo. Fortalecimiento y especialización de motricidad gruesa. Mejora de las cualidades físicas. Desarrollo de habilidades cognitivas y sociales.",
    "dresscode": "Leotardo, lycra corta o larga. Cabello recogido (chongo). NO collares, aretes largos o grandes, pulseras o anillos. Tenis. Botella de agua. Peluche pequeño (no nuevo/uso general). Afiliación a la FMG."
  },
  {
    "id": "Linces",
    "shortCode": "LIN",
    "type": "Formativo",
    "ageRange": "15 años +",
    "days": "M,J",
    "schedule": "19:00-20:00",
    "monthlyFee": 800,
    "inscriptionFee": 500,
    "requiresTutor": false,
    "requiresFMG": false,
    "description": "Práctica la disciplina deportiva con un enfoque FORMATIVO, principalmente en preparación física y acrobacia. Fortalecimiento muscular. Mejora de las cualidades físicas. Desarrollo de habilidades acrobáticas y de expresión.",
    "dresscode": "Leotardo/butarga o playera ajustada sin botones o aplicaciones, lycra corta o larga. Cabello recogido (bien sujetado). NO collares, aretes largos o grandes, pulseras o anillos. Tenis. Botella de agua."
  }
];

async function injectGroups() {
  console.log('🚀 Iniciando inyección de grupos...');
  const batch = db.batch();
  
  for (const group of groups) {
    const { id, ...data } = group;
    const ref = db.collection('groups').doc(id);
    batch.set(ref, data);
    console.log(`- Preparando: ${id}`);
  }
  
  await batch.commit();
  console.log('✅ Inyección completada con éxito.');
}

injectGroups().catch(console.error);
