class UsagData {
  static final List<Map<String, dynamic>> usagGeneralConcepts = [
    {
      'title': '📊 Sistema de Puntuación',
      'icon': 'score',
      'content': 'Nota Final = Start Value (SV) - Deducciones.\n\n• Obligatorios (N1-5): SV siempre = 10.0\n• Opcionales (N6-10): SV = Base (9.5) + SR + VP + CV + Bonos\n\nEl objetivo es minimizar deducciones, no solo hacer habilidades difíciles.',
      'tip': '💡 Consejo moderno: Entrena la LIMPIEZA antes que la DIFICULTAD. Una rutina limpia de N5 gana más que una sucia de N7.',
    },
    {
      'title': '⚠️ Deducciones Frecuentes',
      'icon': 'deductions',
      'content': '• Piernas separadas: hasta -0.20\n• Rodillas flexionadas: hasta -0.30\n• Pies en flex: -0.05\n• Brazos flexionados: hasta -0.30\n• Pasos/desequilibrios: -0.10 a -0.30\n• Caída: -0.50\n• Falta de altura/ángulo: hasta -0.30',
      'tip': '💡 Ejercicio diario: "Drill de pies bonitas" — 3 series de 20 relevés con pies en punta máxima. Reduce -0.05 por pie flex.',
    },
    {
      'title': '🎭 Artística y Composición',
      'icon': 'artistic',
      'content': '• Pausas innecesarias: -0.10\n• Falta de expresión: hasta -0.30\n• Errores de texto coreográfico (obligatorios): deducción directa\n• Ritmo inconsistente: afecta nota global',
      'tip': '💡 Integra "warm-up de expresión": 5 min de baile libre con música variada antes de cada clase para soltar el cuerpo y despertar la artística.',
    },
    {
      'title': '🔀 Compulsory vs Optional',
      'icon': 'divisions',
      'content': '• Compulsory (N1-5): Rutina y música idéntica nacional. Se evalúa biomecánica y texto exacto.\n• Optional (N6-10): Rutinas a medida cumpliendo requisitos de composición.\n• DP: Vía rígida y lineal hacia NCAA/Élite.\n• Xcel: Vía flexible para retención y disfrute.',
      'tip': '💡 Para coaches nuevos: En obligatorios, la clave es la REPETICIÓN PERFECTA. En opcionales, la CREATIVIDAD ESTRATÉGICA.',
    },
    {
      'title': '🧠 Psicología del Rendimiento',
      'icon': 'psychology',
      'content': 'El miedo es el mayor obstáculo técnico. Una gimnasta con miedo pierde extensión, velocidad y confianza.\n\n• Usa progresiones seguras (pit, colchones, spotting)\n• Celebra intentos, no solo logros\n• Crea palabras clave positivas ("¡Vuelo!", "¡Fuerte!")',
      'tip': '💡 Técnica "3-2-1": Antes de un elemento nuevo, la alumna dice 3 cosas que sabe hacer bien, 2 que quiere mejorar, 1 que la emociona.',
    },
    {
      'title': '🏋️ Acondicionamiento Moderno',
      'icon': 'conditioning',
      'content': 'La gimnasia requiere:\n• Fuerza relativa (no peso muerto)\n• Flexibilidad ACTIVA (no solo pasiva)\n• Potencia explosiva\n• Resistencia muscular\n• Propiocepción y equilibrio',
      'tip': '💡 Circuito "Core Power": 30s plancha + 30s hollow body + 30s superman + 30s descanso. 4 rondas. Es la base de TODO en gimnasia.',
    },
  ];

