import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../services/firestore_service.dart';
import '../models/schedule_model.dart';
import '../models/rotation_model.dart';
import '../models/user_model.dart';

class ScheduleGridView extends StatefulWidget {
  final User currentUser;
  final String? initialDay;

  const ScheduleGridView({
    super.key,
    required this.currentUser,
    this.initialDay,
  });

  @override
  State<ScheduleGridView> createState() => _ScheduleGridViewState();
}

class _ScheduleGridViewState extends State<ScheduleGridView> {
  late String _selectedDay;
  final List<String> _days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado'
  ];

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _headerHorizontalController = ScrollController();

  // Time blocks (16:30, 16:45, etc.)
  // (Matching Reference Image)
  final List<String> _timeLabels = [
    '16:30',
    '16:45',
    '16:50',
    '17:00',
    '17:15',
    '17:20',
    '17:30',
    '17:35',
    '17:45',
    '17:55',
    '18:00',
    '18:15',
    '18:25',
    '18:50',
    '19:10',
    '19:30'
  ];

  List<String> get _groups {
    final groups = FirestoreService.availableGroups;
    print('📋 DEBUG UI: Grupos disponibles en interfaz: $groups');
    return groups;
  }
  List<User> _coaches = [];
  List<RotationSlot> _allRotations = [];

  StreamSubscription? _rotSub;
  StreamSubscription? _coachSub;

  static const double _timeColumnWidth = 75;
  static const double _cellWidth = 120;
  static const double _cellHeight = 65;
  static const double _headerHeight = 50;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDay ?? _getCurrentDay();
    _horizontalController.addListener(() {
      if (_headerHorizontalController.hasClients) {
        _headerHorizontalController.jumpTo(_horizontalController.offset);
      }
    });

    _rotSub = FirestoreService.instance.getAllRotations().listen(
      (data) {
        print(
            '🔍 DEBUG ScheduleGridView: Rotations recibidas del stream: ${data?.length ?? 0}');
        if (data != null) {
          for (var r in data.take(3)) {
            print(
                '  - ${r.day} ${r.startTime}-${r.endTime} ${r.groupId} ${r.apparatus}');
          }
        }
        if (mounted) {
          setState(() {
            _allRotations = data ?? [];
          });
        }
      },
      onError: (error) {
        print('❌ ERROR en stream getAllRotations: $error');
        if (mounted) {
          setState(() {
            _allRotations = [];
          });
        }
      },
    );

    _coachSub = FirestoreService.instance.getCoaches().listen(
      (data) {
        print('🔍 DEBUG ScheduleGridView: Coaches recibidos: ${data?.length ?? 0}');
        if (mounted) {
          setState(() {
            _coaches = data ?? [];
          });
        }
      },
      onError: (error) {
        print('❌ ERROR en stream getCoaches: $error');
      },
    );
    print('⏰ DEBUG UI: Horarios definidos: $_timeLabels');
    print('⏰ DEBUG UI: Total slots de tiempo: ${_timeLabels.length}');
  }

  String _getCurrentDay() {
    final weekday = DateTime.now().weekday;
    if (weekday >= 1 && weekday <= 6) return _days[weekday - 1];
    return 'Lunes';
  }

  @override
  void dispose() {
    _rotSub?.cancel();
    _coachSub?.cancel();
    _horizontalController.dispose();
    _verticalController.dispose();
    _headerHorizontalController.dispose();
    super.dispose();
  }

  User _getCoach(String coachId) {
    final coach = _coaches.firstWhere(
      (c) => c.id == coachId, 
      orElse: () {
        print('⚠️ WARNING: Coach no encontrado: $coachId');
        return User(id: 'dummy', name: '?', email: '', role: UserRole.coach);
      }
    );
    return coach;
  }

  // === HELPER PARA DEBUGGING ===
  void _debugCellMatch(String uiGroup, String uiTime, List<RotationSlot> allRotations) {
    final matches = allRotations.where((r) => 
      r.groupId == uiGroup && r.startTime == uiTime
    ).toList();
    
    if (matches.isEmpty) {
      // Buscar coincidencias parciales para diagnosticar
      final groupMatches = allRotations.where((r) => r.groupId == uiGroup).length;
      final timeMatches = allRotations.where((r) => r.startTime == uiTime).length;
      
      print('❌ MATCH: grupo:"$uiGroup" hora:"$uiTime" - 0 matches (${groupMatches} con grupo, ${timeMatches} con hora)');
    } else {
      print('✅ MATCH: grupo:"$uiGroup" hora:"$uiTime" - ${matches.length} rotation(s) encontrada(s)');
    }
  }

  Color _textColorFor(Color bg) {
    final luminance =
        (0.299 * bg.red + 0.587 * bg.green + 0.114 * bg.blue) / 255;
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final allRotations = _allRotations
        .where((r) => r.day == _selectedDay)
        .toList();

    // === DEBUGGING EXHAUSTIVO ===
    print('\n═══════════════════════════════════════');
    print('🔍 DEBUG: Rotations de $_selectedDay: ${allRotations.length}');

    if (allRotations.isNotEmpty) {
      // Grupos en Firestore
      final firestoreGroups = allRotations.map((r) => r.groupId).toSet().toList()..sort();
      print('📊 DEBUG DATA: Grupos únicos en Firestore: $firestoreGroups');
      
      // Grupos en UI
      print('📋 DEBUG UI: Grupos disponibles: $_groups');
      
      // Comparación directa
      print('\n🔄 COMPARACIÓN DE GRUPOS:');
      for (var uiGroup in _groups) {
        final matchInFirestore = firestoreGroups.any((fg) => fg == uiGroup);
        print('  UI: "$uiGroup" -> ${matchInFirestore ? "✅ EXISTE" : "❌ NO EXISTE"} en Firestore');
      }
      
      // Horarios en Firestore
      final firestoreTimes = allRotations.map((r) => r.startTime).toSet().toList()..sort();
      print('\n⏰ DEBUG DATA: Horarios únicos en Firestore (primeros 10): ${firestoreTimes.take(10).toList()}');
      print('⏰ DEBUG UI: Horarios definidos: $_timeLabels');
      
      // Muestra detallada de primeras 3 rotations
      print('\n📝 MUESTRA DE ROTATIONS:');
      for (var i = 0; i < 3 && i < allRotations.length; i++) {
        final r = allRotations[i];
        print('  ${i+1}. grupo:"${r.groupId}" | hora:"${r.startTime}" | aparato:${r.apparatus}');
      }
    }
    print('═══════════════════════════════════════\n');
    // === FIN DEBUG ===

    // ============================================================
    // GRUPOS Y HORARIOS DINÁMICOS (extraídos de rotations reales)
    // ============================================================

    List<String> groups = [];
    List<String> timeLabels = [];

    if (allRotations.isNotEmpty) {
      // Extraer grupos únicos de las rotations
      final groupSet = allRotations.map((r) => r.groupId).toSet();
      groups = groupSet.toList()..sort();
      
      // Extraer horarios únicos de las rotations
      final timeSet = allRotations.map((r) => r.startTime).toSet();
      timeLabels = timeSet.toList()..sort();
      
      print('✅ DYNAMIC: Grupos calculados: $groups');
      print('✅ DYNAMIC: Horarios calculados: $timeLabels');
    } else {
      print('⚠️ DYNAMIC: No hay rotations, usando listas vacías');
    }

    // ============================================================

    // Si no hay grupos después de calcular dinámicamente, mostrar mensaje
    if (groups.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          title: Text('Sábana de Rotaciones', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Text(
            'No hay rotations para $_selectedDay',
            style: GoogleFonts.roboto(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    // Filter logic: if user is coach, we might want to highlight their blocks
    final String? filterCoachId =
        null; // ← DESACTIVADO: mostrar todas las rotations para todos los usuarios

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: Text('Sábana de Rotaciones',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Day selector
          _buildDaySelector(),
          const SizedBox(height: 8),

          // Legend
          _buildCoachLegend(),
          const SizedBox(height: 12),

          Expanded(
            child: allRotations.isEmpty
                ? _buildEmptyState()
                : _buildGrid(allRotations, filterCoachId, groups, timeLabels),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final day = _days[index];
          final isSelected = day == _selectedDay;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(day,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  )),
              selected: isSelected,
              selectedColor: const Color(0xFFE91E63),
              backgroundColor: Colors.white.withOpacity(0.05),
              onSelected: (_) => setState(() => _selectedDay = day),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoachLegend() {
    return Container(
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _coaches.length,
        itemBuilder: (context, index) {
          final coach = _coaches[index];
          final color =
              coach.colorHex != null ? Color(coach.colorHex!) : Colors.cyan;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(coach.name.split(' ').first,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.white70)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_busy, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text('No hay horarios para $_selectedDay',
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Se requiere carga administrativa',
              style: GoogleFonts.poppins(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildGrid(List<RotationSlot> rotations, String? currentCoachId,
      List<String> groups, List<String> times) {
    return Column(
      children: [
        // Headers
        _buildStickyHeader(groups),

        // Grid Body
        Expanded(
          child: Row(
            children: [
              _buildTimeColumn(times),
              Expanded(
                child: _buildScrollableBody(rotations, currentCoachId, groups, times),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStickyHeader(List<String> groups) {
    return Row(
      children: [
        Container(
          width: _timeColumnWidth,
          height: _headerHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            border: Border.all(color: Colors.white12),
          ),
          child: Center(
            child: Text('HORA',
                style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white38)),
          ),
        ),
        Expanded(
          child: Container(
            height: _headerHeight,
            decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              controller: _headerHorizontalController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return Container(
                  width: _cellWidth,
                  height: _headerHeight,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.white10)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(groups[index],
                            style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeColumn(List<String> times) {
    return SizedBox(
      width: _timeColumnWidth,
      child: ListView.builder(
        controller: _verticalController,
        itemCount: times.length,
        itemBuilder: (context, index) {
          return Container(
            height: _cellHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Center(
              child: Text(times[index],
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white60)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScrollableBody(List<RotationSlot> rotations,
      String? currentCoachId, List<String> groups, List<String> times) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          if (_verticalController.hasClients) {
            _verticalController.jumpTo(scrollNotification.metrics.pixels);
          }
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _cellWidth * groups.length,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: times.length,
            itemBuilder: (context, rowIndex) {
              final String timeLabel = times[rowIndex];
              return SizedBox(
                height: _cellHeight,
                child: Row(
                  children: List.generate(groups.length, (colIndex) {
                    final group = groups[colIndex];
                    _debugCellMatch(group, timeLabel, rotations);
                    final entry = rotations.firstWhere(
                      (e) => e.startTime == timeLabel && e.groupId == group,
                      orElse: () => RotationSlot(
                        id: '',
                        coachId: '',
                        groupId: '',
                        day: '',
                        startTime: '',
                        endTime: '',
                        durationMinutes: 0,
                        apparatus: '',
                      ),
                    );

                    if (entry.id.isEmpty) {
                      return Container(
                        width: _cellWidth,
                        height: _cellHeight,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.white.withOpacity(0.02))),
                      );
                    }

                    final coach = _getCoach(entry.coachId);
                    final isMyBlock = currentCoachId != null &&
                        entry.coachId == currentCoachId;
                    final coachColor = coach.colorHex != null
                        ? Color(coach.colorHex!)
                        : Colors.cyan;
                    final textCol = _textColorFor(coachColor);

                    return Container(
                      width: _cellWidth,
                      height: _cellHeight,
                      decoration: BoxDecoration(
                        color: coachColor.withOpacity(isMyBlock ? 1.0 : 0.4),
                        borderRadius: BorderRadius.circular(4),
                        border: isMyBlock
                            ? Border.all(color: Colors.white, width: 2)
                            : Border.all(color: Colors.white10),
                        boxShadow: isMyBlock
                            ? [
                                BoxShadow(
                                    color: coachColor.withOpacity(0.5),
                                    blurRadius: 10)
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(entry.apparatus,
                              style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: isMyBlock ? textCol : Colors.white)),
                          const SizedBox(height: 2),
                          Text(entry.focus ?? '',
                              style: GoogleFonts.poppins(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: isMyBlock
                                      ? textCol.withOpacity(0.8)
                                      : Colors.white70),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(coach.name,
                              style: GoogleFonts.poppins(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: isMyBlock
                                      ? textCol.withOpacity(0.6)
                                      : Colors.white38)),
                        ],
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
