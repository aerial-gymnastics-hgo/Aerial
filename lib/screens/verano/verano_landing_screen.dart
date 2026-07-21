import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Landing page pública del Verano Especializado en Gimnasia 2026.
/// No requiere autenticación.
class VeranoLandingScreen extends StatelessWidget {
  const VeranoLandingScreen({super.key});

  final List<String> _carouselImages = const [
    'assets/images/israel-lopez-othZ2kLqvb4-unsplash.jpg',
    'assets/images/brett-wharton-IW3_4JTH39o-unsplash.jpg',
    'assets/images/atiyeh-fathi-AI2wwbQPcSc-unsplash.jpg',
    'assets/images/vladimir-fedotov-vWE-czm8Ns0-unsplash.jpg',
  ];

  final List<String> _carouselTitles = const [
    'Confianza que se construye',
    'Grupos pequeños, atención real',
    'Disciplina que dura toda la vida',
    'Un verano que recordarán siempre',
  ];

  final List<String> _carouselSubs = const [
    'Cada habilidad nueva construye autoestima real y duradera.',
    'Máximo 8 alumnas por grupo, organizadas por edad y nivel.',
    'La gimnasia entrena el cerebro igual que el cuerpo.',
    'Más que un curso — una experiencia que las transforma.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            _buildUrgency(),
            _buildWhyGymnastics(),
            _buildGalleryCarousel(),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildPricing(),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildGroups(context),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildComplementary(),
            const Divider(height: 1, indent: 16, endIndent: 16),
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
              Image.asset(
                'assets/images/image-Photoroom.png',
                height: 28,
                fit: BoxFit.contain,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
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
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                'assets/images/aerial_logo.png',
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 8),
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
                  color: Color(0xFF78350F),
                ),
                children: [
                  TextSpan(
                    text: 'Puedes incorporarte con inscripción semanal desde \$1,750.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF78350F),
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
                    color: const Color(0xFFF5F3FF),
                    border: Border.all(color: const Color(0xFFE9D5FF)),
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

  Widget _buildWhyGymnastics() {
    return Container(
      color: const Color(0xFF1A0A3C),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No es solo deporte.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const Text(
            'Es desarrollo integral.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Color(0xFFF472B6),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'La gimnasia artística trabaja simultáneamente el cuerpo, la mente y el carácter. '
            'Mientras tu hija aprende a hacer una vertical o a caminar en viga, está desarrollando '
            'concentración, disciplina y confianza — habilidades que se transfieren directamente '
            'al salón de clases y a la vida.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFD4B8F0),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  '40%',
                  'más concentración en niños que practican deportes de precisión',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statCard(
                  '8',
                  'alumnas máximo por grupo — atención real e individualizada',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statCard(
                  '4',
                  'aparatos de gimnasia artística: salto, barras, viga y piso',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2D1060),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6B2FA0)),
            ),
            child: const Text(
              'Mientras la mayoría de los cursos de verano en Pachuca ofrecen recreación general, '
              'aquí cada semana tiene objetivos técnicos concretos adaptados a la edad y nivel de tu hija.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFE9D5FF),
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1060),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF472B6),
              )),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFFD4B8F0),
                height: 1.4,
              )),
        ],
      ),
    );
  }

  Widget _buildGalleryCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 0, 12),
          child: Text(
            'Por qué Aerial este verano',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.88),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Image.asset(
                        _carouselImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.65),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _carouselTitles[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _carouselSubs[index],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
