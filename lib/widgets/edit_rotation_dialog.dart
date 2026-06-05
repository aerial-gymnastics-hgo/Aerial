import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/rotation_model.dart';
import '../models/user_model.dart';

class EditRotationDialog extends StatefulWidget {
  final RotationSlot slot;
  final VoidCallback onSaved;
  final bool isCreating;

  const EditRotationDialog({
    Key? key,
    required this.slot,
    required this.onSaved,
    this.isCreating = false,
  }) : super(key: key);

  @override
  State<EditRotationDialog> createState() => _EditRotationDialogState();
}

class _EditRotationDialogState extends State<EditRotationDialog> {
  late TextEditingController _apparatusController;
  late TextEditingController _focusController;
  late TextEditingController _linksController;
  late TextEditingController _exercisesController;
  late TextEditingController _internalRotationController;
  late TextEditingController _durationController;

  late int _durationMinutes;
  late String _endTime;
  String? _selectedCoachId;
  List<User> _coaches = [];
  bool _loading = true;
  bool _saving = false;
  late Set<String> _linkedSlotIds;

  @override
  void initState() {
    super.initState();
    _apparatusController = TextEditingController(text: widget.slot.apparatus);
    _focusController = TextEditingController(text: widget.slot.focus ?? '');
    _linksController = TextEditingController(text: widget.slot.links ?? '');
    _exercisesController = TextEditingController(text: widget.slot.exercises ?? '');
    _internalRotationController = TextEditingController(text: widget.slot.internalRotation ?? '');
    _durationMinutes = widget.slot.durationMinutes;
    _endTime = widget.slot.endTime;
    _durationController = TextEditingController(text: '$_durationMinutes');
    _selectedCoachId = widget.slot.coachId;
    _linkedSlotIds = Set<String>.from(widget.slot.linkedSlots ?? []);
    _loadCoaches();
  }

  @override
  void dispose() {
    _apparatusController.dispose();
    _focusController.dispose();
    _linksController.dispose();
    _exercisesController.dispose();
    _internalRotationController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _loadCoaches() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'coach')
          .get();

