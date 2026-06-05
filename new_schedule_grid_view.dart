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
  final ScrollController _bodyVerticalController = ScrollController();
  final ScrollController _headerHorizontalController = ScrollController();

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

    _verticalController.addListener(() {
      if (_bodyVerticalController.hasClients &&
          _bodyVerticalController.offset != _verticalController.offset) {
        _bodyVerticalController.jumpTo(_verticalController.offset);
      }
    });

    _bodyVerticalController.addListener(() {
      if (_verticalController.hasClients &&
          _verticalController.offset != _bodyVerticalController.offset) {
        _verticalController.jumpTo(_bodyVerticalController.offset);
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
    _bodyVerticalController.dispose();
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

  int _timeToMinutes(String time) {
    if (time.isEmpty || !time.contains(':')) return 0;
    try {
      final parts = time.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (e) {
      print('Error parsing time "$time": $e');
      return 0;
    }
  }

  String _minutesToTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
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
    print('\n=========================================');
    print('🔍 DEBUG: Rotations de $_selectedDay: ${allRotations.length}');

    if (allRotations.isNotEmpty) {
      final firestoreGroups = allRotations.map((r) => r.groupId).toSet().toList()..sort();
      print('📊 DEBUG DATA: Grupos únicos en Firestore: $firestoreGroups');
      print('📋 DEBUG UI: Grupos disponibles: $_groups');
      
      print('\n🔄 COMPARACIÓN DE GRUPOS:');
      for (var uiGroup in _groups) {
        final matchInFirestore = firestoreGroups.any((fg) => fg == uiGroup);
        print('  UI: "$uiGroup" -> ${matchInFirestore ? "✅ EXISTE" : "❌ NO EXISTE"} en Firestore');
      }
    }
    print('=========================================\n');
    // === FIN DEBUG ===

    List<String> groups = [];
    List<String> timeLabels = [];

    if (allRotations.isNotEmpty) {
      // Extraer grupos únicos de las rotations
      final groupSet = allRotations.map((r) => r.groupId).toSet();
      groups = groupSet.toList()..sort();
      
      // Calcular rango dinámico
      int minMinutes = 16 * 60; // 960 (4:00 PM) default
      int maxMinutes = 20 * 60; // 1200 (8:00 PM) default

      int calculatedMin = 24 * 60;
      int calculatedMax = 0;
      for (final r in allRotations) {
        final start = _timeToMinutes(r.startTime);
        final end = start + r.durationMinutes;
        if (start < calculatedMin) calculatedMin = start;
        if (end > calculatedMax) calculatedMax = end;
      }
      // Redondear minMinutes hacia abajo al múltiplo de 30 más cercano
      minMinutes = (calculatedMin ~/ 30) * 30;
      // Redondear maxMinutes hacia arriba al múltiplo de 30 más cercano
      maxMinutes = ((calculatedMax + 29) ~/ 30) * 30;
      
      if (minMinutes < 0) minMinutes = 0;
      if (maxMinutes > 24 * 60) maxMinutes = 24 * 60;
      if (minMinutes >= maxMinutes) {
        minMinutes = 16 * 60;
        maxMinutes = 20 * 60;
      }

      for (int m = minMinutes; m < maxMinutes; m += 15) {
        timeLabels.add(_minutesToTime(m));
      }
      
      print('✅ DYNAMIC: Grupos calculados: $groups');
      print('✅ DYNAMIC: Horarios calculados (rango $minMinutes min a $maxMinutes min): $timeLabels');
    } else {
      print('⚠️ DYNAMIC: No hay rotations, usando listas vacías');
    }

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

    final String? filterCoachId = null;

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
    final double totalGridHeight = times.length * _cellHeight;
    return SingleChildScrollView(
      controller: _horizontalController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: _cellWidth * groups.length,
        child: ListView(
          controller: _bodyVerticalController,
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: totalGridHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: groups.map((group) {
                  return _buildGroupColumn(group, rotations, currentCoachId, times);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupColumn(String group, List<RotationSlot> rotations,
      String? currentCoachId, List<String> times) {
    final colSlots = rotations.where((r) => r.groupId == group).toList();
    final String minTimeStr = times.isNotEmpty ? times.first : '16:00';
    final int minMin = _timeToMinutes(minTimeStr);

    return Container(
      width: _cellWidth,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Stack(
        children: [
          // Background grid lines (one container per 15-minute cell)
          Column(
            children: List.generate(times.length, (index) {
              return Container(
                height: _cellHeight,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.02)),
                  ),
                ),
              );
            }),
          ),
          // Absolute positioned rotation slots
          ...colSlots.map((slot) {
            final startMin = _timeToMinutes(slot.startTime);
            final top = (startMin - minMin) / 15.0 * _cellHeight;
            final height = slot.durationMinutes / 15.0 * _cellHeight;

            final coach = _getCoach(slot.coachId);
            final isMyBlock = currentCoachId != null && slot.coachId == currentCoachId;
            final coachColor = coach.colorHex != null ? Color(coach.colorHex!) : Colors.cyan;
            final textCol = _textColorFor(coachColor);

            final isTiny  = height < 30;   // < 7.5 min
            final isSmall = height < 50;   // < 12.5 min
            final isMid   = height < 75;   // < 18.75 min

            return Positioned(
              top: top,
              left: 2,
              right: 2,
              height: height,
              child: Container(
                margin: const EdgeInsets.all(1),
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
                padding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: isTiny ? 1 : 3,
                ),
                child: isTiny
                    ? FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          slot.apparatus.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                            color: isMyBlock ? textCol : Colors.white,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Apparatus
                          Text(
                            slot.apparatus.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w800,
                              fontSize: isSmall ? 9 : (isMid ? 10 : 11),
                              color: isMyBlock ? textCol : Colors.white,
                              height: 1.1,
                            ),
                            maxLines: isSmall ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Focus/Description
                          if (!isSmall && slot.focus != null && slot.focus!.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              slot.focus!,
                              style: GoogleFonts.poppins(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: isMyBlock
                                    ? textCol.withOpacity(0.8)
                                    : Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          // Coach name
                          const SizedBox(height: 2),
                          Text(
                            coach.name.isNotEmpty ? coach.name.split(' ').first : '?',
                            style: GoogleFonts.poppins(
                              fontSize: isSmall ? 8 : 9,
                              color: isMyBlock
                                  ? textCol.withOpacity(0.6)
                                  : Colors.white70,
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
