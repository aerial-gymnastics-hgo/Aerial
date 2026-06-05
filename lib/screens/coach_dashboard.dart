import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:async';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/rotation_model.dart';
import '../utils/image_helper.dart';
import '../models/event_model.dart';
import '../models/schedule_model.dart';
import '../services/auth_service.dart';
import '../models/group_model.dart';
import 'landing_page.dart';
import 'coach_session_screen.dart';
import 'coach_daily_schedule.dart';
import 'student_detail_screen.dart';
import 'calendar_screen.dart';
import 'usag_study_hub.dart';
import 'schedule_grid_view.dart';
import '../services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CoachDashboard extends StatefulWidget {
  final User currentUser;
  const CoachDashboard({super.key, required this.currentUser});

  @override
  State<CoachDashboard> createState() => _CoachDashboardState();
}

class _CoachDashboardState extends State<CoachDashboard> {
  bool _alarmsActive = false;
  late User currentUser;
  RotationSlot? currentSlot;
  String selectedGroup = 'auto';
  final List<String> _dismissedNotices = [];

  List<RotationSlot> _rotations = [];
  List<SystemEvent> _events = [];
  Map<String, Map<String, dynamic>> _mesocycles = {};
  List<ScheduleAssignment> _assignments = [];
  List<User> _students = [];

  List<GymGroup> _allGroups = [];

  StreamSubscription? _rotSub, _evSub, _mesoSub, _assSub, _stuSub, _groupsSub;

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
    final cid = currentUser.id;

    _rotSub =
        FirestoreService.instance.getRotationsForCoach(cid).listen((data) {
      if (!mounted) return;
      setState(() {
        _rotations = data;
        _updateCurrentRotation();
      });
    });
    _evSub = FirestoreService.instance.getEventsForRole('coach').listen((data) {
      if (mounted) setState(() => _events = data);
    });
    _mesoSub = FirestoreService.instance.getMesocycles().listen((data) {
      if (mounted) setState(() => _mesocycles = data);
    });
    _assSub = FirestoreService.instance.getAssignments().listen((data) {
      if (mounted) setState(() => _assignments = data);
    });
    _stuSub = FirestoreService.instance.getStudents().listen((data) {
      if (mounted) setState(() => _students = data);
    });

