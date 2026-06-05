import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube una imagen de perfil y retorna la URL de descarga.
  /// La ruta sigue la estructura: profiles/students/{uid}.jpg o profiles/coaches/{uid}.jpg
  static Future<String> uploadProfileImage({
    required String uid,
    required Uint8List bytes,
    bool isStudent = true,
  }) async {
    final rolePath = isStudent ? 'students' : 'coaches';
    final path = 'profiles/$rolePath/$uid.jpg';
    final ref = _storage.ref().child(path);

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'uid': uid},
    );

    // Subir bytes
    await ref.putData(bytes, metadata);

    // Obtener y retornar la URL pública
    return await ref.getDownloadURL();
  }

  /// Elimina una imagen de perfil. Útil para procesos de rollback.
  static Future<void> deleteProfileImage({
    required String uid,
    bool isStudent = true,
  }) async {
    final rolePath = isStudent ? 'students' : 'coaches';
    final path = 'profiles/$rolePath/$uid.jpg';
    final ref = _storage.ref().child(path);

    try {
      await ref.delete();
    } catch (e) {
      // En rollback no queremos frenar por un error de borrado si el archivo no existe
      print('StorageService Error (delete): $e');
    }
  }
}
