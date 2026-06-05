import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/rotation_model.dart';
import 'dart:async';
import '../services/firestore_service.dart';
import 'student_detail_screen.dart';
import '../utils/image_helper.dart';

class CoachSessionScreen extends StatefulWidget {
  final User coach;
  final RotationSlot currentSlot;

  const CoachSessionScreen({
    super.key,
    required this.coach,
    required this.currentSlot,
  });

  @override
  State<CoachSessionScreen> createState() => _CoachSessionScreenState();
}

class _CoachSessionScreenState extends State<CoachSessionScreen> {
  List<User> _groupStudents = [];
  StreamSubscription? _studSub;

  @override
  void initState() {
    super.initState();
    _studSub = FirestoreService.instance.getStudents().listen((data) {
      if (mounted) {
        setState(() {
          _groupStudents = data.where((s) => s.group == widget.currentSlot.groupId).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _studSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.coach.colorHex != null ? Color(widget.coach.colorHex!) : Colors.cyanAccent;

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
          title: Text(
            '${widget.currentSlot.apparatus} - ${widget.currentSlot.groupId}',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white),
          ),
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
        body: Column(
          children: [
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    border: Border(bottom: BorderSide(color: primaryColor.withOpacity(0.5))),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'EN CURSO: ${widget.currentSlot.apparatus.toUpperCase()}',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          shadows: [Shadow(color: primaryColor.withOpacity(0.8), blurRadius: 10)],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Termina: ${widget.currentSlot.endTime}',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                      ),
                      
                      // Enfoques y Trabajos Especiales
                      if (widget.currentSlot.focus != null && widget.currentSlot.focus!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.ads_click, color: Colors.cyanAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Enfoque General:', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54)),
                                    Text(
                                      widget.currentSlot.focus!, 
                                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (widget.currentSlot.specialAssignments != null && widget.currentSlot.specialAssignments!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.assignment_ind, color: Colors.pinkAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Trabajos Especiales:', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54)),
                                    Text(
                                      widget.currentSlot.specialAssignments!, 
                                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
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
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _groupStudents.length,
                itemBuilder: (context, index) {
                  final student = _groupStudents[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: primaryColor.withOpacity(0.2),
                                  backgroundImage: getProfileImageProvider(student.photoUrl),
                                  child: student.photoUrl == null ? Text(student.name[0], style: TextStyle(color: primaryColor)) : null,
                                ),
                                title: Text(
                                  student.name,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                                ),
                                subtitle: Text(
                                  student.group,
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
                                ),
                                trailing: _AttendanceButton(primaryColor: primaryColor, coachId: widget.coach.id, studentId: student.id),
                              ),
                              const Divider(color: Colors.white12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StudentDetailScreen(student: student),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.edit_note, size: 20, color: primaryColor),
                                    label: Text(
                                      'Evaluar Habilidades',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: primaryColor),
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
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAiCoachAssistant(context),
          backgroundColor: Colors.purpleAccent.withOpacity(0.9),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.auto_awesome),
          label: Text('Asistente IA', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _showAiCoachAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: _AiAssistantSheet(slot: widget.currentSlot),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _AiAssistantSheet extends StatefulWidget {
  final RotationSlot slot;
  const _AiAssistantSheet({required this.slot});

  @override
  State<_AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends State<_AiAssistantSheet> {
  bool _isGenerating = true;
  String _warmup = '';
  String _exercises = '';
  String _load = '';

  @override
  void initState() {
    super.initState();
    _simulateAiGeneration();
  }

  void _simulateAiGeneration() async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Simple Heuristic AI Mock
    final apparatus = widget.slot.apparatus.toLowerCase();
    final focus = widget.slot.focus?.toLowerCase() ?? '';

    if (apparatus.contains('viga')) {
      _warmup = 'Caminatas en relevé y desplantes profundos en línea. 3 pases de equilibrios en passè.';
      _exercises = '1. Salidas de conejo a escuadra.\n2. Preparación de cartwheel (Rueda de carro).\n3. Giros de 180° continuos.';
      _load = '4 repeticiones por ejercicio. Enfoque absoluto en postura de brazos.';
    } else if (apparatus.contains('salto')) {
      _warmup = 'Saltos continuos al botador con rebote y apertura de hombros. 20 repeticiones.';
      _exercises = '1. Corridas rápidas de 10m buscando aceleración.\n2. Vuelos extendidos cayendo de espalda en colchón blando.';
      _load = '5 pasadas por gimnasta, descansando el trote de regreso.';
    } else if (apparatus.contains('barras')) {
      _warmup = 'Colgadas pasivas (30s) y dominadas escapulares (10 reps).';
      _exercises = '1. Balances amplios (Kips de pre-requisito).\n2. Subidas de estómago asistidas.';
      _load = '3 series de 5 balances continuos. Vigilar tensión de empeines.';
    } else {
      _warmup = 'Calentamiento general aeróbico: Jumping jacks, burpees y flexibilidad de hombros/espalda baja.';
      _exercises = '1. Rondas de acrobacia básica (Mortero, Cartwheel).\n2. Enlace de gimnasia geométrica (Flick-Flack / Resorte).';
      _load = 'Circuito rotativo de 3 minutos por estación.';
    }

    if (focus.contains('fuerza') || focus.contains('preparacion física')) {
       _load += '\n*Nota IA: Como pediste Fuerza, añadir planchas de 45seg al final de cada pase.';
    }
    
    if (mounted) {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.purpleAccent.withOpacity(0.4), width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Asistente de Clase IA',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Analizando: ${widget.slot.groupId} en ${widget.slot.apparatus}',
            style: GoogleFonts.poppins(color: Colors.purpleAccent, fontStyle: FontStyle.italic),
          ),
          const Divider(color: Colors.white24, height: 32),
          
          Expanded(
            child: _isGenerating 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.purpleAccent),
                      const SizedBox(height: 16),
                      Text('Procesando programa ideal...', style: GoogleFonts.poppins(color: Colors.white70)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAiSection(Icons.local_fire_department, 'Calentamiento Sugerido', _warmup, Colors.orangeAccent),
                      const SizedBox(height: 16),
                      _buildAiSection(Icons.fitness_center, 'Ejercicios Biomecánicos', _exercises, Colors.cyanAccent),
                      const SizedBox(height: 16),
                      _buildAiSection(Icons.timeline, 'Carga y Metodología', _load, Colors.greenAccent),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSection(IconData icon, String title, String content, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceButton extends StatefulWidget {
  final Color primaryColor;
  final String coachId;
  final String studentId;
  const _AttendanceButton({required this.primaryColor, required this.coachId, required this.studentId});

  @override
  State<_AttendanceButton> createState() => _AttendanceButtonState();
}

class _AttendanceButtonState extends State<_AttendanceButton> {
  int _statusIndex = 0;
  final List<Color> _colors = [Colors.white38, Colors.orangeAccent, Colors.redAccent];
  final List<IconData> _icons = [Icons.check_circle_outline, Icons.schedule, Icons.cancel];

  void _toggleStatus() {
    setState(() {
      _statusIndex = (_statusIndex + 1) % 3;
    });
    final statusStr = _statusIndex == 0 ? 'present' : (_statusIndex == 1 ? 'late' : 'absent');
    FirestoreService.instance.saveAttendance(widget.coachId, widget.studentId, statusStr);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_icons[_statusIndex], color: _colors[_statusIndex], size: 32),
      onPressed: _toggleStatus,
      tooltip: 'Marcar Asistencia',
    );
  }
}
