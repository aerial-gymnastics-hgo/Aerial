import 'package:flutter/material.dart';

class SystemEvent {
  final String id;
  final String title;
  final DateTime date;
  final Color color;
  final String targetRole; // 'all', 'coach', 'parent', 'student'
  final String type; // 'event', 'announcement'
  final String? message;

  const SystemEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.color,
    required this.targetRole,
    this.type = 'event',
    this.message,
  });

  bool get isUrgent => targetRole == 'all' && type == 'announcement';

  String get targetEmoji {
    if (type == 'event') return '📅';
    switch (targetRole) {
      case 'coach': return '👨‍🏫';
      case 'parent': return '👨‍👩‍👧';
      case 'student': return '🤸‍♀️';
      case 'all': return '📢';
      default: return '📋';
    }
  }

  String get targetText {
    if (type == 'event') return 'Evento';
    switch (targetRole) {
      case 'coach': return 'Entrenadores';
      case 'parent': return 'Padres';
      case 'student': return 'Alumnas';
      case 'all': return 'Todos';
      default: return 'General';
    }
  }
}
