import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Landing page pública del Verano Especializado en Gimnasia 2026.
/// No requiere autenticación.
class VeranoLandingScreen extends StatelessWidget {
  const VeranoLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            _buildUrgency(),
            _buildPricing(),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildGroups(context),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildComplementary(),
            _buildContact(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.52,
      ),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: const BoxDecoration(
        color: Color(0xFF2D1060),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INSTITUTO',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFFD4B8F0),
                    ),
                  ),
                  Text(
                    'Cedrus',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/login'),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0x33FFFFFF)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline, color: Color(0xCCFFFFFF), size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Iniciar sesión',
                        style: TextStyle(fontSize: 10, color: Color(0xCCFFFFFF)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Center(
            child: Column(
              children: [
                Text(
                  'AERIAL',
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  'GYMNASTICS',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFD4B8F0),
                    letterSpacing: 4.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E8C),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'TRAINING CAMP · VERANO 2026',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: 'Verano ',
                style: TextStyle(
                  fontSize: 21,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                children: [
                  TextSpan(
                    text: 'especializado',
                    style: TextStyle(color: Color(0xFFF472B6)),
                  ),
                  TextSpan(text: '\nen Gimnasia'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              '4 semanas · 8 disciplinas · todos los niveles',
              style: TextStyle(fontSize: 11, color: Color(0xFFD4B8F0)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined, color: Color(0xFFF472B6), size: 14),
                  SizedBox(width: 6),
                  Text(
                    '20 julio — 14 agosto · 9:00–14:30 hrs',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/verano/inscripcion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Inscribirse ahora',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgency() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFEF3C7),
        border: Border(
          left: BorderSide(color: Color(0xFFF59E0B), width: 3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: const TextSpan(
                text: 'El curso ya comenzó. ',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF92400E),
                ),
                children: [
                  TextSpan(
                    text: 'Puedes incorporarte con inscripción semanal desde \$1,750.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricing() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'INVERSIÓN',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.2,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D1060),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0x33F472B6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Recomendado',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFFF472B6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '\$6,200',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        '4 semanas',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFD4B8F0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Flexible',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF1D4ED8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '\$1,750',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF1D1D1D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'por semana',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Incluye kit · box lunch diario · sesiones especiales · control técnico final',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroups(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GRUPOS POR EDAD Y NIVEL',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.2,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _groupCard('🇲🇽', 'México · 4 a 6 años', 'Exploración y psicomotricidad', const Color(0xFFFDE68A)),
          const SizedBox(height: 7),
          _groupCard('🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'Inglaterra · 7 a 9 años', 'Técnica base y fuerza', const Color(0xFFBBF7D0)),
          const SizedBox(height: 7),
          _groupCard('🇵🇹', 'Portugal · 10 a 13 años', 'Potencia y expresión coreográfica', const Color(0xFFBFDBFE)),
          const SizedBox(height: 7),
          _groupCard('🇳🇴', 'Noruega · Competitivo USAG 3–6', 'Precisión técnica y jueceo', const Color(0xFFF5D0FE)),
        ],
      ),
    );
  }

  Widget _groupCard(String flag, String name, String meta, Color dotColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                flag,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  meta,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplementary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SESIONES COMPLEMENTARIAS',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.2,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 3.2,
            children: [
              _compItem(Icons.shield_outlined, 'Defensa personal'),
              _compItem(Icons.pool_outlined, 'Natación · viernes'),
              _compItem(Icons.self_improvement_outlined, 'Ballet aplicado'),
              _compItem(Icons.psychology_outlined, 'Psicología deportiva'),
              _compItem(Icons.emoji_events_outlined, 'Mini mundial'),
              _compItem(Icons.music_note_outlined, 'Breakdance'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compItem(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF6B2FA0)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContact(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '¿Lista para inscribirse?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => _launchWhatsApp(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.chat_rounded, size: 18),
            label: const Text(
              'Escríbenos por WhatsApp',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _launchPhone(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2D1060),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 11),
            ),
            icon: const Icon(Icons.phone_outlined, size: 16),
            label: const Text(
              '(771) 273 2403 · 771 699 0502',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Oficina de vinculación: 7711897104',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  void _launchWhatsApp() {
    final uri = Uri.parse('https://wa.me/527711897104');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _launchPhone() {
    final uri = Uri.parse('tel:7712732403');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
