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

  static const Map<String, Map<int, List<Map<String, String>>>> _objetivos = {
    'mexico': {
      1: [
        {'aparato': 'Salto', 'objetivo': 'Despegue a dos pies desde minitramp hacia colchón blando controlando el aterrizaje.'},
        {'aparato': 'Barras', 'objetivo': 'Fuerza de agarre suspendidas en posición extendida por 10 segundos.'},
        {'aparato': 'Viga', 'objetivo': 'Caminar adelante y atrás sobre vigas bajas con brazos en "avión".'},
        {'aparato': 'Piso', 'objetivo': 'Posición de vela asistida y rodamiento al frente desde plano inclinado.'},
      ],
      2: [
        {'aparato': 'Salto', 'objetivo': 'Coordinar carrera previa con frenado en un pie y despegue en dos pies.'},
        {'aparato': 'Barras', 'objetivo': 'Soporte frontal alto con brazos extendidos manteniendo buena postura.'},
        {'aparato': 'Viga', 'objetivo': 'Caminar en puntas y arabesca en un pie por 3 segundos.'},
        {'aparato': 'Piso', 'objetivo': 'Rodamiento atrás en plano inclinado y vertical con apoyo en pared.'},
      ],
      3: [
        {'aparato': 'Salto', 'objetivo': 'Caída en "firme" (stick) con flexión de rodillas desde una caja.'},
        {'aparato': 'Barras', 'objetivo': '3 balanceos básicos (swings) manteniendo el cuerpo apretado.'},
        {'aparato': 'Viga', 'objetivo': 'Saltos gimnásticos pequeños cuidando la estabilidad.'},
        {'aparato': 'Piso', 'objetivo': 'Puente desde el piso y rueda de carro direccionada.'},
      ],
      4: [
        {'aparato': 'Salto', 'objetivo': 'Integrar carrera, despegue en botador y caída clavada en colchón.'},
        {'aparato': 'Barras', 'objetivo': 'Salida de barra desde soporte frontal con pequeño impulso.'},
        {'aparato': 'Viga', 'objetivo': 'Giros simples y caminata fluida para rutina recreativa.'},
        {'aparato': 'Piso', 'objetivo': 'Rodamiento al frente, rueda de carro y saludo final para clausura.'},
      ],
    },
    'inglaterra': {
      1: [
        {'aparato': 'Salto', 'objetivo': 'Carrera de aproximación con velocidad constante y salto a posición de tabla alta.'},
        {'aparato': 'Barras', 'objetivo': 'Perfeccionar agarre y salto a soporte frontal alto sin asistencia.'},
        {'aparato': 'Viga', 'objetivo': 'Caminar en relevé y patadas al frente a 90 grados.'},
        {'aparato': 'Piso', 'objetivo': 'Vertical buscando alineación perfecta y arco desde abajo.'},
      ],
      2: [
        {'aparato': 'Salto', 'objetivo': 'Técnica del bloqueo de hombros hacia superficie elevada.'},
        {'aparato': 'Barras', 'objetivo': 'Pullover asistido (subida de estómago).'},
        {'aparato': 'Viga', 'objetivo': 'Medio giro en dos pies y saltos gimnásticos agrupados.'},
        {'aparato': 'Piso', 'objetivo': 'Rueda de carro en línea recta y rodamiento atrás con brazos extendidos.'},
      ],
      3: [
        {'aparato': 'Salto', 'objetivo': 'Salto de extensión desde botador a colchón alto con cuerpo rígido.'},
        {'aparato': 'Barras', 'objetivo': 'Swings limpios con talones sobre la altura de la barra.'},
        {'aparato': 'Viga', 'objetivo': 'Entrada básica e inicio de rueda de carro en viga baja.'},
        {'aparato': 'Piso', 'objetivo': 'Vertical-puente con asistencia y patada a redondilla.'},
      ],
      4: [
        {'aparato': 'Salto', 'objetivo': 'Secuencia completa con caída firme.'},
        {'aparato': 'Barras', 'objetivo': 'Pullover, cast e impulso y salida atrás en continuidad.'},
        {'aparato': 'Viga', 'objetivo': 'Secuencia fluida: caminata, salto agrupado, medio giro y salida.'},
        {'aparato': 'Piso', 'objetivo': 'Redondilla con salto estirado atrás y coreografía de control final.'},
      ],
    },
    'portugal': {
      1: [
        {'aparato': 'Salto', 'objetivo': 'Velocidad explosiva en carrera y handspring en plano inclinado.'},
        {'aparato': 'Barras', 'objetivo': 'Pullover independiente y casts a altura de cadera.'},
        {'aparato': 'Viga', 'objetivo': 'Caminatas coreográficas y giros completos (360°) en viga media.'},
        {'aparato': 'Piso', 'objetivo': 'Redondilla con velocidad y vertical con descenso controlado.'},
      ],
      2: [
        {'aparato': 'Salto', 'objetivo': 'Handspring a caer de pie sobre colchones (repulsión de hombros).'},
        {'aparato': 'Barras', 'objetivo': 'Técnica de kipe desde la colgada.'},
        {'aparato': 'Viga', 'objetivo': 'Salto split a 90° y ¾ parada de manos en viga baja.'},
        {'aparato': 'Piso', 'objetivo': 'Parada de manos y back walkover.'},
      ],
      3: [
        {'aparato': 'Salto', 'objetivo': 'Ajustar entrada al botador para ganar altura y distancia.'},
        {'aparato': 'Barras', 'objetivo': 'Kipe, cast alto y back hip circle con brazos rectos.'},
        {'aparato': 'Viga', 'objetivo': 'Rueda de carro en viga alta y salida en resorte.'},
        {'aparato': 'Piso', 'objetivo': 'Progresión de flic-flac con asistencia.'},
      ],
      4: [
        {'aparato': 'Salto', 'objetivo': 'Handspring completo a mesa de salto o colchones normativos.'},
        {'aparato': 'Barras', 'objetivo': 'Rutina completa de barras asimétricas con fluidez mecánica.'},
        {'aparato': 'Viga', 'objetivo': 'Rutina con expresión facial, control de brazos y sticks.'},
        {'aparato': 'Piso', 'objetivo': 'Secuencia de redondilla y bote con música de control técnico.'},
      ],
    },
    'noruega': {
      1: [
        {'aparato': 'Salto', 'objetivo': 'Niv 3/4: plancha invertida. Niv 5/6: Tsukahara/Yurchenko en progresiones.'},
        {'aparato': 'Barras', 'objetivo': 'Niv 3/4: cast horizontal y rodada atrás. Niv 5/6: cast to handstand y khip largo.'},
        {'aparato': 'Viga', 'objetivo': 'Ángulos exactos de saltos split y verticales de 2 segundos obligatorios.'},
        {'aparato': 'Piso', 'objetivo': 'Posiciones de manos/cabeza/pies en coreografías USAG; extensiones de pierna.'},
      ],
      2: [
        {'aparato': 'Salto', 'objetivo': 'Fase de repulsión (block) en mesa minimizando flexión de codos.'},
        {'aparato': 'Barras', 'objetivo': 'Niv 3/4: khip baja y transición a barra alta. Niv 5/6: clear hip circle o rodada gigante.'},
        {'aparato': 'Viga', 'objetivo': 'Estabilidad en series acrobáticas obligatorias (flic-flac o rueda-rueda).'},
        {'aparato': 'Piso', 'objetivo': 'Series conectadas: redondilla + flic-flac + flic-flac o back tuck.'},
      ],
      3: [
        {'aparato': 'Salto', 'objetivo': 'Automatizar carrera midiendo pasos exactos para evitar titubeos.'},
        {'aparato': 'Barras', 'objetivo': 'Salida reglamentaria (salto mortal atrás en Niv 5/6) con altura y distancia.'},
        {'aparato': 'Viga', 'objetivo': 'Jueceo simulado: penalizar flexiones, caídas de puntas y desajustes.'},
        {'aparato': 'Piso', 'objetivo': 'Mortales con máxima altura del centro de gravedad y apertura previa.'},
      ],
      4: [
        {'aparato': 'Salto', 'objetivo': '5 saltos limpios consecutivos con clavadas sin pasos de ajuste.'},
        {'aparato': 'Barras', 'objetivo': 'Rutina competitiva oficial completa sin interrupciones.'},
        {'aparato': 'Viga', 'objetivo': 'Rutina obligatoria completa en viga alta buscando cero caídas.'},
        {'aparato': 'Piso', 'objetivo': 'Rutina oficial con música: potencia acrobática + gracia artística USAG.'},
      ],
    },
  };

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
        actions: [
          IconButton(
            icon: const Icon(Icons.track_changes_outlined),
            tooltip: 'Objetivos de la semana',
            onPressed: _mostrarObjetivos,
          ),
        ],
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

  int _semanaActual() {
    final hoy = DateTime.now();
    if (hoy.isBefore(DateTime(2026, 7, 27))) return 1;
    if (hoy.isBefore(DateTime(2026, 8, 3))) return 2;
    if (hoy.isBefore(DateTime(2026, 8, 10))) return 3;
    return 4;
  }

  void _mostrarObjetivos() {
    final semana = _semanaActual();
    final objetivosGrupo = _objetivos[_grupoSeleccionado]?[semana] ?? [];
    final nombreGrupo = {
      'mexico': '🇲🇽 México',
      'inglaterra': '🏴󠁧󠁢󠁥󠁮󠁧󠁿 Inglaterra',
      'portugal': '🇵🇹 Portugal',
      'noruega': '🇳🇴 Noruega',
    }[_grupoSeleccionado] ?? _grupoSeleccionado;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Objetivos · Semana $semana',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          nombreGrupo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D1060),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5D0FE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Sem $semana / 4',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B2FA0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.all(20),
                itemCount: objetivosGrupo.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final obj = objetivosGrupo[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F5FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9D5FF)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D1060),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            obj['aparato']!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            obj['objetivo']!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1A1A1A),
                              height: 1.5,
                            ),
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
      ),
    );
  }
}
