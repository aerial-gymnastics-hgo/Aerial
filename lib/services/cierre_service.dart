import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class CierreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Genera un cierre de caja para el período indicado y lo persiste en
  /// la colección "caja_cierres". Devuelve el ID del documento creado.
  static Future<String> generarCierre({
    required String cajeroUid,
    required String cajeroEmail,
    required String turno,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    // Consultar pagos del período
    final snap = await _db
        .collection('payments')
        .where('paidAt', isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio))
        .where('paidAt', isLessThanOrEqualTo: Timestamp.fromDate(fechaFin))
        .orderBy('paidAt')
        .get();

    final payments = snap.docs
        .map((d) => Payment.fromJson({...d.data(), 'id': d.id}))
        .toList();

    double totalEfectivo = 0;
    double totalTarjeta = 0;
    double totalTransferencia = 0;

    for (final p in payments) {
      switch (p.paymentMethod) {
        case 'Efectivo':
          totalEfectivo += p.amount;
        case 'Tarjeta':
          totalTarjeta += p.amount;
        case 'Transferencia':
          totalTransferencia += p.amount;
      }
    }

    final totalGeneral = totalEfectivo + totalTarjeta + totalTransferencia;

    final fechaStr =
        '${fechaInicio.year}-${fechaInicio.month.toString().padLeft(2, '0')}-${fechaInicio.day.toString().padLeft(2, '0')}';
    final docId = '${fechaStr}_$cajeroUid';

    final pagosArray = payments
        .map((p) => {
              'folio': p.folio,
              'studentName': p.studentName,
              'concept': p.concept,
              'amount': p.amount,
              'paymentMethod': p.paymentMethod,
              'paidAt': Timestamp.fromDate(p.paidAt),
            })
        .toList();

    await _db.collection('caja_cierres').doc(docId).set({
      'fecha': Timestamp.fromDate(fechaInicio),
      'cajero': cajeroEmail,
      'cajeroUid': cajeroUid,
      'totalEfectivo': totalEfectivo,
      'totalTarjeta': totalTarjeta,
      'totalTransferencia': totalTransferencia,
      'totalGeneral': totalGeneral,
      'totalPagos': payments.length,
      'pagos': pagosArray,
      'turno': turno,
      'creadoEn': FieldValue.serverTimestamp(),
    });

    return docId;
  }

  /// Obtiene los pagos del período para previsualizar antes de generar cierre.
  static Future<List<Payment>> getPagosDelPeriodo({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final snap = await _db
        .collection('payments')
        .where('paidAt', isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio))
        .where('paidAt', isLessThanOrEqualTo: Timestamp.fromDate(fechaFin))
        .orderBy('paidAt')
        .get();

    return snap.docs
        .map((d) => Payment.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }
}