  static final Map<String, Map<String, dynamic>> usagLevelStrategies = {
    'N1-3': {
      'title': 'Niveles 1-3 (5-9 años)',
      'subtitle': 'Obligatorio | Fundamentos',
      'color': 0xFF4CAF50,
      'skills': {
        'Salto (VT)': 'Salto a colchón, parada de manos apoyada',
        'Barras (UB)': 'Pullover, cast, vuelta pajarito',
        'Viga (BB)': 'Caminatas, saltos básicos, parada de manos',
        'Piso (FX)': 'Rueda, rollo, puente, flic-flac (N3)',
      },
      'deductions': 'Flexión de piernas, falta extensión, ritmo inconsistente',
      'drills': [
        '🏃 Calentamiento dinámico con juegos de coordinación (5 min)',
        '🦶 "Pies de bailarina": Caminar en relevé 2 min continuos',
        '💪 Hollow body hold: 3x15s (base de toda acrobacia)',
        '🤸 Rueda contra pared: 10 repeticiones enfocando piernas juntas',
        '🧘 Puente desde piso: 5x sostener 10s con brazos EXTENDIDOS',
      ],
      'focusAreas': ['Postura y alineación', 'Ritmo y musicalidad', 'Confianza y diversión', 'Fuerza de core básica'],
    },
    'N4-5': {
      'title': 'Niveles 4-5 (7-11 años)',
      'subtitle': 'Obligatorio | Filtro Técnico',
      'color': 0xFF2196F3,
      'skills': {
        'Salto (VT)': 'Resorte adelante sobre mesa',
        'Barras (UB)': 'Kip (GRAN FILTRO), clear hip, cast vertical, salida mortal (N5)',
        'Viga (BB)': 'Rueda (N4), flic-flac (N5), giros, salida mortal',
        'Piso (FX)': 'Ronda + 2 flic-flacs, resorte, mortal atrás (N5)',
      },
      'deductions': 'Cast sin ángulo requerido (≤0.30), brazos flexionados en resorte, falta altura en mortales',
      'drills': [
        '🎯 Drill de Kip: 20 glides + 20 leg lifts + 10 intentos diarios',
        '💥 Resorte en trampolín: Enfoque en repulsión de hombros, NO brazos',
        '🔄 Flic-flac en línea: Con spotter, enfocarse en sentarse ATRÁS',
        '⬆️ Cast vertical: Contra pared, sostener 3s arriba x10',
        '🧠 Visualización pre-rutina: 60s con ojos cerrados antes de cada turno',
      ],
      'focusAreas': ['Dominio del Kip (filtro)', 'Repulsión de hombros', 'Conexiones fluidas', 'Resistencia de rutina completa'],
    },
    'N6-7': {
      'title': 'Niveles 6-7 (9-13 años)',
      'subtitle': 'Opcional Básico | Creatividad',
      'color': 0xFF9C27B0,
      'skills': {
        'Salto (VT)': 'Yurchenko/Tsukahara a colchones (N6), resorte/timer (N7)',
        'Barras (UB)': 'Cast vertical, gigantes, salida mortal',
        'Viga (BB)': 'Serie acrobática, salto 180°, giro',
        'Piso (FX)': 'Línea con 2 mortales, salto 180°',
      },
      'deductions': 'Amplitud insuficiente (no llegar a 180°), paradas de manos cortas, aterrizajes descontrolados',
      'drills': [
        '🌟 Split training: PNF stretching 3x30s cada pierna (llegar a 180°)',
        '🔄 Yurchenko timer: 30 reps/semana en pit foam, enfoque en round-off',
        '🎯 Gigante en barras: Drill de "tap swing" para ganar momentum',
        '💃 Coreografía de piso: 20 min/semana de danza contemporánea',
        '⚡ Pliometría: Box jumps + tuck jumps para potencia en tumbling',
      ],
      'focusAreas': ['Amplitud en saltos', 'Construcción de rutina propia', 'Artística y expresión', 'Potencia explosiva'],
    },
    'N8-9': {
      'title': 'Niveles 8-9 (11-16 años)',
      'subtitle': 'Opcional Avanzado | Élite',
      'color': 0xFFE91E63,
      'skills': {
        'Salto (VT)': 'Yurchenko agrupado/extendido',
        'Barras (UB)': 'Vuelos (soltadas), piruetas, salida doble',
        'Viga (BB)': 'Series con vuelo, saltos alta dificultad',
        'Piso (FX)': 'Mortales con giro, mortales dobles',
      },
      'deductions': 'Pausas milimétricas anulan CV, pasos en aterrizajes de alta velocidad',
      'drills': [
        '🏋️ Periodización: Fase fuerza (4 sem) → Fase potencia (3 sem) → Fase rutina (3 sem)',
        '🎯 Aterrizajes: 50 stick drills/día desde diferentes alturas',
        '🔗 Valor Conexión: Practicar TRANSICIONES, no solo elementos sueltos',
        '🧊 Crioterapia post-entrenamiento para recuperación muscular',
        '📹 Video análisis semanal: Grabar rutinas y revisar con la alumna',
      ],
      'focusAreas': ['Valor de Conexión (CV)', 'Gestión de fatiga', 'Aterrizajes clavados', 'Prevención de lesiones'],
    },
    'N10': {
      'title': 'Nivel 10 (13-18+ años)',
      'subtitle': 'Universitario / NCAA',
      'color': 0xFFFF5722,
      'skills': {
        'Salto (VT)': 'Yurchenko 1-1.5 giros',
        'Barras (UB)': 'Soltadas complejas (D/E), salida doble mortal',
        'Viga (BB)': 'Series alto impacto, salidas complejas',
        'Piso (FX)': 'Pasadas dobles, mortales 1.5-2 giros',
      },
      'deductions': 'Aterrizajes profundos (pecho bajo ≤0.30), ejecución bajo fatiga extrema',
      'drills': [
        '🧬 Biomecánica avanzada: Análisis de ángulos con video a 120fps',
        '🧠 Entrenamiento mental: Visualización guiada 15 min pre-competencia',
        '💪 Fuerza específica: Muscle-ups, L-sits 30s, press to handstand',
        '🎭 Performance coaching: Trabajar con experto en expresión escénica',
        '📊 Tracking de deducciones: Registrar y graficar mejoras semanales',
      ],
      'focusAreas': ['Habilidades D/E obligatorias', 'Bonificación por conexión', 'Resistencia de élite', 'Mentalidad competitiva'],
    },
    'Xcel': {
      'title': 'Programa Xcel',
      'subtitle': 'Vía Flexible | Retención',
      'color': 0xFF00BCD4,
      'skills': {
        'Bronze': 'Ritmo, consciencia espacial, seguridad básica',
        'Silver': 'Pullover, rueda sólida, música libre',
        'Gold': 'Kip, resorte, flic-flac, conexiones permisivas',
        'Platinum': 'Mortales en piso, series básicas en viga',
        'Diamond': 'Acrobacias con giro, mortales compuestos',
      },
      'deductions': 'Mismas categorías que DP pero con mayor tolerancia en composición',
      'drills': [
        '🎵 Música libre: Dejar que la gimnasta ELIJA su música (motivación)',
        '🔄 Sustituir debilidades: Si no tiene flic-flac, usar back walkover',
        '🤝 Buddy system: Entrenar en parejas para motivación mutua',
        '🎯 Mini-competencias internas mensuales para simular presión',
        '😊 Enfoque en DISFRUTE: El Xcel retiene talento que el DP pierde',
      ],
      'focusAreas': ['Retención y disfrute', 'Flexibilidad de rutina', 'Comunidad y pertenencia', 'Progreso individualizado'],
    },
  };

