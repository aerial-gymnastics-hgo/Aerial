import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/verano_inscripcion.dart';

class VeranoInscripcionScreen extends StatefulWidget {
  const VeranoInscripcionScreen({super.key});

  @override
  State<VeranoInscripcionScreen> createState() => _VeranoInscripcionScreenState();
}

class _VeranoInscripcionScreenState extends State<VeranoInscripcionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreAlumnaCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  final _nombreTutorCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _grupoSeleccionado = 'mexico';
  String _modalidadSeleccionada = '1semana';
  bool _esAlumnaExistente = false;
  bool _enviando = false;

  @override
  void dispose() {
    _nombreAlumnaCtrl.dispose();
    _edadCtrl.dispose();
    _nombreTutorCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Inscripción · Verano 2026',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _label('Datos de la alumna'),
                _campo(
                  _nombreAlumnaCtrl,
                  'Nombre completo',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                ),
                _campo(
                  _edadCtrl,
                  'Edad',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final edad = int.tryParse(v ?? '');
                    if (edad == null) return 'Ingresa un número válido';
                    if (edad < 4 || edad > 18) return 'La edad debe estar entre 4 y 18 años';
                    return null;
                  },
                ),
                _label('Grupo'),
                DropdownButtonFormField<String>(
                  initialValue: _grupoSeleccionado,
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF6B2FA0), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'mexico', child: Text('🇲🇽 México · 4 a 6 años')),
                    DropdownMenuItem(value: 'inglaterra', child: Text('🏴󠁧󠁢󠁥󠁮󠁧󠁿 Inglaterra · 7 a 9 años')),
                    DropdownMenuItem(value: 'portugal', child: Text('🇵🇹 Portugal · 10 a 13 años')),
                    DropdownMenuItem(value: 'noruega', child: Text('🇳🇴 Noruega · Competitivo USAG')),
                  ],
                  onChanged: (v) => setState(() => _grupoSeleccionado = v!),
                ),
                _label('Modalidad'),
                Row(
                  children: [
                    Expanded(child: _modalidadCard('1semana', '1 semana\n\$1,750')),
                    const SizedBox(width: 8),
                    Expanded(child: _modalidadCard('4semanas', '4 semanas\n\$6,200')),
                  ],
                ),
                _label('Datos del tutor'),
                _campo(
                  _nombreTutorCtrl,
                  'Nombre del tutor o tutora',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                ),
                _campo(
                  _telefonoCtrl,
                  'WhatsApp del tutor',
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 10) return 'Ingresa un teléfono válido (mínimo 10 dígitos)';
                    return null;
                  },
                ),
                _campo(
                  _emailCtrl,
                  'Correo electrónico (opcional)',
                  required: false,
                ),
                SwitchListTile(
                  title: const Text('Ya soy alumna del gimnasio', style: TextStyle(fontSize: 13)),
                  subtitle: const Text(
                    'Vincular con mi cuenta existente',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  value: _esAlumnaExistente,
                  onChanged: (v) => setState(() => _esAlumnaExistente = v),
                  activeThumbColor: const Color(0xFF2D1060),
                  tileColor: Colors.grey[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _enviando ? null : _enviar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D1060),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(_enviando ? 'Enviando...' : 'Confirmar inscripción'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modalidadCard(String valor, String texto) {
    final activo = _modalidadSeleccionada == valor;
    final lineas = texto.split('\n');
    final color = activo ? const Color(0xFF2D1060) : Colors.black;
    return GestureDetector(
      onTap: () => setState(() => _modalidadSeleccionada = valor),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: activo ? const Color(0xFF2D1060) : Colors.grey,
            width: activo ? 2 : 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              lineas[0],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
            ),
            Text(
              lineas[1],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B2FA0),
          ),
        ),
      );

  Widget _campo(
    TextEditingController ctrl,
    String hint, {
    TextInputType? keyboardType,
    bool required = true,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF6B2FA0), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          validator: validator,
        ),
      );

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      final inscripcion = VeranoInscripcion(
        nombreAlumna: _nombreAlumnaCtrl.text.trim(),
        edad: int.parse(_edadCtrl.text.trim()),
        grupo: _grupoSeleccionado,
        modalidad: _modalidadSeleccionada,
        nombreTutor: _nombreTutorCtrl.text.trim(),
        telefonoTutor: _telefonoCtrl.text.trim(),
        emailTutor: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        esAlumnaExistente: _esAlumnaExistente,
      );
      final doc = await FirebaseFirestore.instance
          .collection('verano_inscripciones')
          .add(inscripcion.toFirestore());
      await _enviarConfirmacionWhatsApp(inscripcion, doc.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Inscripción enviada! Te contactaremos por WhatsApp.'),
            backgroundColor: Color(0xFF25D366),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _enviarConfirmacionWhatsApp(VeranoInscripcion i, String docId) async {
    final grupos = {
      'mexico': 'México (4–6 años)',
      'inglaterra': 'Inglaterra (7–9 años)',
      'portugal': 'Portugal (10–13 años)',
      'noruega': 'Noruega (Competitivo USAG)',
    };
    final modalidades = {
      '1semana': '1 semana · \$1,750',
      '4semanas': '4 semanas · \$6,200',
    };
    final mensaje = Uri.encodeComponent(
      '¡Hola! Acabo de inscribir a *${i.nombreAlumna}* al Verano Especializado en Gimnasia 2026.\n\n'
      '📋 *Resumen:*\n'
      '• Grupo: ${grupos[i.grupo]}\n'
      '• Modalidad: ${modalidades[i.modalidad]}\n'
      '• Tutor/a: ${i.nombreTutor}\n'
      '• Folio: $docId\n\n'
      '¿Cuáles son los siguientes pasos para confirmar el lugar?'
    );
    final uri = Uri.parse('https://wa.me/527711897104?text=$mensaje');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
