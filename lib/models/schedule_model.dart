import 'package:flutter/material.dart';

class ScheduleAssignment {
  final String id;
  final String dayOfWeek; // Lunes, Martes, Miércoles, Jueves, Viernes, Sábado
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String groupId;
  final String apparatus;
  final String coachId;
  final String? activityDetail;

  ScheduleAssignment({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.groupId,
    required this.apparatus,
    required this.coachId,
    this.activityDetail,
  });

  String get timeRange => '${startTime.format24} - ${endTime.format24}';
}

extension TimeOfDayExtension on TimeOfDay {
  String get format24 {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }
}
