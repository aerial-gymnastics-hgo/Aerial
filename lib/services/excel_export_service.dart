import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';
import '../utils/web_download.dart';

class ExcelExportService {
  static final _dateFmt = DateFormat('dd/MM/yyyy');
  static final _timeFmt = DateFormat('HH:mm');
  static final _stampFmt = DateFormat('yyyyMMdd_HHmmss');

  static const _mimeXlsx =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  // ── Construcción del Excel ─────────────────────────────────────────────────

  /// Construye el workbook y devuelve los bytes codificados.
  static Uint8List generateBytes(
    List<Payment> payments, {
    String sheetName = 'Reporte de Pagos',
  }) {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    final Sheet sheet = excel[sheetName];

    final headers = [
      'Folio', 'Fecha', 'Hora', 'Alumna', 'Grupo',
      'Concepto', 'Método de Pago', 'Monto (MXN)', 'Registrado Por', 'Estado',
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
      if (i.isEven) {
        final row = i + 1;
        for (int col = 0; col < headers.length; col++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
              .cellStyle = evenRowStyle;
        }
      }
    }

    final total = payments.fold<double>(0, (sum, p) => sum + p.amount);
    final totalStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#E8EAF6'),
      fontColorHex: ExcelColor.fromHexString('#1A237E'),
    );
    final totalRow = payments.length + 1;
    sheet.appendRow([
      TextCellValue(''), TextCellValue(''), TextCellValue(''),
      TextCellValue(''), TextCellValue(''), TextCellValue(''),
      TextCellValue('TOTAL:'),
      DoubleCellValue(total),
      TextCellValue('${payments.length} pagos'),
      TextCellValue(''),
    ]);
    for (int col = 0; col < headers.length; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: totalRow))
          .cellStyle = totalStyle;
    }

    final colWidths = [16, 12, 8, 26, 18, 30, 16, 14, 28, 12];
    for (int i = 0; i < colWidths.length; i++) {
      sheet.setColumnWidth(i, colWidths[i].toDouble());
    }

    return Uint8List.fromList(excel.encode()!);
  }

  // ── Descarga / Compartir ──────────────────────────────────────────────────

  /// En web dispara la descarga del archivo en el navegador.
  /// En otras plataformas abre el menú de compartir nativo.
  static Future<void> downloadReport(
    List<Payment> payments, {
    String? filename,
    String subject = 'Reporte de Pagos – Aerial Gymnastics',
  }) async {
    final bytes = generateBytes(payments);
    final fname =
        filename ?? 'reporte_pagos_${_stampFmt.format(DateTime.now())}.xlsx';

    if (kIsWeb) {
      triggerWebDownload(fname, bytes);
    } else {
      await Share.shareXFiles(
        [XFile.fromData(bytes, name: fname, mimeType: _mimeXlsx)],
        subject: subject,
      );
    }
  }
}
