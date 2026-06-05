import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'landing_page.dart';
import 'student_admin_detail_screen.dart';
import '../utils/image_helper.dart';

import '../models/announcement_model.dart';
import 'admin_reports_hub.dart';
import 'admin_payment_entry_screen.dart';
import 'admin_objectives_editor.dart';
import 'admin_agenda_editor.dart';
import 'admin_role_builder.dart';
import 'schedule_grid_view.dart';
import 'student_registration_screen.dart';
import 'rotation_sabana_screen.dart';
import 'admin_trial_classes_screen.dart';
import 'admin_payments_view.dart';
import 'admin_analytics_screen.dart';

class AdminDashboard extends StatefulWidget {
  final User currentUser;
  const AdminDashboard({super.key, required this.currentUser});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _directoryViewIndex = 0; // 0 for Family, 1 for Group
  bool _isLoading = true;
  String? _error;

  List<User> _students = [];
  List<User> _coaches = [];
  List<User> _parents = [];

  StreamSubscription? _studentsSub;
  StreamSubscription? _coachesSub;
  StreamSubscription? _parentsSub;
  int _loadedCount = 0;

  @override
  void initState() {
    super.initState();
    _debugDirectQuery();
    _initStreams();
  }

  void _debugDirectQuery() async {
    debugPrint('DEBUG: [AdminDashboard] Iniciando Query Directa de Prueba...');
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .limit(5)
          .get();
      
      debugPrint('DEBUG: [AdminDashboard] Query Directa - Documentos encontrados: ${snap.docs.length}');
      for (var doc in snap.docs) {
        debugPrint('DEBUG: [AdminDashboard] Query Directa - Doc ID: ${doc.id}, Data: ${doc.data()}');
      }
    } catch (e) {
      debugPrint('DEBUG: [AdminDashboard] Query Directa - ERROR: $e');
    }
  }

  void _initStreams() {
    debugPrint('DEBUG: [AdminDashboard] Inicializando Streams...');
    try {
      _studentsSub = FirestoreService.instance.getStudents().listen((data) {
        if (!mounted) return;
        debugPrint('DEBUG: [AdminDashboard] Alumnas recibidas: ${data.length}');
        setState(() {
          _students = data;
          _checkIfReady();
        });
      }, onError: (e) {
        debugPrint('DEBUG: [AdminDashboard] Error en stream alumnos: $e');
        if (mounted) setState(() => _error = 'Error alumnos: $e');
      });

      _coachesSub = FirestoreService.instance.getCoaches().listen((data) {
        if (!mounted) return;
        debugPrint('DEBUG: [AdminDashboard] Coaches recibidos: ${data.length}');
        setState(() {
          _coaches = data;
          _checkIfReady();
        });
      }, onError: (e) {
        debugPrint('DEBUG: [AdminDashboard] Error en stream staff: $e');
        if (mounted) setState(() => _error = 'Error staff: $e');
      });

      _parentsSub = FirestoreService.instance.getParents().listen((data) {
        if (!mounted) return;
        debugPrint('DEBUG: [AdminDashboard] Padres recibidos: ${data.length}');
        setState(() {
          _parents = data;
          _checkIfReady();
        });
      }, onError: (e) {
        debugPrint('DEBUG: [AdminDashboard] Error en stream familias: $e');
        if (mounted) setState(() => _error = 'Error familias: $e');
      });
    } catch (e) {
      debugPrint('DEBUG: [AdminDashboard] Excepción al iniciar streams: $e');
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _checkIfReady() {
    if (!mounted) return;
    if (_isLoading) {
      _loadedCount++;
      if (_loadedCount >= 3) {
        setState(() => _isLoading = false);
      }
    } else {
      // Si ya estaba cargado pero los streams envían datos nuevos en tiempo real
      setState(() {}); 
    }
  }

  @override
  void dispose() {
    _studentsSub?.cancel();
    _coachesSub?.cancel();
    _parentsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.redAccent))),
      );
    }
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

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
            'Panel de Administración',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
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
        body: Column(
          children: [
            // Stats Row compact
            _buildStatsRow(context),
            // Minimalist Tab selection using a Custom selector or plain toggle to save space
            _buildDirectAccessGrid(context),
            const SizedBox(height: 12),
            _buildSystemTools(context),
            Expanded(
               child: _buildDirectorySection(context),
            ),
           ],
         ),
         floatingActionButton: FloatingActionButton.extended(
           onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentRegistrationScreen()));
           },
           backgroundColor: const Color(0xFFE91E63),
           icon: const Icon(Icons.person_add, color: Colors.white),
           label: Text('Alta', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
         ),
       ),
     );
   }

  Widget _buildStatsRow(BuildContext context) {
    final studentsCount = _students.length;
    final staffCount = _coaches.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCompactStat(Icons.people, '$studentsCount', 'Alumnas', Colors.purpleAccent),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildCompactStat(Icons.work, '$staffCount', 'Staff', Colors.blueAccent),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildCompactStat(Icons.attach_money, '5', 'Pagos', Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildCompactStat(IconData icon, String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(value, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          ],
        ),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  Widget _buildDirectAccessGrid(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text('Herramientas Estratégicas', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white70, fontSize: 12)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildActionButton(context, Icons.edit_calendar, 'Agenda', Colors.pinkAccent, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminAgendaEditor()));
                }),
                const SizedBox(width: 16),
                _buildActionButton(context, Icons.campaign, 'Avisos', Colors.orangeAccent, () => _showAddAnnouncementDialog(context)),
                const SizedBox(width: 16),
                _buildActionButton(context, Icons.track_changes, 'Metas', Colors.lightBlueAccent, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminObjectivesEditor()));
                }),
                const SizedBox(width: 16),
                _buildActionButton(context, Icons.grid_view_rounded, 'Roles', Colors.tealAccent, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminRoleBuilder()));
                }),
                const SizedBox(width: 16),
                _buildActionButton(context, Icons.table_chart, 'Tabla', Colors.amberAccent, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RotationSabanaScreen(coaches: {for (var c in _coaches) c.id: c})));
                }),
                const SizedBox(width: 16),
                _buildActionButton(context, Icons.payments, 'Pagos', Colors.greenAccent, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPaymentEntryScreen()));
                }),
                const SizedBox(width: 16),
                _buildActionButton(context, Icons.bar_chart, 'Reportes', Colors.purpleAccent, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminReportsScreen()));
                }),
                const SizedBox(width: 16),
                _buildActionButton(context, Icons.how_to_reg, 'Muestra', Colors.orangeAccent, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminTrialClassesScreen()));
                }),
                const SizedBox(width: 16),
                _buildActionButton(context, Icons.receipt_long, 'Historial', Colors.cyanAccent, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPaymentsView()));
                }),
                const SizedBox(width: 16),
                _buildActionButton(context, Icons.analytics, 'Analytics', Colors.lightBlueAccent, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminAnalyticsScreen()));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemTools(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildDirectorySection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Directorio General', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleBtn('Familia', 0),
                      _buildToggleBtn('Grupo', 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: _directoryViewIndex == 0 ? _buildFamilyView() : _buildGroupView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String label, int index) {
    final isSelected = _directoryViewIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _directoryViewIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: isSelected ? Colors.white : Colors.white54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildFamilyView() {
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      children: [
        _buildGlassExpansionTile(
          icon: Icons.sports_gymnastics,
          color: Colors.cyanAccent,
          title: 'Equipo Técnico (Staff)',
          children: _coaches.map((coach) => ListTile(
            visualDensity: VisualDensity.compact,
            leading: CircleAvatar(backgroundColor: Colors.cyanAccent.withOpacity(0.2), child: Text(coach.name[0], style: const TextStyle(color: Colors.cyanAccent))),
            title: Text(coach.name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            subtitle: Text(coach.email, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54)),
          )).toList(),
        ),
        const SizedBox(height: 12),
        _buildGlassExpansionTile(
          icon: Icons.family_restroom,
          color: Colors.pinkAccent,
          title: 'Familias y Alumnas',
          children: _parents.map((parent) {
            final student = _students.firstWhere(
              (s) => s.id == parent.associatedStudentId, 
              orElse: () => User(id: '0', name: 'Desconocido', email: '', role: UserRole.viewer, group: 'N/A')
            );
            return Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: Colors.white,
                collapsedIconColor: Colors.white70,
                leading: const Icon(Icons.person_outline, color: Colors.white70),
                title: Text(parent.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
                subtitle: Text('Tutor de: ${student.name}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54)),
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      visualDensity: VisualDensity.compact,
                      leading: CircleAvatar(
                        backgroundColor: Colors.pinkAccent.withOpacity(0.2),
                        backgroundImage: getProfileImageProvider(student.photoUrl),
                        child: student.photoUrl == null ? Text(student.name[0], style: const TextStyle(color: Colors.pinkAccent)) : null,
                      ),
                      title: Text(student.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                      subtitle: Text(student.group, style: GoogleFonts.poppins(color: Colors.pinkAccent, fontSize: 11)),
                      trailing: IconButton(
                        icon: const Icon(Icons.folder_open, color: Colors.white),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => StudentAdminDetailScreen(student: student)));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGroupView() {
    final groups = _students.map((s) => s.group).toSet().toList()..sort();
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final groupStudents = _students.where((s) => s.group == group).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildGlassExpansionTile(
            title: group,
            subtitle: '${groupStudents.length} alumnas',
            icon: Icons.groups,
            color: Theme.of(context).primaryColor,
            children: groupStudents.map((student) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
              child: ListTile(
                visualDensity: VisualDensity.compact,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundImage: getProfileImageProvider(student.photoUrl),
                  child: student.photoUrl == null ? Text(student.name[0], style: const TextStyle(fontSize: 12)) : null,
                ),
                title: Text(student.name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
                trailing: IconButton(
                  icon: const Icon(Icons.folder_open, color: Colors.white70, size: 20),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => StudentAdminDetailScreen(student: student)));
                  },
                ),
              ),
            )).toList(),
          ),
        );
      },
    );
  }

  Widget _buildGlassExpansionTile({required IconData icon, required Color color, required String title, String? subtitle, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Colors.white,
          collapsedIconColor: Colors.white70,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
          subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)) : null,
          children: children,
        ),
      ),
    );
  }

  void _showAddAnnouncementDialog(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedTarget = 'all';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Nuevo Aviso', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Título',
                    labelStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mensaje',
                    labelStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Text('Dirigido a:', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white70)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('📢 Todos'),
                      selected: selectedTarget == 'all',
                      onSelected: (selected) { if (selected) setState(() => selectedTarget = 'all'); },
                      selectedColor: Colors.red.shade100,
                    ),
                    ChoiceChip(
                      label: const Text('👨‍🏫 Staff'),
                      selected: selectedTarget == 'coach',
                      onSelected: (selected) { if (selected) setState(() => selectedTarget = 'coach'); },
                      selectedColor: Colors.blue.shade100,
                    ),
                    ChoiceChip(
                      label: const Text('👨‍👩‍👧 Padres'),
                      selected: selectedTarget == 'parent',
                      onSelected: (selected) { if (selected) setState(() => selectedTarget = 'parent'); },
                      selectedColor: Colors.green.shade100,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && messageController.text.isNotEmpty) {
                  final announcement = Announcement(
                    id: 'a_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleController.text,
                    message: messageController.text,
                    date: DateTime.now(),
                    targetRole: selectedTarget,
                  );
                  FirebaseFirestore.instance.collection('announcements').doc(announcement.id).set({
                    'title': announcement.title,
                    'message': announcement.message,
                    'date': Timestamp.now(),
                    'targetRole': announcement.targetRole,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aviso publicado'), backgroundColor: Colors.green));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: const Text('Publicar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
