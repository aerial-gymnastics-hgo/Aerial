import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: const AssetImage('assets/images/gimnasia_landing.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.85), BlendMode.darken),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
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
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.analytics, color: Colors.cyanAccent, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analytics Avanzado',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Análisis profundo de asistencia, pagos y proyecciones',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.cyanAccent,
                labelColor: Colors.cyanAccent,
                unselectedLabelColor: Colors.white60,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                unselectedLabelStyle: GoogleFonts.poppins(),
                tabs: const [
                  Tab(icon: Icon(Icons.people), text: 'Asistencia'),
                  Tab(icon: Icon(Icons.attach_money), text: 'Pagos'),
                  Tab(icon: Icon(Icons.trending_up), text: 'Proyecciones'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAsistenciaTab(),
                  _buildPagosTab(),
                  _buildProyeccionesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: Asistencia por Grupo
  Widget _buildAsistenciaTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance')
          .where('createdAt', isGreaterThan: DateTime.now().subtract(const Duration(days: 30)))
          .snapshots(),
      builder: (context, attendanceSnapshot) {
        if (!attendanceSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }

        final attendanceDocs = attendanceSnapshot.data!.docs;

        // Agrupar por grupo y calcular porcentajes
        final Map<String, Map<String, int>> groupStats = {};

        for (final doc in attendanceDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final groupId = data['groupId'] as String? ?? 'unknown';
          final status = data['status'] as String? ?? 'pending';

          if (!groupStats.containsKey(groupId)) {
            groupStats[groupId] = {
              'present': 0,
              'absent': 0,
              'pending': 0,
              'total': 0,
            };
          }

          groupStats[groupId]![status] = (groupStats[groupId]![status] ?? 0) + 1;
          groupStats[groupId]!['total'] = (groupStats[groupId]!['total'] ?? 0) + 1;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asistencia por Grupo (Últimos 30 días)',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              if (groupStats.isEmpty)
                 Container(
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.05),
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: Colors.white.withOpacity(0.1)),
                   ),
                   child: Center(
                     child: Text(
                       'No hay registros de asistencia en los últimos 30 días.',
                       style: GoogleFonts.poppins(color: Colors.white70),
                       textAlign: TextAlign.center,
                     ),
                   ),
                 )
              else
                // Cards por grupo
                ...groupStats.entries.map((entry) {
                  final groupId = entry.key;
                  final stats = entry.value;
                  final total = stats['total'] ?? 1;
                  final present = stats['present'] ?? 0;
                  final absent = stats['absent'] ?? 0;

                  final porcentajeAsistencia = total > 0 ? (present / total * 100) : 0.0;

                  return _buildGroupStatsCard(
                    groupId: groupId,
                    porcentajeAsistencia: porcentajeAsistencia,
                    totalPresentes: present,
                    totalAusentes: absent,
                    totalClases: total,
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupStatsCard({
    required String groupId,
    required double porcentajeAsistencia,
    required int totalPresentes,
    required int totalAusentes,
    required int totalClases,
  }) {
    Color statusColor = porcentajeAsistencia >= 80
        ? Colors.greenAccent
        : porcentajeAsistencia >= 60
            ? Colors.orangeAccent
            : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.group, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupId.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$totalClases clases registradas',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${porcentajeAsistencia.toStringAsFixed(1)}%',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: porcentajeAsistencia / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(statusColor),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 16),

          // Estadísticas detalladas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatChip(
                '✅ $totalPresentes',
                'Presentes',
                Colors.greenAccent,
              ),
              _buildStatChip(
                '❌ $totalAusentes',
                'Ausentes',
                Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  // TAB 2: Análisis de Pagos
  Widget _buildPagosTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('payments')
          .orderBy('createdAt', descending: true)
          .limit(300)
          .snapshots(),
      builder: (context, paymentsSnapshot) {
        if (!paymentsSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }

        final payments = paymentsSnapshot.data!.docs;

        // Agrupar pagos por mes
        final Map<String, double> ingresosPorMes = {};
        final Map<String, int> pagosPorMes = {};

        for (final doc in payments) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

          if (createdAt != null) {
            final mesKey = DateFormat('MMM yyyy').format(createdAt);
            ingresosPorMes[mesKey] = (ingresosPorMes[mesKey] ?? 0) + amount;
            pagosPorMes[mesKey] = (pagosPorMes[mesKey] ?? 0) + 1;
          }
        }

        // Ordenar por fecha
        final mesesOrdenados = ingresosPorMes.keys.toList()
          ..sort((a, b) {
            final dateA = DateFormat('MMM yyyy').parse(a);
            final dateB = DateFormat('MMM yyyy').parse(b);
            return dateA.compareTo(dateB);
          });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tendencias de Pagos Mensuales',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              if (mesesOrdenados.isEmpty)
                Container(
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.05),
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: Colors.white.withOpacity(0.1)),
                   ),
                   child: Center(
                     child: Text(
                       'No hay pagos registrados.',
                       style: GoogleFonts.poppins(color: Colors.white70),
                       textAlign: TextAlign.center,
                     ),
                   ),
                 )
              else ...[
                // Gráfico de barras
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: ingresosPorMes.values.isEmpty
                          ? 10000
                          : ingresosPorMes.values.reduce((a, b) => a > b ? a : b) * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '\$${rod.toY.toStringAsFixed(0)}',
                              GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < mesesOrdenados.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    mesesOrdenados[value.toInt()],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white60,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox();
                              return Text(
                                '\$${(value / 1000).toStringAsFixed(0)}k',
                                style: GoogleFonts.poppins(
                                  color: Colors.white60,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withOpacity(0.1),
                          strokeWidth: 1,
                        ),
                      ),
                      barGroups: List.generate(
                        mesesOrdenados.length,
                        (index) {
                          final mes = mesesOrdenados[index];
                          final ingreso = ingresosPorMes[mes] ?? 0;
  
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: ingreso,
                                color: Colors.cyanAccent,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: ingresosPorMes.values.reduce((a, b) => a > b ? a : b) * 1.2,
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
  
                const SizedBox(height: 24),
  
                // Resumen de estadísticas
                ...mesesOrdenados.reversed.take(6).map((mes) {
                  final ingreso = ingresosPorMes[mes] ?? 0;
                  final numPagos = pagosPorMes[mes] ?? 0;
  
                  return _buildMesStatsCard(
                    mes: mes,
                    ingresos: ingreso,
                    numeroPagos: numPagos,
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMesStatsCard({
    required String mes,
    required double ingresos,
    required int numeroPagos,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_month, color: Colors.cyanAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mes,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$numeroPagos pagos registrados',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${ingresos.toStringAsFixed(2)}',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  // TAB 3: Proyecciones
  Widget _buildProyeccionesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('payments')
          .where('createdAt', isGreaterThan: DateTime.now().subtract(const Duration(days: 90)))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }

        final payments = snapshot.data!.docs;
        
        if (payments.isEmpty) {
          return Center(
             child: Text(
               'No hay pagos recientes para proyectar.',
               style: GoogleFonts.poppins(color: Colors.white70),
               textAlign: TextAlign.center,
             ),
          );
        }

        final totalIngresos = payments.fold<double>(
          0,
          (sum, doc) => sum + (((doc.data() as Map<String, dynamic>)['amount'] as num?)?.toDouble() ?? 0.0),
        );

        final promedioMensual = totalIngresos / 3; // Últimos 3 meses aprox
        final proyeccion3Meses = promedioMensual * 3;
        final proyeccion6Meses = promedioMensual * 6;
        final proyeccion12Meses = promedioMensual * 12;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Proyecciones de Ingresos',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Basado en promedio de los últimos 90 días',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 24),

              _buildProyeccionCard(
                titulo: 'Promedio Mensual',
                monto: promedioMensual,
                icono: Icons.calendar_today,
                color: Colors.blueAccent,
              ),

              _buildProyeccionCard(
                titulo: 'Proyección 3 Meses',
                monto: proyeccion3Meses,
                icono: Icons.calendar_view_week,
                color: Colors.cyanAccent,
              ),

              _buildProyeccionCard(
                titulo: 'Proyección 6 Meses',
                monto: proyeccion6Meses,
                icono: Icons.calendar_view_month,
                color: Colors.greenAccent,
              ),

              _buildProyeccionCard(
                titulo: 'Proyección 12 Meses',
                monto: proyeccion12Meses,
                icono: Icons.event,
                color: Colors.amberAccent,
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orangeAccent.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orangeAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Las proyecciones son estimaciones basadas en datos históricos. Los resultados reales pueden variar.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProyeccionCard({
    required String titulo,
    required double monto,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${monto.toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
