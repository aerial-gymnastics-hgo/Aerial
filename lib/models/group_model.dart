class GymGroup {
  final String id; // El nombre del grupo (ej: "Oruguitas")
  final String shortCode;
  final String type; // "Formativo" o "Competitivo"
  final String ageRange;
  final String days;
  final String schedule;
  final double monthlyFee;
  final double inscriptionFee;
  final bool requiresTutor;
  final bool requiresFMG;
  final String description;
  final String dresscode;

   GymGroup({
    required this.id,
    required this.shortCode,
    required this.type,
    required this.ageRange,
    required this.days,
    required this.schedule,
    required this.monthlyFee,
    required this.inscriptionFee,
    required this.requiresTutor,
    required this.requiresFMG,
    required this.description,
    required this.dresscode,
  });

  factory GymGroup.fromFirestore(String id, Map<String, dynamic> data) {
    return GymGroup(
      id: id,
      shortCode: data['shortCode'] ?? '',
      type: data['type'] ?? 'Formativo',
      ageRange: data['ageRange'] ?? '',
      days: data['days'] ?? '',
      schedule: data['schedule'] ?? '',
      monthlyFee: (data['monthlyFee'] ?? 0).toDouble(),
      inscriptionFee: (data['inscriptionFee'] ?? 0).toDouble(),
      requiresTutor: data['requiresTutor'] ?? false,
      requiresFMG: data['requiresFMG'] ?? false,
      description: data['description'] ?? '',
      dresscode: data['dresscode'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'shortCode': shortCode,
      'type': type,
      'ageRange': ageRange,
      'days': days,
      'schedule': schedule,
      'monthlyFee': monthlyFee,
      'inscriptionFee': inscriptionFee,
      'requiresTutor': requiresTutor,
      'requiresFMG': requiresFMG,
      'description': description,
      'dresscode': dresscode,
    };
  }
}
