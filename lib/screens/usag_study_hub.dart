import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../data/usag_data.dart';

class UsagStudyHub extends StatefulWidget {
  const UsagStudyHub({super.key});

  @override
  State<UsagStudyHub> createState() => _UsagStudyHubState();
}

class _UsagStudyHubState extends State<UsagStudyHub> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: const AssetImage('assets/images/gimnasia_landing.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.88), BlendMode.darken),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Academia USAG',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.amber.withOpacity(0.6), blurRadius: 10)],
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.amber,
            indicatorWeight: 3,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white54,
            labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
            tabs: const [
              Tab(icon: Icon(Icons.school, size: 20), text: 'Conceptos'),
              Tab(icon: Icon(Icons.fitness_center, size: 20), text: 'Por Nivel'),
              Tab(icon: Icon(Icons.psychology, size: 20), text: 'Coaching'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildConceptsTab(),
            _buildLevelsTab(),
            _buildCoachingTab(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TAB 1: Conceptos Generales USAG
  // ============================================================
  Widget _buildConceptsTab() {
    final concepts = UsagData.usagGeneralConcepts;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: concepts.length,
      itemBuilder: (context, index) {
        final concept = concepts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildGlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  concept['title'] as String,
                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  concept['content'] as String,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.85), height: 1.5),
                ),
                const SizedBox(height: 12),
                _buildTipCard(concept['tip'] as String),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // TAB 2: Estrategia por Nivel
  // ============================================================
  Widget _buildLevelsTab() {
    final levels = UsagData.usagLevelStrategies;
    final levelKeys = levels.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: levelKeys.length,
      itemBuilder: (context, index) {
        final key = levelKeys[index];
        final level = levels[key]!;
        final levelColor = Color(level['color'] as int);
        final skills = level['skills'] as Map<String, String>;
        final drills = level['drills'] as List<String>;
        final focusAreas = level['focusAreas'] as List<String>;
        final hacks = UsagData.levelSpecificHacks[key] ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: _buildGlassContainer(
            color: levelColor.withOpacity(0.08),
            borderColor: levelColor.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(color: levelColor, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(level['title'] as String, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(level['subtitle'] as String, style: GoogleFonts.poppins(fontSize: 12, color: levelColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Habilidades por Aparato
                Text('HABILIDADES REQUERIDAS', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1)),
                const SizedBox(height: 8),
                ...skills.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${e.key}: ', style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: levelColor)),
                      Expanded(child: Text(e.value, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70))),
                    ],
                  ),
                )),
                const SizedBox(height: 12),

                // Deducciones
                _buildTipCard('⚠️ Deducciones comunes: ${level['deductions']}', color: Colors.redAccent),
                const SizedBox(height: 12),

                // Focus Areas
                Text('ÁREAS DE ENFOQUE', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: focusAreas.map((area) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: levelColor.withOpacity(0.4)),
                    ),
                    child: Text(area, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white)),
                  )).toList(),
                ),
                const SizedBox(height: 16),

                // Drills
                Text('EJERCICIOS Y DRILLS', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1)),
                const SizedBox(height: 8),
                ...drills.map((drill) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(drill, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.85))),
                )),

                // Hacks específicos
                if (hacks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('🎯 HACKS DE PROGRESIÓN', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  ...hacks.map((hack) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${hack['skill']}', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                            const SizedBox(width: 8),
                            Text('(${hack['apparatus']})', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(hack['hack']!, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.85))),
                        const SizedBox(height: 4),
                        Text('🎯 Enfoque: ${hack['focus']}', style: GoogleFonts.poppins(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.amber.withOpacity(0.7))),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // TAB 3: Coaching Hacks y Metodología
  // ============================================================
  Widget _buildCoachingTab() {
    final hacks = UsagData.coachingHacks;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: hacks.length,
      itemBuilder: (context, index) {
        final hack = hacks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildGlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hack['title'] as String,
                        style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purpleAccent.withOpacity(0.4)),
                      ),
                      child: Text(hack['category'] as String, style: GoogleFonts.poppins(fontSize: 9, color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  hack['content'] as String,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.85), height: 1.5),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📋 Ejemplo Práctico:', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                      const SizedBox(height: 6),
                      Text(hack['example'] as String, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // Widgets Auxiliares
  // ============================================================
  Widget _buildTipCard(String tip, {Color color = Colors.amber}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(tip, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.85), fontStyle: FontStyle.italic))),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, Color? color, Color? borderColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}