      setState(() {
        _coaches = snapshot.docs.map((doc) {
          final data = doc.data();
          return User(
            id: doc.id,
            name: data['name'] ?? 'Sin nombre',
            email: data['email'] ?? '',
            role: UserRole.coach,
            colorHex: data['colorHex'] is int ? data['colorHex'] as int : null,
          );
        }).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _updateDuration(int newDuration) {
    final parts = widget.slot.startTime.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final totalMin = h * 60 + m + newDuration;
    final endH = (totalMin ~/ 60).toString().padLeft(2, '0');
    final endM = (totalMin % 60).toString().padLeft(2, '0');
    setState(() {
      _durationMinutes = newDuration;
      _endTime = '$endH:$endM';
      _durationController.text = '$newDuration';
    });
  }

  Future<bool> _checkForOverlaps() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('rotations')
        .where('groupId', isEqualTo: widget.slot.groupId)
        .where('day', isEqualTo: widget.slot.day)
        .get();
    
    for (final doc in snapshot.docs) {
      final existingSlot = RotationSlot.fromJson({...doc.data(), 'id': doc.id});
      
      if (_timesOverlap(
        widget.slot.startTime,
        _endTime,
        existingSlot.startTime,
        existingSlot.endTime,
      )) {
        return true;
      }
    }
    return false;
  }

  bool _timesOverlap(String start1, String end1, String start2, String end2) {
    final s1 = _timeToMinutes(start1);
    final e1 = _timeToMinutes(end1);
    final s2 = _timeToMinutes(start2);
    final e2 = _timeToMinutes(end2);
    
    return (s1 < e2 && e1 > s2);
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Future<void> _saveChanges() async {
    setState(() => _saving = true);
    
    // Validaciones
    if (_apparatusController.text.trim().isEmpty) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Debes ingresar un aparato'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_selectedCoachId == null || _selectedCoachId!.isEmpty) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Debes seleccionar un coach'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (widget.isCreating) {
      final hasOverlap = await _checkForOverlaps();
      if (hasOverlap) {
        setState(() => _saving = false);
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text('⚠️ Solapamiento Detectado', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Ya existe una rotacion en este horario para este grupo.\n\n'
              '¿Deseas crear de todas formas?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Crear de todas formas'),
              ),
            ],
          ),
        );
        if (proceed != true) return;
        setState(() => _saving = true);
      }
    }

    try {
      final data = {
        'groupId': widget.slot.groupId,
        'day': widget.slot.day,
        'startTime': widget.slot.startTime,
        'subgroupId': widget.slot.subgroupId,
        'apparatus': _apparatusController.text.trim(),
        'coachId': _selectedCoachId ?? widget.slot.coachId,
        'durationMinutes': _durationMinutes,
        'endTime': _endTime,
        'focus': _focusController.text.trim(),
        'links': _linksController.text.trim(),
        'exercises': _exercisesController.text.trim(),
        'internalRotation': _internalRotationController.text.trim(),
        'linkedSlots': _linkedSlotIds.toList(),
        'lastModified': FieldValue.serverTimestamp(),
        'modifiedBy': 'admin',
      };

      String newId = widget.slot.id;
      if (widget.isCreating) {
        final docRef = await FirebaseFirestore.instance.collection('rotations').add(data);
        newId = docRef.id;
      } else {
        await FirebaseFirestore.instance.collection('rotations').doc(widget.slot.id).update(data);
      }

      final oldLinkedIds = Set<String>.from(widget.slot.linkedSlots ?? []);
      final addedLinks = _linkedSlotIds.difference(oldLinkedIds);
      final removedLinks = oldLinkedIds.difference(_linkedSlotIds);

      // Link bidirectionally: add this slot to added links
      for (final linkedId in addedLinks) {
        await FirebaseFirestore.instance
            .collection('rotations')
            .doc(linkedId)
            .update({'linkedSlots': FieldValue.arrayUnion([newId])});
      }

      // Unlink bidirectionally: remove this slot from removed links
      for (final linkedId in removedLinks) {
        await FirebaseFirestore.instance
            .collection('rotations')
            .doc(linkedId)
            .update({'linkedSlots': FieldValue.arrayRemove([newId])});
      }

      widget.onSaved();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _linkedSlotIds.isNotEmpty
                  ? 'Guardado - vinculado con ${_linkedSlotIds.length} grupo(s)'
                  : (widget.isCreating ? 'Rotacion creada exitosamente' : 'Guardado correctamente'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteSlot() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          'Eliminar Rotacion',
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Eliminar "${widget.slot.apparatus}" de ${widget.slot.groupId.toUpperCase()} a las ${widget.slot.startTime}?\nEsta accion no se puede deshacer.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('rotations').doc(widget.slot.id).delete();
        widget.onSaved();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rotacion eliminada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // --- UI Helpers ---

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white70, fontSize: 12),
    ),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
    filled: true,
    fillColor: const Color(0xFF1A1A1A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.white12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.white12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE91E63)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Dialog(
        backgroundColor: Color(0xFF1E1E1E),
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFFE91E63)),
              SizedBox(height: 16),
              Text('Cargando coaches...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    final selectedCoach = _coaches.where((c) => c.id == _selectedCoachId).firstOrNull;
    final headerColor = selectedCoach?.colorHex != null
        ? Color(selectedCoach!.colorHex!)
        : const Color(0xFF0070C0);

    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: headerColor.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isCreating 
                              ? 'CREAR: ${widget.slot.groupId.toUpperCase()} - ${widget.slot.day}'
                              : '${widget.slot.groupId.toUpperCase()} - ${widget.slot.day}',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.slot.startTime} -> $_endTime  ($_durationMinutes min)',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Body (scrollable)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Duration
                    _sectionLabel('Duracion'),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white54),
                          onPressed: _durationMinutes > 5 ? () => _updateDuration(_durationMinutes - 5) : null,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _durationController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDeco('min'),
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null && n >= 5 && n <= 180) _updateDuration(n);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white54),
                          onPressed: _durationMinutes < 180 ? () => _updateDuration(_durationMinutes + 5) : null,
                        ),
                        Text(
                          'min  ->  $_endTime',
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Apparatus
                    _sectionLabel('Aparato / Actividad'),
                    TextField(
                      controller: _apparatusController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco('Ej: SALTO, BARRAS, CAL TOLERANCIA'),
                    ),
                    const SizedBox(height: 14),

                    // Coach
                    _sectionLabel('Coach Asignado'),
                    DropdownButtonFormField<String>(
                      initialValue: _coaches.any((c) => c.id == _selectedCoachId) ? _selectedCoachId : null,
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco(''),
                      items: _coaches.map((coach) {
                        final color = coach.colorHex != null ? Color(coach.colorHex!) : Colors.grey;
                        return DropdownMenuItem(
                          value: coach.id,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(coach.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedCoachId = v),
                    ),
                    const SizedBox(height: 14),

                    // Focus
                    _sectionLabel('Enfoque del Entrenamiento'),
                    TextField(
                      controller: _focusController,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco('Ej: CAL COMP VIGA, Prepa de carrera'),
                    ),
                    const SizedBox(height: 14),

                    // Links
                    _sectionLabel('Links (videos, referencias)'),
                    TextField(
                      controller: _linksController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco('https://youtube.com/...'),
                    ),
                    const SizedBox(height: 14),

                    // Exercises
                    _sectionLabel('Ejercicios Especificos'),
                    TextField(
                      controller: _exercisesController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco('- Parada de manos\n- Rueda lateral\n- Flic-flac'),
                    ),

                    // Internal rotation (for specific groups only)
                    if (['abejitas', 'mariposas', 'oruguitas'].contains(widget.slot.groupId)) ...[
                      const SizedBox(height: 14),
                      _sectionLabel('Rotacion Interna'),
                      TextField(
                        controller: _internalRotationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDeco('Ej: A1, A2, A3_ o M1, M2, M3, M4'),
                      ),
                    ],

                    // Linked groups section
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.link, size: 14, color: Color(0xFFE91E63)),
                        const SizedBox(width: 6),
                        _sectionLabel('Grupos Vinculados (opcional)'),
                      ],
                    ),
                    Text(
                      'Si este coach atiende otros grupos al mismo tiempo, vincuelalos aqui.',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.white38),
                    ),
                    const SizedBox(height: 10),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('rotations')
                          .where('day', isEqualTo: widget.slot.day)
                          .snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63)));

                        final sameTimeSlots = snap.data!.docs
                            .map((doc) => RotationSlot.fromJson(
                                  {...doc.data() as Map<String, dynamic>, 'id': doc.id},
                                ))
                            .where((s) =>
                                s.id != widget.slot.id &&
                                _timesOverlap(widget.slot.startTime, _endTime, s.startTime, s.endTime))
                            .toList();

                        if (sameTimeSlots.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.white54, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No hay otros slots en este horario disponibles para vincular',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white12),
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFF1A1A1A),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: sameTimeSlots.length,
                            itemBuilder: (context, index) {
                              final slot = sameTimeSlots[index];
                              final isLinked = _linkedSlotIds.contains(slot.id);
                              final coachName = _coaches.where((c) => c.id == slot.coachId).firstOrNull?.name ?? 'Sin Coach';

                              return CheckboxListTile(
                                dense: true,
                                title: Text(
                                  '${slot.groupId.toUpperCase()} - ${slot.apparatus}',
                                  style: const TextStyle(fontSize: 13, color: Colors.white),
                                ),
                                subtitle: Text(
                                  '${slot.day} ${slot.startTime}-${slot.endTime} • $coachName',
                                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                                ),
                                value: isLinked,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _linkedSlotIds.add(slot.id);
                                    } else {
                                      _linkedSlotIds.remove(slot.id);
                                    }
                                  });
                                },
                                activeColor: const Color(0xFFE91E63),
                                checkColor: Colors.white,
                                side: const BorderSide(color: Colors.white38),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    if (_linkedSlotIds.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.link, color: Color(0xFFE91E63), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_linkedSlotIds.length} slot(s) vinculado(s).',
                                style: const TextStyle(fontSize: 11, color: Color(0xFFE91E63)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  if (!widget.isCreating)
                    TextButton.icon(
                      onPressed: _saving ? null : _deleteSlot,
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                      label: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                    )
                  else
                    const SizedBox(width: 80),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isCreating ? Colors.green : const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(widget.isCreating ? 'Crear' : 'Guardar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
