import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/landing_page.dart';
import 'screens/verano/verano_landing_screen.dart';
import 'screens/verano/verano_inscripcion_screen.dart';
import 'services/auth_service.dart';
import 'services/navigation_service.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Error inicializando Firebase: $e');
  }

  try {
    await initializeDateFormatting('es_ES', null);
  } catch (e) {
    debugPrint('Error inicializando fechas: $e');
  }
  runApp(const GymManagerApp());
}

class GymManagerApp extends StatelessWidget {
  const GymManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymManager',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212), // Fondo base
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF7B1FA2),
          primary: const Color(0xFF7B1FA2),
          secondary: const Color(0xFFE91E63),
          surface: const Color(0xFF1E1E1E),
        ),
        cardTheme: CardThemeData(
          color: Colors.white10,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(bottom: 12),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B1FA2),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFE91E63),
            side: const BorderSide(color: Color(0xFFE91E63), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      home: const SessionCheck(),
      routes: {
        '/verano': (context) => const VeranoLandingScreen(),
        '/verano/inscripcion': (context) => const VeranoInscripcionScreen(),
      },
    );
  }
}

class SessionCheck extends StatefulWidget {
  const SessionCheck({super.key});

  @override
  State<SessionCheck> createState() => _SessionCheckState();
}

class _SessionCheckState extends State<SessionCheck> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    try {
      final authService = AuthService();
      final user = await authService.checkSession().timeout(const Duration(seconds: 3), onTimeout: () => null);

      if (!mounted) return;

      if (user != null) {
        NavigationService.navigateByRole(user, context);
      } else {
        _goToLanding();
      }
    } catch (e) {
      debugPrint('Error en checkSession: $e');
      _goToLanding();
    }
  }

  void _goToLanding() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LandingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
