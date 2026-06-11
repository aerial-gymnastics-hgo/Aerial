import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/announcement_model.dart';
import '../models/achievement_model.dart';
import '../models/schedule_model.dart';
import '../models/rotation_model.dart';
import '../models/event_model.dart';
import '../models/group_model.dart';
import '../models/schedule_config_model.dart';

/// Servicio encargado de proveer los datos reales desde Firebase Firestore
/// implementando un patrón "Adapter" para emular las firmas asíncronas necesarias.
class FirestoreService {
  // 1. Patrón Singleton
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===========================================================================
  // CONSTANTES ESTÁTICAS Y ALMACENAMIENTO DE IDs (Expando)
  // ===========================================================================
  static const List<String> availableGroups = [
    'Oruguitas', 'Abejitas', 'Mariposas', 'Dragonas', 'Panteras', 
    'Tigresas', 'Panditas', 'Conejas', 'Halconas', 'Linces',
    'Baby Gym A', 'Baby Gym B', 'Principiantes 1', 'Principiantes 2',
    'Intermedio', 'Avanzado', 'Pre-Equipo', 'Equipo Representativo'
  ];



  // ===========================================================================
  // STREAMS PRINCIPALES
  // ===========================================================================

  /// Obtiene la lista de alumnos de un grupo específico
  Stream<List<User>> getStudentsByGroup(String groupName) {
    debugPrint('DEBUG: [FirestoreService] getStudentsByGroup: $groupName');
    return _db.collection('users')
        .where('role', isEqualTo: 'student')
        .where('group', isEqualTo: groupName)
        .snapshots()
        .map((snap) {
          return snap.docs.map(_userFromFirestore).toList();
        });
  }

  /// Obtiene la lista de alumnos en tiempo real
  Stream<List<User>> getStudents() {
    debugPrint('DEBUG: [FirestoreService] Ejecutando query: users where role == student');
    return _db.collection('users').where('role', isEqualTo: 'student').snapshots().map((snap) {
      debugPrint('DEBUG: [FirestoreService] getStudents snapshot recibido. Documentos: ${snap.docs.length}');
      if (snap.docs.isEmpty) {
        debugPrint('DEBUG: [FirestoreService] getStudents snapshot vacío.');
        return <User>[];
      }
      final list = snap.docs.map(_userFromFirestore).toList();
      debugPrint('DEBUG: [FirestoreService] Alumnas mapeadas: ${list.length}');
      if (list.isNotEmpty) {
        debugPrint('DEBUG: [FirestoreService] Muestra - Primera alumna: ${list.first.name} - Grupo: ${list.first.group}');
      }
      return list;
    }).handleError((error) {
      debugPrint('DEBUG: [FirestoreService] Error crítico en getStudents: $error');
      return <User>[]; // Retorna vacío en lugar de crashear
    });
  }

  /// Obtiene la lista de entrenadores en tiempo real
  Stream<List<User>> getCoaches() {
    return _db.collection('users').where('role', isEqualTo: 'coach').snapshots().map((snap) {
      if (snap.docs.isEmpty) return <User>[];
      final users = snap.docs.map(_userFromFirestore).toList();
      final seen = <String>{};
      return users.where((u) => seen.add(u.id)).toList();
    }).handleError((error) {
      debugPrint('Error en getCoaches: $error');
      return <User>[];
    });
  }

  /// Obtiene la lista de familias (padres) en tiempo real
  Stream<List<User>> getParents() {
    // Si los padres están en collection 'users' filtrado por role, o collection aparte.
    // Basado en el esquema, usamos 'users' y filtramos localmente (o directo si los organizas así).
    return _db.collection('users').where('role', isEqualTo: 'parent').snapshots().map((snap) {
      if (snap.docs.isEmpty) return <User>[];
      return snap.docs.map(_userFromFirestore).toList();
    }).handleError((error) {
      debugPrint('Error en getParents: $error');
      return <User>[];
    });
  }

  /// Obtiene la lista de grupos oficiales desde Firestore
  Stream<List<GymGroup>> getGroups() {
    return _db.collection('groups').snapshots().map((snap) {
      return snap.docs.map((doc) => GymGroup.fromFirestore(doc.id, doc.data() as Map<String, dynamic>)).toList();
    }).handleError((error) {
      debugPrint('Error en getGroups: $error');
      return <GymGroup>[];
    });
  }

