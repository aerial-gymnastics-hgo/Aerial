import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class PaymentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Genera un folio único con el formato AER-YYYY-MMDD-NNNNN.
  /// El secuencial NNNNN reinicia cada día desde 00001.
  static Future<String> generateFolio() async {
    final now = DateTime.now();
    final year = now.year;
    final monthDay =
        '${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final prefix = 'AER-$year-$monthDay-';

    final snapshot = await _db
        .collection('payments')
        .where('folio', isGreaterThanOrEqualTo: prefix)
        .where('folio', isLessThan: '${prefix}z') // 'z' > cualquier dígito
        .orderBy('folio', descending: true)
        .limit(1)
        .get();

    int nextNumber = 1;

    if (snapshot.docs.isNotEmpty) {
      final lastFolio = snapshot.docs.first.data()['folio'] as String? ?? '';
      // formato: AER-YYYY-MMDD-NNNNN → parts[3] = NNNNN
      final parts = lastFolio.split('-');
      if (parts.length == 4) {
        nextNumber = (int.tryParse(parts[3]) ?? 0) + 1;
      }
    }

    return '$prefix${nextNumber.toString().padLeft(5, '0')}';
  }

  /// Registra un pago en Firestore y retorna el objeto Payment con ID.
  /// [folioOverride] permite forzar un folio (ej. para inscripciones 2×1 hermana).
  static Future<Payment> registerPayment({
    required String studentId,
    required String studentName,
    required String groupId,
    required double amount,
    required String concept,
    required String paymentMethod,
    String? notes,
    required String registeredBy,
    String? folioOverride,
  }) async {
    final folio = folioOverride ?? await generateFolio();
    final now = DateTime.now();

    final payment = Payment(
      id: '',
      studentId: studentId,
      studentName: studentName,
      groupId: groupId,
      amount: amount,
      concept: concept,
      paymentMethod: paymentMethod,
      folio: folio,
      paidAt: now,
      registeredBy: registeredBy,
      notes: notes?.isNotEmpty == true ? notes : null,
    );

    final data = payment.toJson()..remove('id');
    final docRef = await _db.collection('payments').add(data);

    // Actualizar el doc con su propio ID
    await docRef.update({'id': docRef.id});

    return payment.copyWith(id: docRef.id);
  }

  /// Obtener historial de pagos de una alumna
  static Stream<List<Payment>> getStudentPayments(String studentId) {
    return _db
        .collection('payments')
        .where('studentId', isEqualTo: studentId)
        .orderBy('paidAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Payment.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Obtener todos los pagos (para reportes de admin/caja)
  static Stream<List<Payment>> getAllPayments({int limit = 50}) {
    return _db
        .collection('payments')
        .orderBy('paidAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Payment.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
