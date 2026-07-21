import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/verano_inscripcion.dart';

class VeranoPortalScreen extends StatelessWidget {
  const VeranoPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! VeranoInscripcion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/verano/acceso');
      });
      return const Scaffold(backgroundColor: Colors.white, body: SizedBox.shrink());
    }
    final inscripcion = args;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: const Color(0xFF2D1060),
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hola,',
                            style: TextStyle(fontSize: 14, color: Color(0xFFD4B8F0)),
                          ),
                          Text(
                            inscripcion.nombreTutor.split(' ').first,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/verano',
                          (_) => false,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Salir',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoChip('Folio', inscripcion.id ?? '-'),
                        const SizedBox(width: 12),
                        _infoChip('Grupo', _nombreGrupo(inscripcion.grupo)),
                        const SizedBox(width: 12),
                        _infoChip(
                          'Modalidad',
                          inscripcion.modalidad == '4semanas' ? '4 sem.' : '1 sem.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE9D5FF)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5D0FE),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          inscripcion.nombreAlumna[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B2FA0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inscripcion.nombreAlumna,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            '${inscripcion.edad} años · ${_nombreGrupo(inscripcion.grupo)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _colorEstatus(inscripcion.estatus),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _textoEstatus(inscripcion.estatus),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _colorTextoEstatus(inscripcion.estatus),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles del curso',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.2,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _detalleRow(
                    Icons.calendar_today_outlined,
                    'Fechas',
                    '20 julio — 14 agosto 2026',
                  ),
                  _detalleRow(Icons.access_time_outlined, 'Horario', '9:00 a 14:30 hrs'),
                  _detalleRow(
                    Icons.location_on_outlined,
                    'Lugar',
                    'Instituto Cedrus, Pachuca',
                  ),
                  _detalleRow(Icons.phone_outlined, 'Contacto', '(771) 273 2403'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => _abrirWhatsApp(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 0),
                ),
                icon: const Icon(Icons.chat_rounded, color: Colors.white),
                label: const Text(
                  'Contactar al gimnasio',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirWhatsApp() async {
    final uri = Uri.parse('https://wa.me/527711897104');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _nombreGrupo(String grupo) {
    const grupos = {
      'mexico': 'México · 4–6 años',
      'inglaterra': 'Inglaterra · 7–9 años',
      'portugal': 'Portugal · 10–13 años',
      'noruega': 'Noruega · Competitivo',
    };
    return grupos[grupo] ?? grupo;
  }

  Color _colorEstatus(String estatus) {
    switch (estatus) {
      case 'confirmada':
        return const Color(0xFFD1FAE5);
      case 'cancelada':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  Color _colorTextoEstatus(String estatus) {
    switch (estatus) {
      case 'confirmada':
        return const Color(0xFF065F46);
      case 'cancelada':
        return const Color(0xFF991B1B);
      default:
        return const Color(0xFF92400E);
    }
  }

  String _textoEstatus(String estatus) {
    switch (estatus) {
      case 'confirmada':
        return 'Confirmada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return 'Pendiente de confirmación';
    }
  }

  Widget _infoChip(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFFD4B8F0),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );

  Widget _detalleRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6B2FA0)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
