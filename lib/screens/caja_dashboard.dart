import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';
import '../services/excel_export_service.dart';
import '../widgets/payment_dialog.dart';
import '../widgets/cierre_caja_dialog.dart';
import 'landing_page.dart';
import 'analytics_dashboard.dart';

class CajaDashboard extends StatefulWidget {
  final User currentUser;
  const CajaDashboard({super.key, required this.currentUser});

  @override
  State<CajaDashboard> createState() => _CajaDashboardState();
}

class _CajaDashboardState extends State<CajaDashboard> {
  final _searchController = TextEditingController();
  final _authService = AuthService();
  String? _selectedGroup;
  String _searchQuery = '';

  final List<String> _groups = [
    'Oruguitas', 'Abejitas', 'Mariposas', 'Dragonas',
    'Panteras', 'Tigresas', 'Panditas', 'Conejas',
    'Halconas', 'Linces', 'Baby Gym'
  ];

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LandingPage()),
        (route) => false,
      );
    }
  }

  Future<void> _exportDailyClosure() async {
    final scaffoldMsg = ScaffoldMessenger.of(context);
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);

    try {
      scaffoldMsg.showSnackBar(
        const SnackBar(content: Text('⏳ Generando reporte del día...')),
      );
      final payments = await AnalyticsService.getPaymentsByDateRange(
        start: start,
        end: today,
      );
      if (payments.isEmpty) {
        scaffoldMsg.showSnackBar(
          const SnackBar(
            content: Text('No hay pagos registrados hoy.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      await ExcelExportService.downloadReport(
        payments,
        filename: 'cierre_caja_${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}.xlsx',
        subject: 'Cierre de Caja – ${today.day}/${today.month}/${today.year}',
      );
    } catch (e) {
      scaffoldMsg.showSnackBar(
        SnackBar(content: Text('Error al exportar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COBRO RÁPIDO', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 16)),
            Text('Aerial Gymnastics · ${widget.currentUser.name}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54)),
          ],
        ),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Análisis y Reportes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyticsDashboard()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildTopSearch(),
          const SizedBox(height: 12),
          _buildGroupSelector(),
          const Divider(color: Colors.white10, height: 1),
          Expanded(
            child: _selectedGroup == null && _searchQuery.isEmpty
                ? _buildEmptyState()
                : _buildStudentsList(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab_excel',
            onPressed: _exportDailyClosure,
            backgroundColor: Colors.teal.shade700,
            tooltip: 'Exportar Excel',
            child: const Icon(Icons.table_chart, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'fab_cierre',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const CierreCajaDialog(),
            ),
            backgroundColor: const Color(0xFF3949AB),
            icon: const Icon(Icons.summarize_outlined, color: Colors.white),
            label: Text('CIERRE DE CAJA',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSearch() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Buscar alumna por nombre...',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white54),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        ),
      ),
    );
  }

  Widget _buildGroupSelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final g = _groups[index];
          final isSelected = _selectedGroup == g;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(g, style: GoogleFonts.poppins(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  _selectedGroup = val ? g : null;
                });
              },
              selectedColor: const Color(0xFFE91E63),
              backgroundColor: Colors.white10,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            'Busca una alumna o selecciona un grupo',
            style: GoogleFonts.poppins(color: Colors.white24),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    Stream<List<User>> stream;
    if (_searchQuery.isNotEmpty) {
      stream = FirestoreService.instance.getStudents();
    } else {
      stream = FirestoreService.instance.getStudentsByGroup(_selectedGroup!);
    }

    return StreamBuilder<List<User>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No se encontraron alumnas', style: GoogleFonts.poppins(color: Colors.white38)));
        }

        final list = snapshot.data!.where((s) {
          if (_searchQuery.isEmpty) return true;
          return s.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        if (list.isEmpty) {
          return Center(child: Text('No hay coincidencias', style: GoogleFonts.poppins(color: Colors.white38)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _buildStudentCard(list[index]);
          },
        );
      },
    );
  }

  Widget _buildStudentCard(User student) {
    final bool isOverdue = student.paymentStatus == 'overdue';
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.white10,
                child: Text(student.name[0], style: const TextStyle(color: Colors.white70)),
              ),
              title: Text(student.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.group, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildStatusBadge(student.paymentStatus ?? 'current'),
                      const SizedBox(width: 8),
                      Text(
                        'Deuda: \$${student.monthlyFee?.toStringAsFixed(0) ?? '0'}',
                        style: GoogleFonts.montserrat(fontSize: 11, color: isOverdue ? Colors.redAccent : Colors.white38),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                color: const Color(0xFF2C2C2C),
                onSelected: (val) {
                  if (val == 'pay') _showPaymentDialog(student);
                  if (val == 'edit') _showEditStudentDialog(student);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'pay', child: Text('💳 Cobrar', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'edit', child: Text('📝 Editar Datos', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showPaymentDialog(student),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.payments, color: Colors.white, size: 18),
                      label: Text(
                        student.monthlyFee != null
                            ? 'MENSUALIDAD  \$${student.monthlyFee!.toStringAsFixed(0)}'
                            : 'MENSUALIDAD  \$800',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _showPaymentDialog(student, PaymentConcept.visita),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blueAccent),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('VISITA  \$150',
                              style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showPaymentDialog(
                              student, PaymentConcept.inscripcion),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.orangeAccent),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('INSCRIPCIÓN  \$500',
                              style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.green;
    String text = 'AL DÍA';
    if (status == 'pending') { color = Colors.orange; text = 'PENDIENTE'; }
    if (status == 'overdue') { color = Colors.red; text = 'ATRASO'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }

  // --- DIALOGS ---

  void _showPaymentDialog(User student,
      [PaymentConcept concept = PaymentConcept.mensualidad]) {
    showDialog(
      context: context,
      builder: (_) => PaymentDialog(
        studentId: student.id,
        studentName: student.name,
        groupId: student.group,
        concept: concept,
        monthlyFee: student.monthlyFee,
        guardianPhone: student.guardianPhone,
      ),
    );
  }

  void _showEditStudentDialog(User student) {
    final phoneController = TextEditingController(text: student.phone);
    final emailController = TextEditingController(text: student.email);
    final providerController = TextEditingController(text: student.insuranceProvider);
    final policyController = TextEditingController(text: student.insurancePolicyNumber);
    
    final gNameController = TextEditingController(text: student.guardianName);
    final gPhoneController = TextEditingController(text: student.guardianPhone);
    final gRelController = TextEditingController(text: student.guardianRelationship);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Actualizar Datos', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DATOS ALUMNA', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
              TextField(controller: phoneController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Teléfono Alumna')),
              TextField(controller: emailController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Email Alumna')),
              const SizedBox(height: 16),
              Text('SEGURO MÉDICO', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
              TextField(controller: providerController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Aseguradora')),
              TextField(controller: policyController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Número de Póliza')),
              const SizedBox(height: 16),
              Text('DATOS TUTOR', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
              TextField(controller: gNameController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nombre Tutor')),
              TextField(controller: gPhoneController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Teléfono Tutor')),
              TextField(controller: gRelController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Parentesco')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              await FirestoreService.instance.updateStudentProfile(student.id, {
                'phone': phoneController.text,
                'email': emailController.text,
                'insuranceProvider': providerController.text,
                'insurancePolicyNumber': policyController.text,
                'guardianName': gNameController.text,
                'guardianPhone': gPhoneController.text,
                'guardianRelationship': gRelController.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Datos actualizados correctamente')));
            },
            child: const Text('GUARDAR CAMBIOS'),
          ),
        ],
      ),
    );
  }

}

