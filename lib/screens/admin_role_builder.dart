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
      // Botón de arreglo de colores (temporal)
      Positioned(
        bottom: 160,
        right: 20,
        child: FloatingActionButton.extended(
          heroTag: 'colors',
          onPressed: () async {
            try {
              await _updateCoachColors();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Colores actualizados en Firestore'),
                  backgroundColor: Colors.purple,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          label: const Text('Fix Colors'),
          icon: const Icon(Icons.palette),
          backgroundColor: Colors.purple,
        ),
      ),
      // Botón de migración (solo mostrar en desarrollo)
      Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton.extended(
              heroTag: 'migrate',
              onPressed: () async {
                // Mostrar confirmación
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Migración de Datos'),
                    content: Text('¿Ejecutar migración? Esto borrará todas las rotaciones existentes.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Ejecutar'),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  // Ejecutar migración
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ejecutando migración...')),
                  );
                  
                  try {
                    await _executeMigration(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Migración completada'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              label: Text('Migrar'),
              icon: Icon(Icons.cloud_upload),
              backgroundColor: Colors.orange,
            ),
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

  Future<void> _executeMigration(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    
    // 1. Cargar coaches
    final coachesSnapshot = await firestore
        .collection('users')
        .where('role', isEqualTo: 'coach')
        .get();
    
    final Map<String, String> coachIds = {};
    for (var doc in coachesSnapshot.docs) {
      final name = (doc.data()['name'] as String).toLowerCase();
      coachIds[name] = doc.id;
    }
    
    if (coachIds.isEmpty) {
      throw Exception('No coaches found');
    }
    
    // 2. Borrar rotaciones existentes
    final rotationsSnapshot = await firestore.collection('rotations').get();
    final batch1 = firestore.batch();
    for (var doc in rotationsSnapshot.docs) {
      batch1.delete(doc.reference);
    }
    await batch1.commit();
    
    // 3. Crear TODOS los slots
    await _createAllSlots(firestore, coachIds);

    // Verificar que se guardaron
    final snapshot = await firestore.collection('rotations').get();
    
    print('✅ MIGRACIÓN COMPLETA');
    print('📊 Total documentos en Firestore: ${snapshot.docs.length}');
    
    // Contar por día
    final lunesCount = snapshot.docs.where((d) => (d.data()['day'] as String).toLowerCase() == 'lunes').length;
    final martesCount = snapshot.docs.where((d) => (d.data()['day'] as String).toLowerCase() == 'martes').length;
    final miercolesCount = snapshot.docs.where((d) => (d.data()['day'] as String).toLowerCase() == 'miércoles').length;
    final juevesCount = snapshot.docs.where((d) => (d.data()['day'] as String).toLowerCase() == 'jueves').length;
    final viernesCount = snapshot.docs.where((d) => (d.data()['day'] as String).toLowerCase() == 'viernes').length;
    
    print('  Lunes: $lunesCount slots');
    print('  Martes: $martesCount slots');
    print('  Miércoles: $miercolesCount slots');
    print('  Jueves: $juevesCount slots');
    print('  Viernes: $viernesCount slots');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Migración completada: ${snapshot.docs.length} slots'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _createAllSlots(FirebaseFirestore firestore, Map<String, String> coachIds) async {
    final allSlots = <Map<String, dynamic>>[];
    
    // MIÉRCOLES - 52 slots
    allSlots.addAll(_getMiercolesSlots(coachIds));
    
    // MARTES - 48 slots  
    allSlots.addAll(_getMartesSlots(coachIds));
    
    // LUNES - 15 slots básicos
    allSlots.addAll(_getLunesSlots(coachIds));
    
    // JUEVES - 15 slots básicos
    allSlots.addAll(_getJuevesSlots(coachIds));
    
    // VIERNES - 15 slots básicos
    allSlots.addAll(_getViernesSlots(coachIds));
    
    print('📊 RESUMEN DE MIGRACIÓN:');
    print('  Miércoles: ${_getMiercolesSlots(coachIds).length} slots');
    print('  Martes: ${_getMartesSlots(coachIds).length} slots');
    print('  Lunes: ${_getLunesSlots(coachIds).length} slots');
    print('  Jueves: ${_getJuevesSlots(coachIds).length} slots');
    print('  Viernes: ${_getViernesSlots(coachIds).length} slots');
    print('  TOTAL: ${allSlots.length} slots');
    
    // Guardar en batches de 500
    for (int i = 0; i < allSlots.length; i += 500) {
      final batch = firestore.batch();
      final end = (i + 500 < allSlots.length) ? i + 500 : allSlots.length;
      
      for (int j = i; j < end; j++) {
        final ref = firestore.collection('rotations').doc();
        batch.set(ref, allSlots[j]);
      }
      
      await batch.commit();
    }
  }

  // Helper para crear slot
  Map<String, dynamic> _createSlot(
    String day,
    String groupId,
    String? subgroupId,
    String startTime,
    int duration,
    String? apparatus,
    String? coachName,
    Map<String, String> coachIds, [
    String? focus,
    String? internalRotation,
  ]) {
    final endTime = _calculateEndTime(startTime, duration);
    final coachId = coachName != null 
        ? (coachIds[coachName.toLowerCase()] ?? coachIds.values.first)
        : coachIds.values.first;
    
    return {
      'groupId': groupId,
      'subgroupId': subgroupId,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'durationMinutes': duration,
      'apparatus': apparatus ?? '',
      'coachId': coachId,
      'focus': focus,
      'internalRotation': internalRotation,
      'specialAssignments': '',
      'additionalCoaches': <String>[],
      'modifiedBy': 'migration_script',
      'createdAt': FieldValue.serverTimestamp(),
      'lastModified': FieldValue.serverTimestamp(),
    };
  }

  String _calculateEndTime(String startTime, int duration) {
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]);
    final min = int.parse(parts[1]);
    final totalMin = hour * 60 + min + duration;
    final endHour = totalMin ~/ 60;
    final endMin = totalMin % 60;
    return '${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> _getMiercolesSlots(Map<String, String> coachIds) {
    return [
      // DRAGONAS
      _createSlot('Miércoles', 'dragonas', null, '16:30', 10, 'CAL TOL', 'bruno', coachIds, 'CAL COMP VIGA'),
      _createSlot('Miércoles', 'dragonas', null, '16:40', 15, 'CAL COMP', 'bruno', coachIds, 'VIGA'),
      _createSlot('Miércoles', 'dragonas', null, '16:55', 20, 'SALTO', 'bruno', coachIds),
      _createSlot('Miércoles', 'dragonas', null, '17:15', 20, 'BARRAS', 'ingrid', coachIds),
      _createSlot('Miércoles', 'dragonas', null, '17:35', 15, 'PISO', 'bruno', coachIds),
      _createSlot('Miércoles', 'dragonas', null, '17:50', 10, 'PREPA/ENTREGA', 'bruno', coachIds),
      
      // LEONAS
      _createSlot('Miércoles', 'leonas', null, '16:30', 10, 'CAL TOL', 'ingrid', coachIds, 'CAL COMP VIGA'),
      _createSlot('Miércoles', 'leonas', null, '16:40', 15, 'CAL COMP', 'ingrid', coachIds, 'VIGA'),
      _createSlot('Miércoles', 'leonas', null, '16:55', 20, 'BARRAS', 'ingrid', coachIds),
      _createSlot('Miércoles', 'leonas', null, '17:15', 20, 'VIGA', 'ivan', coachIds),
      _createSlot('Miércoles', 'leonas', null, '17:35', 15, 'SALTO', 'ingrid', coachIds),
      _createSlot('Miércoles', 'leonas', null, '17:50', 10, 'PREPA/ENTREGA', 'ingrid', coachIds),
      
      // PANTERAS
      _createSlot('Miércoles', 'panteras', null, '16:30', 10, 'CAL TOL', 'ivan', coachIds, 'CAL COMP PISO'),
      _createSlot('Miércoles', 'panteras', null, '16:40', 15, 'CAL COMP', 'ivan', coachIds, 'PISO'),
      _createSlot('Miércoles', 'panteras', null, '16:55', 20, 'VIGA', 'ivan', coachIds),
      _createSlot('Miércoles', 'panteras', null, '17:15', 20, 'SALTO', 'ivan', coachIds),
      _createSlot('Miércoles', 'panteras', null, '17:35', 15, 'BARRAS', 'ingrid', coachIds),
      _createSlot('Miércoles', 'panteras', null, '17:50', 10, 'PREPA/ENTREGA', 'ingrid', coachIds),
      
      // PANDITAS N1
      _createSlot('Miércoles', 'panditas', 'N1', '17:35', 25, 'CAL', null, coachIds, 'PANDITAS Y TIGRESAS F EN PISO CON BOTES'),
      _createSlot('Miércoles', 'panditas', 'N1', '18:00', 20, 'VIGA N1', 'ivan', coachIds),
      _createSlot('Miércoles', 'panditas', 'N1', '18:20', 30, 'PISO N1', 'ingrid', coachIds),
      _createSlot('Miércoles', 'panditas', 'N1', '18:50', 10, 'SALTO', 'ingrid', coachIds),
      _createSlot('Miércoles', 'panditas', 'N1', '19:00', 15, 'SALTO / BARRAS', 'ivan', coachIds),
      _createSlot('Miércoles', 'panditas', 'N1', '19:15', 5, 'PREPA', null, coachIds),
      _createSlot('Miércoles', 'panditas', 'N1', '19:20', 5, 'ENTREGA', null, coachIds),
      
      // N3
      _createSlot('Miércoles', 'n3', null, '16:30', 10, 'CAL TOLERANCIA', 'ingrid', coachIds),
      _createSlot('Miércoles', 'n3', null, '16:40', 15, 'CAL COMP', 'ingrid', coachIds, 'BARRAS'),
      _createSlot('Miércoles', 'n3', null, '16:55', 40, 'BARRAS', 'ingrid', coachIds),
      _createSlot('Miércoles', 'n3', null, '17:35', 25, 'PISO', null, coachIds, 'COREO'),
      _createSlot('Miércoles', 'n3', null, '18:00', 20, 'FLIC/FLAC', null, coachIds),
      _createSlot('Miércoles', 'n3', null, '18:20', 10, 'PREPA', 'ivan', coachIds),
      _createSlot('Miércoles', 'n3', null, '18:30', 20, 'BARRAS', null, coachIds),
      _createSlot('Miércoles', 'n3', null, '18:50', 25, 'PREPA', 'ivan', coachIds),
      _createSlot('Miércoles', 'n3', null, '19:15', 10, 'PREPA', null, coachIds),
      _createSlot('Miércoles', 'n3', null, '19:25', 5, 'ENTREGA', null, coachIds),
      
      // N4/N5
      _createSlot('Miércoles', 'n4_n5', null, '16:30', 10, 'CAL TOL', 'bruno', coachIds),
      _createSlot('Miércoles', 'n4_n5', null, '16:40', 15, 'CAL COMP+', 'bruno', coachIds, 'SALTO'),
      _createSlot('Miércoles', 'n4_n5', null, '16:55', 40, 'PISO', 'bruno', coachIds, 'LÍNEAS ACROBÁTICAS'),
      _createSlot('Miércoles', 'n4_n5', null, '17:35', 15, 'VIGA', null, coachIds, 'INMERSIONES ATRÁS'),
      _createSlot('Miércoles', 'n4_n5', null, '17:50', 10, 'VIGA SALIDA', null, coachIds),
      _createSlot('Miércoles', 'n4_n5', null, '18:00', 25, 'SALTO', 'bruno', coachIds),
      _createSlot('Miércoles', 'n4_n5', null, '18:25', 25, 'BARRAS', 'bruno', coachIds),
      _createSlot('Miércoles', 'n4_n5', null, '18:50', 10, 'BARRAS', null, coachIds),
      _createSlot('Miércoles', 'n4_n5', null, '19:00', 15, 'PREPA', null, coachIds),
      _createSlot('Miércoles', 'n4_n5', null, '19:15', 10, 'PREPA', 'bruno', coachIds),
      _createSlot('Miércoles', 'n4_n5', null, '19:25', 5, 'ENTREGA', 'bruno', coachIds),
      
      // TIGRESAS
      _createSlot('Miércoles', 'tigresas', null, '16:30', 10, 'TOL', 'ingrid', coachIds),
      _createSlot('Miércoles', 'tigresas', null, '16:40', 15, 'CAL SALTO', 'ingrid', coachIds),
      _createSlot('Miércoles', 'tigresas', null, '16:55', 40, 'PISO', 'ingrid', coachIds),
      _createSlot('Miércoles', 'tigresas', null, '17:35', 15, 'VIGA', 'ingrid', coachIds, 'ELEMENTOS'),
      _createSlot('Miércoles', 'tigresas', null, '17:50', 10, 'VIGA SALIDA', 'ingrid', coachIds),
      _createSlot('Miércoles', 'tigresas', null, '18:00', 25, 'SALTO', 'ingrid', coachIds),
      _createSlot('Miércoles', 'tigresas', null, '18:25', 25, 'BARRAS', 'ingrid', coachIds),
      _createSlot('Miércoles', 'tigresas', null, '18:50', 10, 'BARRAS', 'ingrid', coachIds),
      _createSlot('Miércoles', 'tigresas', null, '19:00', 15, 'PISO', 'ingrid', coachIds, 'ACRO/XCEL RUTINA'),
      _createSlot('Miércoles', 'tigresas', null, '19:15', 10, 'PREPA', 'ingrid', coachIds),
      _createSlot('Miércoles', 'tigresas', null, '19:25', 5, 'ENTREGA', 'ingrid', coachIds),
    ];
  }

  List<Map<String, dynamic>> _getMartesSlots(Map<String, String> coachIds) {
    return [
      // ABEJITAS
      _createSlot('Martes', 'abejitas', null, '16:00', 15, 'CAL GRAL', 'alexis', coachIds, 'MUSICAL TODAS', 'MUSICAL TODAS'),
      _createSlot('Martes', 'abejitas', null, '16:15', 15, 'SALTO', null, coachIds, 'A1, A2, A3_', 'A1, A2, A3_'),
      _createSlot('Martes', 'abejitas', null, '16:30', 15, 'BARRAS', null, coachIds, '_, A1, A2, A3', '_, A1, A2, A3'),
      _createSlot('Martes', 'abejitas', null, '16:45', 15, 'VIGA', null, coachIds, 'A3_, A1, A2', 'A3_, A1, A2'),
      _createSlot('Martes', 'abejitas', null, '17:00', 15, 'PISO', null, coachIds, 'A2, A3_, A1', 'A2, A3_, A1'),
      _createSlot('Martes', 'abejitas', null, '17:15', 15, 'PREPA/ENTREGA', 'alexis', coachIds),
      
      // MARIPOSAS
      _createSlot('Martes', 'mariposas', null, '17:30', 15, 'CAL GRAL', 'alexis', coachIds, 'MUSICAL TODAS', 'MUSICAL TODAS'),
      _createSlot('Martes', 'mariposas', null, '17:45', 15, 'SALTO', null, coachIds, 'M1, M2, M3, _', 'M1, M2, M3, _'),
      _createSlot('Martes', 'mariposas', null, '18:00', 15, 'BARRAS', null, coachIds, '_, M1, M2, M3', '_, M1, M2, M3'),
      _createSlot('Martes', 'mariposas', null, '18:15', 15, 'VIGA', null, coachIds, 'M3, _, M1, M2', 'M3, _, M1, M2'),
      _createSlot('Martes', 'mariposas', null, '18:30', 15, 'PISO', null, coachIds, 'M2, M3_, M1', 'M2, M3_, M1'),
      _createSlot('Martes', 'mariposas', null, '18:45', 15, 'PREPA/ENTREGA', 'alexis', coachIds),
      
      // ORUGUITAS
      _createSlot('Martes', 'oruguitas', null, '17:30', 10, 'CAL', null, coachIds),
      _createSlot('Martes', 'oruguitas', null, '17:40', 10, 'CIR 1 PISO', null, coachIds),
      _createSlot('Martes', 'oruguitas', null, '17:50', 10, 'CIR 2 BARRA', null, coachIds),
      _createSlot('Martes', 'oruguitas', null, '18:00', 10, 'CIR 3 VIGA', null, coachIds),
      _createSlot('Martes', 'oruguitas', null, '18:10', 10, 'PREPA/ENTREGA', null, coachIds),
      
      // N3
      _createSlot('Martes', 'n3', null, '16:30', 15, 'CAL TOL', 'ingrid', coachIds),
      _createSlot('Martes', 'n3', null, '16:45', 15, 'CAL COMP', 'ingrid', coachIds),
      _createSlot('Martes', 'n3', null, '17:00', 30, 'PISO', 'ingrid', coachIds, 'CIRCUITO DE RECHAZOS, BOTES, V. ATRÁS Y FF'),
      _createSlot('Martes', 'n3', null, '17:30', 25, 'SALTO', 'bruno', coachIds, 'PREPA DE CARRERA'),
      _createSlot('Martes', 'n3', null, '17:55', 20, 'BARRAS', 'ingrid', coachIds, 'FALTANTES'),
      _createSlot('Martes', 'n3', null, '18:15', 10, 'PREPA', 'ingrid', coachIds),
      _createSlot('Martes', 'n3', null, '18:25', 5, 'ENTREGA', 'ingrid', coachIds),
      _createSlot('Martes', 'n3', null, '18:30', 15, 'CAL', 'ingrid', coachIds),
      _createSlot('Martes', 'n3', null, '18:45', 10, 'ACRO', 'ingrid', coachIds),
      
      // N4/N5
      _createSlot('Martes', 'n4_n5', null, '16:30', 15, 'CAL TOL', null, coachIds),
      _createSlot('Martes', 'n4_n5', null, '16:45', 15, 'CAL COMP', null, coachIds),
      _createSlot('Martes', 'n4_n5', null, '17:00', 30, 'BARRAS', null, coachIds, 'CIRC PREPA'),
      _createSlot('Martes', 'n4_n5', null, '17:30', 40, 'VIGA', 'adriana', coachIds, 'PREPA Y BÁSICOS'),
      _createSlot('Martes', 'n4_n5', null, '18:10', 15, 'SALIDAS VIGA', null, coachIds),
      _createSlot('Martes', 'n4_n5', null, '18:25', 20, 'PISO', 'bruno', coachIds, 'CIRCUITO'),
      _createSlot('Martes', 'n4_n5', null, '18:45', 15, 'SALTO', 'bruno', coachIds, 'TABLA ATERRÍZAJE'),
      _createSlot('Martes', 'n4_n5', null, '19:00', 15, 'PREPA', null, coachIds),
      _createSlot('Martes', 'n4_n5', null, '19:15', 10, 'EXCEL PISO', null, coachIds),
      _createSlot('Martes', 'n4_n5', null, '19:25', 5, 'ENTREGA', null, coachIds),
    ];
  }

  List<Map<String, dynamic>> _getLunesSlots(Map<String, String> coachIds) {
    return [
      // ── DRAGONAS (Bruno) – aparatos distintos a Miércoles ──
      _createSlot('Lunes', 'dragonas', null, '16:30', 10, 'CAL TOLERANCIA', 'bruno', coachIds, 'CAL COMP BARRAS'),
      _createSlot('Lunes', 'dragonas', null, '16:40', 15, 'CAL COMP', 'bruno', coachIds, 'BARRAS'),
      _createSlot('Lunes', 'dragonas', null, '16:55', 20, 'BARRAS', 'ingrid', coachIds),
      _createSlot('Lunes', 'dragonas', null, '17:15', 20, 'PISO', 'bruno', coachIds),
      _createSlot('Lunes', 'dragonas', null, '17:35', 15, 'VIGA', 'ivan', coachIds),
      _createSlot('Lunes', 'dragonas', null, '17:50', 10, 'PREPA/ENTREGA', 'bruno', coachIds),

      // ── LEONAS (Ingrid) ──
      _createSlot('Lunes', 'leonas', null, '16:30', 10, 'CAL TOLERANCIA', 'ingrid', coachIds, 'CAL COMP SALTO'),
      _createSlot('Lunes', 'leonas', null, '16:40', 15, 'CAL COMP', 'ingrid', coachIds, 'SALTO'),
      _createSlot('Lunes', 'leonas', null, '16:55', 20, 'SALTO', 'ingrid', coachIds),
      _createSlot('Lunes', 'leonas', null, '17:15', 20, 'PISO', 'ivan', coachIds),
      _createSlot('Lunes', 'leonas', null, '17:35', 15, 'BARRAS', 'ingrid', coachIds),
      _createSlot('Lunes', 'leonas', null, '17:50', 10, 'PREPA/ENTREGA', 'ingrid', coachIds),

      // ── PANTERAS (Ivan) ──
      _createSlot('Lunes', 'panteras', null, '16:30', 10, 'CAL TOLERANCIA', 'ivan', coachIds, 'CAL COMP VIGA'),
      _createSlot('Lunes', 'panteras', null, '16:40', 15, 'CAL COMP', 'ivan', coachIds, 'VIGA'),
      _createSlot('Lunes', 'panteras', null, '16:55', 20, 'VIGA', 'ivan', coachIds),
      _createSlot('Lunes', 'panteras', null, '17:15', 20, 'BARRAS', 'ingrid', coachIds),
      _createSlot('Lunes', 'panteras', null, '17:35', 15, 'SALTO', 'ivan', coachIds),
      _createSlot('Lunes', 'panteras', null, '17:50', 10, 'PREPA/ENTREGA', 'ivan', coachIds),

      // ── PANDITAS N1 ──
      _createSlot('Lunes', 'panditas', 'N1', '17:35', 25, 'CAL', null, coachIds, 'CON BOTES'),
      _createSlot('Lunes', 'panditas', 'N1', '18:00', 20, 'PISO N1', 'ingrid', coachIds),
      _createSlot('Lunes', 'panditas', 'N1', '18:20', 30, 'VIGA N1', 'ivan', coachIds),
      _createSlot('Lunes', 'panditas', 'N1', '18:50', 10, 'BARRAS', 'ingrid', coachIds),
      _createSlot('Lunes', 'panditas', 'N1', '19:00', 15, 'SALTO', 'ivan', coachIds),
      _createSlot('Lunes', 'panditas', 'N1', '19:15', 10, 'PREPA/ENTREGA', null, coachIds),

      // ── N3 (Ingrid) ──
      _createSlot('Lunes', 'n3', null, '16:30', 10, 'CAL TOLERANCIA', 'ingrid', coachIds),
      _createSlot('Lunes', 'n3', null, '16:40', 15, 'CAL COMP', 'ingrid', coachIds, 'VIGA'),
      _createSlot('Lunes', 'n3', null, '16:55', 40, 'VIGA', 'ingrid', coachIds, 'ELEMENTOS BÁSICOS'),
      _createSlot('Lunes', 'n3', null, '17:35', 25, 'SALTO', 'bruno', coachIds, 'TABLA ATERRIZAJE'),
      _createSlot('Lunes', 'n3', null, '18:00', 20, 'PISO', null, coachIds, 'COREO'),
      _createSlot('Lunes', 'n3', null, '18:20', 10, 'PREPA', 'ivan', coachIds),
      _createSlot('Lunes', 'n3', null, '18:30', 20, 'BARRAS', null, coachIds),
      _createSlot('Lunes', 'n3', null, '18:50', 25, 'PREPA', 'ingrid', coachIds),
      _createSlot('Lunes', 'n3', null, '19:15', 10, 'PREPA', null, coachIds),
      _createSlot('Lunes', 'n3', null, '19:25', 5, 'ENTREGA', null, coachIds),

      // ── N4/N5 (Bruno) ──
      _createSlot('Lunes', 'n4_n5', null, '16:30', 10, 'CAL TOL', 'bruno', coachIds),
      _createSlot('Lunes', 'n4_n5', null, '16:40', 15, 'CAL COMP+', 'bruno', coachIds, 'BARRAS'),
      _createSlot('Lunes', 'n4_n5', null, '16:55', 40, 'BARRAS', 'ingrid', coachIds, 'KIPS Y PIROUETTES'),
      _createSlot('Lunes', 'n4_n5', null, '17:35', 15, 'PISO', null, coachIds, 'LÍNEAS ACROBÁTICAS'),
      _createSlot('Lunes', 'n4_n5', null, '17:50', 10, 'PISO SALIDA', null, coachIds),
      _createSlot('Lunes', 'n4_n5', null, '18:00', 25, 'VIGA', 'adriana', coachIds, 'PREPA Y BÁSICOS'),
      _createSlot('Lunes', 'n4_n5', null, '18:25', 25, 'SALTO', 'bruno', coachIds),
      _createSlot('Lunes', 'n4_n5', null, '18:50', 10, 'SALTO AV', null, coachIds),
      _createSlot('Lunes', 'n4_n5', null, '19:00', 15, 'PREPA', null, coachIds),
      _createSlot('Lunes', 'n4_n5', null, '19:15', 10, 'PREPA', 'bruno', coachIds),
      _createSlot('Lunes', 'n4_n5', null, '19:25', 5, 'ENTREGA', 'bruno', coachIds),

      // ── TIGRESAS (Ingrid) ──
      _createSlot('Lunes', 'tigresas', null, '16:30', 10, 'TOL', 'ingrid', coachIds),
      _createSlot('Lunes', 'tigresas', null, '16:40', 15, 'CAL VIGA', 'ingrid', coachIds),
      _createSlot('Lunes', 'tigresas', null, '16:55', 40, 'VIGA', 'ingrid', coachIds, 'INMERSIONES ATRÁS'),
      _createSlot('Lunes', 'tigresas', null, '17:35', 15, 'PISO', 'ingrid', coachIds, 'CIRCUITO ACRO'),
      _createSlot('Lunes', 'tigresas', null, '17:50', 10, 'PISO COREO', 'ingrid', coachIds),
      _createSlot('Lunes', 'tigresas', null, '18:00', 25, 'BARRAS', 'ingrid', coachIds),
      _createSlot('Lunes', 'tigresas', null, '18:25', 25, 'SALTO', 'ingrid', coachIds),
      _createSlot('Lunes', 'tigresas', null, '18:50', 10, 'SALTO AV', 'ingrid', coachIds),
      _createSlot('Lunes', 'tigresas', null, '19:00', 15, 'BARRAS', 'ingrid', coachIds, 'XCEL'),
      _createSlot('Lunes', 'tigresas', null, '19:15', 10, 'PREPA', 'ingrid', coachIds),
      _createSlot('Lunes', 'tigresas', null, '19:25', 5, 'ENTREGA', 'ingrid', coachIds),
    ];
  }

  List<Map<String, dynamic>> _getJuevesSlots(Map<String, String> coachIds) {
    return [
      // ── ABEJITAS (Alexis) – rotación A1/A2/A3 ──
      _createSlot('Jueves', 'abejitas', null, '16:00', 15, 'CAL GRAL', 'alexis', coachIds, 'MUSICAL TODAS', 'MUSICAL TODAS'),
      _createSlot('Jueves', 'abejitas', null, '16:15', 15, 'BARRAS', null, coachIds, 'A1, A2, A3_', 'A1, A2, A3_'),
      _createSlot('Jueves', 'abejitas', null, '16:30', 15, 'VIGA', null, coachIds, '_, A1, A2, A3', '_, A1, A2, A3'),
      _createSlot('Jueves', 'abejitas', null, '16:45', 15, 'PISO', null, coachIds, 'A3_, A1, A2', 'A3_, A1, A2'),
      _createSlot('Jueves', 'abejitas', null, '17:00', 15, 'SALTO', null, coachIds, 'A2, A3_, A1', 'A2, A3_, A1'),
      _createSlot('Jueves', 'abejitas', null, '17:15', 15, 'PREPA/ENTREGA', 'alexis', coachIds),

      // ── MARIPOSAS (Alexis) – rotación M1/M2/M3/M4 ──
      _createSlot('Jueves', 'mariposas', null, '17:30', 15, 'CAL GRAL', 'alexis', coachIds, 'MUSICAL TODAS', 'MUSICAL TODAS'),
      _createSlot('Jueves', 'mariposas', null, '17:45', 15, 'BARRAS', null, coachIds, 'M1, M2, M3, _', 'M1, M2, M3, _'),
      _createSlot('Jueves', 'mariposas', null, '18:00', 15, 'VIGA', null, coachIds, '_, M1, M2, M3', '_, M1, M2, M3'),
      _createSlot('Jueves', 'mariposas', null, '18:15', 15, 'PISO', null, coachIds, 'M3, _, M1, M2', 'M3, _, M1, M2'),
      _createSlot('Jueves', 'mariposas', null, '18:30', 15, 'SALTO', null, coachIds, 'M2, M3_, M1', 'M2, M3_, M1'),
      _createSlot('Jueves', 'mariposas', null, '18:45', 15, 'PREPA/ENTREGA', 'alexis', coachIds),

      // ── ORUGUITAS ──
      _createSlot('Jueves', 'oruguitas', null, '17:30', 10, 'CAL', null, coachIds),
      _createSlot('Jueves', 'oruguitas', null, '17:40', 10, 'C1 SALTO', null, coachIds),
      _createSlot('Jueves', 'oruguitas', null, '17:50', 10, 'C2 PISO', null, coachIds),
      _createSlot('Jueves', 'oruguitas', null, '18:00', 10, 'C3 BARRA', null, coachIds),
      _createSlot('Jueves', 'oruguitas', null, '18:10', 10, 'PREPA/ENTREGA', null, coachIds),

      // ── N3 (Ingrid / Bruno) ──
      _createSlot('Jueves', 'n3', null, '16:30', 15, 'CAL TOL', 'ingrid', coachIds),
      _createSlot('Jueves', 'n3', null, '16:45', 15, 'CAL COMP', 'ingrid', coachIds),
      _createSlot('Jueves', 'n3', null, '17:00', 30, 'VIGA', 'ingrid', coachIds, 'ELEMENTOS Y SALIDA'),
      _createSlot('Jueves', 'n3', null, '17:30', 25, 'PISO', null, coachIds, 'ACRO Y COREO'),
      _createSlot('Jueves', 'n3', null, '17:55', 20, 'SALTO', 'bruno', coachIds, 'PREPA CARRERA'),
      _createSlot('Jueves', 'n3', null, '18:15', 15, 'BARRAS', 'ingrid', coachIds, 'FALTANTES'),
      _createSlot('Jueves', 'n3', null, '18:30', 15, 'BARRAS', 'ingrid', coachIds, 'FALTANTES'),
      _createSlot('Jueves', 'n3', null, '18:45', 10, 'PREPA', 'ingrid', coachIds),
      _createSlot('Jueves', 'n3', null, '18:55', 10, 'ENTREGA', 'ingrid', coachIds),

      // ── N4/N5 (Ingrid / Bruno / Adriana) ──
      _createSlot('Jueves', 'n4_n5', null, '16:30', 15, 'CAL TOL', null, coachIds),
      _createSlot('Jueves', 'n4_n5', null, '16:45', 15, 'CAL COMP', null, coachIds),
      _createSlot('Jueves', 'n4_n5', null, '17:00', 30, 'PISO', null, coachIds, 'CIRC PREPA'),
      _createSlot('Jueves', 'n4_n5', null, '17:30', 40, 'BARRAS', 'ingrid', coachIds, 'KIPS Y PIROUET'),
      _createSlot('Jueves', 'n4_n5', null, '18:10', 15, 'BARRAS AV', null, coachIds),
      _createSlot('Jueves', 'n4_n5', null, '18:25', 20, 'VIGA', 'adriana', coachIds, 'PREPA Y BÁSICOS'),
      _createSlot('Jueves', 'n4_n5', null, '18:45', 15, 'SALTO', 'bruno', coachIds, 'TABLA ATERRIZAJE'),
      _createSlot('Jueves', 'n4_n5', null, '19:00', 15, 'PREPA', null, coachIds),
      _createSlot('Jueves', 'n4_n5', null, '19:15', 10, 'XCEL BARRAS', null, coachIds),
      _createSlot('Jueves', 'n4_n5', null, '19:25', 10, 'ENTREGA', null, coachIds),
    ];
  }

  List<Map<String, dynamic>> _getViernesSlots(Map<String, String> coachIds) {
    return [
      // ── DRAGONAS (Bruno) ──
      _createSlot('Viernes', 'dragonas', null, '16:30', 10, 'CAL TOL', 'bruno', coachIds, 'CAL COMP VIGA'),
      _createSlot('Viernes', 'dragonas', null, '16:40', 15, 'CAL COMP', 'bruno', coachIds, 'VIGA'),
      _createSlot('Viernes', 'dragonas', null, '16:55', 20, 'VIGA', 'ivan', coachIds),
      _createSlot('Viernes', 'dragonas', null, '17:15', 20, 'PISO', 'bruno', coachIds),
      _createSlot('Viernes', 'dragonas', null, '17:35', 15, 'SALTO', 'bruno', coachIds),
      _createSlot('Viernes', 'dragonas', null, '17:50', 10, 'PREPA/ENTREGA', 'bruno', coachIds),

      // ── LEONAS (Ingrid) ──
      _createSlot('Viernes', 'leonas', null, '16:30', 10, 'CAL TOL', 'ingrid', coachIds, 'CAL COMP BARRAS'),
      _createSlot('Viernes', 'leonas', null, '16:40', 15, 'CAL COMP', 'ingrid', coachIds, 'BARRAS'),
      _createSlot('Viernes', 'leonas', null, '16:55', 20, 'BARRAS', 'ingrid', coachIds),
      _createSlot('Viernes', 'leonas', null, '17:15', 20, 'VIGA', 'ivan', coachIds),
      _createSlot('Viernes', 'leonas', null, '17:35', 15, 'PISO', 'ingrid', coachIds),
      _createSlot('Viernes', 'leonas', null, '17:50', 10, 'PREPA/ENTREGA', 'ingrid', coachIds),

      // ── PANTERAS (Ivan) ──
      _createSlot('Viernes', 'panteras', null, '16:30', 10, 'CAL TOL', 'ivan', coachIds, 'CAL COMP PISO'),
      _createSlot('Viernes', 'panteras', null, '16:40', 15, 'CAL COMP', 'ivan', coachIds, 'PISO'),
      _createSlot('Viernes', 'panteras', null, '16:55', 20, 'PISO', 'ivan', coachIds),
      _createSlot('Viernes', 'panteras', null, '17:15', 20, 'VIGA', 'ivan', coachIds),
      _createSlot('Viernes', 'panteras', null, '17:35', 15, 'SALTO', 'ingrid', coachIds),
      _createSlot('Viernes', 'panteras', null, '17:50', 10, 'PREPA/ENTREGA', 'ivan', coachIds),

      // ── N3 (Ingrid) ──
      _createSlot('Viernes', 'n3', null, '16:30', 10, 'CAL TOLERANCIA', 'ingrid', coachIds),
      _createSlot('Viernes', 'n3', null, '16:40', 15, 'CAL COMP', 'ingrid', coachIds, 'PISO'),
      _createSlot('Viernes', 'n3', null, '16:55', 40, 'PISO', 'ingrid', coachIds, 'RUTINA COMPLETA'),
      _createSlot('Viernes', 'n3', null, '17:35', 25, 'BARRAS', null, coachIds, 'FALTANTES'),
      _createSlot('Viernes', 'n3', null, '18:00', 20, 'VIGA', null, coachIds),
      _createSlot('Viernes', 'n3', null, '18:20', 10, 'PREPA', 'ivan', coachIds),
      _createSlot('Viernes', 'n3', null, '18:30', 20, 'SALTO', 'bruno', coachIds),
      _createSlot('Viernes', 'n3', null, '18:50', 25, 'PREPA', 'ingrid', coachIds),
      _createSlot('Viernes', 'n3', null, '19:15', 10, 'PREPA FINAL', null, coachIds),
      _createSlot('Viernes', 'n3', null, '19:25', 5, 'ENTREGA', null, coachIds),

      // ── N4/N5 (Bruno) ──
      _createSlot('Viernes', 'n4_n5', null, '16:30', 10, 'CAL TOL', 'bruno', coachIds),
      _createSlot('Viernes', 'n4_n5', null, '16:40', 15, 'CAL COMP+', 'bruno', coachIds, 'SALTO'),
      _createSlot('Viernes', 'n4_n5', null, '16:55', 40, 'VIGA', 'adriana', coachIds, 'INMERSIONES ATRÁS'),
      _createSlot('Viernes', 'n4_n5', null, '17:35', 15, 'SALTO', 'bruno', coachIds, 'TABLA ATERRIZAJE'),
      _createSlot('Viernes', 'n4_n5', null, '17:50', 10, 'SALTO AV', null, coachIds),
      _createSlot('Viernes', 'n4_n5', null, '18:00', 25, 'PISO', 'bruno', coachIds, 'RUTINA COMPLETA'),
      _createSlot('Viernes', 'n4_n5', null, '18:25', 25, 'BARRAS', 'ingrid', coachIds),
      _createSlot('Viernes', 'n4_n5', null, '18:50', 10, 'BARRAS AV', null, coachIds),
      _createSlot('Viernes', 'n4_n5', null, '19:00', 15, 'PREPA', null, coachIds),
      _createSlot('Viernes', 'n4_n5', null, '19:15', 10, 'PREPA', 'bruno', coachIds),
      _createSlot('Viernes', 'n4_n5', null, '19:25', 5, 'ENTREGA', 'bruno', coachIds),

      // ── TIGRESAS (Ingrid) ──
      _createSlot('Viernes', 'tigresas', null, '16:30', 10, 'TOL', 'ingrid', coachIds),
      _createSlot('Viernes', 'tigresas', null, '16:40', 15, 'CAL BARRAS', 'ingrid', coachIds),
      _createSlot('Viernes', 'tigresas', null, '16:55', 40, 'BARRAS', 'ingrid', coachIds, 'KIPS Y CAST'),
      _createSlot('Viernes', 'tigresas', null, '17:35', 15, 'SALTO', 'ingrid', coachIds),
      _createSlot('Viernes', 'tigresas', null, '17:50', 10, 'SALTO AV', 'ingrid', coachIds),
      _createSlot('Viernes', 'tigresas', null, '18:00', 25, 'VIGA', 'ingrid', coachIds, 'RUTINA COMPLETA'),
      _createSlot('Viernes', 'tigresas', null, '18:25', 25, 'PISO', 'ingrid', coachIds),
      _createSlot('Viernes', 'tigresas', null, '18:50', 10, 'PISO COREO', 'ingrid', coachIds),
      _createSlot('Viernes', 'tigresas', null, '19:00', 15, 'ACRO XCEL', 'ingrid', coachIds),
      _createSlot('Viernes', 'tigresas', null, '19:15', 10, 'PREPA', 'ingrid', coachIds),
      _createSlot('Viernes', 'tigresas', null, '19:25', 5, 'ENTREGA', 'ingrid', coachIds),
    ];
  }


  Future<void> _updateCoachColors() async {
    final firestore = FirebaseFirestore.instance;
    
    // Colores guardados como int (formato 0xFFRRGGBB para usar con Color())
    final colorMap = {
      'ivan':    0xFF00B0F0, // Azul claro
      'ingrid':  0xFF92D050, // Verde lima
      'bruno':   0xFF0070C0, // Azul oscuro
      'mia':     0xFFFFC0CB, // Rosa
      'luis':    0xFFFF6600, // Naranja
      'alexis':  0xFFFFFF00, // Amarillo
      'adriana': 0xFF7030A0, // Morado
    };
    
    final coachesSnapshot = await firestore
        .collection('users')
        .where('role', isEqualTo: 'coach')
        .get();
    
    if (coachesSnapshot.docs.isEmpty) {
      throw Exception('No se encontraron coaches en Firestore');
    }

    final batch = firestore.batch();
    int updated = 0;
    
    for (var doc in coachesSnapshot.docs) {
      final data = doc.data();
      final name = (data['name'] as String? ?? '').toLowerCase();
      // Buscar por primera palabra del nombre (por si son "Bruno X")
      final firstName = name.split(' ').first;
      final color = colorMap[firstName] ?? colorMap[name];
      
      if (color != null) {
        batch.update(doc.reference, {'colorHex': color});
        print('✓ Actualizando $name con color 0x${color.toRadixString(16).toUpperCase()}');
        updated++;
      } else {
        print('⚠️  No hay color definido para: $name');
      }
    }
    
    await batch.commit();
    print('✅ Colores actualizados: $updated coaches');
  }
}