  /// Trae un solo estudiante basado en su Document ID
  Stream<User?> getStudentById(String studentId) {
    if (studentId.isEmpty) return Stream.value(null);
    return _db.collection('users').doc(studentId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _userFromFirestore(doc);
    }).handleError((error) {
      debugPrint('Error en getStudentById: $error');
      return null;
    });
  }

  /// Obtiene la lista de anuncios en tiempo real
  Stream<List<Announcement>> getAnnouncements() {
    return _db.collection('announcements')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return <Announcement>[];
          return snap.docs.map(_announcementFromFirestore).toList();
        })
        .handleError((error) {
          debugPrint('Error en getAnnouncements: $error');
          return <Announcement>[];
        });
  }

  /// Obtiene las asignaciones (matrices de rotación / horarios)
  Stream<List<ScheduleAssignment>> getAssignments() {
    return _db.collection('assignments').snapshots().map((snap) {
      if (snap.docs.isEmpty) return <ScheduleAssignment>[];
      final list = snap.docs.map(_assignmentFromFirestore).toList();
      final seen = <String>{};
      return list.where((a) => seen.add(a.id)).toList();
    }).handleError((error) {
      debugPrint('Error en getAssignments: $error');
      return <ScheduleAssignment>[];
    });
  }

  /// Obtiene la libreta de rotaciones dinámicas de un coach en particular
  Stream<List<RotationSlot>> getRotationsForCoach(String coachId) {
    return _db.collection('rotations')
        .where('coachId', isEqualTo: coachId)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return <RotationSlot>[];
          return snap.docs.map(_rotationFromFirestore).toList();
        })
        .handleError((error) {
          debugPrint('Error en getRotationsForCoach: $error');
          return <RotationSlot>[];
        });
  }

  /// Obtiene TODAS las rotaciones vigentes (para la matriz global)
  Stream<List<RotationSlot>> getAllRotations() {
    return _db.collection('rotations').snapshots().map((snap) {
      if (snap.docs.isEmpty) return <RotationSlot>[];
      return snap.docs.map(_rotationFromFirestore).toList();
    }).handleError((error) {
      debugPrint('Error en getAllRotations: $error');
      return <RotationSlot>[];
    });
  }

  /// Obtiene los eventos de calendario relevantes para un rol. 
  /// Utiliza `whereIn` para optimizar lecturas. El admin ve todo.
  Stream<List<SystemEvent>> getEventsForRole(String role) {
    Query query = _db.collection('events');
    if (role != 'admin') {
      query = query.where('targetRole', whereIn: [role, 'all']);
    }
    return query.snapshots().map((snap) {
      if (snap.docs.isEmpty) return <SystemEvent>[];
      return snap.docs.map(_eventFromFirestore).toList();
    }).handleError((error) {
      debugPrint('Error en getEventsForRole: $error');
      return <SystemEvent>[];
    });
  }

  /// Obtiene los planes vigentes por grupo (Mesociclos)
  Stream<Map<String, Map<String, dynamic>>> getMesocycles() {
    return _db.collection('mesocycles').snapshots().map((snap) {
      final map = <String, Map<String, dynamic>>{};
      for (var doc in snap.docs) {
        map[doc.id] = doc.data(); 
      }
      return map;
    }).handleError((error) {
      debugPrint('Error en getMesocycles: $error');
      return <String, Map<String, dynamic>>{};
    });
  }

  Stream<ScheduleConfig> getScheduleConfig() {
    return _db.collection('settings').doc('schedule').snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return ScheduleConfig.defaultConfig();
      }
      return ScheduleConfig.fromMap(doc.data()!);
    }).handleError((error) {
      debugPrint('Error en getScheduleConfig: $error');
      return ScheduleConfig.defaultConfig();
    });
  }

  Future<void> saveScheduleConfig(ScheduleConfig config) async {
    try {
      await _db.collection('settings').doc('schedule').set(config.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error guardando schedule config: $e');
      rethrow;
    }
  }



  // ===========================================================================
  // ESCRITURA EN FIRESTORE (WRITERS) -> ROTATIONS
  // ===========================================================================

  Future<void> saveRotation(RotationSlot slot) async {
    try {
      await _db.collection('rotations').doc(slot.id).set({
        'coachId': slot.coachId,
        'groupId': slot.groupId,
        'day': slot.day,
        'startTime': slot.startTime,
        'endTime': slot.endTime,
        'durationMinutes': slot.durationMinutes,
        'apparatus': slot.apparatus,
        'focus': slot.focus,
        'specialAssignments': slot.specialAssignments,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error guardando rotación: $e');
      rethrow;
    }
  }

  Future<void> deleteRotation(String id) async {
    try {
      await _db.collection('rotations').doc(id).delete();
    } catch (e) {
      debugPrint('Error borrando rotación: $e');
      rethrow;
    }
  }

  Future<void> deleteAllRotations() async {
    try {
      final snap = await _db.collection('rotations').get();
      final batch = _db.batch();
      for (var doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error borrando todas las rotaciones: $e');
      rethrow;
    }
  }

  Future<void> saveMultipleRotations(List<RotationSlot> slots) async {
    try {
      final batch = _db.batch();
      for (var slot in slots) {
        final docRef = _db.collection('rotations').doc(slot.id);
        batch.set(docRef, {
          'coachId': slot.coachId,
          'groupId': slot.groupId,
          'day': slot.day,
          'startTime': slot.startTime,
          'endTime': slot.endTime,
          'durationMinutes': slot.durationMinutes,
          'apparatus': slot.apparatus,
          'focus': slot.focus,
          'specialAssignments': slot.specialAssignments,
        }, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error guardando múltiples rotaciones: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // ESCRITURA EN FIRESTORE (WRITERS) -> ASSIGNMENTS (ROLES GLOBALES)
  // ===========================================================================

  Future<void> saveAssignment(ScheduleAssignment assignment) async {
    try {
      final String startStr = '${assignment.startTime.hour.toString().padLeft(2, '0')}:${assignment.startTime.minute.toString().padLeft(2, '0')}';
      final String endStr = '${assignment.endTime.hour.toString().padLeft(2, '0')}:${assignment.endTime.minute.toString().padLeft(2, '0')}';
      
      // Set con merge: true previene duplicados y unifica el Create/Update
      await _db.collection('assignments').doc(assignment.id).set({
        'dayOfWeek': assignment.dayOfWeek,
        'startTime': startStr,
        'endTime': endStr,
        'groupId': assignment.groupId,
        'apparatus': assignment.apparatus,
        'coachId': assignment.coachId,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error guardando asignación de clase: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // LECTURA DE STREAMS -> TRIALS
  // ===========================================================================





  // ===========================================================================
  // LECTURA DE STREAMS -> FINANZAS (CASCARÓN)
  // ===========================================================================
  
  // ===========================================================================
  // LECTURA DE STREAMS -> GRUPOS
  // ===========================================================================

  /// Obtiene la información de un grupo específico por su nombre (ID)
  Future<GymGroup?> getGroupInfo(String groupName) async {
    try {
      final doc = await _db.collection('groups').doc(groupName).get();
      if (!doc.exists) return null;
      return GymGroup.fromFirestore(doc.id, doc.data()!);
    } catch (e) {
      debugPrint('Error obteniendo info de grupo: $e');
      return null;
    }
  }

  /// Obtiene la lista de todos los grupos
  Stream<List<GymGroup>> getAllGroups() {
    return _db.collection('groups').snapshots().map((snap) {
      final groups = snap.docs.map((doc) => GymGroup.fromFirestore(doc.id, doc.data())).toList();
      final seen = <String>{};
      return groups.where((g) => seen.add(g.id)).toList();
    }).handleError((error) {
      debugPrint('Error en getAllGroups: $error');
      return <GymGroup>[];
    });
  }

  Stream<List<Map<String, dynamic>>> getFinancialStatus(String studentId) {
    if (studentId.isEmpty) return Stream.value([]);
    
    return _db.collection('payments')
        .where('studentId', isEqualTo: studentId)
        .orderBy('paidAt', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data,
              // Asegurar que paidAt sea DateTime si viene como Timestamp
              'paidAt': (data['paidAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            };
          }).toList();
        });
  }

  // ===========================================================================
  // ESCRITURA EN FIRESTORE (WRITERS) -> EVENTOS DE AGENDA
  // ===========================================================================

  Future<void> saveEvent(SystemEvent event) async {
    try {
      await _db.collection('events').doc(event.id).set({
        'title': event.title,
        'date': Timestamp.fromDate(event.date),
        'colorHex': event.color.value,
        'targetRole': event.targetRole,
        'type': event.type,
        'message': event.message,
      });
    } catch (e) {
      debugPrint('Error guardando evento de agenda: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _db.collection('events').doc(eventId).delete();
    } catch (e) {
      debugPrint('Error borrando evento de agenda: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // ESCRITURA EN FIRESTORE (WRITERS) -> MESOCICLOS Y METAS ESTUDIANTILES
  // ===========================================================================

  Future<void> saveMesocycle(String group, Map<String, dynamic> data) async {
    try {
      await _db.collection('mesocycles').doc(group).set(data);
    } catch (e) {
      debugPrint('Error guardando mesociclo: $e');
      rethrow;
    }
  }

  Future<void> updateStudentProfile(String studentId, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(studentId).update({
        ...data,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error actualizando perfil del estudiante: $e');
      rethrow;
    }
  }

  Future<void> updateStudentObjective(String studentId, String objective) async {
    try {
      // Nota: Colección real es 'users' y se filtra por 'role':'student' en lectura.
      await _db.collection('users').doc(studentId).update({'monthlyObjective': objective});
    } catch (e) {
      debugPrint('Error actualizando objetivo: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // ESCRITURA EN FIRESTORE (WRITERS) -> ASISTENCIA (ATTENDANCE)
  // ===========================================================================
  Future<void> saveAttendance({
    required String coachId,
    required String studentId,
    required String status,
    required String groupId,
  }) async {
    try {
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final docId = '${studentId}_$dateStr';

      if (status.isEmpty) {
        // Si status es vacío, borrar el documento
        await _db.collection('attendance').doc(docId).delete();
      } else {
        // Usar doc(id).set con merge para crear o actualizar
        await _db.collection('attendance').doc(docId).set({
          'coachId': coachId,
          'studentId': studentId,
          'status': status,
          'groupId': groupId,
          'date': dateStr,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error guardando asistencia: $e');
      rethrow;
    }
  }

  /// Calcula retardos y faltas de un alumno en tiempo real basado en Firebase
  Stream<Map<String, int>> getAttendanceStats(String studentId) {
    if (studentId.isEmpty) return Stream.value({'late': 0, 'absent': 0});

    return _db.collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) {
          int lates = 0;
          int absents = 0;
          for (var doc in snap.docs) {
             final data = doc.data();
             final status = data['status'] ?? 'present';
             if (status == 'late') lates += 1;
             if (status == 'absent') absents += 1;
          }
          return {'late': lates, 'absent': absents};
        })
        .handleError((error) {
          debugPrint('Error en getAttendanceStats: $error');
          return {'late': 0, 'absent': 0};
        });
  }

  /// Obtiene el muro de logros (logros, competencias, ascensos)
  Stream<List<Achievement>> getAchievements({String? studentId, String? groupName}) {
    Query query = _db.collection('achievements');

    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    } else if (groupName != null) {
      query = query.where('groupName', isEqualTo: groupName);
    }

    return query
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return <Achievement>[];
          return snap.docs.map(_achievementFromFirestore).toList();
        })
        .handleError((error) {
          debugPrint('Error en getAchievements: $error');
          return <Achievement>[];
        });
  }

  /// Obtiene las métricas financieras/operativas (Acceso restringido por Security Rules)
  Stream<Map<String, dynamic>> getMetrics() {
    // Escucha el documento fijo "general" dentro de metrics (ejemplo de arquitectura)
    return _db.collection('metrics').doc('general').snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return <String, dynamic>{};
      return snap.data()!;
    }).handleError((error) {
      debugPrint('Error en getMetrics: $error');
      return <String, dynamic>{};
    });
  }

  // ===========================================================================
  // PARSERS PROTEGIDOS CONTRA NULOS (??)
  // Ningún parser asume que el campo existe en la BD o que está bien tipado.
  // ===========================================================================

  /// Convierte documento genérico a objeto User (sirve para coaches y students)
  User _userFromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      
      // Parseo rudo de rol
      UserRole role = UserRole.student;
      final String roleStr = data['role'] ?? 'student';
      if (roleStr == 'admin') role = UserRole.admin;
      if (roleStr == 'coach') role = UserRole.coach;
      if (roleStr == 'parent') role = UserRole.parent;

      return User(
        id: doc.id,
        name: data['name'] ?? 'Sin Nombre',
        email: data['email'] ?? '',
        role: role,
        group: data['group'] ?? 'General',
        photoUrl: data['photoUrl'],
        associatedStudentId: data['associatedStudentId'],
        colorHex: _parseColorHex(data['colorHex']),
        phone: data['phone'],
        emergencyContact: data['emergencyContact'],
        allergies: data['allergies'],
        birthDate: (data['birthDate'] as Timestamp?)?.toDate(),
        paymentStatus: data['paymentStatus'],
        nextPaymentDate: (data['nextPaymentDate'] as Timestamp?)?.toDate(),
        monthlyFee: (data['monthlyFee'] as num?)?.toDouble(),
        monthlyObjective: data['monthlyObjective'],
        insuranceProvider: data['insuranceProvider'],
        insurancePolicyNumber: data['insurancePolicyNumber'],
        insuranceExpiryDate: (data['insuranceExpiryDate'] as Timestamp?)?.toDate(),
        guardianName: data['guardianName'],
        guardianPhone: data['guardianPhone'],
        guardianPhoneSecondary: data['guardianPhoneSecondary'],
        guardianEmail: data['guardianEmail'],
        guardianRelationship: data['guardianRelationship'],
      );
    } catch (e) {
      debugPrint('DEBUG: [FirestoreService] ERROR de parseo en _userFromFirestore para doc ${doc.id}: $e');
      rethrow;
    }
  }

  /// Convierte documento a objeto Announcement
  Announcement _announcementFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Announcement(
      id: doc.id,
      title: data['title'] ?? 'Aviso',
      message: data['message'] ?? 'Sin contenido',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      targetRole: data['targetRole'] ?? 'all',
    );
  }

  /// Convierte documento a objeto ScheduleAssignment
  ScheduleAssignment _assignmentFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ScheduleAssignment(
      id: doc.id,
      dayOfWeek: data['dayOfWeek'] ?? 'Lunes',
      startTime: _parseTimeOfDay(data['startTime']),
      endTime: _parseTimeOfDay(data['endTime']),
      groupId: data['groupId'] ?? 'N/A',
      apparatus: data['apparatus'] ?? 'Libre',
      coachId: data['coachId'] ?? 'N/A',
    );
  }

  /// Convierte documento a objeto RotationSlot
  RotationSlot _rotationFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RotationSlot(
      id: doc.id,
      day: data['day'] ?? 'Lunes',
      startTime: data['startTime'] ?? '00:00',
      endTime: data['endTime'] ?? '00:00',
      durationMinutes: data['durationMinutes'] ?? 60,
      groupId: data['groupId'] ?? 'Sin Grupo',
      apparatus: data['apparatus'] ?? 'Piso',
      focus: data['focus'],
      specialAssignments: data['specialAssignments'],
      coachId: data['coachId'] ?? '',
    );
  }

  /// Convierte documento a objeto SystemEvent
  SystemEvent _eventFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SystemEvent(
      id: doc.id,
      title: data['title'] ?? 'Evento',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      color: Color(data['colorHex'] ?? 0xFF00E5FF),
      targetRole: data['targetRole'] ?? 'all',
      type: data['type'] ?? 'event',
      message: data['message'],
    );
  }


  /// Convierte documento a objeto Achievement
  Achievement _achievementFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Convertir el string guardado al Enum local
    AchievementType type = AchievementType.skill;
    final String typeStr = data['type'] ?? 'skill';
    if (typeStr == 'competition') type = AchievementType.competition;
    if (typeStr == 'attitude') type = AchievementType.attitude;

    return Achievement(
      id: doc.id,
      title: data['title'] ?? 'Logro desbloqueado',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      studentName: data['studentName'] ?? 'Alumna',
      studentId: data['studentId'] ?? '',
      groupName: data['groupName'] ?? '',
      type: type,
      // Usamos el icono predeterminado si no viene de DB
      icon: _getIconForAchievementType(type),
      memoryPhotoUrl: data['memoryPhotoUrl'],
      taggedStudents: List<String>.from(data['taggedStudents'] ?? []),
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  TimeOfDay _parseTimeOfDay(String? timeStr) {
    if (timeStr == null || !timeStr.contains(':')) return const TimeOfDay(hour: 0, minute: 0);
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  /// Convierte el campo colorHex de Firestore (puede ser int o String '#RRGGBB') a int?
  int? _parseColorHex(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is String) {
      try {
        final hex = raw.replaceAll('#', '').trim();
        return int.parse('0xFF$hex');
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  IconData _getIconForAchievementType(AchievementType type) {
    switch(type) {
      case AchievementType.skill: return Icons.sports_gymnastics;
      case AchievementType.competition: return Icons.emoji_events;
      case AchievementType.attitude: return Icons.favorite;
    }
  }



  // ===========================================================================
  // ESCRITURA EN FIRESTORE (WRITERS) -> PAGOS (CASCARÓN)
  // ===========================================================================

  Future<void> addPayment(Map<String, dynamic> paymentData) async {
    try {
      await _db.collection('payments').add({
        ...paymentData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error guardando pago: $e');
      rethrow;
    }
  }

  Future<void> addTransaction(Map<String, dynamic> tx) async {
    await addPayment(tx);
  }
}
