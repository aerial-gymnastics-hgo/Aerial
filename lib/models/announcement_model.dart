class Announcement {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final String targetRole; // 'all', 'coach', 'parent', 'student'

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.targetRole,
  });

  // Helper para determinar si es urgente (dirigido a todos)
  bool get isUrgent => targetRole == 'all';

  // Helper para obtener el emoji según el target
  String get targetEmoji {
    switch (targetRole) {
      case 'coach':
        return '👨‍🏫';
      case 'parent':
        return '👨‍👩‍👧';
      case 'student':
        return '🤸‍♀️';
      case 'all':
        return '📢';
      default:
        return '📋';
    }
  }

  // Helper para obtener el texto del target
  String get targetText {
    switch (targetRole) {
      case 'coach':
        return 'Entrenadores';
      case 'parent':
        return 'Padres';
      case 'student':
        return 'Alumnas';
      case 'all':
        return 'Todos';
      default:
        return 'General';
    }
  }
}
