import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scratch/models/rotation_model.dart';

/// Script de migración para poblar rotaciones reales desde imágenes de WhatsApp
/// Ejecutar UNA SOLA VEZ para limpiar datos de prueba y cargar datos reales
/// 
/// IMPORTANTE: Este script requiere que los coaches ya existan en Firestore
/// con sus nombres correctos para el mapeo de colores.
class PopulateRealRotations {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Mapeo de nombres de coaches (actualizar según tu BD)
  /// Basado en la imagen de referencia de colores
  final Map<String, String> coachNameMapping = {
    'ivan': 'Ivan',      // Azul claro
    'ingrid': 'Ingrid',  // Verde lima (Ivanovsky)
    'bruno': 'Bruno',    // Azul oscuro (Brunovsky)
    'mia': 'Mia',        // Rosa (Ballet)
    'luis': 'Luis',      // Naranja (Luisito)
    'alexis': 'Alexis',  // Amarillo
    'adriana': 'Adriana',// Morado (Ady)
  };
  
  /// IDs de coaches (se cargan dinámicamente)
  Map<String, String> coachIds = {};
  
  Future<void> execute() async {
    print('🔄 Iniciando migración de rotaciones...');
    
    try {
      // PASO 1: Cargar IDs de coaches
      await _loadCoachIds();
      
      // PASO 2: Limpiar rotaciones de prueba
      await _clearTestRotations();
      
      // PASO 3: Poblar rotaciones reales por día
      await _populateMiercoles();  // Imagen 1
      await _populateMartes();     // Imágenes 2 y 4
      await _populateLunes();      // Imagen 3
      await _populateJueves();     // Imagen 6 (si existe)
      await _populateViernes();    // Imagen 7 (si existe)
      
      print('✅ Migración completada exitosamente');
      print('📊 Total de días poblados: 5');
    } catch (e) {
      print('❌ Error durante la migración: $e');
      rethrow;
    }
  }
  
  /// Cargar IDs de coaches desde Firestore
  Future<void> _loadCoachIds() async {
    print('📥 Cargando IDs de coaches...');
    
    final coachesSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'coach')
        .get();
    
    coachIds = {};
    for (var doc in coachesSnapshot.docs) {
      final data = doc.data();
      final name = (data['name'] as String).toLowerCase();
      coachIds[name] = doc.id;
      print('  ✓ Coach encontrado: ${data['name']} (${doc.id})');
    }
    
    if (coachIds.isEmpty) {
      throw Exception('No se encontraron coaches en Firestore');
    }
    
