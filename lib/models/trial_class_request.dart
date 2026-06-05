import 'package:cloud_firestore/cloud_firestore.dart';

class TrialClassRequest {
  final String id;
  final String studentName;
  final String studentAge; // "5 años 6 meses"
  final DateTime birthDate;
  final String parentName;
  final String parentPhone;
  final String parentEmail;
  final String selectedGroup;
  final DateTime trialDate; // Fecha de la clase muestra
  final String dayOfWeek; // "Miércoles" o "Jueves"

  // Información adicional
  final bool hasGymnasticsExperience;
  final String experienceDetails;
  final bool hasMedicalConditions;
  final String medicalDetails;
  final bool practicesSports;
  final String sportsDetails;
  final bool isFirstSport;
  final String behaviorNotes;

  // NUEVOS CAMPOS:
  final bool hasUSAGLevel;
  final String usagLevelDetails;
  final bool hasOtherGymnasticsExperience;
  final String otherGymnasticsDetails;

  // Estado
  final String status; // "pending", "confirmed", "completed", "cancelled"
  final DateTime createdAt;
  final DateTime? confirmedAt;

  TrialClassRequest({
    required this.id,
    required this.studentName,
    required this.studentAge,
    required this.birthDate,
    required this.parentName,
    required this.parentPhone,
    required this.parentEmail,
    required this.selectedGroup,
    required this.trialDate,
    required this.dayOfWeek,
    this.hasGymnasticsExperience = false,
    this.experienceDetails = '',
    this.hasMedicalConditions = false,
    this.medicalDetails = '',
    this.practicesSports = false,
    this.sportsDetails = '',
    this.isFirstSport = true,
    this.behaviorNotes = '',
    
    // NUEVOS PARÁMETROS:
    this.hasUSAGLevel = false,
    this.usagLevelDetails = '',
    this.hasOtherGymnasticsExperience = false,
    this.otherGymnasticsDetails = '',
    
    this.status = 'pending',
    required this.createdAt,
    this.confirmedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'studentAge': studentAge,
      'birthDate': Timestamp.fromDate(birthDate),
      'parentName': parentName,
      'parentPhone': parentPhone,
      'parentEmail': parentEmail,
      'selectedGroup': selectedGroup,
      'trialDate': Timestamp.fromDate(trialDate),
      'dayOfWeek': dayOfWeek,
      'hasGymnasticsExperience': hasGymnasticsExperience,
      'experienceDetails': experienceDetails,
      'hasMedicalConditions': hasMedicalConditions,
      'medicalDetails': medicalDetails,
      'practicesSports': practicesSports,
      'sportsDetails': sportsDetails,
      'isFirstSport': isFirstSport,
      'behaviorNotes': behaviorNotes,
      
      // NUEVOS CAMPOS:
      'hasUSAGLevel': hasUSAGLevel,
      'usagLevelDetails': usagLevelDetails,
      'hasOtherGymnasticsExperience': hasOtherGymnasticsExperience,
      'otherGymnasticsDetails': otherGymnasticsDetails,
      
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'confirmedAt':
          confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
    };
  }

  factory TrialClassRequest.fromJson(Map<String, dynamic> json, String id) {
    return TrialClassRequest(
      id: id,
      studentName: json['studentName'] ?? '',
      studentAge: json['studentAge'] ?? '',
      birthDate: (json['birthDate'] as Timestamp).toDate(),
      parentName: json['parentName'] ?? '',
      parentPhone: json['parentPhone'] ?? '',
      parentEmail: json['parentEmail'] ?? '',
      selectedGroup: json['selectedGroup'] ?? '',
      trialDate: (json['trialDate'] as Timestamp).toDate(),
      dayOfWeek: json['dayOfWeek'] ?? '',
      hasGymnasticsExperience: json['hasGymnasticsExperience'] ?? false,
      experienceDetails: json['experienceDetails'] ?? '',
      hasMedicalConditions: json['hasMedicalConditions'] ?? false,
      medicalDetails: json['medicalDetails'] ?? '',
      practicesSports: json['practicesSports'] ?? false,
      sportsDetails: json['sportsDetails'] ?? '',
      isFirstSport: json['isFirstSport'] ?? true,
      behaviorNotes: json['behaviorNotes'] ?? '',
      
      // NUEVOS CAMPOS:
      hasUSAGLevel: json['hasUSAGLevel'] ?? false,
      usagLevelDetails: json['usagLevelDetails'] ?? '',
      hasOtherGymnasticsExperience: json['hasOtherGymnasticsExperience'] ?? false,
      otherGymnasticsDetails: json['otherGymnasticsDetails'] ?? '',
      
      status: json['status'] ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      confirmedAt: json['confirmedAt'] != null
          ? (json['confirmedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
