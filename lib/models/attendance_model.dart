// Estados posibles de asistencia
enum AttendanceStatus {
  presente,
  falta,
  retardo,
}

// Clase que representa el registro de asistencia de una alumna
class Attendance {
  final String id;
  final String studentId; // ID de la alumna
  final String coachId;   // ID del entrenador que tomó la asistencia
  final DateTime date;    // Fecha de la asistencia
  final AttendanceStatus status; // Estado de la asistencia

  Attendance({
    required this.id,
    required this.studentId,
    required this.coachId,
    required this.date,
    required this.status,
  });
}
