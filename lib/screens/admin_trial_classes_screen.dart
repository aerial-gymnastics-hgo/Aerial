import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trial_class_request.dart';

class AdminTrialClassesScreen extends StatefulWidget {
  const AdminTrialClassesScreen({Key? key}) : super(key: key);

  @override
  State<AdminTrialClassesScreen> createState() => _AdminTrialClassesScreenState();
}

class _AdminTrialClassesScreenState extends State<AdminTrialClassesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/gimnasia_landing.png'),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsCards(),
            _buildFilterTabs(),
            Expanded(child: _buildRequestsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          SizedBox(width: 16),
          Icon(Icons.event_available, color: Colors.pink, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clases Muestra',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Gestión de solicitudes de clases de prueba',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trial_class_requests')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(height: 100);
        }

        final requests = snapshot.data!.docs;
        final pending = requests.where((d) => 
            (d.data() as Map)['status'] == 'pending').length;
        final confirmed = requests.where((d) => 
            (d.data() as Map)['status'] == 'confirmed').length;
        final completed = requests.where((d) => 
            (d.data() as Map)['status'] == 'completed').length;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pendientes',
                  pending.toString(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Confirmadas',
                  confirmed.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completadas',
                  completed.toString(),
                  Icons.done_all,
                  Colors.blue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.pink,
        labelColor: Colors.pink,
        unselectedLabelColor: Colors.white60,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'Todas'),
          Tab(text: 'Pendientes'),
          Tab(text: 'Confirmadas'),
          Tab(text: 'Completadas'),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildFilteredList(null),
        _buildFilteredList('pending'),
        _buildFilteredList('confirmed'),
        _buildFilteredList('completed'),
      ],
    );
  }

  Widget _buildFilteredList(String? statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: statusFilter == null
          ? FirebaseFirestore.instance
              .collection('trial_class_requests')
              .orderBy('createdAt', descending: true)
              .snapshots()
          : FirebaseFirestore.instance
              .collection('trial_class_requests')
              .where('status', isEqualTo: statusFilter)
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!.docs;

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.white30),
                SizedBox(height: 16),
                Text(
                  'No hay solicitudes',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(24),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final doc = requests[index];
            final data = doc.data() as Map<String, dynamic>;
            final request = TrialClassRequest.fromJson(data, doc.id);

            return _buildRequestCard(request);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(TrialClassRequest request) {
    Color statusColor;
    IconData statusIcon;
    
    switch (request.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
        break;
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    final isCompetitive = request.selectedGroup == 'conejas' || 
                         request.selectedGroup == 'halconas';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.all(20),
        childrenPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(statusIcon, color: statusColor, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                request.studentName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (isCompetitive)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'COMPETITIVO',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              '${request.studentAge} • ${request.selectedGroup.toUpperCase()}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '📅 ${DateFormat('EEEE, d MMM yyyy', 'es_ES').format(request.trialDate)}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.cyan,
              ),
            ),
          ],
        ),
        children: [
          _buildRequestDetails(request),
          SizedBox(height: 16),
          _buildActionButtons(request),
        ],
      ),
    );
  }

  Widget _buildRequestDetails(TrialClassRequest request) {
    final isCompetitive = request.selectedGroup == 'conejas' || 
                         request.selectedGroup == 'halconas';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('👤 Tutor', request.parentName),
          _buildDetailRow('📱 Teléfono', request.parentPhone),
          if (request.parentEmail.isNotEmpty)
            _buildDetailRow('📧 Email', request.parentEmail),
          
          Divider(color: Colors.white10, height: 24),
          
          // NUEVA: Sección de Nivel USAG
          if (request.hasUSAGLevel) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade900.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.military_tech, color: Colors.amber, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'NIVEL USAG CERTIFICADO',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    request.usagLevelDetails,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
          ],
          
          if (request.hasGymnasticsExperience) ...[
            _buildDetailRow('🤸 Experiencia gimnasia', request.experienceDetails),
          ],
          
          // NUEVA: Otras disciplinas
          if (request.hasOtherGymnasticsExperience) ...[
            _buildDetailRow('🎪 Otras disciplinas', request.otherGymnasticsDetails),
          ],
          
          if (request.practicesSports) ...[
            _buildDetailRow('⚽ Otros deportes', request.sportsDetails),
          ],
          
          if (request.isFirstSport) ...[
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.celebration, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text(
                    '¡Primer deporte! 🎉',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (request.hasMedicalConditions) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medical_services, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'INFORMACIÓN MÉDICA',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    request.medicalDetails,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (request.behaviorNotes.isNotEmpty) ...[
            SizedBox(height: 12),
            _buildDetailRow('📝 Notas', request.behaviorNotes),
          ],
          
          // NUEVA: Advertencia si es grupo competitivo
          if (isCompetitive) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'GRUPO COMPETITIVO',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Recordar: Evaluación + 1 mes desarrollo obligatorio antes de ingreso',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          Divider(color: Colors.white10, height: 24),
          
          _buildDetailRow(
            '🕐 Registrado',
            DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white60,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(TrialClassRequest request) {
    return Row(
      children: [
        if (request.status == 'pending') ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateStatus(request.id, 'confirmed'),
              icon: Icon(Icons.check),
              label: Text('CONFIRMAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateStatus(request.id, 'cancelled'),
              icon: Icon(Icons.close),
              label: Text('CANCELAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
        
        if (request.status == 'confirmed') ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateStatus(request.id, 'completed'),
              icon: Icon(Icons.done_all),
              label: Text('MARCAR COMPLETADA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
        
        if (request.status == 'completed' || request.status == 'cancelled') ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _deleteRequest(request.id),
              icon: Icon(Icons.delete),
              label: Text('ELIMINAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
        
        SizedBox(width: 12),
        
        IconButton(
          onPressed: () => _openWhatsApp(request.parentPhone),
          icon: Icon(Icons.chat, color: Colors.green),
          tooltip: 'Abrir WhatsApp',
        ),
      ],
    );
  }

  Future<void> _updateStatus(String requestId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('trial_class_requests')
          .doc(requestId)
          .update({
        'status': newStatus,
        if (newStatus == 'confirmed') 'confirmedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Estado actualizado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteRequest(String requestId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar solicitud?'),
        content: Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('trial_class_requests')
            .doc(requestId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Solicitud eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openWhatsApp(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('WhatsApp: $phone')),
    );
  }
}