    _groupsSub = FirestoreService.instance.getAllGroups().listen((data) {
      if (mounted) setState(() => _allGroups = data);
    });
  }

  @override
  void dispose() {
    _rotSub?.cancel();
    _evSub?.cancel();
    _mesoSub?.cancel();
    _assSub?.cancel();
    _stuSub?.cancel();
    _groupsSub?.cancel();
    super.dispose();
  }

  DateTime _parseTimeStringToToday(String timeStr) {
    if (timeStr.isEmpty) return DateTime.now();
    final parts = timeStr.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.tryParse(parts[0]) ?? 0,
        int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  }

  void _updateCurrentRotation() {
    final now = DateTime.now();
    final todayName = _getCurrentDayName();

    final todayRotations = _rotations.where((r) => r.day == todayName).toList();

    try {
      currentSlot = todayRotations.firstWhere((slot) {
        final start = _parseTimeStringToToday(slot.startTime);
        final end = _parseTimeStringToToday(slot.endTime);
        return now.isAfter(start) && now.isBefore(end);
      });
    } catch (e) {
      currentSlot = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = currentUser.colorHex != null
        ? Color(currentUser.colorHex!)
        : Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: const AssetImage('assets/images/gimnasia_landing.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.85), BlendMode.darken),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          title: Text(
            'Centro de Mando',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: primaryColor, blurRadius: 10)]),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            _buildNotificationBadge(primaryColor),
            StatefulBuilder(
              builder: (context, setIcon) => IconButton(
                icon: Icon(
                  _alarmsActive
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  color: _alarmsActive ? Colors.amberAccent : Colors.white70,
                ),
                tooltip: _alarmsActive
                    ? 'Alarmas Activas'
                    : 'Activar Alarmas de Turno',
                onPressed: () async {
                  if (_alarmsActive) {
                    await NotificationService.instance.cancelAll();
                    setState(() => _alarmsActive = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Alarmas canceladas.',
                              style: GoogleFonts.poppins()),
                          backgroundColor: Colors.red.shade800,
                        ),
                      );
                    }
                  } else {
                    final todaySchedule = _rotations
                        .where((e) =>
                            e.coachId == widget.currentUser.id &&
                            e.day == _getCurrentDayName())
                        .toList();

                    if (todaySchedule.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No hay bloques asignados para hoy.',
                                style: GoogleFonts.poppins()),
                            backgroundColor: Colors.orange.shade800,
                          ),
                        );
                      }
                      return;
                    }

                    final count = await NotificationService.instance
                        .scheduleRotationAlerts(
                      coachSchedule: todaySchedule,
                      coachName: widget.currentUser.name.split(' ').first,
                    );

                    setState(() => _alarmsActive = true);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '🔔 $count alarmas programadas para el turno de hoy. Puedes bloquear tu pantalla.',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.green.shade800,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.menu_book_rounded),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UsagStudyHub()));
              },
              tooltip: 'Academia USAG',
            ),
            IconButton(
              icon: const Icon(Icons.table_chart),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ScheduleGridView(currentUser: widget.currentUser)));
              },
              tooltip: 'Rol del Día',
            ),
            IconButton(
              icon: const Icon(Icons.edit_calendar),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CalendarScreen(
                            role: widget.currentUser.role.name)));
              },
              tooltip: 'Agenda Global',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LandingPage()),
                    (route) => false,
                  );
                }
              },
              tooltip: 'Cerrar Sesión',
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStrategicFocusSection(primaryColor),
              const SizedBox(height: 24),
              _buildGroupSelector(primaryColor),
              const SizedBox(height: 24),
              if (selectedGroup == 'auto') ...[
                _buildRotationMatrix(primaryColor),
                const SizedBox(height: 24),
                _buildMissionSection(primaryColor),
              ] else ...[
                _buildManualGroupSection(primaryColor, selectedGroup),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(Color primaryColor) {
    final activeAnnouncements = _events
        .where((a) =>
            a.type == 'announcement' && !_dismissedNotices.contains(a.title))
        .toList();
    final announcementsCount = activeAnnouncements.length;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, size: 28),
          onPressed: () => _showNoticesModal(context, primaryColor),
        ),
        if (announcementsCount > 0)
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: Colors.redAccent, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$announcementsCount',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _showNoticesModal(BuildContext context, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final announcements = _events
              .where((a) =>
                  a.type == 'announcement' &&
                  !_dismissedNotices.contains(a.title))
              .toList();

          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2))),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Text('Notificaciones',
                              style: GoogleFonts.montserrat(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const Spacer(),
                          IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white54),
                              onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: announcements.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final a = announcements[index];
                          return _buildGlassContainer(
                            color: a.isUrgent
                                ? Colors.red.withOpacity(0.1)
                                : Colors.white.withOpacity(0.05),
                            borderColor: a.isUrgent
                                ? Colors.redAccent.withOpacity(0.3)
                                : Colors.white10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(a.targetEmoji,
                                        style: const TextStyle(fontSize: 24)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Text(a.title,
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold,
                                                color: a.isUrgent
                                                    ? Colors.redAccent
                                                    : Colors.white))),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.white30,
                                          size: 20),
                                      onPressed: () {
                                        setState(() =>
                                            _dismissedNotices.add(a.title));
                                        setModalState(() {});
                                        if (announcements.length <= 1)
                                          Navigator.pop(context);
                                      },
                                      tooltip: 'Marcar como leído',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(a.message ?? '',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStrategicFocusSection(Color primaryColor) {
    final nextComp = _events.where((e) => e.type == 'event').firstOrNull ??
        SystemEvent(
            id: 'dummy',
            title: 'Competencia',
            date: DateTime(2027),
            color: Colors.blue,
            targetRole: 'all',
            type: 'event');
    final daysLeft = nextComp.date.difference(DateTime.now()).inDays.abs();

    final activeGroup = (selectedGroup == 'auto' && currentSlot != null)
        ? currentSlot!.groupId
        : (selectedGroup != 'auto' ? selectedGroup : 'General');
    final activeMesocycle = _mesocycles[activeGroup];
    final hasMesocycle = activeMesocycle != null;
    final objectives = hasMesocycle
        ? [activeMesocycle['objective'] as String]
        : ['Postura básica', 'Tensión muscular', 'Flexibilidad'];
    final dynamics = hasMesocycle
        ? activeMesocycle['dynamics'] as String?
        : 'Limpieza de ejecuciones aéreas y control de aterrizajes.';
    final supportLink =
        hasMesocycle ? activeMesocycle['supportLink'] as String? : null;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.military_tech_rounded,
                  color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(
                'Enfoque Táctico USAG',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.amber.withOpacity(0.5), blurRadius: 10)
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: _buildGlassContainer(
                  color: Colors.amber.withOpacity(0.05),
                  borderColor: Colors.amber.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('META: ${nextComp.title.toUpperCase()}',
                          style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('$daysLeft',
                              style: GoogleFonts.montserrat(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(width: 8),
                          Text('DÍAS\nRESTANTES',
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white54)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: _buildGlassContainer(
                  color: primaryColor.withOpacity(0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PROGRAMA: $activeGroup',
                          style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryColor)),
                      const SizedBox(height: 8),
                      ...objectives
                          .take(hasMesocycle ? 1 : 2)
                          .map((obj) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle_outline,
                                        size: 14, color: primaryColor),
                                    const SizedBox(width: 6),
                                    Expanded(
                                        child: Text(obj,
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.white))),
                                  ],
                                ),
                              )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.purpleAccent.withOpacity(0.05),
            borderColor: Colors.purpleAccent.withOpacity(0.2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome,
                    color: Colors.purpleAccent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dinámica de Comunidad:',
                        style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.purpleAccent),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dynamics ?? 'Limpieza general',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (supportLink != null && supportLink.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final url = Uri.parse(supportLink);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: _buildGlassContainer(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.blueAccent.withOpacity(0.1),
                borderColor: Colors.blueAccent.withOpacity(0.4),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_fill,
                        color: Colors.blueAccent, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ver Video de Apoyo / Drill USAG',
                        style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      ),
                    ),
                    const Icon(Icons.open_in_new,
                        color: Colors.blueAccent, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupSelector(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.groups, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Seleccionar Grupo',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: primaryColor.withOpacity(0.8), blurRadius: 8)
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: (selectedGroup == 'auto' ||
                        _allGroups.any((g) => g.id == selectedGroup))
                    ? selectedGroup
                    : 'auto',
                isExpanded: true,
                dropdownColor: Colors.black87,
                icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'auto',
                    child: Text('📅 Mi Horario Automático'),
                  ),
                  ..._allGroups.map((group) => DropdownMenuItem(
                        value: group.id,
                        child: Text(group.id),
                      )),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedGroup = value;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _textColorFor(Color bg) {
    final luminance =
        (0.299 * bg.red + 0.587 * bg.green + 0.114 * bg.blue) / 255;
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  String _getCurrentDayName() {
    final weekday = DateTime.now().weekday;
    final List<String> days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado'
    ];
    if (weekday >= 1 && weekday <= days.length) return days[weekday - 1];
    return 'Lunes';
  }

  Widget _buildRotationMatrix(Color primaryColor) {
    final String dayName = _getCurrentDayName();

    final myBlocks = _rotations
        .where((e) => e.coachId == currentUser.id && e.day == dayName)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (myBlocks.isEmpty) {
      return _buildNoScheduleCard(primaryColor);
    }

    final coachColor = primaryColor;
    final textColor = _textColorFor(coachColor);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration:
                    BoxDecoration(color: coachColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                'Mi Turno de Hoy',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: coachColor.withOpacity(0.8), blurRadius: 8)
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${myBlocks.length} bloques',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...myBlocks.asMap().entries.map((entry) {
            final idx = entry.key;
            final block = entry.value;

            final groupName = block.groupId;

            final now = DateTime.now();
            final blockStart = _parseTimeStringToToday(block.startTime);
            final blockEnd = _parseTimeStringToToday(block.endTime);

            final isActive = now.isAfter(blockStart) && now.isBefore(blockEnd);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isActive
                              ? coachColor
                              : coachColor.withOpacity(0.4),
                          shape: BoxShape.circle,
                          border: isActive
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                          boxShadow: isActive
                              ? [BoxShadow(color: coachColor, blurRadius: 8)]
                              : null,
                        ),
                      ),
                      if (idx < myBlocks.length - 1)
                        Container(
                          width: 2,
                          height: 68,
                          color: coachColor.withOpacity(0.2),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? coachColor
                            : coachColor.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                    color: coachColor.withOpacity(0.5),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4))
                              ]
                            : null,
                        border: isActive
                            ? Border.all(
                                color: Colors.white.withOpacity(0.6),
                                width: 1.5)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                block.startTime,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                block.endTime,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: textColor.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Container(
                              width: 1,
                              height: 36,
                              color: textColor.withOpacity(0.2)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  block.apparatus.toUpperCase(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  block.focus ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: textColor.withOpacity(0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  groupName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: textColor.withOpacity(0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '● AHORA',
                                style: GoogleFonts.montserrat(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNoScheduleCard(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildGlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.event_busy, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              'Sin bloques asignados hoy',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'El administrador aún no ha publicado el rol.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white38),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(Widget child,
      {required double height, Color? color, EdgeInsetsGeometry? padding}) {
    return Container(
      height: height,
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        border:
            Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMissionSection(Color primaryColor) {
    if (currentSlot == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildGlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.schedule, size: 60, color: Colors.white38),
              const SizedBox(height: 16),
              Text(
                'No hay clase activa en este momento',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona un grupo arriba para gestionar cualquier clase',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CoachDailySchedule(),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                label: Text(
                  'Ver Horario Completo',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor.withOpacity(0.5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Mi Misión',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: primaryColor.withOpacity(0.8), blurRadius: 8)
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.6),
                  primaryColor.withOpacity(0.2)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu Grupo Actual',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentSlot!.groupId,
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentSlot!.apparatus,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoachSessionScreen(
                          coach: currentUser,
                          currentSlot: currentSlot!,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.play_arrow, size: 24, color: primaryColor),
                  label: Text(
                    'Iniciar Clase',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildManualGroupSection(Color primaryColor, String groupName) {
    final studentsInGroup =
        _students.where((s) => s.group == groupName).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Alumnas de $groupName',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: primaryColor.withOpacity(0.8), blurRadius: 8)
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Gestión manual - Puedes tomar asistencia y evaluar',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          if (studentsInGroup.isEmpty)
            _buildGlassContainer(
              child: Center(
                child: Text(
                  'No hay alumnas en este grupo',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ),
            )
          else
            ...studentsInGroup.map((student) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _buildGlassContainer(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: primaryColor.withOpacity(0.2),
                            backgroundImage: getProfileImageProvider(student.photoUrl),
                            child: student.photoUrl == null
                                ? Text(student.name[0],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))
                                : null,
                          ),
                          title: Text(
                            student.name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            student.group,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                          trailing: _AttendanceButton(
                            coachId: widget.currentUser.id,
                            studentId: student.id,
                          ),
                        ),
                        Divider(color: Colors.white.withOpacity(0.2)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StudentDetailScreen(student: student),
                                  ),
                                );
                              },
                              icon: Icon(Icons.edit_note,
                                  size: 20, color: primaryColor),
                              label: Text(
                                'Evaluar',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildGlassContainer(
      {Widget? child,
      EdgeInsetsGeometry? padding,
      Color? color,
      Color? borderColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: borderColor ?? Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AttendanceButton extends StatefulWidget {
  final String coachId;
  final String studentId;

  const _AttendanceButton({required this.coachId, required this.studentId});

  @override
  State<_AttendanceButton> createState() => _AttendanceButtonState();
}

class _AttendanceButtonState extends State<_AttendanceButton> {
  int _statusIndex = 0;
  final List<Color> _colors = [
    Colors.white54,
    Colors.greenAccent,
    Colors.redAccent
  ];
  final List<IconData> _icons = [
    Icons.check_circle_outline,
    Icons.check_circle,
    Icons.cancel
  ];
  final List<String> _statusValues = ['pending', 'present', 'absent'];

  void _toggleStatus() async {
    final newIndex = (_statusIndex + 1) % 3;
    setState(() {
      _statusIndex = newIndex;
    });

    try {
      await FirestoreService.instance.saveAttendance(
        widget.coachId,
        widget.studentId,
        _statusValues[newIndex],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Asistencia guardada'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error guardando: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_icons[_statusIndex], color: _colors[_statusIndex], size: 32),
      onPressed: _toggleStatus,
      tooltip: 'Marcar Asistencia',
    );
  }
}
