import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../utils/image_helper.dart';

class AdminObjectivesEditor extends StatefulWidget {
  const AdminObjectivesEditor({super.key});

  @override
  State<AdminObjectivesEditor> createState() => _AdminObjectivesEditorState();
}

class _AdminObjectivesEditorState extends State<AdminObjectivesEditor>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _objectiveController = TextEditingController();
  final _dynamicsController = TextEditingController();
  final _linkController = TextEditingController();
  final _studentObjectiveController = TextEditingController();

  String? selectedGroup;
  User? selectedStudent;

  Map<String, Map<String, dynamic>> _mesocycles = {};
  List<User> _students = [];

  StreamSubscription? _mesoSub;
  StreamSubscription? _studentSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _mesoSub = FirestoreService.instance.getMesocycles().listen((data) {
      if (!mounted) return;
      setState(() => _mesocycles = data);
      if (selectedGroup != null) {
        _loadGroupData(selectedGroup!); // Refresca en vivo si está viéndolo
      }
    });

    _studentSub = FirestoreService.instance.getStudents().listen((data) {
      if (!mounted) return;
      setState(() => _students = data);
      if (selectedStudent != null) {
        selectedStudent = _students.firstWhere(
            (s) => s.id == selectedStudent!.id,
            orElse: () => selectedStudent!);
      }
    });
  }

  @override
  void dispose() {
    _mesoSub?.cancel();
    _studentSub?.cancel();
    _tabController.dispose();
    _objectiveController.dispose();
    _dynamicsController.dispose();
    _linkController.dispose();
    _studentObjectiveController.dispose();
    super.dispose();
  }

  void _loadGroupData(String group) {
    selectedGroup = group;
    final data = _mesocycles[group];
    if (data != null) {
      _objectiveController.text = data['objective'] ?? '';
      _dynamicsController.text = data['dynamics'] ?? '';
      _linkController.text = data['supportLink'] ?? '';
    } else {
      _objectiveController.clear();
      _dynamicsController.clear();
      _linkController.clear();
    }
    setState(() {});
  }

  void _saveGroupData() async {
    if (selectedGroup == null) return;
    try {
      await FirestoreService.instance.saveMesocycle(selectedGroup!, {
        'objective': _objectiveController.text.trim(),
        'dynamics': _dynamicsController.text.trim(),
        'supportLink': _linkController.text.trim(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Mesociclo guardado exitosamente'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _saveStudentData() async {
    if (selectedStudent == null) return;
    try {
      await FirestoreService.instance.updateStudentObjective(
          selectedStudent!.id, _studentObjectiveController.text.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Meta u objetivo actualizado exitosamente'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.85), BlendMode.darken),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Editor de Mesociclos',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  const Shadow(color: Colors.cyanAccent, blurRadius: 10)
                ]),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.cyanAccent,
            labelColor: Colors.cyanAccent,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(icon: Icon(Icons.groups), text: 'Grupos (Mesociclos)'),
              Tab(icon: Icon(Icons.person), text: 'Alumnas (Metas)'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildGroupTab(),
            _buildStudentTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTab() {
    const groups = FirestoreService.availableGroups;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1. Selecciona el Grupo',
              style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: groups.map((g) {
                final isSelected = selectedGroup == g;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(g,
                        style: GoogleFonts.poppins(
                            color: isSelected ? Colors.black : Colors.white)),
                    selected: isSelected,
                    selectedColor: Colors.cyanAccent,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    onSelected: (val) {
                      if (val) _loadGroupData(g);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          if (selectedGroup != null) ...[
            _buildGlassContainer(
              borderColor: Colors.cyanAccent.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mesociclo Actual: $selectedGroup',
                      style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent)),
                  const SizedBox(height: 16),
                  _buildInputField(
                      'Objetivo Físico/Técnico del Mes', _objectiveController,
                      maxLines: 2),
                  const SizedBox(height: 16),
                  _buildInputField(
                      'Dinámica de Felicidad y Comunidad (Juegos/Retos)',
                      _dynamicsController,
                      maxLines: 2),
                  const SizedBox(height: 16),
                  _buildInputField('Enlace de Apoyo (Video/PDF Ejercicios)',
                      _linkController),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                        side: BorderSide(
                            color: Colors.cyanAccent.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveGroupData,
                      child: Text('GUARDAR MESOCICLO',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: Colors.cyanAccent)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentTab() {
    final students = _students;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1. Selecciona la Alumna',
              style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 12),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final isSelected = selectedStudent?.id == student.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedStudent = student;
                      _studentObjectiveController.text =
                          student.monthlyObjective ?? '';
                    });
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.purpleAccent.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.purpleAccent)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                            backgroundImage:
                                getProfileImageProvider(student.photoUrl),
                            radius: 24,
                            child: student.photoUrl == null
                                ? Text(student.name[0])
                                : null),
                        const SizedBox(height: 4),
                        Text(student.name.split(' ').first,
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: Colors.white),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          if (selectedStudent != null) ...[
            _buildGlassContainer(
              borderColor: Colors.purpleAccent.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alumna: ${selectedStudent!.name}',
                      style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purpleAccent)),
                  const SizedBox(height: 16),
                  _buildInputField('Asignar Meta o Enfoque Específico',
                      _studentObjectiveController,
                      maxLines: 3),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent.withOpacity(0.2),
                        side: BorderSide(
                            color: Colors.purpleAccent.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveStudentData,
                      child: Text('ACTUALIZAR META',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: Colors.purpleAccent)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black45,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white12)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.cyanAccent)),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassContainer({required Widget child, Color? borderColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: borderColor ?? Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}
