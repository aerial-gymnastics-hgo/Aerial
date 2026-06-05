import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../models/user_model.dart';
import 'landing_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isObscure = true;

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Por favor ingresa email y contraseña')));
      return;
    }
    setState(() => _isLoading = true);
    final user = await _authService.login(
        _emailController.text.trim(), _passwordController.text.trim());
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (user != null) {
      NavigationService.navigateByRole(user, context);
    } else {
      final errorMsg = _authService.lastErrorMessage ?? 'Credenciales incorrectas';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red));
    }
  }

  void _navigateToDashboard(User user) {
    NavigationService.navigateByRole(user, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/gimnasia_login.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.7), BlendMode.darken),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sports_gymnastics,
                          size: 80, color: Colors.white),
                      const SizedBox(height: 24),
                      Text('Bienvenido',
                          style: GoogleFonts.montserrat(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('Ingresa a tu cuenta',
                          style: GoogleFonts.poppins(color: Colors.white70)),
                      const SizedBox(height: 48),
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        style: const TextStyle(color: Colors.white),
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          suffixIcon: IconButton(
                            icon: Icon(
                                _isObscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white70),
                            onPressed: () =>
                                setState(() => _isObscure = !_isObscure),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text('Iniciar Sesión',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Volver al Inicio',
                            style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
