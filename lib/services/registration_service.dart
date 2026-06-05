import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user_model.dart';
import 'storage_service.dart';

class RegistrationService {
  /// Genera contraseña temporal: primeras 4 letras del nombre + año de nacimiento
  static String generatePassword(String studentName, DateTime birthDate) {
    final namePart = studentName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z]'), '')
        .substring(
            0,
            studentName.replaceAll(RegExp(r'[^a-zA-Z]'), '').length >= 4
                ? 4
                : studentName.replaceAll(RegExp(r'[^a-zA-Z]'), '').length);
    final yearPart = birthDate.year.toString();
    return '$namePart$yearPart';
  }

  /// Sanitiza texto para generar emails
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

  /// Registra una nueva alumna y su tutor. Retorna un Map con las credenciales generadas.
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
    // 1. Preparar emails y passwords
    final studentEmail =
        '${_sanitize(studentName).replaceAll('_', '.')}@aerial.com';
    final parentEmail = tutorEmail.isNotEmpty
        ? tutorEmail
        : 'familia.${_sanitize(studentName).replaceAll('_', '.')}@aerial.com';

    final studentPassword = generatePassword(studentName, birthDate);
    final parentPassword = generatePassword(tutorName, birthDate);

    final firebaseAuth = fb_auth.FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;

    fb_auth.UserCredential? studentCred;
    String? finalPhotoUrl = photoUrl;
    bool photoUploaded = false;
    String? studentUid;

    try {
      // 2. Crear cuenta de estudiante en Auth
      studentCred = await firebaseAuth.createUserWithEmailAndPassword(
        email: studentEmail,
        password: studentPassword,
      );
      studentUid = studentCred.user!.uid;

      // 2.1 Subir foto si existen bytes (Fase 3)
      if (photoBytes != null) {
        try {
          finalPhotoUrl = await StorageService.uploadProfileImage(
            uid: studentUid,
            bytes: photoBytes,
            isStudent: true,
          );
          photoUploaded = true;
        } catch (e) {
          // Si el Storage falla, el registro continúa con la URL default/fallback
          print('Error al subir foto (continuando registro): $e');
        }
      }

      // 3. Crear cuenta de tutor en Auth
      final parentCred = await firebaseAuth.createUserWithEmailAndPassword(
        email: parentEmail,
        password: parentPassword,
      );
      final parentUid = parentCred.user!.uid;

      // 4. Crear modelos User (solo en memoria) usando los Auth UIDs
      final student = User(
        id: studentUid,
        name: studentName,
        email: studentEmail,
        role: UserRole.student,
        group: group,
        password: studentPassword, // Mantenido solo en memoria
        birthDate: birthDate,
        photoUrl: finalPhotoUrl ?? 'https://i.pravatar.cc/150?u=$studentUid',
        joinDate: DateTime.now(),
      );

      final parent = User(
        id: parentUid,
        name: 'Familia ${_extractSurnames(studentName)}',
        email: parentEmail,
        role: UserRole.parent,
        associatedStudentId: studentUid,
        password: parentPassword, // Mantenido solo en memoria
        emergencyContact: tutorPhone,
      );

      // 5. Escribir a Firestore usando WriteBatch
      final batch = db.batch();

      // Mapeos limpios (sin "password") directamente aquí
      final studentMap = {
        'name': student.name,
        'email': student.email,
        'role': student.role.name,
        'group': student.group,
        'photoUrl': student.photoUrl,
        'birthDate': student.birthDate != null
            ? Timestamp.fromDate(student.birthDate!)
            : null,
        'joinDate': student.joinDate != null
            ? Timestamp.fromDate(student.joinDate!)
            : null,
        'parentEmail': parentEmail,
      };

      final parentMap = {
        'name': parent.name,
        'email': parent.email,
        'role': parent.role.name,
        'associatedStudentId': parent.associatedStudentId,
        'emergencyContact': parent.emergencyContact,
      };

      // Doc en colección 'users' para student
      batch.set(db.collection('users').doc(studentUid), studentMap);

      // Doc en colección 'users' para parent
      batch.set(db.collection('users').doc(parentUid), parentMap);

      await batch.commit();

      // 6. Retornar resumen
      return {
        'student': student,
        'parent': parent,
        'studentPassword': studentPassword,
        'parentPassword': parentPassword,
      };
    } catch (e) {
      // 7. Rollback: limpiar cuenta auth student e imagen si se crearon
      if (studentUid != null) {
        try {
          // Limpiar archivo de Storage si se subió
          if (photoUploaded) {
            await StorageService.deleteProfileImage(uid: studentUid, isStudent: true);
          }

          // Re-auth como estudiante para luego borrar su cuenta (necesario sin admin SDK)
          await firebaseAuth.signInWithEmailAndPassword(
            email: studentEmail,
            password: studentPassword,
          );
          await firebaseAuth.currentUser?.delete();
        } catch (_) {
          // Ignoramos errores de rollback para no enmascarar el error original
        }
      }
      rethrow;
    }
  }
}
