import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/rotation_model.dart';
import '../models/schedule_model.dart'; // solo para TimeOfDayExtension
import '../models/group_model.dart';

import '../widgets/excel_table_view.dart';
import '../config/group_config.dart';
class AdminRoleBuilder extends StatefulWidget {
  const AdminRoleBuilder({super.key});

  @override
  State<AdminRoleBuilder> createState() => _AdminRoleBuilderState();
}

class _AdminRoleBuilderState extends State<AdminRoleBuilder> {
  String _selectedDay = 'Lunes';
  final List<String> _days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
  final List<String> _apparatus = [
    'Calentamiento', 'Salto', 'Barras', 'Viga', 'Piso',
    'Piso Acro', 'Piso Líneas', 'Flic-Flac', 'Prepa / Entrega',
    'Cal Tolerancia', 'Cal Piso', 'Viga Elementos', 'N2 / Cal',
    'Salto / Barras', 'Piso N1', 'Viga N1', 'Libre', 'General',
  ];

  List<String> get _groups => _officialGroups.map((g) => g.id).toList();
  List<GymGroup> _officialGroups = [];
  
  List<User> _staff = [];
  List<RotationSlot> _rotations = [];
  bool _isLoading = true;
  String? _error;

  StreamSubscription? _coachesSub;
  StreamSubscription? _rotationsSub;
  StreamSubscription? _groupsSub;
  int _loadedCount = 0;

  @override
  void initState() {
    super.initState();
    _initStreams();
  }

  void _initStreams() {
    _coachesSub = FirestoreService.instance.getCoaches().listen((data) {
      if (!mounted) return;
      _staff = data;
      _checkReady();
    }, onError: (e) {
      if (mounted) setState(() => _error = e.toString());
    });

    _rotationsSub = FirestoreService.instance.getAllRotations().listen((data) {
      if (!mounted) return;
      _rotations = data;
      _checkReady();
    }, onError: (e) {
      if (mounted) setState(() => _error = e.toString());
    });

    _groupsSub = FirestoreService.instance.getGroups().listen((data) {
      if (!mounted) return;
      _officialGroups = data;
      _checkReady();
    }, onError: (e) {
      if (mounted) setState(() => _error = e.toString());
    });
  }