  static final List<Map<String, dynamic>> coachingHacks = [
    {
      'title': '🔄 Sistema de Estaciones',
      'category': 'Metodología',
      'content': 'El mayor error es la FILA DE ESPERA. Mientras una gimnasta recibe spotting directo, las demás ejecutan drills complementarios en 3-4 estaciones periféricas.',
      'example': 'Aparato: Barras (Kip)\n• Estación 1: Glide swings en barra baja\n• Estación 2: Leg lifts acostada con PVC\n• Estación 3: Chin-up holds (fuerza)\n• Estación 4: Spotting directo del coach',
    },
    {
      'title': '🧩 Micro-Metas (Chunking)',
      'category': 'Metodología',
      'content': 'Desglosar cada habilidad en 3 fases biomecánicas:\n1. ENTRADA (Take-off)\n2. VUELO/EJECUCIÓN (Flight)\n3. ATERRIZAJE (Landing)\n\nLas correcciones deben apuntar a la fase EXACTA donde ocurre la falla.',
      'example': 'Flic-flac:\n• Entrada: ¿Se sienta atrás o salta arriba?\n• Vuelo: ¿Brazos junto a orejas?\n• Aterrizaje: ¿Rebote o se "clava"?',
    },
    {
      'title': '👁️ Lenguaje Visual',
      'category': 'Metodología',
      'content': 'Las marcas visuales optimizan la memoria muscular sin instrucción verbal constante:\n• Cinta de colores en la viga para posición de manos\n• Bloques de espuma como targets de altura\n• Líneas en el suelo para alineación',
      'example': 'Rueda lateral: Colocar 4 marcas de cinta en línea recta. Las manos y pies deben pisar EXACTAMENTE sobre las marcas.',
    },
    {
      'title': '💪 Prerrequisitos de Fuerza',
      'category': 'Ciencia',
      'content': 'Cada habilidad tiene un prerrequisito físico. NO enseñar el elemento hasta cumplirlo:\n• Kip → 10 leg lifts + 15s L-sit\n• Flic-flac → 30s hollow body + 10 bridge kick-overs\n• Mortal → 5 tuck jumps al pecho + 20s plank',
      'example': 'Test de Preparación:\nSI puede sostener hollow body 30s → listo para flic-flac\nSI NO → 2 semanas más de core',
    },
    {
      'title': '🎯 Troubleshooting (Si/Entonces)',
      'category': 'Corrección',
      'content': 'Sistema de corrección rápida:\n\n• SI flexiona brazos en resorte → ENTONCES bloqueos de hombros contra pared\n• SI piernas separadas en rueda → ENTONCES ruedas con banda elástica en tobillos\n• SI no alcanza vertical en cast → ENTONCES planks con hombros proyectados',
      'example': 'Protocolo de corrección:\n1. Identificar la fase del error\n2. Recetar drill específico (3-5 min)\n3. Reintentar el elemento\n4. Si persiste → volver al prerrequisito',
    },
    {
      'title': '📐 Biomecánica Clave',
      'category': 'Ciencia',
      'content': 'Puntos de inflexión por aparato:\n• SALTO: Ángulo de entrada al trampolín (plano = más potencia)\n• BARRAS: Cambio de muñecas en la vertical (wrist shift)\n• VIGA: Cabeza neutra (mirar abajo = caerse)\n• PISO: El giro nace de pies/caderas EN ALTURA, nunca en el despegue',
      'example': 'Yurchenko: Colocar un bloque frente al trampolín para forzar entrada plana, maximizando la transferencia de energía.',
    },
  ];

