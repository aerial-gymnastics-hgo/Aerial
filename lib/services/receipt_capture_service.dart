import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/payment_model.dart';

/// ReceiptCaptureService — captura de recibos como imagen.
/// No disponible en web (única plataforma desplegada).
/// payment_dialog.dart muestra PaymentReceipt widget como fallback cuando
/// getReceiptBytes devuelve null.
class ReceiptCaptureService {
  static Future<Uint8List?> getReceiptBytes(Payment payment) async => null;

  static Future<void> shareReceipt(
    Payment payment, {
    BuildContext? context,
  }) async {
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compartir recibo no está disponible en web.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  static Future<String?> saveReceipt(Payment payment) async => null;
}
