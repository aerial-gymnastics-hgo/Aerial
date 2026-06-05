// Definición de roles de usuario disponibles en el sistema
enum UserRole {
  admin,    // Administrador del sistema
  coach,    // Entrenador
  parent,   // Padre/Madre de familia
  student,  // Alumna
  caja,     // Nuevo: Rol de caja/cobros
  viewer,   // Lector o visualizador sin permisos de edición
}

// Clase que representa a un usuario del sistema
class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? associatedStudentId; // ID de la hija asociada (solo para padres)
  final String? photoUrl; // URL de la foto de perfil
  final String group; // Nuevo campo para el grupo (ej: "Nivel 3")
  final String password; // Contraseña del usuario
  final DateTime? joinDate; // Fecha de inscripción
  final String? phone;
  final String? emergencyContact;
  final String? allergies;
  final DateTime? birthDate;
  final int? colorHex;
  final String? paymentStatus;
  final DateTime? nextPaymentDate;
  final double? monthlyFee;
  String? monthlyObjective;

  // Campos de Seguro
  final String? insuranceProvider;
  final String? insurancePolicyNumber;
  final DateTime? insuranceExpiryDate;

  // Campos de Tutor
  final String? guardianName;
  final String? guardianPhone;
  final String? guardianPhoneSecondary;
  final String? guardianEmail;
  final String? guardianRelationship;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.associatedStudentId,
    this.photoUrl,
    this.group = 'General',
    this.password = '123456',
    this.joinDate,
    this.phone,
    this.emergencyContact,
    this.allergies,
    this.birthDate,
    this.colorHex,
    this.paymentStatus,
    this.nextPaymentDate,
    this.monthlyFee,
    this.monthlyObjective,
    this.insuranceProvider,
    this.insurancePolicyNumber,
    this.insuranceExpiryDate,
    this.guardianName,
    this.guardianPhone,
    this.guardianPhoneSecondary,
    this.guardianEmail,
    this.guardianRelationship,
  });
}
