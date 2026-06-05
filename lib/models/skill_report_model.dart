// Clase que representa la evaluación mensual de habilidades
class SkillReport {
  final String id;
  final String studentId; // ID de la alumna evaluada
  final String month;     // Mes de la evaluación (ej. "Noviembre 2025")
  
  // Mapa de habilidades: Nombre de la habilidad -> Puntuación (0-2)
  // 0: Necesita mejorar, 1: En proceso, 2: Dominado
  final Map<String, int> skills; 
  
  final String comment; // Comentario general del entrenador

  SkillReport({
    required this.id,
    required this.studentId,
    required this.month,
    required this.skills,
    required this.comment,
  });
}
