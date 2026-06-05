import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';

class ParentFinancesScreen extends StatelessWidget {
  final String studentId;
  final String studentName;

  const ParentFinancesScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: const AssetImage('assets/images/gimnasia_landing.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.85), BlendMode.darken),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estado Financiero', 
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
              Text(studentName, 
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)),
            ],
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('payments')
              .where('studentId', isEqualTo: studentId)
              .orderBy('paidAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar pagos', style: GoogleFonts.poppins(color: Colors.redAccent)));
            }
            
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
            }
            
            final payments = snapshot.data!.docs
                .map((doc) => Payment.fromJson({
                      ...doc.data() as Map<String, dynamic>,
                      'id': doc.id,
                    }))
                .toList();
            
            if (payments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long, size: 64, color: Colors.white10),
                    const SizedBox(height: 16),
                    Text(
                      'No hay pagos registrados',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white38),
                    ),
                  ],
                ),
              );
            }

            final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.amount);
            
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSummaryCard(totalPaid, payments.length),
                const SizedBox(height: 24),
                Text(
                  'Historial de Transacciones',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ...payments.map((payment) => _buildPaymentCard(payment)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double total, int count) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyanAccent.withOpacity(0.15), Colors.blueAccent.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Text(
                'Total Invertido en Formación',
                style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(total),
                style: GoogleFonts.montserrat(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [const Shadow(color: Colors.cyanAccent, blurRadius: 15)],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count pagos registrados a la fecha',
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: _getPaymentMethodColor(payment.paymentMethod).withOpacity(0.2),
                child: Icon(
                  _getPaymentMethodIcon(payment.paymentMethod),
                  color: _getPaymentMethodColor(payment.paymentMethod),
                  size: 20,
                ),
              ),
              title: Text(
                payment.concept,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('dd/MM/yyyy HH:mm').format(payment.paidAt)} • ${payment.paymentMethod}',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54),
                  ),
                  Text(
                    'Folio: ${payment.folio}',
                    style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.cyanAccent.withOpacity(0.5)),
                  ),
                ],
              ),
              trailing: Text(
                '\$${payment.amount.toStringAsFixed(2)}',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'Efectivo': return Icons.payments_outlined;
      case 'Transferencia': return Icons.account_balance_outlined;
      case 'Tarjeta': return Icons.credit_card_outlined;
      default: return Icons.account_balance_wallet_outlined;
    }
  }

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'Efectivo': return Colors.greenAccent;
      case 'Transferencia': return Colors.blueAccent;
      case 'Tarjeta': return Colors.purpleAccent;
      default: return Colors.grey;
    }
  }
}
