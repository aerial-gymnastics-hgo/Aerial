import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';

class ExcelExportService {
  static final _currencyFmt =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  static final _dateFmt = DateFormat('dd/MM/yyyy');
  static final _timeFmt = DateFormat('HH:mm');
  static final _stampFmt = DateFormat('yyyyMMdd_HHmmss');

  /// Genera el reporte Excel y retorna el [File] creado.
  static Future<File> generateReport(
    List<Payment> payments, {
    String sheetName = 'Reporte de Pagos',
  }) async {
    final excel = Excel.createExcel();
    // Eliminar la hoja por defecto de la librería
    excel.delete('Sheet1');

    final Sheet sheet = excel[sheetName];

    // ── Encabezados ─────────────────────────────────────────────────────────
    final headers = [
      'Folio',
      'Fecha',
      'Hora',
      'Alumna',
      'Grupo',
      'Concepto',
      'Método de Pago',
      'Monto (MXN)',
      'Registrado Por',
      'Estado',
    ];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#1A237E'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
    );

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    for (int col = 0; col < headers.length; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
          .cellStyle = headerStyle;
    }

    // ── Filas de datos ───────────────────────────────────────────────────────
    final evenRowStyle = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#F5F5F5'),
    );

    for (int i = 0; i < payments.length; i++) {
      final p = payments[i];
      sheet.appendRow([
        TextCellValue(p.folio),
        TextCellValue(_dateFmt.format(p.paidAt)),
        TextCellValue(_timeFmt.format(p.paidAt)),
        TextCellValue(p.studentName),
        TextCellValue(p.groupId.toUpperCase()),
        TextCellValue(p.concept),
        TextCellValue(p.paymentMethod),
        DoubleCellValue(p.amount),
        TextCellValue(p.registeredBy),
        TextCellValue(p.status),
      ]);

      // Filas alternadas de color
      if (i.isEven) {
        final row = i + 1; // 0-indexed header already occupies row 0
        for (int col = 0; col < headers.length; col++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
              .cellStyle = evenRowStyle;
        }
      }
    }

    // ── Fila de total ────────────────────────────────────────────────────────
    final total = payments.fold<double>(0, (sum, p) => sum + p.amount);

    final totalStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#E8EAF6'),
      fontColorHex: ExcelColor.fromHexString('#1A237E'),
    );

    final totalRow = payments.length + 1;
    sheet.appendRow([
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('TOTAL:'),
      DoubleCellValue(total),
      TextCellValue('${payments.length} pagos'),
      TextCellValue(''),
    ]);

    for (int col = 0; col < headers.length; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: col, rowIndex: totalRow))
          .cellStyle = totalStyle;
    }

    // ── Ancho de columnas ────────────────────────────────────────────────────
    final colWidths = [16, 12, 8, 26, 18, 30, 16, 14, 28, 12];
    for (int i = 0; i < colWidths.length; i++) {
      sheet.setColumnWidth(i, colWidths[i].toDouble());
    }

    // ── Guardar archivo ──────────────────────────────────────────────────────
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = _stampFmt.format(DateTime.now());
    final filePath = '${dir.path}/reporte_pagos_$timestamp.xlsx';

    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  /// Genera el reporte y lo comparte inmediatamente.
  static Future<void> exportAndShare(
    List<Payment> payments, {
    String subject = 'Reporte de Pagos – Casa Pädi',
  }) async {
    final file = await generateReport(payments);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
      subject: subject,
    );
  }
}
