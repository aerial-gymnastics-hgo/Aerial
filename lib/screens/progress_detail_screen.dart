import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressDetailScreen extends StatelessWidget {
  final String studentId;
  final String studentName;

  const ProgressDetailScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

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
          title: Text(
            'Progreso de $studentName',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white),
          ),
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('evaluations')
              .where('studentId', isEqualTo: studentId)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
            }

            final evaluations = snapshot.data!.docs;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResumenEjecutivo(evaluations),
                  const SizedBox(height: 32),
                  Text(
                    'Reconocimientos del Coach',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: const [Shadow(color: Colors.pinkAccent, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...evaluations.map((evalDoc) {
                    final evalData = evalDoc.data() as Map<String, dynamic>;
                    return _buildReconocimientoCard(evalData);
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResumenEjecutivo(List<DocumentSnapshot> evaluations) {
    if (evaluations.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: Text('Aún no hay evaluaciones registradas', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final totalEvaluaciones = evaluations.length;
    final scores = evaluations
        .map((e) => ((e.data() as Map<String, dynamic>)['score'] as num?)?.toInt() ?? 0)
        .toList();
    final promedioGeneral = scores.reduce((a, b) => a + b) / scores.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 48, color: Colors.amberAccent),
          const SizedBox(height: 16),
          Text(
            'Desempeño General',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn(
                totalEvaluaciones.toString(),
                'Evaluaciones',
                Icons.assignment_turned_in,
                Colors.cyanAccent,
              ),
              _buildStatColumn(
                '${promedioGeneral.toStringAsFixed(0)}%',
                'Promedio',
                Icons.trending_up,
                Colors.greenAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildReconocimientoCard(Map<String, dynamic> evalData) {
    final fecha = (evalData['createdAt'] as Timestamp?)?.toDate();
    final coachName = evalData['coachName'] as String? ?? 'Coach';
    final notes = evalData['notes'] as String? ?? '';
    final badge = evalData['badge'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.pinkAccent.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.pinkAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coachName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    if (fecha != null)
                      Text(
                        DateFormat('dd/MM/yyyy').format(fecha),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                  ],
                ),
              ),
              if (badge != null && badge.isNotEmpty)
                Chip(
                  avatar: const Icon(Icons.star, size: 16, color: Colors.amberAccent),
                  label: Text(badge, style: const TextStyle(fontSize: 11, color: Colors.white)),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                notes,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
