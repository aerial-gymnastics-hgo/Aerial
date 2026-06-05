import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/trial_class_request.dart';

class TrialClassRegistrationForm extends StatefulWidget {
  const TrialClassRegistrationForm({Key? key}) : super(key: key);

  @override
  State<TrialClassRegistrationForm> createState() =>
      _TrialClassRegistrationFormState();
}

class _TrialClassRegistrationFormState
    extends State<TrialClassRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controladores
  final _studentNameController = TextEditingController();
  final _studentAgeController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _experienceDetailsController = TextEditingController();
  final _medicalDetailsController = TextEditingController();
  final _sportsDetailsController = TextEditingController();
  final _behaviorNotesController = TextEditingController();

  // Variables para grupos competitivos
  bool _hasUSAGLevel = false;
  String _usagLevelDetails = '';
  final _usagLevelController = TextEditingController();

  bool _hasOtherGymnasticsExperience = false;
  String _otherGymnasticsDetails = '';
  final _otherGymnasticsController = TextEditingController();

  // Datos del formulario
  DateTime? _birthDate;
  String? _selectedGroup;
  DateTime? _selectedTrialDate;
  bool _hasGymnasticsExperience = false;
  bool _hasMedicalConditions = false;
  bool _practicesSports = false;
  bool _isFirstSport = true;

  // Grupos disponibles con sus días de clase muestra
  final Map<String, Map<String, dynamic>> _groupsConfig = {
    'oruguitas': {
      'name': 'Oruguitas (2.6-3.10 años)',
      'days': ['Mar', 'Jue'],
      'trialDay': 'Jueves',
    },
    'abejitas': {
      'name': 'Abejitas (4-6 años)',
      'days': ['Mar', 'Jue'],
      'trialDay': 'Jueves',
    },
    'mariposas': {
      'name': 'Mariposas (6-13 años)',
      'days': ['Mar', 'Jue'],
      'trialDay': 'Jueves',
    },
    'dragonas': {
      'name': 'Dragonas (5-8 años)',
      'days': ['Lun', 'Mié', 'Vie'],
      'trialDay': 'Miércoles',
    },
    'panteras': {
      'name': 'Panteras 1 y 2 (8-14 años)',
      'days': ['Lun', 'Mié', 'Vie'],
      'trialDay': 'Miércoles',
    },
    'tigresas': {
      'name': 'Tigresas/X (12-17 años)',
      'days': ['Lun', 'Mié', 'Vie'],
      'trialDay': 'Miércoles',
    },
    'panditas': {
      'name': 'Panditas 1 y 2 (8-14 años)',
      'days': ['Lun', 'Mié', 'Vie'],
      'trialDay': 'Miércoles',
    },
    'conejas': {
      'name': 'Conejas (7-13 años)',
      'days': ['Lun-Vie'],
      'trialDay': 'Miércoles',
    },
    'halconas': {
      'name': 'Halconas (9-16 años)',
      'days': ['Lun-Vie'],
      'trialDay': 'Miércoles',
    },
    'linces': {
      'name': 'Linces (15+ años)',
      'days': ['Mar', 'Jue'],
      'trialDay': 'Jueves',
    },
  };
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _currentStep > 0 ? () {
            setState(() => _currentStep--);
          } : null,
          controlsBuilder: (context, details) {
            return Padding(
              padding: EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text(
                      _currentStep == 3 ? 'ENVIAR SOLICITUD' : 'SIGUIENTE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text('ATRÁS'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: Text('Datos del Tutor'),
              content: _buildStep1(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: Text('Datos de la Niña'),
              content: _buildStep2(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: Text('Información Adicional'),
              content: _buildStep3(),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: Text('Seleccionar Grupo y Fecha'),
              content: _buildStep4(),
              isActive: _currentStep >= 3,
              state: _currentStep > 3 ? StepState.complete : StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }
  // PASO 1: Datos del tutor
  Widget _buildStep1() {
    return Column(
      children: [
        TextFormField(
          controller: _parentNameController,
          decoration: InputDecoration(
            labelText: 'Nombre del padre/madre/tutor *',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Campo obligatorio' : null,
        ),
        SizedBox(height: 20),
        
        TextFormField(
          controller: _parentPhoneController,
          decoration: InputDecoration(
            labelText: 'Teléfono/WhatsApp *',
            prefixIcon: Icon(Icons.phone),
            hintText: '7711234567',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Campo obligatorio' : null,
        ),
        SizedBox(height: 20),
        
        TextFormField(
          controller: _parentEmailController,
          decoration: InputDecoration(
            labelText: 'Correo electrónico (opcional)',
            prefixIcon: Icon(Icons.email),
            hintText: 'ejemplo@correo.com',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  // PASO 2: Datos de la niña
  Widget _buildStep2() {
    return Column(
      children: [
        TextFormField(
          controller: _studentNameController,
          decoration: InputDecoration(
            labelText: 'Nombre completo de la niña *',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Campo obligatorio' : null,
        ),
        SizedBox(height: 20),
        
        TextFormField(
          controller: _studentAgeController,
          decoration: InputDecoration(
            labelText: 'Edad (ej: 5 años 6 meses) *',
            prefixIcon: Icon(Icons.cake),
            hintText: 'Ejemplo: 6 años 3 meses',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Campo obligatorio' : null,
        ),
        SizedBox(height: 20),
        
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text('Fecha de nacimiento *'),
            subtitle: Text(
              _birthDate != null
                  ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                  : 'No seleccionada',
              style: TextStyle(
                color: _birthDate != null ? Colors.black : Colors.grey,
              ),
            ),
            trailing: Icon(Icons.calendar_today, color: Color(0xFFE91E63)),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(Duration(days: 365 * 5)),
                firstDate: DateTime.now().subtract(Duration(days: 365 * 20)),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Color(0xFFE91E63),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() => _birthDate = date);
              }
            },
          ),
        ),
      ],
    );
  }

  // PASO 3: Información adicional
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: Text('¿Tiene experiencia en gimnasia artística?'),
          value: _hasGymnasticsExperience,
          onChanged: (value) {
            setState(() => _hasGymnasticsExperience = value ?? false);
          },
          activeColor: Color(0xFFE91E63),
        ),
        if (_hasGymnasticsExperience) ...[
          SizedBox(height: 12),
          TextFormField(
            controller: _experienceDetailsController,
            decoration: InputDecoration(
              labelText: 'Detalles de experiencia',
              hintText: '¿Dónde? ¿Cuánto tiempo?',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            maxLines: 2,
          ),
        ],
        
        SizedBox(height: 16),
        
        CheckboxListTile(
          title: Text('¿Practica otros deportes actualmente?'),
          value: _practicesSports,
          onChanged: (value) {
            setState(() => _practicesSports = value ?? false);
          },
          activeColor: Color(0xFFE91E63),
        ),
        if (_practicesSports) ...[
          SizedBox(height: 12),
          TextFormField(
            controller: _sportsDetailsController,
            decoration: InputDecoration(
              labelText: '¿Cuáles deportes?',
              hintText: 'Natación, danza, etc.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            maxLines: 2,
          ),
        ],
        
        SizedBox(height: 16),
        
        CheckboxListTile(
          title: Text('¡Es la primera vez que practica un deporte! 🎉'),
          value: _isFirstSport,
          onChanged: (value) {
            setState(() => _isFirstSport = value ?? false);
          },
          activeColor: Color(0xFFE91E63),
        ),
        
        SizedBox(height: 16),
        
        CheckboxListTile(
          title: Text('¿Tiene lesiones o condiciones médicas?'),
          value: _hasMedicalConditions,
          onChanged: (value) {
            setState(() => _hasMedicalConditions = value ?? false);
          },
          activeColor: Color(0xFFE91E63),
        ),
        if (_hasMedicalConditions) ...[
          SizedBox(height: 12),
          TextFormField(
            controller: _medicalDetailsController,
            decoration: InputDecoration(
              labelText: 'Detalles médicos importantes *',
              hintText: 'Alergias, lesiones, medicamentos, etc.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            maxLines: 3,
            validator: _hasMedicalConditions
                ? (value) => value?.isEmpty ?? true ? 'Campo obligatorio' : null
                : null,
          ),
        ],
        
        SizedBox(height: 16),
        
        TextFormField(
          controller: _behaviorNotesController,
          decoration: InputDecoration(
            labelText: 'Notas adicionales (opcional)',
            hintText: 'Personalidad, miedos, preferencias, etc.',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  // PASO 4: Seleccionar grupo y fecha
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona el grupo más adecuado',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        
        DropdownButtonFormField<String>(
          value: _selectedGroup,
          decoration: InputDecoration(
            labelText: 'Grupo *',
            prefixIcon: Icon(Icons.group),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: _groupsConfig.entries.map((entry) {
            // Identificar grupos competitivos (solo visual)
            final isCompetitive = entry.key == 'conejas' || entry.key == 'halconas';
            
            return DropdownMenuItem<String>(
              value: entry.key,
              // SIN RESTRICCIÓN: enabled: true siempre
              child: Row(
                children: [
                  Text(entry.value['name']),
                  if (isCompetitive) ...[
                    SizedBox(width: 8),
                    Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGroup = value;
              _selectedTrialDate = null;
            });
          },
          validator: (value) => value == null ? 'Selecciona un grupo' : null,
        ),
        
        if (_selectedGroup != null) ...[
          SizedBox(height: 16),
          
          // NUEVA: Advertencia si es grupo competitivo
          if (_selectedGroup == 'conejas' || _selectedGroup == 'halconas') ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '🏆 Grupo Competitivo Seleccionado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Has seleccionado un grupo de nivel competitivo (${_selectedGroup == 'conejas' ? 'N3' : 'N4/N5'} USAG).',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Proceso de Ingreso',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        _buildInfoBullet('Evaluación inicial obligatoria'),
                        _buildInfoBullet('Mínimo 1 mes en entrenamientos de desarrollo'),
                        _buildInfoBullet('Aprobación de coaches para ingreso'),
                        _buildInfoBullet('Afiliación a federación (FMG/USAG)'),
                        SizedBox(height: 8),
                        Text(
                          _hasUSAGLevel 
                            ? '✓ Excelente - ya tienes nivel USAG. Confirmaremos tu nivel en la evaluación.'
                            : 'ℹ️ Todas las gimnastas deben pasar por este proceso, incluso con experiencia previa.',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: _hasUSAGLevel ? Colors.green.shade700 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Día de clase muestra: ${_groupsConfig[_selectedGroup]!['trialDay']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Días regulares: ${(_groupsConfig[_selectedGroup]!['days'] as List).join(', ')}',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          Text(
            'Selecciona la fecha de tu clase muestra',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          
          FutureBuilder<List<DateTime>>(
            future: _getAvailableTrialDates(_selectedGroup!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final availableDates = snapshot.data!;
              
              if (availableDates.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'No hay fechas disponibles en este momento. Por favor contacta al gimnasio.',
                    style: TextStyle(color: Colors.orange.shade900),
                  ),
                );
              }
              
              return Column(
                children: availableDates.map((date) {
                  return FutureBuilder<int>(
                    future: _getTrialClassCount(_selectedGroup!, date),
                    builder: (context, countSnapshot) {
                      final count = countSnapshot.data ?? 0;
                      final isFull = count >= 4;
                      final isSelected = _selectedTrialDate?.year == date.year &&
                          _selectedTrialDate?.month == date.month &&
                          _selectedTrialDate?.day == date.day;
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected 
                                ? Color(0xFFE91E63) 
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RadioListTile<DateTime>(
                          value: date,
                          groupValue: _selectedTrialDate,
                          onChanged: isFull ? null : (value) {
                            setState(() => _selectedTrialDate = value);
                          },
                          title: Text(
                            DateFormat('EEEE, d \'de\' MMMM yyyy', 'es_ES').format(date),
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            isFull 
                                ? '🔴 Lleno (4/4)'
                                : '🟢 Disponible ($count/4)',
                            style: TextStyle(
                              color: isFull ? Colors.red : Colors.green,
                              fontSize: 12,
                            ),
                          ),
                          activeColor: Color(0xFFE91E63),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ],
    );
  }
  // Obtener próximas fechas disponibles
  Future<List<DateTime>> _getAvailableTrialDates(String groupId) async {
    final trialDay = _groupsConfig[groupId]!['trialDay'] as String;
    final targetWeekday = trialDay == 'Miércoles' ? DateTime.wednesday : DateTime.thursday;
    
    final dates = <DateTime>[];
    DateTime current = DateTime.now();
    
    // Buscar próximos 8 días del tipo correcto
    while (dates.length < 8) {
      current = current.add(Duration(days: 1));
      if (current.weekday == targetWeekday) {
        dates.add(DateTime(current.year, current.month, current.day));
      }
    }
    
    return dates;
  }

  // Contar registros existentes
  Future<int> _getTrialClassCount(String groupId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final nextDay = dateOnly.add(Duration(days: 1));
    
    final snapshot = await FirebaseFirestore.instance
        .collection('trial_class_requests')
        .where('selectedGroup', isEqualTo: groupId)
        .where('trialDate', isGreaterThanOrEqualTo: Timestamp.fromDate(dateOnly))
        .where('trialDate', isLessThan: Timestamp.fromDate(nextDay))
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();
    
    return snapshot.docs.length;
  }

  // Navegar entre pasos
  void _onStepContinue() {
    if (_currentStep == 1 && _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona la fecha de nacimiento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_currentStep == 3) {
      if (_selectedGroup == null || _selectedTrialDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor completa todos los campos'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      _submitForm();
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      setState(() => _currentStep++);
    }
  }

  // Enviar formulario
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    
    try {
      final request = TrialClassRequest(
        id: '',
        studentName: _studentNameController.text.trim(),
        studentAge: _studentAgeController.text.trim(),
        birthDate: _birthDate!,
        parentName: _parentNameController.text.trim(),
        parentPhone: _parentPhoneController.text.trim(),
        parentEmail: _parentEmailController.text.trim(),
        selectedGroup: _selectedGroup!,
        trialDate: _selectedTrialDate!,
        dayOfWeek: _groupsConfig[_selectedGroup]!['trialDay'],
        hasGymnasticsExperience: _hasGymnasticsExperience,
        experienceDetails: _experienceDetailsController.text.trim(),
        hasMedicalConditions: _hasMedicalConditions,
        medicalDetails: _medicalDetailsController.text.trim(),
        practicesSports: _practicesSports,
        sportsDetails: _sportsDetailsController.text.trim(),
        isFirstSport: _isFirstSport,
        behaviorNotes: _behaviorNotesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('trial_class_requests')
          .add(request.toJson());

      Navigator.pop(context); // Cerrar loading
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Expanded(child: Text('¡Solicitud Enviada!')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu solicitud ha sido registrada exitosamente.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📅 Clase muestra:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(DateFormat('EEEE, d \'de\' MMMM yyyy', 'es_ES').format(_selectedTrialDate!)),
                    SizedBox(height: 8),
                    Text(
                      '👧 Grupo: ${_groupsConfig[_selectedGroup]!['name']}',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Te contactaremos pronto al ${_parentPhoneController.text} para confirmar los detalles.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
              child: Text('CERRAR'),
            ),
          ],
        ),
      );

    } catch (e) {
      Navigator.pop(context); // Cerrar loading
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar solicitud: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _currentStep = 0;
      _studentNameController.clear();
      _studentAgeController.clear();
      _parentNameController.clear();
      _parentPhoneController.clear();
      _parentEmailController.clear();
      _experienceDetailsController.clear();
      _medicalDetailsController.clear();
      _sportsDetailsController.clear();
      _behaviorNotesController.clear();
      _birthDate = null;
      _selectedGroup = null;
      _selectedTrialDate = null;
      _hasGymnasticsExperience = false;
      _hasMedicalConditions = false;
      _practicesSports = false;
      _isFirstSport = true;
    });
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _studentAgeController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _parentEmailController.dispose();
    _experienceDetailsController.dispose();
    _medicalDetailsController.dispose();
    _sportsDetailsController.dispose();
    _behaviorNotesController.dispose();
    _usagLevelController.dispose();
    _otherGymnasticsController.dispose();
    super.dispose();
  }

  Widget _buildInfoBullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 16, color: Color(0xFFE91E63))),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}