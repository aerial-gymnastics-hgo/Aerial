import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String studentId;
  final String studentName;
  final String groupId;
  final double amount;
  final String currency;
  final String concept;
  final String paymentMethod;
  final String folio;
  final DateTime paidAt;
  final String registeredBy;
  final String? receiptUrl;
  final String? notes;
  final String status;

  Payment({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.groupId,
    required this.amount,
    this.currency = 'MXN',
    required this.concept,
    required this.paymentMethod,
    required this.folio,
    required this.paidAt,
    required this.registeredBy,
    this.receiptUrl,
    this.notes,
    this.status = 'completed',
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String? ?? '',
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      groupId: json['groupId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'MXN',
      concept: json['concept'] as String,
      paymentMethod: json['paymentMethod'] as String,
      folio: json['folio'] as String,
      paidAt: (json['paidAt'] as Timestamp).toDate(),
      registeredBy: json['registeredBy'] as String,
      receiptUrl: json['receiptUrl'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'completed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'groupId': groupId,
      'amount': amount,
      'currency': currency,
      'concept': concept,
      'paymentMethod': paymentMethod,
      'folio': folio,
      'paidAt': Timestamp.fromDate(paidAt),
      'registeredBy': registeredBy,
      'receiptUrl': receiptUrl,
      'notes': notes,
      'status': status,
    };
  }

  Payment copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? groupId,
    double? amount,
    String? currency,
    String? concept,
    String? paymentMethod,
    String? folio,
    DateTime? paidAt,
    String? registeredBy,
    String? receiptUrl,
    String? notes,
    String? status,
  }) {
    return Payment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      groupId: groupId ?? this.groupId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      concept: concept ?? this.concept,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      folio: folio ?? this.folio,
      paidAt: paidAt ?? this.paidAt,
      registeredBy: registeredBy ?? this.registeredBy,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}
