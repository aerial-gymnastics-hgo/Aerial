import 'package:cloud_firestore/cloud_firestore.dart';

class RotationSlot {
  final String id;
  final String coachId;
  final String groupId;
  final String? subgroupId;
  final String day;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String apparatus;
  final String? focus;
  final String? specialAssignments;
  final String? internalRotation;
  final List<String>? additionalCoaches;
  final DateTime? createdAt;
  final DateTime? lastModified;
  final String? modifiedBy;

  // Campos para contenido pedagógico
  final String? links;
  final String? exercises;

  // IDs de otros slots que ocurren simultáneamente con este (mismo coach, mismo horario, grupos distintos)
  final List<String>? linkedSlots;

  RotationSlot({
    required this.id,
    required this.coachId,
    required this.groupId,
    this.subgroupId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.apparatus,
    this.focus,
    this.specialAssignments,
    this.internalRotation,
    this.additionalCoaches,
    this.createdAt,
    this.lastModified,
    this.modifiedBy,
    this.links,
    this.exercises,
    this.linkedSlots,
  });

  factory RotationSlot.fromJson(Map<String, dynamic> json) {
    return RotationSlot(
      id: json['id'] as String,
      coachId: json['coachId'] as String? ?? '',
      groupId: json['groupId'] as String? ?? '',
      subgroupId: json['subgroupId'] as String?,
      day: json['day'] as String? ?? 'Lunes',
      startTime: json['startTime'] as String? ?? '00:00',
      endTime: json['endTime'] as String? ?? '00:00',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      apparatus: json['apparatus'] as String? ?? '',
      focus: json['focus'] as String?,
      specialAssignments: json['specialAssignments'] as String?,
      internalRotation: json['internalRotation'] as String?,
      additionalCoaches: (json['additionalCoaches'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      lastModified: (json['lastModified'] as Timestamp?)?.toDate(),
      modifiedBy: json['modifiedBy'] as String?,
      links: json['links'] as String?,
      exercises: json['exercises'] as String?,
      linkedSlots: (json['linkedSlots'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coachId': coachId,
      'groupId': groupId,
      'subgroupId': subgroupId,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'durationMinutes': durationMinutes,
      'apparatus': apparatus,
      'focus': focus,
      'specialAssignments': specialAssignments,
      'internalRotation': internalRotation,
      'additionalCoaches': additionalCoaches,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastModified': lastModified != null ? Timestamp.fromDate(lastModified!) : null,
      'modifiedBy': modifiedBy,
      'links': links,
      'exercises': exercises,
      'linkedSlots': linkedSlots,
    };
  }
}
