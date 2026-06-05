import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/rotation_model.dart';
import '../models/user_model.dart';
import '../config/group_config.dart';
import '../widgets/edit_rotation_dialog.dart';

class RotationSabanaScreen extends StatefulWidget {
  final Map<String, User> coaches;
  final String? initialDay;

  const RotationSabanaScreen({
    super.key,
    required this.coaches,
    this.initialDay,
  });

  @override
  State<RotationSabanaScreen> createState() => _RotationSabanaScreenState();
}

class _RotationSabanaScreenState extends State<RotationSabanaScreen> {
  late String _selectedDay;
  final List<String> _days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];

  final double rowHeight = 60.0;
  final double columnWidth = 120.0;
  final double timeColumnWidth = 80.0;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDay ?? _getCurrentDayName();
  }

  String _getCurrentDayName() {
    final weekday = DateTime.now().weekday;
    if (weekday >= 1 && weekday <= _days.length) return _days[weekday - 1];
    return 'Lunes';
  }

  List<TimeSlotRow> _generateTimeSlotRows() {
    const startStr = '16:00';
    const endStr = '20:00';
    final startMin = _timeToMinutes(startStr);
    final endMin = _timeToMinutes(endStr);
    List<TimeSlotRow> rows = [];
    for (int m = startMin; m < endMin; m += 15) {
      rows.add(TimeSlotRow(startTime: _minutesToTime(m), durationMinutes: 15));
    }
    return rows;
  }

  List<PhysicalColumn> _getPhysicalColumns() {
    List<PhysicalColumn> cols = [];
    for (final config in groupConfigurations.values) {
      if (config.columns == 1) {
        cols.add(PhysicalColumn(groupId: config.groupId, displayName: config.displayName));
      } else {
        for (final sub in config.subgroups ?? []) {
          cols.add(PhysicalColumn(
            groupId: config.groupId,
            subgroupId: sub,
            displayName: '${config.displayName} $sub',
          ));
        }
      }
    }
    return cols;
  }

  Color _getCoachColor(String coachId) {
    final coach = widget.coaches[coachId];
    if (coach == null) return Colors.grey.withOpacity(0.3);
    if (coach.colorHex != null) {
      return Color(coach.colorHex!);
    }
    return Colors.grey.withOpacity(0.3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'SÁBANA DE ROTACIONES',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Selector de día
          ..._days.map((day) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(day, style: TextStyle(fontSize: 12, color: _selectedDay == day ? Colors.white : Colors.white70)),
              selected: _selectedDay == day,
              onSelected: (val) {
                if (val) setState(() => _selectedDay = day);
              },
              selectedColor: const Color(0xFFE91E63),
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          )).toList(),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rotations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final allSlots = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return RotationSlot.fromJson({...data, 'id': doc.id});
          }).toList();

          final filteredSlots = allSlots.where((slot) => 
            slot.day.trim().toLowerCase() == _selectedDay.trim().toLowerCase()
          ).toList();

          final timeRows = _generateTimeSlotRows();
          final physicalCols = _getPhysicalColumns();

          return Column(
            children: [
              // Leyenda de coaches
              _buildCoachLegend(),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimeColumn(timeRows),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: physicalCols.map((col) => _buildGroupColumn(col, timeRows, filteredSlots)).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCoachLegend() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.black,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: widget.coaches.values.map((coach) {
          final color = coach.colorHex != null ? Color(coach.colorHex!) : Colors.grey;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(coach.name.split(' ').first, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeColumn(List<TimeSlotRow> rows) {
    return Container(
      width: timeColumnWidth,
      decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white12))),
      child: Column(
        children: [
          Container(
            height: 50,
            alignment: Alignment.center,
            color: const Color(0xFF2A2A2A),
            child: const Text('HORA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11)),
          ),
          ...rows.map((row) => Container(
            height: (row.durationMinutes / 15) * rowHeight,
            alignment: Alignment.center,
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
            child: Text(
              '${row.startTime}\n${_calculateEndTime(row.startTime, row.durationMinutes)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildGroupColumn(PhysicalColumn col, List<TimeSlotRow> timeRows, List<RotationSlot> slots) {
    final colSlots = slots.where((s) {
      final matchesGroup = s.groupId == col.groupId;
      final matchesSub = col.subgroupId == null || s.subgroupId == col.subgroupId;
      return matchesGroup && matchesSub;
    }).toList();

    return Container(
      width: columnWidth,
      decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white12))),
      child: Column(
        children: [
          Container(
            height: 50,
            alignment: Alignment.center,
            color: const Color(0xFF2A2A2A),
            child: Text(col.displayName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11), textAlign: TextAlign.center),
          ),
          SizedBox(
            height: timeRows.fold<double>(0, (sum, r) => sum + (r.durationMinutes / 15) * rowHeight),
            child: Stack(
              children: [
                Column(
                  children: timeRows.map((row) {
                    return InkWell(
                      onTap: () => _openSlotEditor(col: col, startTime: row.startTime),
                      child: Container(
                        height: (row.durationMinutes / 15) * rowHeight,
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
                      ),
                    );
                  }).toList(),
                ),
                ...colSlots.map((slot) {
                  final top = ( _timeToMinutes(slot.startTime) - _timeToMinutes('16:00') ) / 15 * rowHeight;
                  final height = (slot.durationMinutes / 15) * rowHeight;
                  final bg = _getCoachColor(slot.coachId);
                  final coachName = _getCoachFirstName(slot.coachId);
                  
                  // Contraste de texto según luminancia del fondo
                  final textColor = _textColorFor(bg);
                  final subTextColor = textColor.withValues(alpha: 0.75);
                  
                  // Layout adaptativo según altura disponible
                  final isTiny  = height < 30;   // < 7.5 min: solo aparato en tiny font
                  final isSmall = height < 50;   // < 12.5 min: aparato + coach en mini
                  final isMid   = height < 75;   // < 18.75 min: aparato bold + coach

                  return Positioned(
                    top: top,
                    left: 0,
                    right: 0,
                    height: height,
                    child: Tooltip(
                      message: _buildSlotTooltip(slot),
                      preferBelow: false,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      child: InkWell(
                        onTap: () => _openSlotEditor(slot: slot),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: bg.withValues(alpha: 0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 9,
                                      color: textColor,
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
                                    // Aparato
                                    Text(
                                      slot.apparatus.toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: isSmall ? 9 : (isMid ? 10 : 11),
                                        color: textColor,
                                        height: 1.1,
                                      ),
                                      maxLines: isSmall ? 1 : 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // Coach name
                                    if (coachName.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        coachName,
                                        style: TextStyle(
                                          fontSize: isSmall ? 8 : 9,
                                          color: subTextColor,
                                          fontWeight: FontWeight.w600,
                                          height: 1.0,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    // Badge de grupos vinculados
                                    if (!isTiny &&
                                        slot.linkedSlots != null &&
                                        slot.linkedSlots!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.link, size: 9, color: textColor.withValues(alpha: 0.8)),
                                          const SizedBox(width: 2),
                                          Text(
                                            '+${slot.linkedSlots!.length}',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: textColor.withValues(alpha: 0.8),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers de coach ────────────────────────────────────────────────────────

  String _getCoachFirstName(String coachId) {
    final coach = widget.coaches[coachId];
    if (coach == null || coach.name.isEmpty) return '';
    return coach.name.split(' ').first;
  }

  /// Contraste de texto (blanco o negro) según luminancia del fondo.
  Color _textColorFor(Color bg) {
    final luminance = (0.299 * bg.red + 0.587 * bg.green + 0.114 * bg.blue) / 255;
    return luminance > 0.55 ? Colors.black87 : Colors.white;
  }

  /// Tooltip con detalles del slot.
  String _buildSlotTooltip(RotationSlot slot) {
    final coach = widget.coaches[slot.coachId];
    final lines = <String>[
      '${slot.apparatus.toUpperCase()} · ${slot.groupId.toUpperCase()}',
      '${slot.startTime} → ${slot.endTime}  (${slot.durationMinutes} min)',
      if (coach != null) 'Coach: ${coach.name}',
      if (slot.focus != null && slot.focus!.isNotEmpty) 'Enfoque: ${slot.focus}',
      if (slot.linkedSlots != null && slot.linkedSlots!.isNotEmpty)
        '🔗 Vinculado con ${slot.linkedSlots!.length} grupo(s) más',
    ];
    return lines.join('\n');
  }

  void _openSlotEditor({PhysicalColumn? col, String? startTime, RotationSlot? slot}) {
    if (slot == null) return;
    showDialog(
      context: context,
      builder: (_) => EditRotationDialog(
        slot: slot,
        onSaved: () => setState(() {}),
      ),
    );
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _minutesToTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String _calculateEndTime(String start, int duration) {
    final startM = _timeToMinutes(start);
    return _minutesToTime(startM + duration);
  }
}

// Modelo auxiliar para la fila horaria.
class TimeSlotRow {
  final String startTime;
  final int durationMinutes;

  const TimeSlotRow({required this.startTime, required this.durationMinutes});
}