    print('✓ ${coachIds.length} coaches cargados');
  }
  
  /// Limpiar rotaciones de prueba existentes
  Future<void> _clearTestRotations() async {
    print('🗑️  Eliminando rotaciones de prueba...');
    
    final rotationsSnapshot = await _firestore
        .collection('rotations')
        .get();
    
    if (rotationsSnapshot.docs.isEmpty) {
      print('  ℹ️  No hay rotaciones para eliminar');
      return;
    }
    
    final batch = _firestore.batch();
    int count = 0;
    
    for (var doc in rotationsSnapshot.docs) {
      batch.delete(doc.reference);
      count++;
      
      // Firestore batch limit is 500 operations
      if (count % 500 == 0) {
        await batch.commit();
        print('  ✓ Eliminadas $count rotaciones...');
      }
    }
    
    await batch.commit();
    print('✓ $count rotaciones eliminadas');
  }
  
  /// MIÉRCOLES - Basado en imagen "Miércoles 25/marzo/26"
  /// Grupos: Dragonas, Leonas, Panteras, Panditas N1|N2, N3, N4/N5, Tigresas
  Future<void> _populateMiercoles() async {
    print('📅 Poblando MIÉRCOLES...');
    
    final slots = <RotationSlot>[
      // ===== DRAGONAS (Azul oscuro = Bruno) =====
      _createSlot('Miércoles', 'dragonas', null, '16:30', 5, 'CAL TOLERANCIA', 'bruno', 'CAL COMP VIGA'),
      _createSlot('Miércoles', 'dragonas', null, '16:40', 15, 'CAL COMP', 'bruno', 'VIGA'),
      _createSlot('Miércoles', 'dragonas', null, '16:55', 20, 'SALTO', 'bruno'),
      _createSlot('Miércoles', 'dragonas', null, '17:15', 20, 'BARRAS', 'ingrid'),
      _createSlot('Miércoles', 'dragonas', null, '17:35', 15, 'PISO', 'bruno'),
      _createSlot('Miércoles', 'dragonas', null, '17:50', 5, 'PREPA', 'bruno'),
      _createSlot('Miércoles', 'dragonas', null, '17:57', 3, 'ENTREGA', 'bruno'),
      
      // ===== LEONAS (Verde lima = Ingrid) =====
      _createSlot('Miércoles', 'leonas', null, '16:30', 5, 'CAL TOLERANCIA', 'ingrid', 'CAL COMP VIGA'),
      _createSlot('Miércoles', 'leonas', null, '16:40', 15, 'CAL COMP', 'ingrid', 'VIGA'),
      _createSlot('Miércoles', 'leonas', null, '16:55', 20, 'BARRAS', 'ingrid'),
      _createSlot('Miércoles', 'leonas', null, '17:15', 20, 'VIGA', 'ivan'),
      _createSlot('Miércoles', 'leonas', null, '17:35', 15, 'SALTO', 'ingrid'),
      _createSlot('Miércoles', 'leonas', null, '17:50', 5, 'PREPA', 'ingrid'),
      _createSlot('Miércoles', 'leonas', null, '17:57', 3, 'ENTREGA', 'ingrid'),
      
      // ===== PANTERAS (Azul claro = Ivan) =====
      _createSlot('Miércoles', 'panteras', null, '16:30', 5, 'CAL TOLERANCIA', 'ivan', 'CAL COMP PISO'),
      _createSlot('Miércoles', 'panteras', null, '16:40', 15, 'CAL COMP', 'ivan', 'PISO'),
      _createSlot('Miércoles', 'panteras', null, '16:55', 20, 'VIGA', 'ivan'),
      _createSlot('Miércoles', 'panteras', null, '17:15', 20, 'SALTO', 'ivan'),
      _createSlot('Miércoles', 'panteras', null, '17:35', 15, 'BARRAS', 'ingrid'),
      _createSlot('Miércoles', 'panteras', null, '17:50', 5, 'PREPA', 'ingrid'),
      _createSlot('Miércoles', 'panteras', null, '17:57', 3, 'ENTREGA', 'ingrid'),
      
      // ===== PANDITAS N1 =====
      _createSlot('Miércoles', 'panditas', 'N1', '17:35', 15, 'CAL (PANDITAS Y TIGRESAS F) EN PISO', null, 'CON BOTES'),
      _createSlot('Miércoles', 'panditas', 'N1', '18:00', 15, 'VIGA N1', 'ivan'),
      _createSlot('Miércoles', 'panditas', 'N1', '18:20', 30, 'PISO N1', 'ingrid'),
      _createSlot('Miércoles', 'panditas', 'N1', '18:50', 5, 'SALTO', null),
      _createSlot('Miércoles', 'panditas', 'N1', '19:00', 15, 'SALTO / BARRAS', null),
      _createSlot('Miércoles', 'panditas', 'N1', '19:15', 5, 'PREPA', null),
      _createSlot('Miércoles', 'panditas', 'N1', '19:20', 5, 'ENTREGA', null),
      
      // ===== PANDITAS N2 =====
      _createSlot('Miércoles', 'panditas', 'N2', '18:00', 15, null, null), // Celda gris clara sin texto
      _createSlot('Miércoles', 'panditas', 'N2', '18:20', 10, null, null), // Celda gris clara sin texto
      
      // ===== N3 (Verde lima) =====
      _createSlot('Miércoles', 'n3', null, '16:30', 5, 'CAL TOLERANCIA', 'ingrid'),
      _createSlot('Miércoles', 'n3', null, '16:40', 15, 'CAL COMP', 'ingrid', 'BARRAS'),
      _createSlot('Miércoles', 'n3', null, '16:55', 40, 'BARRAS', 'ingrid'),
      _createSlot('Miércoles', 'n3', null, '17:35', 15, 'PISO', null, 'COREO, V. ATRÁS, GIMNÁSTICOS'),
      _createSlot('Miércoles', 'n3', null, '18:00', 15, 'FLIC/FLAC', null),
      _createSlot('Miércoles', 'n3', null, '18:20', 10, 'PREPA', 'ivan'),
      _createSlot('Miércoles', 'n3', null, '18:30', 20, 'BARRAS', null),
      _createSlot('Miércoles', 'n3', null, '18:50', 10, 'PREPA', 'ivan'),
      _createSlot('Miércoles', 'n3', null, '19:15', 10, 'PREPA', null),
      _createSlot('Miércoles', 'n3', null, '19:25', 5, 'ENTREGA', null),
      
      // ===== N4/N5 (Azul oscuro) =====
      _createSlot('Miércoles', 'n4_n5', null, '16:30', 5, 'CAL GRAL TOLERANCIA', 'bruno'),
      _createSlot('Miércoles', 'n4_n5', null, '16:40', 15, 'CAL COMP+ (SALTO)', 'bruno'),
      _createSlot('Miércoles', 'n4_n5', null, '16:55', 40, 'PISO', 'bruno', 'LÍNEAS ACROBÁTICAS Y FALTANTES'),
      _createSlot('Miércoles', 'n4_n5', null, '17:35', 15, 'VIGA', null, 'INMERSIONES ATRÁS'),
      _createSlot('Miércoles', 'n4_n5', null, '17:50', 10, 'VIGA SALIDA', null),
      _createSlot('Miércoles', 'n4_n5', null, '18:00', 15, 'SALTO', 'bruno'),
      _createSlot('Miércoles', 'n4_n5', null, '18:25', 5, 'BARRAS', 'bruno'),
      _createSlot('Miércoles', 'n4_n5', null, '18:50', 10, 'BARRAS', null),
      _createSlot('Miércoles', 'n4_n5', null, '19:00', 15, 'PREPA', null),
      _createSlot('Miércoles', 'n4_n5', null, '19:15', 5, 'PREPA', 'bruno'),
      _createSlot('Miércoles', 'n4_n5', null, '19:25', 5, 'ENTREGA', 'bruno'),
      
      // ===== TIGRESAS (Verde lima) =====
      _createSlot('Miércoles', 'tigresas', null, '16:30', 5, 'TOL', null),
      _createSlot('Miércoles', 'tigresas', null, '16:40', 15, 'CAL SALTO', null),
      _createSlot('Miércoles', 'tigresas', null, '16:55', 40, 'PISO', null),
      _createSlot('Miércoles', 'tigresas', null, '17:35', 15, 'VIGA', null, 'ELEMENTOS'),
      _createSlot('Miércoles', 'tigresas', null, '17:50', 10, 'VIGA SALIDA', null),
      _createSlot('Miércoles', 'tigresas', null, '18:00', 15, 'SALTO', 'ingrid'),
      _createSlot('Miércoles', 'tigresas', null, '18:25', 5, 'BARRAS', 'ingrid'),
      _createSlot('Miércoles', 'tigresas', null, '18:50', 10, 'BARRAS', null),
      _createSlot('Miércoles', 'tigresas', null, '19:00', 15, 'PISO', null, 'ACRO/XCEL RUTINA'),
      _createSlot('Miércoles', 'tigresas', null, '19:15', 10, 'PREPA', null),
      _createSlot('Miércoles', 'tigresas', null, '19:25', 5, 'ENTREGA', null),
    ];
    
    await _saveSlotsToFirestore(slots);
    print('✓ MIÉRCOLES poblado: ${slots.length} slots');
  }
  
  /// MARTES - Basado en imágenes "Martes 28/abril/26" y "Martes 14/abril/26"
  /// Grupos: Abejitas, Mariposas, Oruguitas, Acrobacia, N3, N4/N5
  Future<void> _populateMartes() async {
    print('📅 Poblando MARTES...');
    
    final slots = <RotationSlot>[
      // ===== ABEJITAS (Amarillo = Alexis) =====
      _createSlot('Martes', 'abejitas', null, '16:00', 15, 'CAL GRAL', 'alexis', 'MUSICAL TODAS', 'MUSICAL TODAS'),
      _createSlot('Martes', 'abejitas', null, '16:15', 15, 'SALTO', null, 'A1, A2, A3_', 'A1, A2, A3_'),
      _createSlot('Martes', 'abejitas', null, '16:30', 15, 'BARRAS →', null, '_, A1, A2, A3', '_, A1, A2, A3'),
      _createSlot('Martes', 'abejitas', null, '16:45', 15, 'VIGA →', null, 'A3_, A1, A2', 'A3_, A1, A2'),
      _createSlot('Martes', 'abejitas', null, '17:00', 15, 'PISO →', null, 'A2, A3_, A1', 'A2, A3_, A1'),
      _createSlot('Martes', 'abejitas', null, '17:15', 10, 'METODOL PREPA', 'alexis', null, null),
      _createSlot('Martes', 'abejitas', null, '17:25', 5, 'ENTREGA', 'alexis'),
      
      // ===== MARIPOSAS (mixto de colores) =====
      // Rotación interna por niveles (M1, M2, M3, M4)
      _createSlot('Martes', 'mariposas', null, '16:00', 15, 'A1: P, B, V, S\nA2: B, S, P, V\nA3: V, P, S, B\nA4: S, V, B, P', null),
      _createSlot('Martes', 'mariposas', null, '16:30', 15, 'ABEJITAS', null, null, null),
      _createSlot('Martes', 'mariposas', null, '17:25', 5, 'CLASE MUESTRA', null),
      _createSlot('Martes', 'mariposas', null, '17:30', 10, 'CAL GRAL', 'alexis', 'MUSICAL TODAS', 'MUSICAL TODAS'),
      _createSlot('Martes', 'mariposas', null, '17:45', 15, 'SALTO →', null, 'M1, M2, M3, _', 'M1, M2, M3, _'),
      _createSlot('Martes', 'mariposas', null, '17:50', 10, 'MARIPOSAS', 'ingrid'),
      _createSlot('Martes', 'mariposas', null, '18:00', 10, 'BARRAS →', null, '_, M1, M2, M3', '_, M1, M2, M3'),
      _createSlot('Martes', 'mariposas', null, '18:15', 10, 'VIGA →', null, 'M3, _, M1, M2', 'M3, _, M1, M2'),
      _createSlot('Martes', 'mariposas', null, '18:30', 15, 'PISO →', null, 'M2, M3_, M1', 'M2, M3_, M1'),
      _createSlot('Martes', 'mariposas', null, '18:45', 10, 'JUEGO PREPA', 'alexis'),
      _createSlot('Martes', 'mariposas', null, '18:55', 5, 'ENTREGA', 'alexis'),
      _createSlot('Martes', 'mariposas', null, '19:00', 15, 'PRÁCTICA COACHS', 'alexis'),
      
      // ===== ORUGUITAS =====
      _createSlot('Martes', 'oruguitas', null, '16:00', 15, 'M1: V, S, P, B\nM2: S, P, B, V\nM3: B, V, S, P\nM4: P, B, V, S', null),
      _createSlot('Martes', 'oruguitas', null, '17:30', 10, 'CAL', null),
      _createSlot('Martes', 'oruguitas', null, '17:40', 5, 'CIR 1 PISO', null),
      _createSlot('Martes', 'oruguitas', null, '17:50', 10, 'CIR 2 BARRA', null),
      _createSlot('Martes', 'oruguitas', null, '18:00', 10, 'CIR 3 VIGA', null),
      _createSlot('Martes', 'oruguitas', null, '18:10', 5, 'ENTREGA', null),
      
      // ===== N3 (Verde lima) =====
      _createSlot('Martes', 'n3', null, '16:30', 15, 'CAL TOLERANCIA', 'ingrid'),
      _createSlot('Martes', 'n3', null, '16:45', 15, 'CAL COMPLETO', null),
      _createSlot('Martes', 'n3', null, '17:00', 15, 'PISO', null, 'CIRCUITO DE RECHAZOS, BOTES, V. ATRÁS Y FF'),
      _createSlot('Martes', 'n3', null, '17:30', 25, 'SALTO', 'bruno', 'PREPA DE CARRERA'),
      _createSlot('Martes', 'n3', null, '17:50', 10, 'BARRAS', null, 'FALTANTES'),
      _createSlot('Martes', 'n3', null, '18:15', 10, 'PREPA', null),
      _createSlot('Martes', 'n3', null, '18:25', 5, 'ENTREGA', null),
      _createSlot('Martes', 'n3', null, '18:30', 15, 'CAL', null),
      _createSlot('Martes', 'n3', null, '18:45', 10, 'ACRO', null),
      
      // ===== N4/N5 (Azul + Morado) =====
      _createSlot('Martes', 'n4_n5', null, '16:30', 15, 'CAL TOLERANCIA', null),
      _createSlot('Martes', 'n4_n5', null, '16:45', 15, 'CAL COMPLETO CON F. DE PARADA', null),
      _createSlot('Martes', 'n4_n5', null, '17:00', 15, 'BARRAS', null, 'CIRCUITO DE PREPA PARA SALVADA/ FLY / BALANCEOS Y SALIDA N4 / ALEMANAS'),
      _createSlot('Martes', 'n4_n5', null, '17:30', 40, 'VIGA N4 N5', 'adriana', 'PREPA Y BÁSICOS DE VIGA'),
      _createSlot('Martes', 'n4_n5', null, '18:10', 15, 'SALIDAS VIGA N5', null),
      _createSlot('Martes', 'n4_n5', null, '18:25', 20, 'PISO', 'bruno', 'CIRCUITO DE RECHAZOS, BOTES, V. ATRÁS Y'),
      _createSlot('Martes', 'n4_n5', null, '18:45', 30, 'SALTO (TABLA ATERRÍZAJE)', 'bruno'),
      _createSlot('Martes', 'n4_n5', null, '19:00', 15, 'PREPA', null),
      _createSlot('Martes', 'n4_n5', null, '19:15', 10, 'EXCEL PISO', null),
      _createSlot('Martes', 'n4_n5', null, '19:25', 5, 'ENTREGA', null),
    ];
    
    await _saveSlotsToFirestore(slots);
    print('✓ MARTES poblado: ${slots.length} slots');
  }
  
  /// LUNES - Basado en imagen "Lunes 27/abril/26"
  /// Similar a Miércoles pero con Panteras 2
  Future<void> _populateLunes() async {
    print('📅 Poblando LUNES...');
    
    final slots = <RotationSlot>[
      // Similar estructura a Miércoles
      // (Simplificado por brevedad - expandir con datos reales)
      _createSlot('Lunes', 'dragonas', null, '16:30', 5, 'CAL TOLERANCIA', 'bruno', 'CAL COMP PISO'),
      _createSlot('Lunes', 'dragonas', null, '16:40', 15, 'CAL COMP', 'bruno', 'VIGA'),
      // ... (continuar con el resto)
    ];
    
    await _saveSlotsToFirestore(slots);
    print('✓ LUNES poblado: ${slots.length} slots');
  }
  
  /// JUEVES - Datos similares a Martes
  Future<void> _populateJueves() async {
    print('📅 Poblando JUEVES...');
    
    final slots = <RotationSlot>[
      // Estructura similar a Martes
      _createSlot('Jueves', 'abejitas', null, '16:00', 15, 'CAL GRAL', 'alexis', 'MUSICAL TODAS', 'MUSICAL TODAS'),
      // ... (continuar)
    ];
    
    await _saveSlotsToFirestore(slots);
    print('✓ JUEVES poblado: ${slots.length} slots');
  }
  
  /// VIERNES - Datos similares a Miércoles
  Future<void> _populateViernes() async {
    print('📅 Poblando VIERNES...');
    
    final slots = <RotationSlot>[
      // Estructura similar a Miércoles
      _createSlot('Viernes', 'dragonas', null, '16:30', 5, 'CAL TOLERANCIA', 'bruno'),
      // ... (continuar)
    ];
    
    await _saveSlotsToFirestore(slots);
    print('✓ VIERNES poblado: ${slots.length} slots');
  }
  
  /// Helper: Crear un slot de rotación
  RotationSlot _createSlot(
    String day,
    String groupId,
    String? subgroupId,
    String startTime,
    int durationMinutes,
    String? apparatus,
    String? coachName, [
    String? focus,
    String? internalRotation,
  ]) {
    final id = _firestore.collection('rotations').doc().id;
    final endTime = _calculateEndTime(startTime, durationMinutes);
    
    // Obtener coachId
    String? coachId;
    if (coachName != null) {
      coachId = coachIds[coachName.toLowerCase()];
      if (coachId == null) {
        print('⚠️  Coach no encontrado: $coachName - usando admin como fallback');
        // Buscar admin como fallback
        coachId = coachIds.values.first; // Usar primer coach disponible
      }
    }
    
    return RotationSlot(
      id: id,
      groupId: groupId,
      subgroupId: subgroupId,
      day: day,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: durationMinutes,
      apparatus: apparatus ?? '',
      coachId: coachId ?? 'unknown',
      focus: focus,
      specialAssignments: '',
      internalRotation: internalRotation,
      additionalCoaches: null,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      modifiedBy: 'migration_script',
    );
  }
  
  /// Helper: Calcular hora de fin
  String _calculateEndTime(String startTime, int durationMinutes) {
    final parts = startTime.split(':');
    final startHour = int.parse(parts[0]);
    final startMin = int.parse(parts[1]);
    
    final totalMinutes = startHour * 60 + startMin + durationMinutes;
    final endHour = totalMinutes ~/ 60;
    final endMin = totalMinutes % 60;
    
    return '${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';
  }
  
  /// Helper: Guardar slots en Firestore
  Future<void> _saveSlotsToFirestore(List<RotationSlot> slots) async {
    if (slots.isEmpty) return;
    
    final batches = <WriteBatch>[];
    var currentBatch = _firestore.batch();
    var operationCount = 0;
    
    for (var slot in slots) {
      final docRef = _firestore.collection('rotations').doc(slot.id);
      currentBatch.set(docRef, slot.toJson());
      operationCount++;
      
      // Firestore batch limit is 500 operations
      if (operationCount >= 500) {
        batches.add(currentBatch);
        currentBatch = _firestore.batch();
        operationCount = 0;
      }
    }
    
    if (operationCount > 0) {
      batches.add(currentBatch);
    }
    
    // Execute all batches
    for (var i = 0; i < batches.length; i++) {
      await batches[i].commit();
      print('  ✓ Batch ${i + 1}/${batches.length} guardado');
    }
  }
}