  void _checkReady() {
    if (!mounted) return;
    if (_isLoading) {
      _loadedCount++;
      if (_loadedCount >= 3) {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _coachesSub?.cancel();
    _rotationsSub?.cancel();
    _groupsSub?.cancel();
    super.dispose();
  }

  Color _getCoachColor(String coachId) {
    if (_staff.isEmpty) return Colors.white10;
    try {
      final coach = _staff.firstWhere((c) => c.id == coachId);
      return Color(coach.colorHex ?? 0xFF9E9E9E);
    } catch (_) {
      return Colors.white10;
    }
  }

  String _getCoachName(String coachId) {
    if (_staff.isEmpty) return 'Sin asignar';
    try {
      final coach = _staff.firstWhere((c) => c.id == coachId);
      return coach.name;
    } catch (_) {
      return 'Sin asignar';
    }
  }

  Color _textColorFor(Color bg) {
    final luminance = (0.299 * bg.red + 0.587 * bg.green + 0.114 * bg.blue) / 255;
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  TimeOfDay _parseToTimeOfDay(String s) {
    final p = s.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  int _parseTime(String t) {
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  bool _hasOverlap(RotationSlot slot, List<RotationSlot> others) {
    final start = _parseTime(slot.startTime);
    final end = start + slot.durationMinutes;
    for (var o in others) {
      if (o.id == slot.id) continue;
      final oStart = _parseTime(o.startTime);
      final oEnd = oStart + o.durationMinutes;
      // Overlap condition: start1 < end2 AND end1 > start2
      if (start < oEnd && end > oStart) return true;
    }
    return false;
  }

  void _showEditModal(String group, RotationSlot? existing) {
    TimeOfDay selectedStart = existing != null ? _parseToTimeOfDay(existing.startTime) : const TimeOfDay(hour: 16, minute: 0);
    int selectedDuration = existing?.durationMinutes ?? 60;
    final durationController = TextEditingController(text: selectedDuration.toString());
    String selectedApparatus = existing?.apparatus ?? 'Libre';
    String? selectedCoach = existing?.coachId;
    final focusController = TextEditingController(text: existing?.focus ?? '');
    final notesController = TextEditingController(text: existing?.specialAssignments ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(existing == null ? 'Nueva Rotación - $group' : 'Editar Rotación - $group', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('$_selectedDay', style: GoogleFonts.poppins(color: Colors.white54)),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time),
                            label: Text('Inicio: ${selectedStart.format24}'),
                            onPressed: () async {
                              final t = await showTimePicker(context: context, initialTime: selectedStart);
                              if (t != null) setModalState(() => selectedStart = t);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Duración (min)', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: durationController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Ej: 45',
                                  hintStyle: const TextStyle(color: Colors.white24),
                                  isDense: true,
                                  suffixText: 'min',
                                  suffixStyle: const TextStyle(color: Colors.white38),
                                  filled: true,
                                  fillColor: Colors.white10,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                                onChanged: (val) {
                                  final d = int.tryParse(val);
                                  if (d != null && d >= 5 && d <= 180) {
                                    selectedDuration = d;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text('Coach', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _staff.any((c) => c.id == selectedCoach) ? selectedCoach : null,
                          hint: Text('Selecciona Coach', style: GoogleFonts.poppins(color: Colors.white38)),
                          dropdownColor: const Color(0xFF2A2A2A),
                          isExpanded: true,
                          items: (() {
                            final uniqueStaff = <String, User>{};
                            for (var coach in _staff) uniqueStaff[coach.id] = coach;
                            return uniqueStaff.values.map((c) {
                              final color = Color(c.colorHex ?? 0xFF9E9E9E);
                              return DropdownMenuItem(
                                value: c.id,
                                child: Row(
                                  children: [
                                    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                    const SizedBox(width: 8),
                                    Text(c.name, style: const TextStyle(color: Colors.white)),
                                  ],
                                ),
                              );
                            }).toList();
                          })(),
                          onChanged: (val) => setModalState(() => selectedCoach = val),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('Aparato', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _apparatus.contains(selectedApparatus) ? selectedApparatus : null,
                          dropdownColor: const Color(0xFF2A2A2A),
                          isExpanded: true,
                          items: _apparatus.toSet().toList().map((a) => DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(color: Colors.white)))).toList(),
                          onChanged: (val) => setModalState(() => selectedApparatus = val ?? 'Libre'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: focusController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Enfoque / Actividad',
                        labelStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: notesController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Notas / Tareas Especiales',
                        labelStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        if (existing != null)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await FirestoreService.instance.deleteRotation(existing.id);
                                if (mounted) Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 14)),
                              child: const Text('Borrar'),
                            ),
                          ),
                        if (existing != null) const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: selectedCoach == null ? null : () async {
                              // Asegurar que tomamos el valor del TextField
                              final d = int.tryParse(durationController.text);
                              if (d != null && d >= 5 && d <= 180) {
                                selectedDuration = d;
                              }

                              final startMins = selectedStart.hour * 60 + selectedStart.minute;
                              final endMins = startMins + selectedDuration;
                              final endHour = endMins ~/ 60;
                              final endMinute = endMins % 60;
                              final endStr = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
                              final startStr = selectedStart.format24;

                              final id = existing?.id ?? '${_selectedDay}_${startStr}_$group';
                              final slot = RotationSlot(
                                id: id,
                                day: _selectedDay,
                                startTime: startStr,
                                endTime: endStr,
                                durationMinutes: selectedDuration,
                                groupId: group,
                                apparatus: selectedApparatus,
                                coachId: selectedCoach!,
                                focus: focusController.text.trim(),
                                specialAssignments: notesController.text.trim(),
                              );
                              await FirestoreService.instance.saveRotation(slot);
                              if (mounted) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Guardar Asignación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

/// Abre el diálogo de tabla Excel con las rotaciones del día seleccionado
void _openExcelTableView() {
  // Debug info
  print('=== DEBUG Excel Table ===');
  print('Día seleccionado: $_selectedDay');
  print('Total de rotaciones: ${_rotations.length}');
  
  // Filtrar slots del día seleccionado
  final slotsForDay = _rotations
      .where((slot) => slot.day == _selectedDay)
      .toList();
  
  print('Rotaciones para hoy: ${slotsForDay.length}');
  
  // Crear mapa de coaches (id -> User)
  final Map<String, User> coachesMap = {};
  for (var coach in _staff) {
    coachesMap[coach.id] = coach;
    print('Coach: ${coach.name} - Color: ${coach.colorHex ?? "sin color"}');
  }
  
  print('Total coaches: ${coachesMap.length}');
  print('========================');
  
  // Abrir diálogo
  showDialog(
    context: context,
    builder: (context) => ExcelTableView(
      selectedDay: _selectedDay,
      slots: slotsForDay,
      coaches: coachesMap,
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    if (_error != null) return Scaffold(backgroundColor: const Color(0xFF121212), body: Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red))));
    if (_isLoading) return const Scaffold(backgroundColor: Color(0xFF121212), body: Center(child: CircularProgressIndicator(color: Color(0xFFE91E63))));

    final dayRotations = _rotations.where((r) => r.day == _selectedDay).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('Gestor de Rotaciones', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Day selector
              Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                final isSelected = day == _selectedDay;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(day, style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
                    selected: isSelected,
                    selectedColor: const Color(0xFFE91E63),
                    backgroundColor: Colors.white10,
                    onSelected: (_) => setState(() {
                      _selectedDay = day;
                    }),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Timeline body
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index];
                final groupRotations = dayRotations.where((r) => r.groupId == group).toList();
                groupRotations.sort((a, b) => _parseTime(a.startTime).compareTo(_parseTime(b.startTime)));

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(group, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.pinkAccent),
                            onPressed: () => _showEditModal(group, null),
                            tooltip: 'Añadir rotación',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (groupRotations.isEmpty)
                        Text('Sin asignaciones', style: GoogleFonts.poppins(color: Colors.white38, fontStyle: FontStyle.italic))
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: groupRotations.map((slot) {
                              final isOverlap = _hasOverlap(slot, groupRotations);
                              final coachColor = _getCoachColor(slot.coachId);
                              final textCol = _textColorFor(coachColor);
                              // Width scale: 2 pixels per minute
                              final width = slot.durationMinutes * 2.0;

                              return InkWell(
                                onTap: () => _showEditModal(group, slot),
                                child: Container(
                                  width: width < 100 ? 100 : width, // Minimum width for visibility
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: coachColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isOverlap ? Colors.redAccent : coachColor.withOpacity(0.5),
                                      width: isOverlap ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.schedule, size: 12, color: isOverlap ? Colors.redAccent : Colors.white70),
                                          const SizedBox(width: 4),
                                          Text('${slot.startTime} - ${slot.endTime}', style: GoogleFonts.poppins(fontSize: 11, color: isOverlap ? Colors.redAccent : Colors.white70, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: coachColor, borderRadius: BorderRadius.circular(4)),
                                        child: Text(_getCoachName(slot.coachId), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: textCol)),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(slot.apparatus, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                                      if (slot.focus != null && slot.focus!.isNotEmpty)
                                        Text(slot.focus!, style: GoogleFonts.poppins(fontSize: 10, color: Colors.cyanAccent), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
            ],
          ),
        ],
      ),
       floatingActionButton: FloatingActionButton.extended(
         onPressed: _openExcelTableView,
         icon: const Icon(Icons.table_chart),
         label: const Text('Ver Tabla General'),
         backgroundColor: Colors.blue,
         tooltip: 'Abrir vista de tabla Excel',
       ),
       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
     );
  }

}