  static final Map<String, List<Map<String, String>>> levelSpecificHacks = {
    'N1-3': [
      {'skill': 'Rueda Lateral', 'apparatus': 'Piso/Viga', 'hack': 'Usar bloque de espuma. La gimnasta pasa las manos POR ENCIMA, forzando extensión de hombros y brazos bloqueados.', 'focus': 'Alineación de caderas y punta de pies'},
      {'skill': 'Pullover', 'apparatus': 'Barras', 'hack': 'Bloque inclinado debajo de la barra. La gimnasta camina antes de patear, manteniendo cadera pegada a la barra.', 'focus': 'Cadera pegada, chin-up holds como drill'},
      {'skill': 'Vuelta Pajarito', 'apparatus': 'Barras', 'hack': 'Enseñar el cast empujando la barra hasta los muslos. Banda de resistencia en piernas para mantenerlas juntas.', 'focus': 'Cast inicial y piernas unificadas'},
    ],
    'N4-5': [
      {'skill': 'Kip (FILTRO)', 'apparatus': 'Barras', 'hack': 'Hack 1: Glide swing aterrizando en bloque (extensión completa de cadera). Hack 2: Acostada con PVC, leg lifts rápidos imitando el panting.', 'focus': 'Glide + acción rápida pies-a-barra'},
      {'skill': 'Flic-Flac', 'apparatus': 'Piso', 'hack': 'SENTARSE hacia atrás (no saltar arriba). Usar octágono o cuña cuesta abajo. Rodillas a 90° en despegue.', 'focus': 'Ángulo de rodillas y dirección del impulso'},
      {'skill': 'Resorte Adelante', 'apparatus': 'Salto', 'hack': 'Bloqueos de hombros contra la pared. La potencia viene del REBOTE de hombros, NO de flexionar codos.', 'focus': 'Repulsión de hombros, no brazos'},
    ],
    'N6-7': [
      {'skill': 'Cast Vertical', 'apparatus': 'Barras', 'hack': '"Planchar" hombros sobre la barra. Hollow body planks con hombros proyectados más allá de muñecas.', 'focus': 'Proyección de hombros y hollow body'},
      {'skill': 'Flic-Flac en Viga', 'apparatus': 'Viga', 'hack': 'Practicar en LÍNEA en el suelo. Cabeza NEUTRA siempre. Mirar abajo = caerse.', 'focus': 'Cabeza neutra y línea recta'},
      {'skill': 'Mortales', 'apparatus': 'Piso', 'hack': 'Mini-tramp a plataforma elevada, aterrizando en espalda alta. Fuerza la elevación de cadera (SET) sin tirar hombros atrás.', 'focus': 'Set de cadera, no tirar hombros'},
    ],
    'N8-10': [
      {'skill': 'Yurchenko', 'apparatus': 'Salto', 'hack': 'Bloque frente al trampolín para entrada plana. Ejercicios de velocidad de carrera. Transferencia máxima de energía a la mesa.', 'focus': 'Velocidad de entrada y ángulo plano'},
      {'skill': 'Gigantes/Soltadas', 'apparatus': 'Barras', 'hack': 'Barra de correa (strap bar) para cientos de reps sin destruir manos. Construye memoria muscular del wrist shift.', 'focus': 'Cambio de muñecas en vertical'},
      {'skill': 'Mortales con Giro', 'apparatus': 'Piso', 'hack': 'Giro nace de pies/caderas EN ALTURA MÁXIMA, nunca en el despegue. Usar cama elástica para sentir la diferencia.', 'focus': 'Twist timing: altura primero, giro después'},
    ],
  };
}
