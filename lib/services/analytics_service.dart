import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class AnalyticsService {
  /// Obtiene pagos en un rango de fechas desde Firestore
  static Future<List<Payment>> getPaymentsByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('payments')
        .where('paidAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('paidAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('paidAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Payment.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// Agrupa totales por grupo (ej. 'DRAGONAS', 'PANTERAS')
  static Map<String, double> getTotalsByGroup(List<Payment> payments) {
    final totals = <String, double>{};
    for (final p in payments) {
      final key = p.groupId.isEmpty ? 'Sin Grupo' : p.groupId.toUpperCase();
      totals[key] = (totals[key] ?? 0) + p.amount;
    }
    // Ordenar por valor descendente
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  /// Agrupa totales por método de pago
  static Map<String, double> getTotalsByPaymentMethod(List<Payment> payments) {
    final totals = <String, double>{};
    for (final p in payments) {
      final key = p.paymentMethod.isEmpty ? 'Otro' : p.paymentMethod;
      totals[key] = (totals[key] ?? 0) + p.amount;
    }
    return totals;
  }

  /// Agrupa totales por día (cronológico)
  static Map<DateTime, double> getTotalsByDay(List<Payment> payments) {
    final totals = <DateTime, double>{};
    for (final p in payments) {
      final date = DateTime(p.paidAt.year, p.paidAt.month, p.paidAt.day);
      totals[date] = (totals[date] ?? 0) + p.amount;
    }
    return Map.fromEntries(
      totals.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  /// Estadísticas generales del período
  static Map<String, dynamic> getStats(List<Payment> payments) {
    if (payments.isEmpty) {
      return {'total': 0.0, 'average': 0.0, 'count': 0, 'highest': 0.0};
    }
    final total = payments.fold<double>(0, (sum, p) => sum + p.amount);
    final highest = payments.map((p) => p.amount).reduce((a, b) => a > b ? a : b);
    return {
      'total': total,
      'average': total / payments.length,
      'count': payments.length,
      'highest': highest,
    };
  }

  /// Pagos agrupados por día de la semana (0=Lunes, 6=Domingo)
  static Map<int, double> getTotalsByWeekday(List<Payment> payments) {
    final totals = <int, double>{for (int i = 1; i <= 7; i++) i: 0.0};
    for (final p in payments) {
      final weekday = p.paidAt.weekday; // 1=Mon ... 7=Sun
      totals[weekday] = (totals[weekday] ?? 0) + p.amount;
    }
    return totals;
  }
}
