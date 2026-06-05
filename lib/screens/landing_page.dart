import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import '../widgets/trial_class_registration_form.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  
  // Keys para navegación de secciones
  final GlobalKey _gruposKey = GlobalKey();
  final GlobalKey _horariosKey = GlobalKey();
  final GlobalKey _costosKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  final GlobalKey _formularioKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildHeroSection(),
              _buildSobreNosotros(),
              _buildGruposYNiveles(),
              _buildGaleria(),
              _buildHorarios(),
              _buildCostos(),
              _buildBeneficios(),
              _buildInscripcion(),
              _buildReglamento(),
              _buildTestimonios(),
              _buildFAQ(),
              _buildFormularioClaseMuestra(),
              _buildFooter(),
            ]),
          ),
        ],
      ),
      floatingActionButton: _buildWhatsAppButton(),
    );
  }

  // ==================== NAVBAR ====================
  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 80,
      backgroundColor: const Color(0xFF1A1A2E),
      title: const Row(
        children: [
          Icon(Icons.stars, color: Color(0xFFE91E63), size: 28),
          SizedBox(width: 8),
          Text(
            'Gimnasio Aerial',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _scrollToSection(_gruposKey),
          child: const Text('Grupos', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => _scrollToSection(_horariosKey),
          child: const Text('Horarios', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => _scrollToSection(_costosKey),
          child: const Text('Costos', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => _scrollToSection(_faqKey),
          child: const Text('FAQ', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Iniciar Sesión'),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  void _scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // ==================== HERO SECTION ====================
  Widget _buildHeroSection() {
    return Container(
      height: 700,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=1920',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.stars,
                      size: 60,
                      color: Color(0xFFE91E63),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'AERIAL',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    Text(
                      'GYMNASTICS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'GIMNASIA ARTÍSTICA FEMENIL',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Desarrolla tu Potencial',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Gimnasio afiliado a CEDRUS',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _scrollToSection(_formularioKey),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('AGENDA TU CLASE MUESTRA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      elevation: 8,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _scrollToSection(_gruposKey),
                    icon: const Icon(Icons.groups),
                    label: const Text('VER GRUPOS'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SOBRE NOSOTROS ====================
  Widget _buildSobreNosotros() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SOBRE NOSOTROS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE91E63),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Excelencia en Gimnasia Artística',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Somos un gimnasio especializado en gimnasia artística femenil, '
                  'comprometidos con el desarrollo integral de nuestras gimnastas. '
                  'Contamos con entrenadores certificados por CEDRUS, instalaciones de primer nivel '
                  'y programas adaptados a cada edad y nivel de habilidad.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.8,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Nuestro enfoque combina técnica, disciplina y diversión para formar '
                  'gimnastas completas, preparadas tanto para competencias como para disfrutar '
                  'de este hermoso deporte.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.8,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    _buildStatCard('156+', 'Alumnas'),
                    _buildStatCard('9', 'Coaches'),
                    _buildStatCard('10', 'Grupos'),
                    _buildStatCard('5', 'Días/semana'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 60),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
                height: 500,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== GRUPOS Y NIVELES ====================
  Widget _buildGruposYNiveles() {
    return Container(
      key: _gruposKey,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          const Text(
            'NUESTROS GRUPOS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE91E63),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Encuentra tu Nivel Perfecto',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 48),
          
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _buildGrupoCardReal(
                titulo: 'ORUGUITAS',
                edades: '3-5 años',
                nivel: 'Iniciación',
                descripcion: 'Primer contacto con la gimnasia a través del juego',
                icono: Icons.child_care,
                color: const Color(0xFFFFB74D),
              ),
              _buildGrupoCardReal(
                titulo: 'ABEJITAS',
                edades: '6-7 años',
                nivel: 'Básico',
                descripcion: 'Desarrollo de habilidades básicas y coordinación',
                icono: Icons.sports_gymnastics,
                color: const Color(0xFFFFD54F),
              ),
              _buildGrupoCardReal(
                titulo: 'MARIPOSAS',
                edades: '8-9 años',
                nivel: 'Intermedio',
                descripcion: 'Perfeccionamiento técnico y preparación competitiva',
                icono: Icons.emoji_events,
                color: const Color(0xFF81C784),
              ),
              _buildGrupoCardReal(
                titulo: 'DRAGONAS',
                edades: '10-12 años',
                nivel: 'Avanzado',
                descripcion: 'Alto rendimiento y competencias nacionales',
                icono: Icons.military_tech,
                color: const Color(0xFFE91E63),
              ),
              _buildGrupoCardReal(
                titulo: 'LEONAS',
                edades: '13+ años',
                nivel: 'Élite',
                descripcion: 'Nivel competitivo profesional',
                icono: Icons.star,
                color: const Color(0xFF9C27B0),
              ),
              _buildGrupoCardReal(
                titulo: 'CONEJAS',
                edades: '7-13 años',
                nivel: 'Nivel 3',
                descripcion: 'Primer nivel competitivo. Introducción a rutinas y requerimientos de USAG/FMG.',
                icono: Icons.emoji_events,
                color: const Color(0xFFF48FB1),
              ),
              _buildGrupoCardReal(
                titulo: 'HALCONAS',
                edades: '9-16 años',
                nivel: 'Nivel 4/5',
                descripcion: 'Nivel competitivo avanzado. Ejecución de rutinas complejas y alto rendimiento.',
                icono: Icons.military_tech,
                color: const Color(0xFFCE93D8),
              ),
              _buildGrupoCardReal(
                titulo: 'ADULTOS / FITNESS',
                edades: '+18 años',
                nivel: 'Recreativo',
                descripcion: 'Fitness y acondicionamiento físico',
                icono: Icons.fitness_center,
                color: const Color(0xFF00BCD4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrupoCardReal({
    required String titulo,
    required String edades,
    required String nivel,
    required String descripcion,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.network(
                  _getImagenPorGrupo(titulo),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        color.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icono, size: 24, color: color),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (titulo == 'CONEJAS' || titulo == 'HALCONAS') ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.emoji_events, size: 16, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'GRUPO COMPETITIVO',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            titulo,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      edades,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        nivel,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (titulo == 'CONEJAS' || titulo == 'HALCONAS') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Requisitos de Ingreso',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Mínimo 1 mes en grupo de desarrollo\n'
                          '• Evaluación de coaches obligatoria\n'
                          '• Afiliación a federación (FMG/USAG)\n'
                          '• Compromiso de competencia',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getImagenPorGrupo(String titulo) {
    final imagenes = {
      'ORUGUITAS': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      'ABEJITAS': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
      'MARIPOSAS': 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800',
      'DRAGONAS': 'https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=800',
      'LEONAS': 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800',
      'ADULTOS / FITNESS': 'https://images.unsplash.com/photo-1513593771513-7b58b6c4af38?w=800',
      'PANTERAS 1 y 2': 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800',
      'TIGRESAS / X': 'https://images.unsplash.com/photo-1513593771513-7b58b6c4af38?w=800',
      'PANDITAS 1 y 2': 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800',
      'CONEJAS': 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800',
      'HALCONAS': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800',
      'LINCES': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
    };
    return imagenes[titulo] ?? 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800';
  }

  // ==================== GALERIA ====================
  Widget _buildGaleria() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'GALERÍA',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE91E63),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Momentos que Inspiran',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 48),
          
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildGaleriaItem('https://images.unsplash.com/photo-1518611012118-696072aa579a?w=600'),
              _buildGaleriaItem('https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600'),
              _buildGaleriaItem('https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=600'),
              _buildGaleriaItem('https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=600'),
              _buildGaleriaItem('https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=600'),
              _buildGaleriaItem('https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=600'),
              _buildGaleriaItem('https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=600'),
              _buildGaleriaItem('https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=600'),
            ],
          ),
          
          const SizedBox(height: 32),
          
          TextButton.icon(
            onPressed: () {
              // TODO: Ver galería completa
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('Ver galería completa'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE91E63),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaleriaItem(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== COSTOS ====================
  Widget _buildCostos() {
    return Container(
      key: _costosKey,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF9C27B0).withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'INVERSIÓN',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE91E63),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Planes y Mensualidades',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _buildPricingCard(
                titulo: 'INICIACIÓN',
                grupos: 'Oruguitas, Abejitas, Mariposas',
                mensualidad: '\$950 - \$1,000',
                inscripcion: '\$500',
                sesiones: '2 días/semana',
                duracion: '1.5 horas',
                incluye: const [
                  'Entrenamiento personalizado',
                  'Evaluación inicial',
                  'Seguimiento del progreso',
                  'Acceso a instalaciones',
                ],
                color: const Color(0xFFFFD54F),
                destacado: false,
              ),
              
              _buildPricingCard(
                titulo: 'DESARROLLO',
                grupos: 'Dragonas, Panteras, Panditas',
                mensualidad: '\$1,150 - \$1,250',
                inscripcion: '\$500',
                sesiones: '3 días/semana',
                duracion: '2 horas',
                incluye: const [
                  'Entrenamiento intensivo',
                  'Preparación para competencias',
                  'Evaluaciones mensuales',
                  'Acceso prioritario',
                ],
                color: const Color(0xFFE91E63),
                destacado: true,
              ),
              
              _buildPricingCard(
                titulo: 'COMPETITIVO',
                grupos: 'Tigresas, Conejas, Halconas',
                mensualidad: '\$1,350 - \$1,450',
                inscripcion: '\$500',
                sesiones: '4-5 días/semana',
                duracion: '2-3 horas',
                incluye: const [
                  'Entrenamiento de élite',
                  'Competencias estatales/nacionales',
                  'Afiliación a la FMG',
                  'Material especializado',
                ],
                color: const Color(0xFF9C27B0),
                destacado: false,
              ),
              
              _buildPricingCard(
                titulo: 'ACONDICIONAMIENTO',
                grupos: 'Linces (Adultos/Fitness)',
                mensualidad: '\$800',
                inscripcion: '\$500',
                sesiones: '2 días/semana',
                duracion: '1 hora',
                incluye: const [
                  'Preparación física',
                  'Acrobacia básica',
                  'Flexibilidad y fuerza',
                  'Ambiente recreativo',
                ],
                color: const Color(0xFF00BCD4),
                destacado: false,
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'COSTOS ADICIONALES',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCostoAdicional('Credencial CEDRUS', '\$250'),
                    _buildCostoAdicional('Recargo después del día 10', '10%'),
                    _buildCostoAdicional('Visita por sesión', '\$150'),
                    _buildCostoAdicional('Guardia (+15 min)', '\$100'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard({
    required String titulo,
    required String grupos,
    required String mensualidad,
    required String inscripcion,
    required String sesiones,
    required String duracion,
    required List<String> incluye,
    required Color color,
    required bool destacado,
  }) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: destacado ? Border.all(color: color, width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: destacado ? 30 : 20,
            offset: Offset(0, destacado ? 15 : 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                if (destacado)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'MÁS POPULAR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                if (destacado) const SizedBox(height: 12),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  grupos,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mensualidad.split(' ').first,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '/mes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (mensualidad.contains('-'))
                  Text(
                    mensualidad,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                
                const SizedBox(height: 8),
                Text(
                  'Inscripción: $inscripcion',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                
                _buildPricingFeature(Icons.calendar_today, sesiones),
                const SizedBox(height: 12),
                _buildPricingFeature(Icons.schedule, duracion),
                
                const SizedBox(height: 24),
                
                ...incluye.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                )),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Scroll to formulario
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: destacado ? 8 : 2,
                    ),
                    child: const Text(
                      'AGENDAR CLASE MUESTRA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildCostoAdicional(String label, String valor) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD54F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  // ==================== PLACEHOLDERS RESTANTES ====================
  Widget _buildHorarios() {
    return Container(
      key: _horariosKey,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: const Color(0xFFF5F5F5),
      child: const Center(child: Text('[HORARIOS - Por implementar]', style: TextStyle(color: Colors.black))),
    );
  }

  Widget _buildBeneficios() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          const Text(
            'BENEFICIOS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE91E63),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¿Por qué elegir Aerial Gymnastics?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 48),
          
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: [
              _buildBeneficioCard(
                icono: Icons.directions_run,
                titulo: 'Desarrollo Motor',
                descripcion: 'Mejora el equilibrio, la coordinación, la agilidad y el desarrollo de motricidad gruesa.',
                color: const Color(0xFFFFB74D),
              ),
              _buildBeneficioCard(
                icono: Icons.favorite,
                titulo: 'Salud Física',
                descripcion: 'Fortalece huesos y músculos, mejora las cualidades físicas como fuerza, flexibilidad y equilibrio.',
                color: const Color(0xFFE91E63),
              ),
              _buildBeneficioCard(
                icono: Icons.emoji_events,
                titulo: 'Confianza y Autoestima',
                descripcion: 'Lograr pequeñas metas aumenta la seguridad en sí mismos y el desarrollo de habilidades cognitivas.',
                color: const Color(0xFF9C27B0),
              ),
              _buildBeneficioCard(
                icono: Icons.group,
                titulo: 'Habilidades Sociales',
                descripcion: 'Fomenta el trabajo en equipo, compartir, hacer amigos y la conducta e interacción guiada.',
                color: const Color(0xFF00BCD4),
              ),
              _buildBeneficioCard(
                icono: Icons.school,
                titulo: 'Disciplina y Concentración',
                descripcion: 'Aprende a seguir instrucciones y normas, mejora la orientación y coordinación.',
                color: const Color(0xFF81C784),
              ),
              _buildBeneficioCard(
                icono: Icons.celebration,
                titulo: 'Diversión y Alegría',
                descripcion: 'Una forma divertida de jugar y liberar energía en un ambiente seguro y profesional.',
                color: const Color(0xFFFFD54F),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficioCard({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Color color,
  }) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 40, color: color),
          ),
          const SizedBox(height: 24),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            descripcion,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInscripcion() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'PROCESO DE INSCRIPCIÓN',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE91E63),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¿Cómo inscribirte?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 48),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildPasoInscripcion(
                  numero: '1',
                  titulo: 'REGISTRO',
                  descripcion: 'Envía por WhatsApp:\n'
                      '• Nombre completo\n'
                      '• Edad (mes/año)\n'
                      '• Experiencia deportiva\n\n'
                      '⚠️ Grupos competitivos requieren evaluación previa',
                  icono: Icons.phone_android,
                  color: const Color(0xFFE91E63),
                ),
              ),
              const SizedBox(width: 24),
              Icon(Icons.arrow_forward, size: 32, color: Colors.grey.shade400),
              const SizedBox(width: 24),
              
              Expanded(
                child: _buildPasoInscripcion(
                  numero: '2',
                  titulo: 'CONFIRMACIÓN',
                  descripcion: 'Recibirás los detalles del grupo asignado y el horario de clase muestra.\n\nConfirma lectura y aceptación de reglamentos.',
                  icono: Icons.assignment_turned_in,
                  color: const Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(width: 24),
              Icon(Icons.arrow_forward, size: 32, color: Colors.grey.shade400),
              const SizedBox(width: 24),
              
              Expanded(
                child: _buildPasoInscripcion(
                  numero: '3',
                  titulo: 'CLASE MUESTRA',
                  descripcion: 'Toma tu clase muestra gratuita.\n\n¡Conoce nuestras instalaciones y coaches!',
                  icono: Icons.sports_gymnastics,
                  color: const Color(0xFF00BCD4),
                ),
              ),
              const SizedBox(width: 24),
              Icon(Icons.arrow_forward, size: 32, color: Colors.grey.shade400),
              const SizedBox(width: 24),
              
              Expanded(
                child: _buildPasoInscripcion(
                  numero: '4',
                  titulo: 'BIENVENIDA',
                  descripcion: 'Solicita tu hoja de registro para inscripción formal.\n\nConfirma al 7711897104 y ¡serás parte del equipo!',
                  icono: Icons.celebration,
                  color: const Color(0xFFFFB74D),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // NUEVA SECCIÓN: Nota sobre grupos competitivos
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade300, width: 2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Interesada en grupos competitivos?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Conejas (N3) • Halconas (N4/N5)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.amber.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.amber.shade300),
                const SizedBox(height: 16),
                Text(
                  'Los grupos competitivos están diseñados para gimnastas de alto rendimiento que participan en competencias estatales y nacionales.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Proceso de Ingreso',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildRequisitoItem('Iniciar en grupo de desarrollo (mínimo 1 mes)'),
                      _buildRequisitoItem('Evaluación técnica de coaches'),
                      _buildRequisitoItem('Aprobación para nivel competitivo'),
                      _buildRequisitoItem('Afiliación a federación (FMG/USAG)'),
                      _buildRequisitoItem('Compromiso de asistencia y competencias'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Todas las gimnastas, sin importar su experiencia previa, deben completar este proceso para garantizar la preparación adecuada para competencias.',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Listo para comenzar?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Contáctanos por WhatsApp y agenda tu clase muestra',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Abrir WhatsApp
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp: 7711897104'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasoInscripcion({
    required String numero,
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              Icon(icono, size: 40, color: color),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      numero,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            descripcion,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReglamento() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          const Text(
            'REGLAMENTO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE91E63),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Normas Importantes',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Para el mejor funcionamiento del gimnasio y seguridad de nuestras gimnastas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 48),
          
          Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                _buildReglamentoItem(
                  numero: '1',
                  titulo: 'Credencial de Identificación',
                  descripcion: 'Después de la clase muestra, tramitar la credencial de identificación (\$250) en el Departamento de Control Escolar para acceso a las instalaciones.',
                  icono: Icons.badge,
                ),
                _buildReglamentoItem(
                  numero: '2',
                  titulo: 'Acceso al Gimnasio',
                  descripcion: 'El acceso es únicamente para gimnastas. Se permite entrada al área de casilleros 3 minutos antes del horario. En grupos Abejitas y Oruguitas, un familiar/tutor puede permanecer en el área de espera.',
                  icono: Icons.door_front_door,
                ),
                _buildReglamentoItem(
                  numero: '3',
                  titulo: 'Vestimenta Obligatoria',
                  descripcion: 'Ropa deportiva ajustada (leotardo y lycra corta o larga), cabello recogido SIN accesorios. NO collares, aretes largos, pulseras o anillos. Tenis SIN AGUJETAS.',
                  icono: Icons.checkroom,
                  destacado: true,
                ),
                _buildReglamentoItem(
                  numero: '4',
                  titulo: 'Puntualidad',
                  descripcion: 'Tolerancia máxima de 10 minutos. ES DE SUMA IMPORTANCIA RESPETAR LOS HORARIOS DE ENTRADA para asegurar correcto calentamiento. Si llegas tarde, no podrás ser supervisado.',
                  icono: Icons.schedule,
                  destacado: true,
                ),
                _buildReglamentoItem(
                  numero: '5',
                  titulo: 'Objetos Prohibidos',
                  descripcion: 'No está permitido el uso de aparatos, colchonetas o realizar ejercicios sin supervisión. Tampoco entrada con zapatos o tenis con zapatos al área de manos libres o colchonetas.',
                  icono: Icons.block,
                ),
                _buildReglamentoItem(
                  numero: '6',
                  titulo: 'Alimentos y Bebidas',
                  descripcion: 'No se permite entrada con alimentos chatarra o bebidas que puedan derramarse. No está permitido el consumo de snacks durante entrenamientos menores de 120 minutos.',
                  icono: Icons.no_food,
                ),
                _buildReglamentoItem(
                  numero: '7',
                  titulo: 'Orden y Limpieza',
                  descripcion: 'Es responsabilidad de las gimnastas mantener el área de casilleros ordenada y cuidado de sus pertenencias. No podemos hacernos responsables de objetos extraviados/olvidados.',
                  icono: Icons.cleaning_services,
                ),
                _buildReglamentoItem(
                  numero: '8',
                  titulo: 'Lenguaje y Trato',
                  descripcion: 'El lenguaje y trato entre gimnastas y entrenadores deberá ser cordial y de apoyo mutuo. Cualquier falta debe ser notificada y atendida en el momento.',
                  icono: Icons.favorite,
                ),
                _buildReglamentoItem(
                  numero: '9',
                  titulo: 'Acceso de Padres',
                  descripcion: 'En períodos de acceso a padres de familia (entrada, sesión, cierre, salida), NO acceder al área de entrenamiento o interrumpir la dinámica de entrenamiento.',
                  icono: Icons.family_restroom,
                ),
                _buildReglamentoItem(
                  numero: '10',
                  titulo: 'Tolerancia de Salida',
                  descripcion: 'La tolerancia para recoger a las gimnastas será de 15 minutos máximo. En la última sesión del día, después de ese tiempo se cobrará cuota de guardia de \$100.00.',
                  icono: Icons.access_time,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReglamentoItem({
    required String numero,
    required String titulo,
    required String descripcion,
    required IconData icono,
    bool destacado = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: destacado 
            ? Border.all(color: const Color(0xFFE91E63), width: 2) 
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: destacado 
                  ? const Color(0xFFE91E63).withOpacity(0.1)
                  : const Color(0xFF9C27B0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icono,
                  color: destacado ? const Color(0xFFE91E63) : const Color(0xFF9C27B0),
                  size: 24,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: destacado ? const Color(0xFFE91E63) : const Color(0xFF9C27B0),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        numero,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonios() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9C27B0),
            Color(0xFFE91E63),
          ],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'TESTIMONIOS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lo que dicen nuestras familias',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          
          SizedBox(
            height: 300,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTestimonioCard(
                  nombre: 'María López',
                  relacion: 'Mamá de Ana (Grupo Mariposas)',
                  testimonio: 'Mi hija ha crecido mucho en confianza gracias al equipo de coaches. Los resultados son increíbles y el ambiente es súper profesional. ¡Recomendado 100%!',
                  estrellas: 5,
                ),
                _buildTestimonioCard(
                  nombre: 'Sofía Hernández',
                  relacion: 'Mamá de Lucía (Grupo Dragonas)',
                  testimonio: 'Excelente gimnasio. Las instalaciones son de primer nivel y los entrenadores están muy preparados. Mi hija ama sus clases y ha mejorado muchísimo.',
                  estrellas: 5,
                ),
                _buildTestimonioCard(
                  nombre: 'Carlos Ramírez',
                  relacion: 'Papá de Isabella (Grupo Abejitas)',
                  testimonio: 'El mejor lugar para iniciar en gimnasia. El enfoque formativo es ideal para niñas pequeñas y el seguimiento personalizado es excelente.',
                  estrellas: 5,
                ),
                _buildTestimonioCard(
                  nombre: 'Laura Martínez',
                  relacion: 'Mamá de Valentina (Grupo Conejas)',
                  testimonio: 'Aerial ha sido clave en el desarrollo de mi hija. La preparación para competencias es de alto nivel y los coaches son muy dedicados.',
                  estrellas: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonioCard({
    required String nombre,
    required String relacion,
    required String testimonio,
    required int estrellas,
  }) {
    return Container(
      width: 400,
      margin: const EdgeInsets.only(right: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              estrellas,
              (index) => const Icon(Icons.star, color: Color(0xFFFFD54F), size: 20),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"$testimonio"',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF9C27B0).withOpacity(0.1),
                child: Text(
                  nombre[0],
                  style: const TextStyle(
                    color: Color(0xFF9C27B0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      relacion,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    return Container(
      key: _faqKey,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'PREGUNTAS FRECUENTES',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE91E63),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¿Tienes dudas?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 48),
          
          Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                _buildFAQItem(
                  pregunta: '¿Cuánto cuesta la mensualidad?',
                  respuesta: 'Las mensualidades varían según el grupo:\n\n'
                      '• Grupos de iniciación (Oruguitas, Abejitas, Mariposas): \$950 - \$1,000/mes\n'
                      '• Grupos de desarrollo (Dragonas, Panteras, Panditas): \$1,150 - \$1,250/mes\n'
                      '• Grupos competitivos (Tigresas, Conejas, Halconas): \$1,350 - \$1,450/mes\n'
                      '• Linces (Adultos/Fitness): \$800/mes\n\n'
                      'La inscripción es de \$500 (nuevo ingreso o reinscripción después de 3 meses sin asistir).',
                ),
                _buildFAQItem(
                  pregunta: '¿Cuáles son los horarios generales?',
                  respuesta: 'Tenemos horarios de lunes a viernes entre las 16:00 y 20:00 horas. '
                      'Los horarios específicos varían por grupo:\n\n'
                      '• Grupos de 2 días/semana: Martes y Jueves\n'
                      '• Grupos de 3 días/semana: Lunes, Miércoles y Viernes\n'
                      '• Grupos intensivos: Lunes a Viernes\n\n'
                      'Consulta la sección de Horarios para ver los detalles de cada grupo.',
                ),
                _buildFAQItem(
                  pregunta: '¿Qué necesito llevar a las clases?',
                  respuesta: 'Es OBLIGATORIO:\n\n'
                      '• Leotardo o playera ajustada sin botones (NO lycra corta o larga en iniciación)\n'
                      '• Cabello recogido (bien sujetado, sin accesorios)\n'
                      '• NO collares, aretes largos o grandes, pulseras o anillos\n'
                      '• Tenis SIN AGUJETAS\n'
                      '• Botella de agua\n'
                      '• Peluche pequeño (opcional, no nuevo/no valor sentimental)\n\n'
                      'Para grupos Oruguitas y Abejitas: Pagar al sanitario ANTES del inicio de sesión.',
                ),
                _buildFAQItem(
                  pregunta: '¿Cuándo se paga la mensualidad?',
                  respuesta: 'La mensualidad se paga del 1 al 5 de cada mes (solo en efectivo en recepción del Polideportivo).\n\n'
                      'Horario de caja:\n'
                      '• 9:00 - 12:00 hrs\n'
                      '• 14:00 - 19:00 hrs\n\n'
                      'Recargos:\n'
                      '• Del día 6 al 10: 10% de recargo\n'
                      '• Después del día 10: se cobran asistencias individuales (\$150 por sesión)\n\n'
                      'NO se recorre por fin de semana, días festivos o cualquier otro motivo.',
                ),
                _buildFAQItem(
                  pregunta: '¿Hay reposición de clases?',
                  respuesta: 'NO hay reposición de clases por suspensiones oficiales de la SEP.\n\n'
                      'En caso de suspensión extraoficial, se informará con anticipación el día y horario de reposición.\n\n'
                      'Los días de descanso activo (1 semana en Enero, Marzo, Agosto y Diciembre) se cubren con la mensualidad completa.\n\n'
                      'Una vez pagada la mensualidad, NO se puede solicitar cambio a mes diferente ni validación para otro mes.',
                ),
                _buildFAQItem(
                  pregunta: '¿Los días de entrenamiento son intercambiables?',
                  respuesta: 'NO. Los días de entrenamiento NO son intercambiables por ningún motivo.\n\n'
                      'No se puede tomar una sesión de otro grupo/horario, ya que cada uno tiene una programación y características diferentes.',
                ),
                _buildFAQItem(
                  pregunta: '¿Necesito seguro médico?',
                  respuesta: 'SÍ. Debes contar con seguro de gastos médicos o servicio médico vigente.\n\n'
                      'La naturaleza de la práctica deportiva conlleva riesgos. Contamos con personal capacitado en primeros auxilios, sin embargo, cualquier eventualidad mayor debe contar con un medio de contacto y atención urgente.\n\n'
                      '⚠️ IMPORTANTE: La mensualidad y clase muestra NO incluyen seguro médico.',
                ),
                _buildFAQItem(
                  pregunta: '¿Qué pasa si llego tarde?',
                  respuesta: 'La tolerancia de entrada es de 10 MINUTOS MÁXIMO.\n\n'
                      '⚠️ ES DE SUMA IMPORTANCIA RESPETAR LOS HORARIOS DE ENTRADA para que el entrenador pueda asegurar un correcto calentamiento. En caso contrario, no podrá ser supervisado.\n\n'
                      'Si llegas tarde de manera recurrente, la coordinación puede solicitar cambio de grupo u horario.',
                ),
                _buildFAQItem(
                  pregunta: '¿Pueden entrar los padres al entrenamiento?',
                  respuesta: 'NO. En los períodos de acceso a padres de familia (entrada, sesión de entrenamiento, cierre de sesión y salida), se les solicita NO acceder al área de entrenamiento o interrumpir de alguna forma la dinámica de entrenamiento.\n\n'
                      'Excepción: En grupos Abejitas y Oruguitas, un familiar o tutor puede permanecer pendiente en el área de espera para asistencia que pueda requerir por la edad.',
                ),
                _buildFAQItem(
                  pregunta: '¿Qué es la credencial CEDRUS y cuánto cuesta?',
                  respuesta: 'La credencial de identificación del Instituto CEDRUS cuesta \$250.\n\n'
                      'Debe tramitarse en el Departamento de Control Escolar (ubicado en el edificio central) después de tu sesión de clase muestra.\n\n'
                      'Esta credencial es la que permite el acceso a las instalaciones, por lo que sin ella es imposible dar entrada.',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.help_outline, size: 32, color: Color(0xFF9C27B0)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¿Tienes más preguntas?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Contáctanos por WhatsApp al 7711897104 y con gusto te atenderemos',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({
    required String pregunta,
    required String respuesta,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          title: Text(
            pregunta,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          children: [
            Text(
              respuesta,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioClaseMuestra() {
    return Container(
      key: _formularioKey,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF9C27B0).withOpacity(0.9),
          ],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'AGENDA TU CLASE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFD54F),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¡Comienza Hoy!',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna izquierda: Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tu Primera Clase es GRATIS',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Completa el formulario o contáctanos directamente por WhatsApp para agendar tu clase muestra.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    _buildContactInfo(
                      Icons.phone,
                      'WhatsApp',
                      '771 189 7104',
                    ),
                    const SizedBox(height: 16),
                    _buildContactInfo(
                      Icons.schedule,
                      'Horario de atención',
                      'Lun - Vie: 9:00 - 20:00',
                    ),
                    const SizedBox(height: 16),
                    _buildContactInfo(
                      Icons.location_on,
                      'Ubicación',
                      'Polideportivo CEDRUS, Pachuca',
                    ),
                    
                    const SizedBox(height: 40),
                    
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: Color(0xFFFFD54F), size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Incluye en tu mensaje:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildListItem('Nombre completo'),
                          _buildListItem('Edad (mes/año)'),
                          _buildListItem('Experiencia deportiva'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 60),
              
              // Columna derecha: Formulario de 4 pasos con Firestore
              const Expanded(
                child: TrialClassRegistrationForm(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.arrow_right, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(60),
      color: const Color(0xFF1A1A2E),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna 1: Logo y descripción
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.stars, color: Color(0xFFE91E63), size: 32),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AERIAL',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'GYMNASTICS',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Gimnasio de gimnasia artística femenil afiliado a CEDRUS. '
                      'Desarrollando campeonas desde Pachuca, Hidalgo.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 60),
              
              // Columna 2: Enlaces rápidos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ENLACES RÁPIDOS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFooterLink('Nuestros Grupos', () => _scrollToSection(_gruposKey)),
                    _buildFooterLink('Horarios', () => _scrollToSection(_horariosKey)),
                    _buildFooterLink('Costos', () => _scrollToSection(_costosKey)),
                    _buildFooterLink('Preguntas Frecuentes', () => _scrollToSection(_faqKey)),
                    _buildFooterLink('Iniciar Sesión', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }),
                  ],
                ),
              ),
              
              const SizedBox(width: 60),
              
              // Columna 3: Contacto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CONTACTO',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFooterContact(Icons.phone, '771 189 7104'),
                    _buildFooterContact(Icons.location_on, 'Polideportivo CEDRUS\nPachuca, Hidalgo'),
                    _buildFooterContact(Icons.schedule, 'Lun - Vie: 9:00 - 20:00'),
                  ],
                ),
              ),
              
              const SizedBox(width: 60),
              
              // Columna 4: Redes sociales
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SÍGUENOS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildSocialButton(Icons.facebook, () {
                          // TODO: Abrir Facebook
                        }),
                        const SizedBox(width: 12),
                        _buildSocialButton(Icons.camera_alt, () {
                          // TODO: Abrir Instagram
                        }),
                        const SizedBox(width: 12),
                        _buildSocialButton(Icons.video_library, () {
                          // TODO: Abrir TikTok/YouTube
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 60),
          const Divider(color: Colors.white24),
          const SizedBox(height: 24),
          
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2026 Aerial Gymnastics - Todos los derechos reservados',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.verified, color: Color(0xFF9C27B0), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Gimnasio afiliado a CEDRUS',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterContact(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFE91E63), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildWhatsAppButton() {
    return FloatingActionButton.extended(
      onPressed: () async {
        final url = Uri.parse('https://wa.me/527711897104?text=Hola,%20quiero%20información%20sobre%20clases%20de%20gimnasia');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
      backgroundColor: const Color(0xFF25D366),
      icon: const Icon(Icons.chat),
      label: const Text('WhatsApp'),
      elevation: 8,
    );
  }

  Widget _buildRequisitoItem(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFE91E63),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
