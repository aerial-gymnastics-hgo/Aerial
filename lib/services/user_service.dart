import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Obtiene los datos del perfil de un usuario desde Firestore.
  /// En la Fase 1, si el usuario no existe en la base de datos de producción, 
  /// puede buscar en el MOCK como mecanismo de seguridad (fallback) para que no truene.
  Future<User?> getUserProfile(String uid, String email) async {
    print('DEBUG: Consultando Firestore colección "users" documento: $uid');
    try {
      final doc = await _db.collection('users').doc(uid).get();

      if (doc.exists) {
        print('DEBUG: Documento encontrado en Firestore.');
        final data = doc.data() as Map<String, dynamic>;
        
        // Conversión segura del rol almacenado
        UserRole role = UserRole.viewer;
        final String dbRole = data['role'] ?? 'viewer';
        print('DEBUG: Rol en DB: $dbRole');
        
        if (dbRole == 'admin') role = UserRole.admin;
        if (dbRole == 'coach') role = UserRole.coach;
        if (dbRole == 'parent') role = UserRole.parent;
        if (dbRole == 'student') role = UserRole.student;
        if (dbRole == 'caja') role = UserRole.caja;

        return User(
          id: uid,
          name: data['name'] ?? 'Usuario',
          email: email,
          role: role,
          group: data['group'] ?? 'General',
          photoUrl: data['photoUrl'],
          associatedStudentId: data['associatedStudentId'],
          colorHex: data['colorHex'],
          password: '',
        );
      } else {
        print('DEBUG: El documento NO existe en la colección "users".');
        return null;
      }
    } catch (e) {
      print('DEBUG: Error en getUserProfile: $e');
      return null;
    }
  }

  /// Crea o actualiza un registro de base en Firestore (Ej: tras registrarse)
  Future<void> createUserProfile(User user) async {
    try {
      await _db.collection('users').doc(user.id).set({
        'name': user.name,
        'email': user.email,
        'role': user.role.name,
        'group': user.group,
        'photoUrl': user.photoUrl,
        'associatedStudentId': user.associatedStudentId,
        'colorHex': user.colorHex,
        // Evitamos guardar password en texto plano. Firebase Auth de encarga.
      });
    } catch (e) {
      print('UserService Error (Create): $e');
    }
  }
}
