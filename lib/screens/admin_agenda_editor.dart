import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import '../services/firestore_service.dart';
import '../models/event_model.dart';
import 'package:intl/intl.dart';

class AdminAgendaEditor extends StatefulWidget {
  const AdminAgendaEditor({super.key});

  @override
  State<AdminAgendaEditor> createState() => _AdminAgendaEditorState();
}

class _AdminAgendaEditorState extends State<AdminAgendaEditor> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late ValueNotifier<List<SystemEvent>> _selectedEvents;
  late Map<DateTime, List<SystemEvent>> _eventsMap;
  
  StreamSubscription? _eventsSub;
  List<SystemEvent> _allEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _eventsMap = {};
    _selectedEvents = ValueNotifier([]);
    
    // Escucha en tiempo real de los eventos en Firestore
    _eventsSub = FirestoreService.instance.getEventsForRole('admin').listen((data) {
      if (!mounted) return;
      setState(() {
        _allEvents = data;
        _buildEventsMap();
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    });
  }

  void _buildEventsMap() {
    _eventsMap = {};
    for (var ev in _allEvents) {
      final normalizedDate = DateTime.utc(ev.date.year, ev.date.month, ev.date.day);
      if (_eventsMap[normalizedDate] == null) _eventsMap[normalizedDate] = [];
      _eventsMap[normalizedDate]!.add(ev);
    }
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    _selectedEvents.dispose();
    super.dispose();
  }

  List<SystemEvent> _getEventsForDay(DateTime day) {
    final normalizedDate = DateTime.utc(day.year, day.month, day.day);
    return _eventsMap[normalizedDate] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _selectedEvents.value = _getEventsForDay(selectedDay);
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    String selectedRole = 'all';
    Color selectedColor = Colors.cyanAccent;

    final colors = [
      Colors.cyanAccent,
      Colors.pinkAccent,
      Colors.orangeAccent,
      Colors.redAccent,
      Colors.greenAccent,
      Colors.purpleAccent
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Programar Evento', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fecha: ${DateFormat('d MMMM y', 'es_ES').format(_selectedDay!)}',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Título del Evento',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Público Objetivo:', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(label: const Text('Todos'), selected: selectedRole == 'all', onSelected: (val) { if (val) setDialogState(() => selectedRole = 'all'); }),
                    ChoiceChip(label: const Text('Staff'), selected: selectedRole == 'coach', onSelected: (val) { if (val) setDialogState(() => selectedRole = 'coach'); }),
                    ChoiceChip(label: const Text('Padres'), selected: selectedRole == 'parent', onSelected: (val) { if (val) setDialogState(() => selectedRole = 'parent'); }),
                    ChoiceChip(label: const Text('Alumnas'), selected: selectedRole == 'student', onSelected: (val) { if (val) setDialogState(() => selectedRole = 'student'); }),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Color del Evento:', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: colors.map((color) => GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = color),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selectedColor == color ? Border.all(color: Colors.white, width: 3) : null,
                      ),
                    ),
                  )).toList(),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final newEvent = SystemEvent(
                    id: 'ev_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleController.text,
                    date: _selectedDay!,
                    color: selectedColor,
                    targetRole: selectedRole,
                  );
                  Navigator.pop(context); // Cierra el modal primero
                  try {
                    await FirestoreService.instance.saveEvent(newEvent);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento guardado con éxito'), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error guardando: $e'), backgroundColor: Colors.red));
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteEvent(SystemEvent event) async {
    try {
      await FirestoreService.instance.deleteEvent(event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento eliminado'), backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al borrar: $e'), backgroundColor: Colors.red));
      }
    }
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
          title: Text('Gestión de Agenda Global', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddEventDialog,
          backgroundColor: Colors.pinkAccent,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Añadir Evento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: TableCalendar<SystemEvent>(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: _onDaySelected,
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) setState(() => _calendarFormat = format);
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    eventLoader: _getEventsForDay,
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.white70),
                      weekendStyle: TextStyle(color: Colors.white54),
                    ),
                    headerStyle: const HeaderStyle(
                      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
                      formatButtonTextStyle: TextStyle(color: Colors.white),
                      formatButtonDecoration: BoxDecoration(
                        border: Border.fromBorderSide(BorderSide(color: Colors.white38)),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: const TextStyle(color: Colors.white),
                      weekendTextStyle: const TextStyle(color: Colors.white70),
                      outsideTextStyle: const TextStyle(color: Colors.white38),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.pinkAccent,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.pinkAccent.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isEmpty) return null;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: events.map((event) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: event.color),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<SystemEvent>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  if (value.isEmpty) {
                    return Center(
                      child: Text(
                        'Día libre de actividades.',
                        style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80), // Fab space
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      final event = value[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: event.color.withOpacity(0.2), shape: BoxShape.circle),
                                child: Icon(Icons.event, color: event.color),
                              ),
                              title: Text(
                                event.title,
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Audience: ${_translateRole(event.targetRole)}',
                                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  _deleteEvent(event);
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _translateRole(String role) {
    switch (role) {
      case 'coach': return 'STAFF';
      case 'parent': return 'PADRES';
      case 'student': return 'ALUMNAS';
      case 'admin': return 'ADMIN';
      default: return 'GENERAL / TODOS';
    }
  }
}
