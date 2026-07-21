import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/verano_inscripcion.dart';

class VeranoAccesoScreen extends StatefulWidget {
  const VeranoAccesoScreen({super.key});

  @override
  State<VeranoAccesoScreen> createState() => _VeranoAccesoScreenState();
}

class _VeranoAccesoScreenState extends State<VeranoAccesoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _folioCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _folioCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/images/aerial_logo.webp',
                  height: 56,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Acceso para familias',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ingresa el folio que recibiste por WhatsApp al inscribirte.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _campo(
                      _folioCtrl,
                      'Folio de inscripción',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Campo requerido';
                        if (v.trim().length < 6) return 'El folio debe tener al menos 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _campo(
                      _telefonoCtrl,
                      'WhatsApp del tutor (10 dígitos)',
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        final digits = (v ?? '').trim();
                        if (!RegExp(r'^\d{10}$').hasMatch(digits)) {
                          return 'Ingresa exactamente 10 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _verificar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D1060),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(_cargando ? 'Verificando...' : 'Entrar'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/verano/inscripcion'),
                        child: const Text(
                          '¿No tienes folio? Inscríbete aquí',
                          style: TextStyle(color: Color(0xFF6B2FA0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController ctrl,
    String hint, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          validator: validator,
        ),
      );

  Future<void> _verificar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final folio = _folioCtrl.text.trim().toUpperCase();
      final telefono = _telefonoCtrl.text.trim();
      final query = await FirebaseFirestore.instance
          .collection('verano_inscripciones')
          .where(FieldPath.documentId, isEqualTo: folio)
          .where('telefonoTutor', isEqualTo: telefono)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        setState(() => _error = 'Folio o teléfono incorrectos. Verifica los datos e intenta de nuevo.');
      } else {
        final inscripcion = VeranoInscripcion.fromFirestore(query.docs.first);
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/verano/portal',
            arguments: inscripcion,
          );
        }
      }
    } catch (e) {
      setState(() => _error = 'Error de conexión. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }
}
