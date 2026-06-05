import '../models/user_model.dart';

abstract class IAuthService {
  /// Inicia sesión con email y password.
  /// Devuelve el modelo de usuario o null si falla.
  Future<User?> login(String email, String password);

  /// Cierra la sesión actual.
  Future<void> logout();

  /// Comprueba si hay una sesión activa y devuelve el usuario.
  Future<User?> checkSession();

  // /// (Opcional) Registra un nuevo usuario.
  // Future<User?> register(String email, String password, UserRole role);
}
