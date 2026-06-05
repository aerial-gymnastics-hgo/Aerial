import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/rotation_model.dart';
import '../models/achievement_model.dart';
import 'landing_page.dart';
import 'student_achievements_screen.dart';
import 'calendar_screen.dart';
import '../models/event_model.dart';

class StudentDashboard extends StatefulWidget {
  final User currentUser;
  const StudentDashboard({super.key, required this.currentUser});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List<RotationSlot> _allRotations = [];
  List<SystemEvent> _events = [];
  List<Achievement> _achievements = [];

  StreamSubscription? _rotationsSub;
  StreamSubscription? _eventsSub;
  StreamSubscription? _achSub;

  @override
  void initState() {
    super.initState();
    // Suscripciones a los streams para mantener los datos frescos
    _rotationsSub = FirestoreService.instance.getAllRotations().listen((data) {
      if (mounted) setState(() => _allRotations = data);
    });

    _eventsSub = FirestoreService.instance.getEventsForRole('student').listen((data) {
      if (mounted) setState(() => _events = data);
    });

    // Filtramos logros usando queries
    _achSub = FirestoreService.instance.getAchievements(studentId: widget.currentUser.id).listen((data) {
      if (mounted) setState(() => _achievements = data);
    });
  }

  @override
  void dispose() {
    _rotationsSub?.cancel();
    _eventsSub?.cancel();
    _achSub?.cancel();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  DateTime _parseTimeStringToToday(String timeStr) {
    if (timeStr.isEmpty) return DateTime.now();
    final parts = timeStr.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.tryParse(parts[0]) ?? 0, int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  }

  // Lógica para interceptar el entrenamiento inmediato de hoy
  Map<String, dynamic>? _getNextTraining() {
    final now = DateTime.now();
    
    // Filtramos las rotaciones basadas en el stream
    List<RotationSlot> groupRotations = _allRotations
        .where((r) => r.groupId.toLowerCase() == widget.currentUser.group.toLowerCase())
        .toList();
        
    if (groupRotations.isEmpty) return null;

    groupRotations.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Busca el que está ocurriendo o el más próximo hoy
    for (var slot in groupRotations) {
       final slotEnd = _parseTimeStringToToday(slot.endTime);
       if (slotEnd.isAfter(now)) {
          return {'slot': slot, 'coach': User(id: slot.coachId, name: 'Tú Entrenador(a)', email: '', role: UserRole.coach, colorHex: 0xFF2196F3)};
       }
    }
    
    // Si ya terminaron todos hoy, muestra el primero del día
    return {'slot': groupRotations.first, 'coach': User(id: groupRotations.first.coachId, name: 'Tú Entrenador(a)', email: '', role: UserRole.coach, colorHex: 0xFF2196F3)};
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: const AssetImage('assets/images/gimnasia_landing.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.90), BlendMode.darken), // Ultra Dark para Alto Rendimiento
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            '¡Hola, ${widget.currentUser.name.split(" ")[0]}!',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.cyanAccent, blurRadius: 15)],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_calendar, color: Colors.cyanAccent),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarScreen(role: widget.currentUser.role.name)));
              },
              tooltip: 'Agenda Central',
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              onPressed: () async {
                 await AuthService().logout();
                 if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                       MaterialPageRoute(builder: (context) => const LandingPage()),
                       (route) => false,
                    );
                 }
              },
            ),
          ],
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            _buildNextTrainingCard(context),
            const SizedBox(height: 24),
            
            _buildCommunityBanner(context),
            const SizedBox(height: 32),
            
            _buildAnnouncementsSection(context),
            const SizedBox(height: 32),
            
            _buildMyRecentAchievements(context),
            const SizedBox(height: 32),
            
            _buildTechnicalLibrary(context),
            const SizedBox(height: 48), 
          ],
        ),
      ),
    );
  }

  // --- 1. MÓDULO DE PRÓXIMO ENTRENAMIENTO (MÉTRICA) ---
  Widget _buildNextTrainingCard(BuildContext context) {
    final nextR = _getNextTraining();
    if (nextR == null) return const SizedBox.shrink();

    final slot = nextR['slot'] as RotationSlot;
    final coach = nextR['coach'] as User;
    final String timeStr = slot.startTime;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 20, spreadRadius: -5),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   const Icon(Icons.radar, color: Colors.cyanAccent, size: 20),
                   const SizedBox(width: 8),
                   Text('PRÓXIMA ESTACIÓN', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(coach.colorHex ?? 0xFF00BFFF).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(coach.colorHex ?? 0xFF00BFFF).withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Text(
                        timeStr,
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot.apparatus.toUpperCase(),
                          style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 14, color: Colors.white54),
                            const SizedBox(width: 4),
                            Text('Coach: ${coach.name.split(' ')[0]}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (slot.focus != null && slot.focus!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: const Border(left: BorderSide(color: Colors.orangeAccent, width: 3))),
                  child: Row(
                    children: [
                       const Icon(Icons.stars, color: Colors.orangeAccent, size: 16),
                       const SizedBox(width: 8),
                       Expanded(child: Text('Enfoque: ${slot.focus}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.orangeAccent, fontStyle: FontStyle.italic))),
                    ],
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. COMUNIDAD AERIAL (SALÓN DE LA FAMA ARRIBA) ---
  Widget _buildCommunityBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentAchievementsScreen(
              studentName: widget.currentUser.name,
              groupName: widget.currentUser.group,
              studentId: widget.currentUser.id,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFFE91E63), Color(0xFFFF9800)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          boxShadow: [
             BoxShadow(color: const Color(0xFFE91E63).withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 5)),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.public, size: 36, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Comunidad Aerial', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Entra al Feed de Logros y apoya a tu equipo.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.9))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  // --- 3. AVISOS DEL CLUB ---
  Widget _buildAnnouncementsSection(BuildContext context) {
    final announcements = _events.where((e) => e.type == 'announcement').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Radar del Club',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.pinkAccent, blurRadius: 10)],
          ),
        ),
        const SizedBox(height: 16),
        if (announcements.isEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
                child: Text('Sin transmisiones pendientes.', style: GoogleFonts.poppins(color: Colors.white54), textAlign: TextAlign.center),
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: announcements.map((ann) => _buildGlassAnnouncementCard(context, ann)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildGlassAnnouncementCard(BuildContext context, SystemEvent announcement) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: announcement.isUrgent ? Colors.red.withOpacity(0.15) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: announcement.isUrgent ? Colors.redAccent.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(announcement.targetEmoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: announcement.isUrgent ? Colors.redAccent : Colors.white,
                        ),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  announcement.message ?? '',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.80)),
                  maxLines: 4, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 4. TROFEOS RECIENTES ---
  Widget _buildMyRecentAchievements(BuildContext context) {
    final achievements = _achievements;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mis Conquistas Privadas',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.purpleAccent, blurRadius: 10)],
          ),
        ),
        const SizedBox(height: 16),
        if (achievements.isEmpty)
           ClipRRect(
             borderRadius: BorderRadius.circular(20),
             child: BackdropFilter(
               filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
               child: Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
                 child: Text('Sigue entrenando para desbloquear tu primer logro. ¡Tú puedes!', style: GoogleFonts.poppins(color: Colors.white54), textAlign: TextAlign.center),
               ),
             ),
           )
        else
           SingleChildScrollView(
             scrollDirection: Axis.horizontal,
             physics: const BouncingScrollPhysics(),
             child: Row(
               children: achievements.take(4).map((ach) => _buildAchievementDot(ach)).toList(),
             ),
           ),
      ],
    );
  }
  
  Widget _buildAchievementDot(Achievement ach) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ach.color.withOpacity(0.9), ach.color],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: ach.color.withOpacity(0.6), blurRadius: 15, offset: const Offset(0, 0)),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            ),
            child: Icon(ach.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 80,
            child: Text(
              ach.title,
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9)),
              textAlign: TextAlign.center,
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. VIDEOTECA TÉCNICA (Alto Rendimiento) ---
  Widget _buildTechnicalLibrary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Videoteca Biomecánica',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.lightGreenAccent, blurRadius: 10)],
          ),
        ),
        const SizedBox(height: 16),
        _buildVideoCard(
          context,
          'Acondicionamiento Core Nivel 3',
          'Fuerza abdominal para mortales - 8 Min',
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?auto=format&fit=crop&q=80&w=600',
          'https://www.youtube.com/watch?v=l1o0gL0j5bI',
        ),
      ],
    );
  }

  Widget _buildVideoCard(BuildContext context, String title, String subtitle, String imageUrl, String videoUrl) {
    return GestureDetector(
      onTap: () => _launchUrl(videoUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      height: 160, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(color: Colors.black45, height: 160, child: const Center(child: Icon(Icons.video_library, color: Colors.white24, size: 40))),
                    ),
                    Positioned.fill(
                      child: Container(
                         decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
                         child: Center(
                           child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.5))),
                              child: const Icon(Icons.play_arrow, size: 32, color: Colors.white),
                           ),
                         ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
