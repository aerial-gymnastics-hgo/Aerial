import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
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

  static Future<void> generateDebtorsPdf(
      List<User> debtors, Map<String, double> debtAmounts) async {
    final doc = pw.Document();
    final date = DateFormat('dd/MM/yyyy').format(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          _buildHeader('Reporte de Adeudos', date),
          pw.SizedBox(height: 20),
          _buildDebtorsTable(debtors, debtAmounts),
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

  static Future<Uint8List> generateReceiptPdf(Payment payment) async {
    final doc = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'es_MX');
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final date = dateFormat.format(payment.paidAt);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'AERIAL GYMNASTICS',
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.purple),
                    ),
                    pw.Text(
                      'Gimnasia Artística · Pachuca, Hgo.',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'RECIBO DE PAGO',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 2),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              // Folio
              pw.Text(
                'Folio: ${payment.folio}',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.purple),
              ),
              pw.SizedBox(height: 16),

              // Student Data
              pw.Text('DATOS DE LA ALUMNA', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey)),
              pw.SizedBox(height: 6),
              pw.Text('Nombre: ${payment.studentName}', style: const pw.TextStyle(fontSize: 11)),
              pw.Text('Grupo: ${payment.groupId.toUpperCase()}', style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 16),

              // Payment Detail
              pw.Text('DETALLE DEL PAGO', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey)),
              pw.SizedBox(height: 6),
              pw.Text('Concepto: ${payment.concept}', style: const pw.TextStyle(fontSize: 11)),
              pw.Text('Método: ${payment.paymentMethod}', style: const pw.TextStyle(fontSize: 11)),
              pw.Text('Fecha: $date', style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 16),

              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 12),

              // Amount
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL PAGADO',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      currencyFormat.format(payment.amount),
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.purple),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  '✓ Pago completado',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.green),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Registrado por: ${payment.registeredBy}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
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

  static pw.Widget _buildDebtorsTable(
      List<User> debtors, Map<String, double> debtAmounts) {
    double totalDebt = 0;
    final data = <List<String>>[];

    for (var s in debtors) {
      final amount = debtAmounts[s.id] ?? 0;
      totalDebt += amount;
      data.add([
        s.name,
        s.group,
        'Mensualidad',
        '\$${amount.toStringAsFixed(2)}',
      ]);
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
      data: students.where((s) => s.birthDate != null).map((s) {
        return [
          s.birthDate!.day.toString(),
          s.name,
          s.group,
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
