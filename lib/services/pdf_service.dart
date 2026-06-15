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

  static Future<Uint8List> generateCierrePdf(Map<String, dynamic> cierre) async {
    final doc = pw.Document();
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm', 'es_MX');
    final currencyFmt = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final fechaTs = cierre['fecha'];
    final fechaStr = fechaTs is DateTime
        ? dateFmt.format(fechaTs)
        : dateFmt.format((fechaTs as dynamic).toDate());
    final generadoStr = dateFmt.format(DateTime.now());

    final pagos = (cierre['pagos'] as List<dynamic>? ?? []);

    final tableData = pagos.map<List<String>>((p) {
      final paidAt = p['paidAt'];
      final paidAtStr = paidAt is DateTime
          ? DateFormat('HH:mm').format(paidAt)
          : DateFormat('HH:mm').format((paidAt as dynamic).toDate());
      return [
        p['folio']?.toString() ?? '',
        paidAtStr,
        p['studentName']?.toString() ?? '',
        p['concept']?.toString() ?? '',
        p['paymentMethod']?.toString() ?? '',
        currencyFmt.format((p['amount'] as num?)?.toDouble() ?? 0),
      ];
    }).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) => [
          // Encabezado
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('AERIAL GYMNASTICS',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.purple)),
                  pw.Text('Gimnasia Artística · Pachuca, Hgo.',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('CIERRE DE CAJA',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Generado: $generadoStr',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                ],
              ),
            ],
          ),
          pw.Divider(color: PdfColors.purple),
          pw.SizedBox(height: 8),

          // Datos del cierre
          pw.Row(children: [
            pw.Expanded(child: pw.Text('Fecha: $fechaStr', style: const pw.TextStyle(fontSize: 10))),
            pw.Expanded(child: pw.Text('Turno: ${cierre['turno'] ?? ''}', style: const pw.TextStyle(fontSize: 10))),
            pw.Expanded(child: pw.Text('Cajero: ${cierre['cajero'] ?? ''}', style: const pw.TextStyle(fontSize: 10))),
          ]),
          pw.SizedBox(height: 16),

          // Tabla de pagos
          pw.Text('DETALLE DE PAGOS',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
          pw.SizedBox(height: 6),
          pw.Table.fromTextArray(
            headers: ['Folio', 'Hora', 'Alumna', 'Concepto', 'Método', 'Monto'],
            data: tableData,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellHeight: 22,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.center,
              5: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 20),

          // Totales
          pw.Text('RESUMEN DE TOTALES',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              children: [
                _cierreTotalRow('Efectivo', currencyFmt.format(cierre['totalEfectivo'] ?? 0)),
                _cierreTotalRow('Tarjeta', currencyFmt.format(cierre['totalTarjeta'] ?? 0)),
                _cierreTotalRow('Transferencia', currencyFmt.format(cierre['totalTransferencia'] ?? 0)),
                pw.Divider(color: PdfColors.grey400),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL GENERAL',
                        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    pw.Text(currencyFmt.format(cierre['totalGeneral'] ?? 0),
                        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.purple)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text('${cierre['totalPagos'] ?? 0} pagos registrados',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _cierreTotalRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
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
