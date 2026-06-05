import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/rotation_model.dart';

class CoachDailySchedule extends StatefulWidget {
  const CoachDailySchedule({super.key});

  @override
  State<CoachDailySchedule> createState() => _CoachDailyScheduleState();
}

class _CoachDailyScheduleState extends State<CoachDailySchedule> {
  List<User> _coaches = [];
  List<RotationSlot> _rotations = [];

  StreamSubscription? _coachSub;
  StreamSubscription? _rotSub;

  @override
  void initState() {
    super.initState();
    _coachSub = FirestoreService.instance.getCoaches().listen((data) {
      if (mounted) setState(() => _coaches = data);
    });
    _rotSub = FirestoreService.instance.getAllRotations().listen((data) {
      if (mounted) setState(() => _rotations = data);
    });
  }

  @override
  void dispose() {
    _coachSub?.cancel();
    _rotSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRotations = <Map<String, dynamic>>[];

    for (final coach in _coaches) {
      final rotationsForCoach =
          _rotations.where((r) => r.coachId == coach.id).toList();
      for (final slot in rotationsForCoach) {
        allRotations.add({
          'coach': coach,
          'slot': slot,
        });
      }
    }

    final groupedByTime = <String, List<Map<String, dynamic>>>{};
    for (final rotation in allRotations) {
      final slot = rotation['slot'] as RotationSlot;
      final timeKey = slot.startTime;

      if (!groupedByTime.containsKey(timeKey)) {
        groupedByTime[timeKey] = [];
      }
      groupedByTime[timeKey]!.add(rotation);
    }

    final sortedTimes = groupedByTime.keys.toList()
      ..sort((a, b) {
        final timeA = _parseTime(a);
        final timeB = _parseTime(b);
        return timeA.compareTo(timeB);
      });

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
          title: Text('Horario de Hoy',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              tooltip: 'Ir al Inicio',
            ),
          ],
        ),
        body: sortedTimes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule, size: 80, color: Colors.white24),
                    const SizedBox(height: 16),
                    Text(
                      'No hay rotaciones programadas',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedTimes.length,
                itemBuilder: (context, index) {
                  final timeKey = sortedTimes[index];
                  final rotations = groupedByTime[timeKey]!;
                  final firstSlot = rotations.first['slot'] as RotationSlot;

                  return _buildTimeBlock(
                    context,
                    timeKey,
                    firstSlot.endTime,
                    rotations,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTimeBlock(
    BuildContext context,
    String startTime,
    String endTime,
    List<Map<String, dynamic>> rotations,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startTime,
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  endTime,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 3,
            height: rotations.length * 68.0 + 20,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.8),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rotations.map((rotation) {
                final coach = rotation['coach'] as User;
                final slot = rotation['slot'] as RotationSlot;
                final coachColor = coach.colorHex != null
                    ? Color(coach.colorHex!)
                    : Colors.cyanAccent;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: coachColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: coachColor.withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${slot.groupId} en ${slot.apparatus}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Icon(Icons.sports_gymnastics,
                                    color: coachColor, size: 18),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.person,
                                    color: Colors.white54, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  coach.name.split(' ')[0],
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
