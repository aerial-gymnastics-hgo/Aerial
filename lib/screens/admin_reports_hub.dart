import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'student_admin_detail_screen.dart';
import '../utils/image_helper.dart';
import '../services/pdf_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  List<User> _students = [];
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FirestoreService.instance.getStudents().listen((data) {
      if (mounted) {
        setState(() => _students = data);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildDarkScaffold(
      context: context,
      title: 'Centro de Reportes',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEnrollmentChart(context),
            const SizedBox(height: 24),
            Text(
              'Reportes Detallados',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  const Shadow(color: Colors.cyanAccent, blurRadius: 10)
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildReportGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkScaffold(
      {required BuildContext context,
      required String title,
      required Widget body,
      List<Widget>? actions}) {
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
          title: Text(title,
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: actions,
        ),
        body: body,
      ),
    );
  }

  Widget _buildGlassContainer(
      {required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
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

  Widget _buildEnrollmentChart(BuildContext context) {
    final totalStudents = _students.length;

    final groupCounts = <String, int>{};
    for (var s in _students) {
      groupCounts[s.group] = (groupCounts[s.group] ?? 0) + 1;
    }

    final colors = [
      Colors.cyanAccent,
      Colors.pinkAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.tealAccent,
      Colors.indigoAccent,
    ];

    return _buildGlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis de Matrícula',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total Alumnas Activas: $totalStudents',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          if (totalStudents > 0)
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 200,
                    child: CustomPaint(
                      painter: _PieChartPainter(
                        counts: groupCounts.values.toList(),
                        colors: colors,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: groupCounts.entries.map((entry) {
                      final index =
                          groupCounts.keys.toList().indexOf(entry.key);
                      final color = colors[index % colors.length];
                      final percentage = (entry.value / totalStudents * 100)
                          .toStringAsFixed(0);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReportGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildReportCard(
          context,
          title: 'Reporte de Adeudos',
          icon: Icons.credit_card_off,
          color: Colors.redAccent,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const DebtorsReportScreen())),
        ),
        _buildReportCard(
          context,
          title: 'Próximos Cumpleaños',
          icon: Icons.cake,
          color: Colors.pinkAccent,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BirthdaysReportScreen())),
        ),
        _buildReportCard(
          context,
          title: 'Listas por Grupo',
          icon: Icons.list_alt,
          color: Colors.cyanAccent,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const GroupRostersScreen())),
        ),
      ],
    );
  }

  Widget _buildReportCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: _buildGlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<int> counts;
  final List<Color> colors;

  _PieChartPainter({required this.counts, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (counts.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width / 2 : size.height / 2;
    final total = counts.fold(0, (a, b) => a + b);
    if (total == 0) return;

    double startAngle = -3.14159 / 2;

    for (int i = 0; i < counts.length; i++) {
      final sweepAngle = (counts[i] / total) * 2 * 3.14159;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 25;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 15),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DebtorsReportScreen extends StatefulWidget {
  const DebtorsReportScreen({super.key});

  @override
  State<DebtorsReportScreen> createState() => _DebtorsReportScreenState();
}

class _DebtorsReportScreenState extends State<DebtorsReportScreen> {
  List<User> _debtors = [];
  Map<String, double> _debtAmounts = {};
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FirestoreService.instance.getStudents().listen(_computeDebtors);
  }

  Future<void> _computeDebtors(List<User> students) async {
    try {
      final paidIds =
          await FirestoreService.instance.getStudentIdsPaidThisMonth();
      final debtors =
          students.where((s) => !paidIds.contains(s.id)).toList();

      final groupFees = <String, double>{};
      final amounts = <String, double>{};
      for (var s in debtors) {
        double? fee = s.monthlyFee;
        if (fee == null) {
          if (!groupFees.containsKey(s.group)) {
            final info = await FirestoreService.instance.getGroupInfo(s.group);
            groupFees[s.group] = info?.monthlyFee ?? 0;
          }
          fee = groupFees[s.group];
        }
        amounts[s.id] = fee ?? 0;
      }

      if (mounted) {
        setState(() {
          _debtors = debtors;
          _debtAmounts = amounts;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error consultando pagos: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalDebt =
        _debtAmounts.values.fold<double>(0, (sum, amount) => sum + amount);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
            image: const AssetImage('assets/images/gimnasia_landing.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.85), BlendMode.darken)),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Reporte de Adeudos',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
                icon: const Icon(Icons.print),
                onPressed: () =>
                    PdfService.generateDebtorsPdf(_debtors, _debtAmounts),
                tooltip: 'Imprimir Reporte'),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.redAccent))
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_error!,
                          textAlign: TextAlign.center,
                          style:
                              GoogleFonts.poppins(color: Colors.redAccent)),
                    ))
                : Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  border: const Border(
                      bottom: BorderSide(color: Colors.redAccent))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Deuda General Activa:',
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white70)),
                  Text('\$${totalDebt.toStringAsFixed(2)}',
                      style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _debtors.length,
                itemBuilder: (context, index) {
                  final student = _debtors[index];

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              border: Border.all(
                                  color: Colors.redAccent.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(16)),
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              iconColor: Colors.white,
                              collapsedIconColor: Colors.white70,
                              leading: CircleAvatar(
                                backgroundColor:
                                    Colors.redAccent.withOpacity(0.2),
                                backgroundImage: getProfileImageProvider(student.photoUrl),
                                child: student.photoUrl == null
                                    ? Text(student.name[0],
                                        style: const TextStyle(
                                            color: Colors.white))
                                    : null,
                              ),
                              title: Text(student.name,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              subtitle: Text(student.group,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: Colors.white54)),
                              children: [
                                ListTile(
                                  dense: true,
                                  title: Text('Mensualidad Vencida',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13, color: Colors.white70)),
                                  trailing: Text(
                                      '\$${(_debtAmounts[student.id] ?? 0).toStringAsFixed(2)}',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
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

class BirthdaysReportScreen extends StatefulWidget {
  const BirthdaysReportScreen({super.key});

  @override
  State<BirthdaysReportScreen> createState() => _BirthdaysReportScreenState();
}

class _BirthdaysReportScreenState extends State<BirthdaysReportScreen> {
  List<User> _birthdayGirls = [];
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    final currentMonth = DateTime.now().month;
    _sub = FirestoreService.instance.getStudents().listen((data) {
      if (mounted) {
        setState(() {
          _birthdayGirls = data
              .where((s) => s.birthDate?.month == currentMonth)
              .toList()
            ..sort((a, b) => a.birthDate!.day.compareTo(b.birthDate!.day));
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
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
                Colors.black.withOpacity(0.85), BlendMode.darken)),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Cumpleaños del Mes',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
                icon: const Icon(Icons.print),
                onPressed: () => PdfService.generateBirthdayPdf(_birthdayGirls),
                tooltip: 'Imprimir Lista'),
          ],
        ),
        body: _birthdayGirls.isEmpty
            ? Center(
                child: Text('No hay cumpleaños este mes',
                    style: GoogleFonts.poppins(color: Colors.white70)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _birthdayGirls.length,
                itemBuilder: (context, index) {
                  final student = _birthdayGirls[index];
                  final day = student.birthDate!.day;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              border: Border.all(
                                  color: Colors.pinkAccent.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.pinkAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.pinkAccent)),
                              child: Text(day.toString(),
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pinkAccent,
                                      fontSize: 18)),
                            ),
                            title: Text(student.name,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            subtitle: Text(student.group,
                                style:
                                    GoogleFonts.poppins(color: Colors.white70)),
                            trailing: const Icon(Icons.cake,
                                color: Colors.pinkAccent),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class GroupRostersScreen extends StatefulWidget {
  const GroupRostersScreen({super.key});

  @override
  State<GroupRostersScreen> createState() => _GroupRostersScreenState();
}

class _GroupRostersScreenState extends State<GroupRostersScreen> {
  String? selectedGroup;
  List<User> _allStudents = [];
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    selectedGroup = FirestoreService.availableGroups.first;
    _sub = FirestoreService.instance.getStudents().listen((data) {
      if (mounted) setState(() => _allStudents = data);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const groups = FirestoreService.availableGroups;
    final students = selectedGroup != null
        ? _allStudents.where((s) => s.group == selectedGroup).toList()
        : <User>[];

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
            image: const AssetImage('assets/images/gimnasia_landing.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.85), BlendMode.darken)),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Listas por Grupo',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            if (selectedGroup != null)
              IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: () =>
                      PdfService.generateRosterPdf(selectedGroup!, students),
                  tooltip: 'Imprimir Lista'),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  final isSelected = selectedGroup == group;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(group,
                          style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white)),
                      selected: isSelected,
                      selectedColor: Colors.cyanAccent,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      onSelected: (val) =>
                          setState(() => selectedGroup = group),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: students.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.white12),
                itemBuilder: (context, index) {
                  final student = students[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.white.withOpacity(0.05),
                        child: ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                            child: Text('${index + 1}',
                                style: const TextStyle(
                                    color: Colors.cyanAccent,
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text(student.name,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          trailing: IconButton(
                            icon: const Icon(Icons.info_outline,
                                color: Colors.cyanAccent),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          StudentAdminDetailScreen(
                                              student: student)));
                            },
                          ),
                        ),
                      ),
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
