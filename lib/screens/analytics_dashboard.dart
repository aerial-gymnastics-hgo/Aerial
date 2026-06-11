import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';
import '../services/analytics_service.dart';
import '../services/excel_export_service.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard>
    with SingleTickerProviderStateMixin {
  // ── Rango de fechas ────────────────────────────────────────────────────────
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 29));
  DateTime _endDate = DateTime.now();
  String _selectedQuickRange = '30d';

  // ── Datos ──────────────────────────────────────────────────────────────────
  List<Payment> _payments = [];
  Map<String, double> _byGroup = {};
  Map<String, double> _byMethod = {};
  Map<DateTime, double> _byDay = {};
  Map<String, dynamic> _stats = {'total': 0.0, 'average': 0.0, 'count': 0, 'highest': 0.0};

  bool _loading = true;
  bool _exporting = false;

  // ── Tooltip state ──────────────────────────────────────────────────────────
  int _touchedPieIndex = -1;

  // ── Formatters ─────────────────────────────────────────────────────────────
  final _currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  final _shortDate = DateFormat('dd/MM', 'es_MX');
  final _fullDate = DateFormat('d MMM yyyy', 'es_MX');

  // ── Paleta de colores ──────────────────────────────────────────────────────
  static const _chartColors = [
    Color(0xFF00E5FF),
    Color(0xFFE91E63),
    Color(0xFFFFAB00),
    Color(0xFF69F0AE),
    Color(0xFFEA80FC),
    Color(0xFFFF6D00),
    Color(0xFF40C4FF),
    Color(0xFFB9F6CA),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── Carga de datos ─────────────────────────────────────────────────────────
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final payments = await AnalyticsService.getPaymentsByDateRange(
        start: _startDate,
        end: _endDate,
      );
      if (!mounted) return;
      setState(() {
        _payments = payments;
        _byGroup = AnalyticsService.getTotalsByGroup(payments);
        _byMethod = AnalyticsService.getTotalsByPaymentMethod(payments);
        _byDay = AnalyticsService.getTotalsByDay(payments);
        _stats = AnalyticsService.getStats(payments);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ── Exportar Excel ─────────────────────────────────────────────────────────
  Future<void> _exportToExcel() async {
    if (_payments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay pagos en el rango seleccionado.'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _exporting = true);
    try {
      await ExcelExportService.downloadReport(_payments);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Reporte Excel generado'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ── Rango rápido ───────────────────────────────────────────────────────────
  void _applyQuickRange(String label, int days) {
    setState(() {
      _selectedQuickRange = label;
      _endDate = DateTime.now();
      if (label == 'hoy') {
        _startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      } else if (label == 'mes') {
        _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
      } else {
        _startDate = DateTime.now().subtract(Duration(days: days - 1));
      }
    });
    _loadData();
  }

  // ── Selector de fecha personalizado ───────────────────────────────────────
  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5FF),
            surface: Color(0xFF1E1E2E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      _selectedQuickRange = 'custom';
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
    _loadData();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: const AssetImage('assets/images/gimnasia_landing.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.88), BlendMode.darken),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D0D1A).withOpacity(0.9),
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Análisis de Ingresos',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
              Text(
                '${_fullDate.format(_startDate)} – ${_fullDate.format(_endDate)}',
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54),
              ),
            ],
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            if (_exporting)
              const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.cyanAccent,
                    strokeWidth: 2,
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.download_outlined, color: Colors.cyanAccent),
                tooltip: 'Exportar Excel',
                onPressed: _exportToExcel,
              ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
            : RefreshIndicator(
                onRefresh: _loadData,
                color: const Color(0xFF00E5FF),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildDateRangeSelector(),
                    const SizedBox(height: 20),
                    _buildStatsCards(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('📈 Tendencia de Ingresos'),
                    const SizedBox(height: 12),
                    _buildTrendChart(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('🍩 Distribución por Grupo'),
                    const SizedBox(height: 12),
                    _buildGroupPieChart(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('💳 Método de Pago'),
                    const SizedBox(height: 12),
                    _buildPaymentMethodBreakdown(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGETS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.montserrat(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 16,
        shadows: const [Shadow(color: Colors.cyanAccent, blurRadius: 8)],
      ),
    );
  }

  // ── Selector de rango ─────────────────────────────────────────────────────
  Widget _buildDateRangeSelector() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Período de Análisis',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _quickChip('Hoy', 'hoy', 1),
                const SizedBox(width: 8),
                _quickChip('7 días', '7d', 7),
                const SizedBox(width: 8),
                _quickChip('30 días', '30d', 30),
                const SizedBox(width: 8),
                _quickChip('Este mes', 'mes', 0),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _dateTile('Desde', _startDate, true)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white30, size: 16),
              const SizedBox(width: 8),
              Expanded(child: _dateTile('Hasta', _endDate, false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickChip(String label, String key, int days) {
    final selected = _selectedQuickRange == key;
    return GestureDetector(
      onTap: () => _applyQuickRange(key, days),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00E5FF) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(0xFF00E5FF) : Colors.white12),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _dateTile(String label, DateTime date, bool isStart) {
    return GestureDetector(
      onTap: () => _pickDate(isStart: isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.cyanAccent, size: 14),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10)),
                Text(_fullDate.format(date),
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Cards de estadísticas ─────────────────────────────────────────────────
  Widget _buildStatsCards() {
    final total = _stats['total'] as double;
    final count = _stats['count'] as int;
    final avg = _stats['average'] as double;
    final highest = _stats['highest'] as double;

    return Row(
      children: [
        Expanded(child: _statCard('Total de Ingresos', _currency.format(total), Icons.monetization_on, const Color(0xFF00E5FF))),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Número de Pagos', '$count', Icons.receipt_long, const Color(0xFFE91E63))),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(value,
                  style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [Shadow(color: color.withOpacity(0.8), blurRadius: 10)])),
              const SizedBox(height: 4),
              Text(label,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Gráfico de tendencia (línea) ──────────────────────────────────────────
  Widget _buildTrendChart() {
    if (_byDay.isEmpty) return _emptyChart('Sin datos en el período seleccionado');

    final entries = _byDay.entries.toList();
    final maxY = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    return _glassCard(
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY * 1.25,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Colors.white10, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 56,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox.shrink();
                    return Text(
                      _compactCurrency(value),
                      style: GoogleFonts.poppins(color: Colors.white38, fontSize: 9),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: entries.length <= 7 ? 1 : (entries.length / 6).ceilToDouble(),
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _shortDate.format(entries[idx].key),
                        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 9),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                color: const Color(0xFF00E5FF),
                barWidth: 2.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                    radius: 3,
                    color: const Color(0xFF00E5FF),
                    strokeWidth: 1.5,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00E5FF).withOpacity(0.25),
                      const Color(0xFF00E5FF).withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots.map((s) {
                  final idx = s.x.toInt();
                  final label = idx < entries.length
                      ? _fullDate.format(entries[idx].key)
                      : '';
                  return LineTooltipItem(
                    '$label\n${_currency.format(s.y)}',
                    GoogleFonts.poppins(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Gráfico de pastel (grupos) ────────────────────────────────────────────
  Widget _buildGroupPieChart() {
    if (_byGroup.isEmpty) return _emptyChart('Sin pagos agrupados');

    final entries = _byGroup.entries.toList();
    final total = entries.fold<double>(0, (s, e) => s + e.value);

    final sections = entries.asMap().entries.map((e) {
      final idx = e.key;
      final isTouched = idx == _touchedPieIndex;
      final color = _chartColors[idx % _chartColors.length];
      final pct = (e.value.value / total * 100);

      return PieChartSectionData(
        value: e.value.value,
        color: color,
        radius: isTouched ? 72 : 60,
        titleStyle: GoogleFonts.poppins(
          fontSize: isTouched ? 13 : 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        title: pct >= 5 ? '${pct.toStringAsFixed(0)}%' : '',
        borderSide: isTouched
            ? const BorderSide(color: Colors.white, width: 2)
            : BorderSide.none,
      );
    }).toList();

    return _glassCard(
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 48,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              _touchedPieIndex = -1;
                            } else {
                              _touchedPieIndex =
                                  response.touchedSection!.touchedSectionIndex;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Leyenda
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entries.asMap().entries.map((e) {
                        final color = _chartColors[e.key % _chartColors.length];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  e.value.key,
                                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Detalle del grupo tocado
          if (_touchedPieIndex >= 0 && _touchedPieIndex < entries.length)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _chartColors[_touchedPieIndex % _chartColors.length].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _chartColors[_touchedPieIndex % _chartColors.length].withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entries[_touchedPieIndex].key,
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                    ),
                    Text(
                      _currency.format(entries[_touchedPieIndex].value),
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w900,
                          color: _chartColors[_touchedPieIndex % _chartColors.length],
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Barras de método de pago ──────────────────────────────────────────────
  Widget _buildPaymentMethodBreakdown() {
    if (_byMethod.isEmpty) return _emptyChart('Sin datos de métodos de pago');

    final total = _byMethod.values.fold<double>(0, (a, b) => a + b);
    final methodIcons = {
      'Efectivo': (Icons.money, const Color(0xFF69F0AE)),
      'Transferencia': (Icons.account_balance, const Color(0xFF40C4FF)),
      'Tarjeta': (Icons.credit_card, const Color(0xFFEA80FC)),
    };

    return _glassCard(
      child: Column(
        children: _byMethod.entries.map((entry) {
          final pct = total > 0 ? (entry.value / total) : 0.0;
          final meta = methodIcons[entry.key];
          final icon = meta?.$1 ?? Icons.payment;
          final color = meta?.$2 ?? const Color(0xFF00E5FF);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 18),
                    const SizedBox(width: 8),
                    Text(entry.key,
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(
                      _currency.format(entry.value),
                      style: GoogleFonts.montserrat(
                          color: color, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 38,
                      child: Text(
                        '${(pct * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Helpers de UI ──────────────────────────────────────────────────────────
  Widget _glassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _emptyChart(String msg) {
    return _glassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.bar_chart, color: Colors.white12, size: 48),
              const SizedBox(height: 8),
              Text(msg, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  String _compactCurrency(double value) {
    if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(0)}k';
    return '\$${value.toStringAsFixed(0)}';
  }
}
