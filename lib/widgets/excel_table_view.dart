import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rotation_model.dart';
import '../models/user_model.dart';
import '../config/group_config.dart';
import 'edit_rotation_dialog.dart';

/// Widget que muestra las rotaciones en una tabla tipo Excel.
class ExcelTableView extends StatefulWidget {
  final String selectedDay;
  final List<RotationSlot> slots;
  final Map<String, User> coaches;
  // Configuración opcional de horario (startHour/endHour en "HH:mm").
  final ScheduleConfig? config;

  const ExcelTableView({
    Key? key,
    required this.selectedDay,
    required this.slots,
    required this.coaches,
    this.config,
  }) : super(key: key);

  @override
  State<ExcelTableView> createState() => _ExcelTableViewState();
}

class _ExcelTableViewState extends State<ExcelTableView> {
  // altura por cada franja de 15 minutos
  final double rowHeight = 60.0;
  final double timeColumnWidth = 80.0;
  final double columnWidth = 120.0;

  // ---------- HELPERS ----------
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _minutesToTime(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Genera la lista de franjas horarias a partir de la configuración.
  List<TimeSlotRow> _generateTimeSlotRows() {
    final startStr = widget.config?.startHour ?? '16:00';
    final endStr = widget.config?.endHour ?? '20:00';
    final startMin = _timeToMinutes(startStr);
    final endMin = _timeToMinutes(endStr);
    List<TimeSlotRow> rows = [];
    for (int m = startMin; m < endMin; m += 15) {
      rows.add(TimeSlotRow(startTime: _minutesToTime(m), durationMinutes: 15));
    }
    return rows;
  }

  /// Obtiene la lista de columnas físicas (grupo + sub‑grupo) que deben mostrarse.
  List<PhysicalColumn> _getPhysicalColumns() {
    List<PhysicalColumn> cols = [];
    for (final config in groupConfigurations.values) {
      if (config.columns == 1) {
        cols.add(PhysicalColumn(groupId: config.groupId, displayName: config.displayName));
      } else {
        // crear una columna por cada sub‑grupo definido
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

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rotations').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        // --- LOGS SOLICITADOS ---
        print('🔍 Total documentos de Firestore: ${snapshot.data?.docs.length ?? 0}');
        print('🔍 Día seleccionado: ${widget.selectedDay}');

        final allSlots = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return RotationSlot.fromJson({...data, 'id': doc.id});
        }).toList();

        print('🔍 Total slots parseados: ${allSlots.length}');

        final filteredSlots = allSlots.where((slot) => 
          slot.day.trim().toLowerCase() == widget.selectedDay.trim().toLowerCase()
        ).toList();

        print('🔍 Slots después de filtrar por día: ${filteredSlots.length}');
        print('🔍 Primeros 5 slots:');
        for (var slot in filteredSlots.take(5)) {
          print('  - ${slot.startTime} ${slot.groupId} ${slot.apparatus}');
        }
        // -------------------------

        final timeRows = _generateTimeSlotRows();
        final physicalCols = _getPhysicalColumns();

        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: MediaQuery.of(context).size.width * 0.95,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ROTACIONES - ${widget.selectedDay.toUpperCase()}',
                      style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Colors.white24),
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
            ),
          ),
        );
      },
    );
  }

  // ---------- Columna de tiempo ----------
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
            child: const Text('HORARIO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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

  String _calculateEndTime(String start, int duration) {
    final startM = _timeToMinutes(start);
    return _minutesToTime(startM + duration);
  }

  int _timeDiff(String time1, String time2) {
    final t1Parts = time1.split(':');
    final t2Parts = time2.split(':');
    final t1Min = int.parse(t1Parts[0]) * 60 + int.parse(t1Parts[1]);
    final t2Min = int.parse(t2Parts[0]) * 60 + int.parse(t2Parts[1]);
    return t2Min - t1Min;
  }

  // ---------- Columna de grupo ----------
  Widget _buildGroupColumn(PhysicalColumn col, List<TimeSlotRow> timeRows, List<RotationSlot> slots) {
    final colSlots = slots.where((s) {
      final matchesGroup = s.groupId == col.groupId;
      // Si la columna NO tiene subgrupo → acepta TODOS los slots del grupo
      // Si la columna SÍ tiene subgrupo → filtra exactamente ese subgrupo
      final matchesSub = col.subgroupId == null || s.subgroupId == col.subgroupId;
      return matchesGroup && matchesSub;
    }).toList();

    // Debug de Gaps
    final sortedSlots = List<RotationSlot>.from(colSlots)..sort((a, b) => a.startTime.compareTo(b.startTime));
    for (int i = 0; i < sortedSlots.length - 1; i++) {
      final current = sortedSlots[i];
      final next = sortedSlots[i + 1];
      if (current.endTime != next.startTime) {
        print('⚠️ GAP DETECTADO en ${current.groupId}:');
        print('   ${current.apparatus} termina: ${current.endTime}');
        print('   ${next.apparatus} inicia: ${next.startTime}');
        print('   Diferencia: ${_timeDiff(current.endTime, next.startTime)} min');
      }
    }

    print('🔍 DEBUG - Columna: ${col.displayName}');
    print('🔍 DEBUG - Slots después de filtrar: ${colSlots.length}');
    if (colSlots.isNotEmpty) {
      print('🔍 DEBUG - Primer slot: ${colSlots.first.day} - ${colSlots.first.groupId}');
    }

    return Container(
      width: columnWidth,
      decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white12))),
      child: Column(
        children: [
          // Header del grupo
          Container(
            height: 50,
            alignment: Alignment.center,
            color: const Color(0xFF2A2A2A),
            child: Text(col.displayName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
          ),
          // Celdas (uso de Stack para posicionar bloques con row‑span)
          SizedBox(
            height: timeRows.fold<double>(0, (sum, r) => sum + (r.durationMinutes / 15) * rowHeight),
            child: Stack(
              children: [
                // Fondo: cuadrícula de celdas vacías (para que sea clickeable)
                Column(
                  children: timeRows.map((row) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openSlotEditor(col: col, startTime: row.startTime),
                        hoverColor: Colors.white.withOpacity(0.05),
                        child: Container(
                          height: (row.durationMinutes / 15) * rowHeight,
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
                          child: const Center(
                            child: Icon(Icons.add, color: Colors.white12, size: 20),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // Slots ocupados
                ...colSlots.map((slot) {
                  final top = ( _timeToMinutes(slot.startTime) - _timeToMinutes(widget.config?.startHour ?? '16:00') ) / 15 * rowHeight;
                  final height = (slot.durationMinutes / 15) * rowHeight;
                  final bg = _getCoachColor(slot.coachId);
                  final isVerySmall = height < 30; // slots de 5-7 min
                  final isSmall = height < 55;     // slots de 10-13 min
                  return Positioned(
                    top: top,
                    left: 0,
                    right: 0,
                    height: height,
                    child: InkWell(
                      onTap: () => _openSlotEditor(slot: slot),
                      child: ClipRect( // evita overflow visual
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 3,
                            vertical: isVerySmall ? 1 : 2,
                          ),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: (slot.linkedSlots != null && slot.linkedSlots!.isNotEmpty)
                                ? [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                            border: (slot.linkedSlots != null && slot.linkedSlots!.isNotEmpty)
                                ? Border.all(color: Colors.amber, width: 1)
                                : null,
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: isVerySmall ? 0 : 2,
                                  ),
                                  child: isVerySmall
                                      ? FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            slot.apparatus.toUpperCase(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              slot.apparatus.toUpperCase(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: isSmall ? 10 : 12,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (!isSmall && slot.internalRotation != null && slot.internalRotation!.isNotEmpty)
                                              Text(
                                                slot.internalRotation!,
                                                style: const TextStyle(fontSize: 9, color: Colors.white70),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                ),
                              ),
                              if (slot.linkedSlots != null && slot.linkedSlots!.isNotEmpty)
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.amber,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.link,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
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

  // ---------- Interacción ----------
  void _openSlotEditor({PhysicalColumn? col, String? startTime, RotationSlot? slot}) {
    if (slot == null && col != null && startTime != null) {
      final startM = _timeToMinutes(startTime);
      final endTime = _minutesToTime(startM + 30);

      final newSlot = RotationSlot(
        id: '',
        groupId: col.groupId,
        day: widget.selectedDay,
        startTime: startTime,
        endTime: endTime,
        durationMinutes: 30,
        apparatus: '',
        coachId: '',
        focus: '',
        links: '',
        exercises: '',
        internalRotation: '',
        subgroupId: col.subgroupId,
      );

      showDialog(
        context: context,
        builder: (_) => EditRotationDialog(
          slot: newSlot,
          isCreating: true,
          onSaved: () => setState(() {}),
        ),
      );
      return;
    }
    
    if (slot != null) {
      showDialog(
        context: context,
        builder: (_) => EditRotationDialog(
          slot: slot,
          onSaved: () => setState(() {}),
        ),
      );
    }
  }
}

// Modelo auxiliar para la fila horaria.
class TimeSlotRow {
  final String startTime;
  final int durationMinutes;

  const TimeSlotRow({required this.startTime, required this.durationMinutes});
}

class ScheduleConfig {
  final String startHour;
  final String endHour;

  const ScheduleConfig({
    required this.startHour,
    required this.endHour,
  });
}
