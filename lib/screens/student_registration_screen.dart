import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';
import '../services/registration_service.dart';
import '../models/group_model.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Student fields
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  DateTime? _birthDate;
  String _selectedGroup = 'Oruguitas';

  // Tutor fields
  final _tutorNameController = TextEditingController();
  final _tutorPhoneController = TextEditingController();
  final _tutorEmailController = TextEditingController();

  // Photo
  Uint8List? _photoBytes;
  String? _photoName;
  bool _isRegistering = false;

  final ImagePicker _picker = ImagePicker();

  List<GymGroup> _allGroups = [];
  bool _loadingGroups = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() async {
    FirestoreService.instance.getAllGroups().listen((data) {
      if (mounted) {
        setState(() {
          _allGroups = data;
          if (_allGroups.isNotEmpty && !_allGroups.any((g) => g.id == _selectedGroup)) {
            _selectedGroup = _allGroups.first.id;
          }
          _loadingGroups = false;
        });
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _photoBytes = bytes;
          _photoName = image.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _register() async {
    if (_nameController.text.isEmpty || _lastNameController.text.isEmpty || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los datos de la alumna'), backgroundColor: Colors.orange),
      );
      setState(() => _currentStep = 0);
      return;
    }

    if (_tutorNameController.text.isEmpty || _tutorEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los datos del tutor'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isRegistering = true);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final fullName = '${_nameController.text.trim()} ${_lastNameController.text.trim()}';

    try {
      final result = await RegistrationService.registerStudentAndParent(
        studentName: fullName,
        birthDate: _birthDate!,
        group: _selectedGroup,
        tutorName: _tutorNameController.text.trim(),
        tutorPhone: _tutorPhoneController.text.trim(),
        tutorEmail: _tutorEmailController.text.trim(),
        photoBytes: _photoBytes,
      );

      if (!mounted) return;
      setState(() => _isRegistering = false);

      // Show success dialog with credentials
      _showSuccessDialog(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRegistering = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 28),
            const SizedBox(width: 8),
            Text('¡Alta Exitosa!', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCredentialRow('👧 Alumna', result['student'].name, result['student'].email, result['studentPassword']),
            const Divider(color: Colors.white24, height: 24),
            _buildCredentialRow('👨‍👩‍👧 Tutor', result['parent'].name, result['parent'].email, result['parentPassword']),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Comparta estas credenciales con el tutor. Se recomienda cambiar las contraseñas al primer ingreso.',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // return to admin dashboard
            },
            child: Text('Cerrar', style: GoogleFonts.poppins(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Reset form for another registration
              _resetForm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Registrar Otra', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String roleLabel, String name, String email, String password) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(roleLabel, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)),
        const SizedBox(height: 4),
        Text(name, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.email, size: 14, color: Colors.white38),
            const SizedBox(width: 6),
            Expanded(child: Text(email, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.key, size: 14, color: Colors.greenAccent),
            const SizedBox(width: 6),
            Text(password, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.greenAccent, letterSpacing: 2)),
          ],
        ),
      ],
    );
  }

  void _resetForm() {
    _nameController.clear();
    _lastNameController.clear();
    _tutorNameController.clear();
    _tutorPhoneController.clear();
    _tutorEmailController.clear();
    setState(() {
      _currentStep = 0;
      _birthDate = null;
      _photoBytes = null;
      _photoName = null;
      _selectedGroup = 'Oruguitas';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _tutorNameController.dispose();
    _tutorPhoneController.dispose();
    _tutorEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('Alta de Alumna', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep == 0) {
              setState(() => _currentStep = 1);
            } else {
              _register();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            } else {
              Navigator.pop(context);
            }
          },
          type: StepperType.vertical,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _isRegistering ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStep == 1 ? const Color(0xFFE91E63) : const Color(0xFF7B1FA2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isRegistering
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _currentStep == 1 ? '✨ Registrar' : 'Siguiente',
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: Text(_currentStep == 0 ? 'Cancelar' : 'Atrás', style: GoogleFonts.poppins(color: Colors.white54)),
                  ),
                ],
              ),
            );
          },
          steps: [
            // Step 1: Student Data
            Step(
              title: Text('Datos de la Alumna', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text('Información personal y grupo', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54)),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildStudentForm(),
            ),
            // Step 2: Tutor Data
            Step(
              title: Text('Datos del Tutor', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text('Persona responsable y contacto', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54)),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildTutorForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentForm() {
    return Column(
      children: [
        // Avatar + Photo picker
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.1),
                backgroundImage: _photoBytes != null ? MemoryImage(_photoBytes!) : null,
                child: _photoBytes == null
                    ? const Icon(Icons.person_add_alt_1, size: 40, color: Colors.white38)
                    : null,
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE91E63),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        if (_photoName != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${(_photoBytes!.lengthInBytes / 1024).toStringAsFixed(0)} KB',
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.greenAccent),
            ),
          ),
        const SizedBox(height: 20),

        // Name field
        _buildTextField(_nameController, 'Nombre(s)', Icons.person_outline),
        const SizedBox(height: 12),

        // Last name field
        _buildTextField(_lastNameController, 'Apellidos', Icons.people_outline),
        const SizedBox(height: 12),

        // Birth date picker
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime(2017, 1, 1),
              firstDate: DateTime(2005),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFFE91E63),
                      surface: Color(0xFF1E1E1E),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) setState(() => _birthDate = date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined, color: Colors.white38, size: 20),
                const SizedBox(width: 12),
                Text(
                  _birthDate != null
                      ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                      : 'Fecha de Nacimiento',
                  style: GoogleFonts.poppins(
                    color: _birthDate != null ? Colors.white : Colors.white38,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Group dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _loadingGroups 
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              )
            : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGroup,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF2A2A2A),
                  icon: const Icon(Icons.groups, color: Colors.white38),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  items: _allGroups.map((g) => DropdownMenuItem(
                    value: g.id,
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 10, color: Colors.pinkAccent),
                        const SizedBox(width: 10),
                        Text(g.id),
                      ],
                    ),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedGroup = val);
                  },
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildTutorForm() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF7B1FA2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF7B1FA2).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.family_restroom, color: Color(0xFF7B1FA2)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Estos datos crearán la cuenta del tutor para acceder al app.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
        _buildTextField(_tutorNameController, 'Nombre Completo del Tutor', Icons.badge_outlined),
        const SizedBox(height: 12),
        _buildTextField(_tutorPhoneController, 'Teléfono', Icons.phone_outlined, keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        _buildTextField(_tutorEmailController, 'Correo Electrónico (Login)', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE91E63), width: 1.5),
        ),
      ),
    );
  }
}
