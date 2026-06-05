import 'package:flutter/material.dart';

enum AchievementType {
  skill,
  competition,
  attitude,
}

class Achievement {
  final String id;
  final String title;
  final DateTime date;
  final String studentName;
  final String studentId;
  final String groupName;
  final AchievementType type;
  final IconData icon;
  final String? memoryPhotoUrl;
  final List<String> taggedStudents;
  final Map<String, int> reactions; // e.g. {'heart': 12, 'fire': 5}

  Achievement({
    required this.id,
    required this.title,
    required this.date,
    required this.studentName,
    required this.studentId,
    required this.groupName,
    required this.type,
    required this.icon,
    this.memoryPhotoUrl,
    this.taggedStudents = const [],
    this.reactions = const {},
  });

  // Helper para obtener el color según el tipo
  Color get color {
    switch (type) {
      case AchievementType.skill:
        return const Color(0xFFFFD700); // Dorado
      case AchievementType.competition:
        return const Color(0xFFC0C0C0); // Plateado
      case AchievementType.attitude:
        return const Color(0xFFE91E63); // Rosa
    }
  }

  // Helper para obtener el texto del tipo
  String get typeText {
    switch (type) {
      case AchievementType.skill:
        return 'Habilidad';
      case AchievementType.competition:
        return 'Competencia';
      case AchievementType.attitude:
        return 'Actitud';
    }
  }

  // Helper para obtener tiempo relativo
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months ${months == 1 ? 'mes' : 'meses'}';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'Ahora mismo';
    }
  }
}
