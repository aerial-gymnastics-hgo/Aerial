import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/verano_inscripcion.dart';

class VeranoCoachScreen extends StatefulWidget {
  final User currentUser;
  const VeranoCoachScreen({super.key, required this.currentUser});

  @override
  State<VeranoCoachScreen> createState() => _VeranoCoachScreenState();
}

class _VeranoCoachScreenState extends State<VeranoCoachScreen> {
  String _grupoSeleccionado = 'mexico';
  bool _cargando = false;
  List<VeranoInscripcion> _alumnas = [];
  String? _error;
  Map<String, bool?> _asistenciaHoy = {};

  @override
  void initState() {
    super.initState();
    _cargarAlumnas();
  }

  Future<void> _cargarAlumnas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('verano_inscripciones')
          .where('grupo', isEqualTo: _grupoSeleccionado)
          .orderBy('nombreAlumna')
          .get();
      setState(() {
        _alumnas = snap.docs
            .map((d) => VeranoInscripcion.fromFirestore(d))
            .toList();
      });
      await _cargarAsistenciaHoy();
    } catch (e) {
      setState(() => _error = 'Error al cargar: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cargarAsistenciaHoy() async {
    final hoy = DateTime.now();
    final fechaKey = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    final Map<String, bool?> resultado = {};
    for (final alumna in _alumnas) {
      if (alumna.id == null) continue;
      final doc = await FirebaseFirestore.instance
          .collection('verano_inscripciones')
          .doc(alumna.id)
          .collection('asistencia')
          .doc(fechaKey)
          .get();
      resultado[alumna.id!] = doc.exists ? (doc.data()?['presente'] as bool?) : null;
    }
    if (mounted) setState(() => _asistenciaHoy = resultado);
  }

  Future<void> _marcarAsistencia(String inscripcionId, bool presente) async {
    final hoy = DateTime.now();
    final fechaKey = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    setState(() => _asistenciaHoy[inscripcionId] = presente);
    try {
      await FirebaseFirestore.instance
          .collection('verano_inscripciones')
          .doc(inscripcionId)
          .collection('asistencia')
          .doc(fechaKey)
          .set({
            'presente': presente,
            'registradoPor': widget.currentUser.id,
            'hora': FieldValue.serverTimestamp(),
            'grupo': _grupoSeleccionado,
          });
    } catch (e) {
      if (mounted) setState(() => _asistenciaHoy[inscripcionId] = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red[700]),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1060),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Verano 2026 · Mis grupos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF2D1060),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    _fechaHoy(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFD4B8F0),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _grupoChip('mexico', '🇲🇽 México'),
                        const SizedBox(width: 8),
                        _grupoChip('inglaterra', '🏴󠁧󠁢󠁥󠁮󠁧󠁿 Inglaterra'),
                        const SizedBox(width: 8),
                        _grupoChip('portugal', '🇵🇹 Portugal'),
                        const SizedBox(width: 8),
                        _grupoChip('noruega', '🇳🇴 Noruega'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildContenido()),
        ],
      ),
    );
  }

  Widget _buildContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6B2FA0)),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: TextStyle(color: Colors.red[400])),
      );
    }
    if (_alumnas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Sin inscripciones en este grupo',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: _alumnas.length,
      itemBuilder: (context, index) => _alumnaRow(_alumnas[index]),
    );
  }

  Widget _grupoChip(String valor, String label) {
    final selected = _grupoSeleccionado == valor;
    return GestureDetector(
      onTap: () {
        setState(() => _grupoSeleccionado = valor);
        _cargarAlumnas();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF472B6) : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _alumnaRow(VeranoInscripcion a) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Color(0xFFF5D0FE), shape: BoxShape.circle),
            child: Center(
              child: Text(
                a.nombreAlumna[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B2FA0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.nombreAlumna,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  '${a.edad} años · ${a.modalidad == '4semanas' ? '4 semanas' : '1 semana'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          a.id != null
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  _botonAsistencia(a.id!, true),
                  const SizedBox(width: 6),
                  _botonAsistencia(a.id!, false),
                ])
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _botonAsistencia(String id, bool presente) {
    final estado = _asistenciaHoy[id];
    final activo = estado == presente;
    return GestureDetector(
      onTap: () => _marcarAsistencia(id, presente),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: activo
              ? (presente ? const Color(0xFF25D366) : const Color(0xFFEF4444))
              : Colors.grey[100],
          border: Border.all(
            color: activo
                ? (presente ? const Color(0xFF25D366) : const Color(0xFFEF4444))
                : Colors.grey[300]!,
          ),
        ),
        child: Icon(
          presente ? Icons.check : Icons.close,
          size: 18,
          color: activo ? Colors.white : Colors.grey[400],
        ),
      ),
    );
  }

  String _fechaHoy() {
    final dias = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
      'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    final hoy = DateTime.now();
    return '${dias[hoy.weekday - 1]} ${hoy.day} de ${meses[hoy.month - 1]}';
  }
}
