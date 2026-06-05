import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/payment_model.dart';
import '../widgets/payment_receipt.dart';

class ReceiptCaptureService {
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  /// Genera la imagen del recibo y la guarda en un archivo temporal.
  /// Retorna el [File] con la imagen, o null si falla.
  static Future<File?> generateReceiptImage(Payment payment) async {
    try {
      final Uint8List? imageBytes =
          await _screenshotController.captureFromWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: PaymentReceipt(payment: payment),
              ),
            ),
          ),
        ),
        delay: const Duration(milliseconds: 200),
        pixelRatio: 2.0,
      );

      if (imageBytes == null) return null;

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/recibo_${payment.folio.replaceAll('-', '_')}.png';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);
      return file;
    } catch (e) {
      debugPrint('❌ Error generando imagen del recibo: $e');
      return null;
    }
  }

  /// Comparte el recibo vía WhatsApp, email o cualquier app disponible.
  static Future<void> shareReceipt(Payment payment, {BuildContext? context}) async {
    final file = await generateReceiptImage(payment);
    if (file == null) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No se pudo generar el recibo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    await Share.shareXFiles(
      [XFile(file.path)],
      text:
          'Recibo de pago - ${payment.folio}\nCasa Pädi · Gimnasia Artística\n${payment.studentName} · \$${payment.amount.toStringAsFixed(2)} MXN',
      subject: 'Recibo ${payment.folio} - Casa Pädi',
    );
  }

  /// Guarda una copia permanente en el directorio de documentos de la app.
  static Future<String?> saveReceipt(Payment payment) async {
    final file = await generateReceiptImage(payment);
    if (file == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    final recibosDir = Directory('${directory.path}/recibos');
    await recibosDir.create(recursive: true);

    final savedPath =
        '${recibosDir.path}/recibo_${payment.folio.replaceAll('-', '_')}.png';
    await file.copy(savedPath);
    debugPrint('✅ Recibo guardado en: $savedPath');
    return savedPath;
  }

  /// Retorna los bytes de la imagen (útil para previsualizarla en pantalla).
  static Future<Uint8List?> getReceiptBytes(Payment payment) async {
    try {
      return await _screenshotController.captureFromWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: PaymentReceipt(payment: payment),
              ),
            ),
          ),
        ),
        delay: const Duration(milliseconds: 200),
        pixelRatio: 2.0,
      );
    } catch (e) {
      debugPrint('❌ Error capturando recibo: $e');
      return null;
    }
  }
}
