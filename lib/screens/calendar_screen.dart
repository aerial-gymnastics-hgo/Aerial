import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import '../services/firestore_service.dart';
import '../models/event_model.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final String role;
  const CalendarScreen({super.key, required this.role});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<SystemEvent>> _selectedEvents;
  late Map<DateTime, List<SystemEvent>> _eventsMap;

  StreamSubscription? _eventsSub;
  List<SystemEvent> _allEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _eventsMap = {};
    _selectedEvents = ValueNotifier([]);
    
    _eventsSub = FirestoreService.instance.getEventsForRole(widget.role).listen((data) {
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
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
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
          title: Text('Agenda de Actividades', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
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
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Colors.grey,
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
            const SizedBox(height: 8.0),
            Expanded(
              child: ValueListenableBuilder<List<SystemEvent>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  if (value.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay eventos para este día.',
                        style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16),
                      ),
                    );
                  }
                  return ListView.builder(
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
                                DateFormat('EEEE d', 'es_ES').format(event.date).toUpperCase(),
                                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                              ),
                              trailing: event.targetRole != 'all' ? 
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
                                  child: Text(_translateRole(event.targetRole), style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                                ) : null,
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
      case 'admin': return 'ADMINISTRACIÓN';
      default: return 'GENERAL';
    }
  }
}
