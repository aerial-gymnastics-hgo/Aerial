import 'package:cloud_firestore/cloud_firestore.dart';

class VeranoInscripcion {
  final String? id;
  final String nombreAlumna;
  final int edad;
  final String grupo; // 'mexico' | 'inglaterra' | 'portugal' | 'noruega'
  final String modalidad; // '1semana' | '4semanas'
  final String nombreTutor;
  final String telefonoTutor;
  final String? emailTutor;
  final bool esAlumnaExistente;
  final String? idAlumnaExistente;
  final DateTime fechaInscripcion;
  final String estatus; // 'pendiente' | 'confirmada' | 'cancelada'

  VeranoInscripcion({
    this.id,
    required this.nombreAlumna,
    required this.edad,
    required this.grupo,
    required this.modalidad,
    required this.nombreTutor,
    required this.telefonoTutor,
    this.emailTutor,
    required this.esAlumnaExistente,
    this.idAlumnaExistente,
    DateTime? fechaInscripcion,
    this.estatus = 'pendiente',
  }) : fechaInscripcion = fechaInscripcion ?? DateTime.now();

  factory VeranoInscripcion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VeranoInscripcion(
      id: doc.id,
      nombreAlumna: data['nombreAlumna'] ?? '',
      edad: data['edad'] ?? 0,
      grupo: data['grupo'] ?? '',
      modalidad: data['modalidad'] ?? '',
      nombreTutor: data['nombreTutor'] ?? '',
      telefonoTutor: data['telefonoTutor'] ?? '',
      emailTutor: data['emailTutor'],
      esAlumnaExistente: data['esAlumnaExistente'] ?? false,
      idAlumnaExistente: data['idAlumnaExistente'],
      fechaInscripcion: (data['fechaInscripcion'] as Timestamp).toDate(),
      estatus: data['estatus'] ?? 'pendiente',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombreAlumna': nombreAlumna,
      'edad': edad,
      'grupo': grupo,
      'modalidad': modalidad,
      'nombreTutor': nombreTutor,
      'telefonoTutor': telefonoTutor,
      'emailTutor': emailTutor,
      'esAlumnaExistente': esAlumnaExistente,
      'idAlumnaExistente': idAlumnaExistente,
      'fechaInscripcion': Timestamp.fromDate(fechaInscripcion),
      'estatus': estatus,
    };
  }
}
