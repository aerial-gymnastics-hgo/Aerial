import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'user_service.dart';
import 'i_auth_service.dart';

class AuthService implements IAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final UserService _userService = UserService();

  String? _lastErrorMessage;
  String? get lastErrorMessage => _lastErrorMessage;

  // ---------- Mapeo de errores ----------
  String _mapErrorCode(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Credenciales incorrectas';
      case 'email-already-in-use':
        return 'El correo ya está registrado';
      case 'too-many-requests':
        return 'Demasiados intentos, intente más tarde';
      default:
        return 'Error de autenticación: $code';
    }
  }

  // ---------- Login ----------
  @override
  Future<User?> login(String email, String password) async {
    print('DEBUG: Intentando login para: $email');

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        print('DEBUG: FirebaseUser es null después de signIn');
        return null;
      }
      print('DEBUG: Login exitoso en Firebase Auth. UID: ${firebaseUser.uid}');

      // Intentar obtener rol desde Custom Claims
      String? roleFromClaim;
      try {
        final idTokenResult = await firebaseUser.getIdTokenResult(true);
        roleFromClaim = idTokenResult.claims?['role'] as String?;
        if (roleFromClaim != null) {
          print('DEBUG: Rol obtenido de Claims: $roleFromClaim');
        }
      } catch (e) {
        print('DEBUG: Error al obtener Claims: $e');
      }

      User? userProfile;
      if (roleFromClaim != null) {
        userProfile = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? email,
          role: UserRole.values.firstWhere((r) => r.name == roleFromClaim,
              orElse: () => UserRole.viewer),
          photoUrl: firebaseUser.photoURL,
          associatedStudentId: null,
          colorHex: null,
          password: '',
        );
      } else {
        print('DEBUG: Buscando perfil en Firestore para UID: ${firebaseUser.uid}');
        // Fallback a Firestore para obtener perfil completo
        userProfile = await _userService.getUserProfile(
            firebaseUser.uid, firebaseUser.email ?? email);
        if (userProfile == null) {
          print('DEBUG: No se encontró perfil en Firestore para el UID proporcionado.');
          _lastErrorMessage = 'Perfil de usuario no encontrado en la base de datos.';
        } else {
          print('DEBUG: Perfil cargado desde Firestore. Rol: ${userProfile.role}');
        }
      }

      if (userProfile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userProfile.id);
      }

      _lastErrorMessage = null;
      return userProfile;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _lastErrorMessage = _mapErrorCode(e.code);
      print('DEBUG: FirebaseAuthException: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      _lastErrorMessage = 'Error inesperado: $e';
      print('DEBUG: Error desconocido en login: $e');
      return null;
    }
  }

  // ---------- Logout ----------
  @override
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    // No eliminamos userRole (ya no se guarda)
  }

  // ---------- Check Session ----------
  @override
  Future<User?> checkSession() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        // Intentar obtener rol desde Custom Claims
        String? roleFromClaim;
        try {
          final idTokenResult = await firebaseUser.getIdTokenResult(true);
          roleFromClaim = idTokenResult.claims?['role'] as String?;
        } catch (_) {}

        if (roleFromClaim != null) {
          return User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
            role: UserRole.values.firstWhere((r) => r.name == roleFromClaim,
                orElse: () => UserRole.viewer),
            photoUrl: firebaseUser.photoURL,
            associatedStudentId: null,
            colorHex: null,
            password: '',
          );
        }
        // Fallback a Firestore
        return await _userService.getUserProfile(
            firebaseUser.uid, firebaseUser.email ?? '');
      } else {
        // No hay sesión en Firebase, limpiar prefs si existían
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getString('userId') != null) {
          await logout();
        }
      }
    } catch (e) {
      print('AuthService: Error al comprobar sesión: $e');
    }
    return null;
  }
}
