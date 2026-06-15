import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'storage_service.dart';

class RegistrationService {
  /// Genera contraseña temporal: primeras 4 letras del nombre + año de nacimiento
  static String generatePassword(String name, DateTime birthDate) {
    final namePart = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z]'), '')
        .substring(
            0,
            name.replaceAll(RegExp(r'[^a-zA-Z]'), '').length >= 4
                ? 4
                : name.replaceAll(RegExp(r'[^a-zA-Z]'), '').length);
    return '$namePart${birthDate.year}';
  }

  static String _sanitize(String text) => text
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[^a-z0-9]'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  static String _extractSurnames(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[parts.length - 2]} ${parts.last}';
    return parts.last;
  }

  /// Registra una nueva alumna y su tutor vía Cloud Function (admin no se desloguea).
  /// Retorna un Map con las credenciales generadas para mostrar al admin.
  static Future<Map<String, dynamic>> registerStudentAndParent({
    required String studentName,
    required DateTime birthDate,
    required String group,
    required String tutorName,
    required String tutorPhone,
    required String tutorEmail,
    Uint8List? photoBytes,
    String? photoUrl,
  }) async {
    // Generar credenciales client-side para mostrar al admin
    final studentEmail =
        '${_sanitize(studentName).replaceAll('_', '.')}@aerial.com';
    final parentEmail = tutorEmail.isNotEmpty
        ? tutorEmail
        : 'familia.${_sanitize(studentName).replaceAll('_', '.')}@aerial.com';

    final studentPassword = generatePassword(studentName, birthDate);
    final parentPassword = generatePassword(tutorName, birthDate);

    String? finalPhotoUrl = photoUrl;

    try {
      // Crear accounts vía Cloud Function: admin SDK no desloguea al usuario actual
      final fn = FirebaseFunctions.instance.httpsCallable('registerStudent');
      final result = await fn.call({
        'email': studentEmail,
        'password': studentPassword,
        'name': studentName,
        'groupId': group,
        'birthDate': birthDate.toIso8601String(),
        'phone': tutorPhone,
        'parentName': tutorName,
        'parentPhone': tutorPhone,
        'parentEmail': parentEmail,
      });

      final data = result.data as Map<dynamic, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Error en el servidor');
      }

      final studentUid = data['uid'] as String;

      // Subir foto si fue seleccionada
      if (photoBytes != null) {
        try {
          finalPhotoUrl = await StorageService.uploadProfileImage(
            uid: studentUid,
            bytes: photoBytes,
            isStudent: true,
          );
        } catch (_) {
          // Registro continúa sin foto
        }
      }

      return {
        'studentName': studentName,
        'studentEmail': studentEmail,
        'studentPassword': studentPassword,
        'parentName': 'Familia ${_extractSurnames(studentName)}',
        'parentEmail': parentEmail,
        'parentPassword': parentPassword,
      };
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Error al registrar alumna');
    }
  }
}
