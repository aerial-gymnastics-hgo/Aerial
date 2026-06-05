import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../utils/image_helper.dart';

class StudentDetailScreen extends StatelessWidget {
  final User student;

  const StudentDetailScreen({super.key, required this.student});

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
          title: Text(student.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.cyanAccent, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                    backgroundImage: getProfileImageProvider(student.photoUrl),
                    child: student.photoUrl == null
                        ? Text(student.name[0], style: const TextStyle(fontSize: 40, color: Colors.cyanAccent))
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Nivel de Habilidades',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [const Shadow(color: Colors.cyanAccent, blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: const [
                    TrafficLightSkill(skillName: 'Parado de Manos (Vertical)'),
                    TrafficLightSkill(skillName: 'Rueda de Carro'),
                    TrafficLightSkill(skillName: 'Salto Extendido'),
                    TrafficLightSkill(skillName: 'Rodada al Frente'),
                    TrafficLightSkill(skillName: 'Flexibilidad Arco'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrafficLightSkill extends StatefulWidget {
  final String skillName;

  const TrafficLightSkill({super.key, required this.skillName});

  @override
  State<TrafficLightSkill> createState() => _TrafficLightSkillState();
}

class _TrafficLightSkillState extends State<TrafficLightSkill> {
  int _status = 0;

  Color get _currentColor {
    switch (_status) {
      case 0:
        return Colors.white24; 
      case 1:
        return Colors.redAccent; 
      case 2:
        return Colors.amberAccent; 
      case 3:
        return Colors.greenAccent; 
      default:
        return Colors.white24;
    }
  }

  void _cycleStatus() {
    setState(() {
      _status = (_status + 1) % 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _currentColor.withOpacity(0.5)),
            ),
            child: ListTile(
              title: Text(
                widget.skillName,
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600),
              ),
              trailing: GestureDetector(
                onTap: _cycleStatus,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentColor.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: _currentColor.withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _status == 0 ? const Icon(Icons.remove, color: Colors.white54, size: 20) : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
