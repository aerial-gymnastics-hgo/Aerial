import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import 'dart:async';
import '../services/firestore_service.dart';
import '../models/group_model.dart';

class StudentAdminDetailScreen extends StatelessWidget {
  final User student;

  const StudentAdminDetailScreen({super.key, required this.student});

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
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(student.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
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
            bottom: TabBar(
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              indicatorColor: Colors.cyanAccent,
              labelColor: Colors.cyanAccent,
              unselectedLabelColor: Colors.white54,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Académico'),
                Tab(text: 'Finanzas'),
                Tab(text: 'Datos'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _AcademicTab(student: student),
              _FinanceTab(student: student),
              _PersonalDataTab(student: student),
            ],
          ),
        ),
      ),
    );
  }
}

class _AcademicTab extends StatefulWidget {
  final User student;
  const _AcademicTab({required this.student});

  @override
  State<_AcademicTab> createState() => _AcademicTabState();
}

class _AcademicTabState extends State<_AcademicTab> {
  Map<String, int> _stats = {'late': 0, 'absent': 0};
  GymGroup? _groupInfo;
  StreamSubscription? _sub;
  bool _loadingGroup = true;

  @override
  void initState() {
    super.initState();
    _sub = FirestoreService.instance.getAttendanceStats(widget.student.id).listen((data) {
      if(mounted) setState(() => _stats = data);
    });
    _loadGroupInfo();
  }

  void _loadGroupInfo() async {
    final info = await FirestoreService.instance.getGroupInfo(widget.student.group);
    if (mounted) {
      setState(() {
        _groupInfo = info;
        _loadingGroup = false;
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Información del Grupo'),
          _buildGlassCard(
            child: _loadingGroup 
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
                )
              : ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                    child: const Icon(Icons.groups, color: Colors.cyanAccent),
                  ),
                  title: Text(widget.student.group, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text(
                    _groupInfo != null 
                      ? 'Horario: ${_groupInfo!.schedule} (${_groupInfo!.days})\nCosto Mensual: \$${_groupInfo!.monthlyFee.toStringAsFixed(2)}'
                      : 'Información de grupo no disponible', 
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                  isThreeLine: true,
                ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Asistencia del Ciclo'),
          Row(
            children: [
              Expanded(child: _buildStatCard('Faltas', '${_stats['absent']}', Colors.redAccent)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Retardos', '${_stats['late']}', Colors.orangeAccent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return _buildGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
    );
  }
}

class _FinanceTab extends StatefulWidget {
  final User student;
  const _FinanceTab({required this.student});

  @override
  State<_FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends State<_FinanceTab> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.instance.getFinancialStatus(widget.student.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.poppins(color: Colors.redAccent)));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }

        final finances = snapshot.data!;

        if (finances.isEmpty) {
          return Center(child: Text('Sin registros de pago', style: GoogleFonts.poppins(color: Colors.white54)));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: finances.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = finances[index];
            final status = item['status'] ?? 'Pagado';
            final isPaid = status == 'Pagado' || status == 'completed';
            final color = isPaid ? Colors.greenAccent : Colors.redAccent;
            final amount = item['amount'] is num ? item['amount'].toDouble() : 0.0;
            final paidAt = item['paidAt'] is DateTime ? item['paidAt'] as DateTime : DateTime.now();

            return _buildGlassCard(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(isPaid ? Icons.check : Icons.priority_high, color: color, size: 20),
                ),
                title: Text(item['concept'] ?? 'Sin concepto', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('dd/MM/yyyy HH:mm').format(paidAt)} • ${item['paymentMethod'] ?? 'N/A'}',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54),
                    ),
                    if (item['folio'] != null)
                      Text(
                        'Folio: ${item['folio']}',
                        style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.cyanAccent.withOpacity(0.5)),
                      ),
                  ],
                ),
                trailing: Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                ),
                onTap: () => _showPaymentDetail(context, item),
              ),
            );
          },
        );
      },
    );
  }

  void _showPaymentDetail(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
          title: Text('Detalle de Pago', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Folio', item['folio'] ?? 'N/A'),
              _detailRow('Concepto', item['concept'] ?? 'N/A'),
              _detailRow('Monto', '\$${(item['amount'] ?? 0.0).toStringAsFixed(2)}'),
              _detailRow('Método', item['paymentMethod'] ?? 'N/A'),
              _detailRow('Fecha', DateFormat('dd/MM/yyyy HH:mm').format(item['paidAt'] ?? DateTime.now())),
              if (item['notes'] != null && item['notes'].toString().isNotEmpty) 
                _detailRow('Notas', item['notes']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text('$label:', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _PersonalDataTab extends StatelessWidget {
  final User student;
  const _PersonalDataTab({required this.student});

  @override
  Widget build(BuildContext context) {
    final dob = student.birthDate != null ? DateFormat('dd/MM/yyyy').format(student.birthDate!) : 'No registrado';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(Icons.phone_in_talk, 'Contacto de Emergencia', student.emergencyContact ?? 'No registrado'),
          const SizedBox(height: 12),
          _buildInfoCard(Icons.medical_services, 'Alergias / Condiciones', student.allergies ?? 'Ninguna'),
          const SizedBox(height: 12),
          _buildInfoCard(Icons.cake, 'Fecha de Nacimiento', dob),
          const SizedBox(height: 12),
          _buildInfoCard(Icons.email, 'Correo Electrónico', student.email),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    final isPlaceholder = value == 'No registrado' || value == 'Ninguna';
    return _buildGlassCard(
      child: ListTile(
        leading: Icon(icon, color: Colors.cyanAccent),
        title: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)),
        subtitle: Text(
          value, 
          style: GoogleFonts.poppins(
            fontSize: 15, 
            fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w600, 
            color: isPlaceholder ? Colors.white38 : Colors.white,
            fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}

Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: child,
      ),
    ),
  );
}
