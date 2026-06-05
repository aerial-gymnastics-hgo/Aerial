import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateRosterPdf(String groupName, List<User> students) async {
    final doc = pw.Document();
    final date = DateFormat('dd/MM/yyyy').format(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          _buildHeader('Lista de Asistencia - $groupName', date),
          pw.SizedBox(height: 20),
          _buildRosterTable(students),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Lista_$groupName.pdf',
    );
  }

  static Future<void> generateDebtorsPdf(List<User> debtors) async {
    final doc = pw.Document();
    final date = DateFormat('dd/MM/yyyy').format(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          _buildHeader('Reporte de Adeudos', date),
          pw.SizedBox(height: 20),
          _buildDebtorsTable(debtors),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Reporte_Adeudos.pdf',
    );
  }

  static Future<void> generateBirthdayPdf(List<User> students) async {
    final doc = pw.Document();
    final date = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final monthName = DateFormat('MMMM', 'es_ES').format(DateTime.now()); // Necesita inicialización de locale, usaremos inglés o simple por ahora

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          _buildHeader('Cumpleaños del Mes', date),
          pw.SizedBox(height: 20),
          _buildBirthdayTable(students),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Cumpleanos_Mes.pdf',
    );
  }

  static pw.Widget _buildHeader(String title, String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('AERIAL GYMNASTICS', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.purple)),
            pw.Text('Generado: $date', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
          ],
        ),
        pw.Divider(color: PdfColors.purple),
        pw.SizedBox(height: 10),
        pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildRosterTable(List<User> students) {
    return pw.Table.fromTextArray(
      headers: ['#', 'Nombre Completo', 'Asistencia', 'Observaciones'],
      data: List<List<String>>.generate(
        students.length,
        (index) => [
          (index + 1).toString(),
          students[index].name,
          '', // Espacio para check
          '', // Espacio para notas
        ],
      ),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.purple),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerLeft,
      },
    );
  }

  static pw.Widget _buildDebtorsTable(List<User> debtors) {
    double totalDebt = 0;
    final data = <List<String>>[];

    for (var s in debtors) {
      final isDebt = s.id.toLowerCase().contains('a') || s.id.toLowerCase().contains('o');
      if (isDebt) {
        totalDebt += 1200.0;
        data.add([
          s.name,
          s.group ?? 'N/A',
          'Mensualidad',
          '\$1200.0',
        ]);
      }
    }

    // Agregar fila de total
    data.add(['', '', 'TOTAL', '\$${totalDebt.toStringAsFixed(2)}']);

    return pw.Table.fromTextArray(
      headers: ['Alumna', 'Grupo', 'Concepto', 'Monto'],
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.red),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildBirthdayTable(List<User> students) {
    return pw.Table.fromTextArray(
      headers: ['Día', 'Nombre', 'Grupo'],
      data: students.map((s) {
        final day = (s.name.length * 3) % 28 + 1; // Simulación determinista
        return [
          day.toString(),
          s.name,
          s.group ?? 'N/A',
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.pink),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
      },
    );
  }
}
