import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../services/firestore_service.dart';
import '../models/event_model.dart';
import 'calendar_screen.dart';
import '../services/auth_service.dart';
import 'landing_page.dart';
import '../models/user_model.dart';
import 'parent_finances_screen.dart';
import '../utils/image_helper.dart';
import 'progress_detail_screen.dart';

class ParentDashboard extends StatefulWidget {
  final User currentUser;
  const ParentDashboard({super.key, required this.currentUser});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  List<User> _students = [];
  List<SystemEvent> _events = [];
  StreamSubscription? _studentsSub;
  StreamSubscription? _eventsSub;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initStreams();
  }

  void _initStreams() {
    final parentEmail = widget.currentUser.email;
    
    // Buscar todas las alumnas que tengan este parentEmail
    _studentsSub = FirebaseFirestore.instance
        .collection('users')
        .where('parentEmail', isEqualTo: parentEmail)
        .where('role', isEqualTo: 'student')
        .snapshots()
        .listen((snap) {
          if (mounted) {
            setState(() {
              _students = snap.docs.map((doc) => User(
                id: doc.id,
                name: doc.get('name') ?? '',
                email: doc.get('email') ?? '',
                role: UserRole.student,
                group: doc.get('group') ?? 'General',
                photoUrl: doc.data().containsKey('photoUrl') ? doc.get('photoUrl') : null,
              )).toList();
              _loading = false;
            });
          }
        });

    _eventsSub = FirestoreService.instance.getEventsForRole('parent').listen((data) {
      if (mounted) setState(() => _events = data);
    });
  }

  @override
  void dispose() {
    _studentsSub?.cancel();
    _eventsSub?.cancel();
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
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.85), BlendMode.darken),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          title: Text(
            'Portal de Padres',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
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
        body: _loading 
          ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          : _students.isEmpty 
            ? _buildEmptyState()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnnouncementsSection(context),
                    const SizedBox(height: 32),
                    Text(
                      'Mis Hijas',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: const [Shadow(color: Colors.pinkAccent, blurRadius: 10)],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._students.map((student) => _buildStudentCard(context, student)).toList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.family_restroom, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            'No se encontraron alumnas asociadas\na su cuenta (${widget.currentUser.email})',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, User student) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Alumna
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent.withOpacity(0.15),
                  border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white10,
                      backgroundImage: getProfileImageProvider(student.photoUrl),
                      child: student.photoUrl == null ? Text(student.name[0], style: const TextStyle(color: Colors.white)) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            'Grupo: ${student.group}',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Cuerpo: Información Principal y Botón de Finanzas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Horarios de Entrenamiento',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.cyanAccent, fontSize: 14),
                ),
                const SizedBox(height: 12),
                _buildSchedulesList(student.group),
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),
                _buildFinanceButton(student),
                const SizedBox(height: 16),
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),
                _buildGeneralProgressSection(student.id, student.name),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulesList(String groupId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rotations')
          .where('groupId', isEqualTo: groupId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Cargando horarios...', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12));
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Text('No hay horarios asignados esta semana', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12));
        }

        final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
        List<Widget> dayWidgets = [];

        for (var day in days) {
          final dayDocs = docs.where((doc) => (doc.data() as Map)['day'] == day).toList();
          if (dayDocs.isNotEmpty) {
            // Sort by start time if multiple
            dayDocs.sort((a, b) => (a.get('startTime') as String).compareTo(b.get('startTime') as String));
            final startTime = dayDocs.first.get('startTime');
            
            dayWidgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white38, size: 14),
                    const SizedBox(width: 8),
                    Text('$day: ', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('$startTime - Entrenamiento', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
            );
          }
        }

        return Column(children: dayWidgets);
      },
    );
  }

  Widget _buildFinanceButton(User student) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ParentFinancesScreen(
              studentId: student.id,
              studentName: student.name,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined, color: Colors.white54, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ver Estado Financiero',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }


  Widget _buildAnnouncementsSection(BuildContext context) {
    final announcements = _events.where((e) => e.type == 'announcement').toList();
    if (announcements.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.campaign, color: Colors.orangeAccent, size: 24),
            const SizedBox(width: 12),
            Text(
              'Avisos del Club',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: const [Shadow(color: Colors.orangeAccent, blurRadius: 10)]
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: announcement.isUrgent ? Colors.red.withOpacity(0.1) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: announcement.isUrgent ? Colors.redAccent.withOpacity(0.3) : Colors.white.withOpacity(0.1),
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
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  announcement.message ?? '',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralProgressSection(String studentId, String studentName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up, color: Colors.greenAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              'Progreso y Logros',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('evaluations')
              .where('studentId', isEqualTo: studentId)
              .orderBy('createdAt', descending: true)
              .limit(10)
              .snapshots(),
          builder: (context, evalSnapshot) {
            if (!evalSnapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.pinkAccent),
                ),
              );
            }

            final evaluations = evalSnapshot.data!.docs;

            if (evaluations.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Las evaluaciones aparecerán aquí conforme avance en sus entrenamientos',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final progresoData = _calcularProgresoGeneral(evaluations);

            return Column(
              children: [
                _buildTendenciaGeneralCard(progresoData),
                const SizedBox(height: 12),
                if (progresoData['badges'] != null && (progresoData['badges'] as List).isNotEmpty)
                  _buildDistintivosRecientes(progresoData['badges']),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProgressDetailScreen(
                            studentId: studentId,
                            studentName: studentName,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.emoji_events, size: 18),
                    label: const Text('Ver Progreso Completo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.greenAccent,
                      side: const BorderSide(color: Colors.greenAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Map<String, dynamic> _calcularProgresoGeneral(List<DocumentSnapshot> evaluations) {
    if (evaluations.isEmpty) {
      return {
        'tendencia': 'neutral',
        'mensaje': 'Sin evaluaciones aún',
        'capacidades': <String, List<int>>{},
        'badges': <String>[],
      };
    }

    final Map<String, List<int>> capacidades = {
      'fuerza': [],
      'flexibilidad': [],
      'equilibrio': [],
      'coordinacion': [],
    };

    final List<String> badges = [];

    for (final evalDoc in evaluations) {
      final evalData = evalDoc.data() as Map<String, dynamic>;
      final category = evalData['category'] as String? ?? '';
      final score = (evalData['score'] as num?)?.toInt() ?? 0;
      
      final lowerCat = category.toLowerCase();
      if (lowerCat.contains('fuerza') || lowerCat.contains('strength')) {
        capacidades['fuerza']!.add(score);
      } else if (lowerCat.contains('flexibilidad') || lowerCat.contains('flexibility')) {
        capacidades['flexibilidad']!.add(score);
      } else if (lowerCat.contains('equilibrio') || lowerCat.contains('balance')) {
        capacidades['equilibrio']!.add(score);
      } else if (lowerCat.contains('coordinacion') || lowerCat.contains('coordination')) {
        capacidades['coordinacion']!.add(score);
      }
      
      final badge = evalData['badge'] as String?;
      if (badge != null && badge.isNotEmpty && !badges.contains(badge)) {
        badges.add(badge);
      }
    }

    final allScores = evaluations
        .map((e) => ((e.data() as Map<String, dynamic>)['score'] as num?)?.toInt() ?? 0)
        .toList();
    
    String tendencia = 'neutral';
    String mensaje = 'Progreso constante';
    
    if (allScores.length >= 5) {
      final recientes = allScores.take(5).toList();
      final anteriores = allScores.skip(5).take(5).toList();
      
      if (anteriores.isNotEmpty) {
        final promedioReciente = recientes.reduce((a, b) => a + b) / recientes.length;
        final promedioAnterior = anteriores.reduce((a, b) => a + b) / anteriores.length;
        
        if (promedioReciente > promedioAnterior + 5) {
          tendencia = 'mejorando';
          mensaje = '¡Excelente progreso!';
        } else if (promedioReciente < promedioAnterior - 5) {
          tendencia = 'bajando';
          mensaje = 'Necesita más práctica';
        }
      }
    }

    return {
      'tendencia': tendencia,
      'mensaje': mensaje,
      'capacidades': capacidades,
      'badges': badges.take(3).toList(),
    };
  }

  Widget _buildTendenciaGeneralCard(Map<String, dynamic> progresoData) {
    final tendencia = progresoData['tendencia'] as String;
    final mensaje = progresoData['mensaje'] as String;
    final capacidades = progresoData['capacidades'] as Map<String, List<int>>;
    
    Color trendColor;
    IconData trendIcon;
    
    switch (tendencia) {
      case 'mejorando':
        trendColor = Colors.greenAccent;
        trendIcon = Icons.trending_up;
        break;
      case 'bajando':
        trendColor = Colors.orangeAccent;
        trendIcon = Icons.trending_down;
        break;
      default:
        trendColor = Colors.cyanAccent;
        trendIcon = Icons.trending_flat;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: trendColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(trendIcon, color: trendColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mensaje,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: trendColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Basado en evaluaciones recientes',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          
          Text(
            'Capacidades Físicas',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCapacidadChip('💪 Fuerza', capacidades['fuerza'] ?? []),
              _buildCapacidadChip('🤸 Flexibilidad', capacidades['flexibilidad'] ?? []),
              _buildCapacidadChip('⚖️ Equilibrio', capacidades['equilibrio'] ?? []),
              _buildCapacidadChip('🎯 Coordinación', capacidades['coordinacion'] ?? []),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapacidadChip(String label, List<int> scores) {
    if (scores.isEmpty) {
      return Chip(
        label: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        backgroundColor: Colors.white.withOpacity(0.05),
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      );
    }
    
    final promedio = scores.reduce((a, b) => a + b) / scores.length;
    
    Color textColor = Colors.white;
    Color chipColor;
    if (promedio >= 80) {
      chipColor = Colors.greenAccent.withOpacity(0.2);
      textColor = Colors.greenAccent;
    } else if (promedio >= 60) {
      chipColor = Colors.orangeAccent.withOpacity(0.2);
      textColor = Colors.orangeAccent;
    } else {
      chipColor = Colors.white.withOpacity(0.1);
    }
    
    return Chip(
      label: Text(
        '$label ${promedio.toStringAsFixed(0)}%',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
      ),
      backgroundColor: chipColor,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDistintivosRecientes(List<dynamic> badges) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amberAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amberAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Distintivos Recientes',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: badges.map((badge) => Chip(
              avatar: const Icon(Icons.stars, size: 16, color: Colors.amberAccent),
              label: Text(
                badge.toString(),
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
              backgroundColor: Colors.white.withOpacity(0.1),
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            )).toList(),
          ),
        ],
      ),
    );
  }
}
