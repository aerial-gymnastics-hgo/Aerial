import 'package:firebase_core/firebase_core.dart';
import 'populate_real_rotations.dart';

/// Script ejecutable para poblar rotaciones reales
/// 
/// IMPORTANTE: Este script borra TODAS las rotaciones existentes
/// y las reemplaza con los datos de las imágenes de WhatsApp.
/// 
/// Ejecutar con:
/// dart migration/run_migration.dart
void main() async {
  print('═══════════════════════════════════════════════════');
  print('  MIGRACIÓN DE ROTACIONES - Aerial Gymnastics');
  print('═══════════════════════════════════════════════════');
  print('');
  
  try {
    // Inicializar Firebase
    print('⚙️  Inicializando Firebase...');
    await Firebase.initializeApp();
    print('✓ Firebase inicializado');
    print('');
    
    // Ejecutar migración
    await PopulateRealRotations().execute();
    
    print('');
    print('═══════════════════════════════════════════════════');
    print('  ✅ MIGRACIÓN COMPLETADA EXITOSAMENTE');
    print('═══════════════════════════════════════════════════');
    
  } catch (e, stackTrace) {
    print('');
    print('═══════════════════════════════════════════════════');
    print('  ❌ ERROR EN MIGRACIÓN');
    print('═══════════════════════════════════════════════════');
    print('Error: $e');
    print('');
    print('Stack trace:');
    print(stackTrace);
  }
}
