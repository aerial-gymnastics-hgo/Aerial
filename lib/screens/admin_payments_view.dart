import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';

class AdminPaymentsView extends StatelessWidget {
  const AdminPaymentsView({super.key});

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
          title: Text('Historial de Pagos', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('payments')
              .orderBy('paidAt', descending: true)
              .limit(100)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildMessage('Error al cargar pagos: ${snapshot.error}');
            }
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
            }
            
            final payments = snapshot.data!.docs
                .map((doc) => Payment.fromJson({
                      ...doc.data() as Map<String, dynamic>,
                      'id': doc.id,
                    }))
                .toList();
            
            if (payments.isEmpty) {
              return _buildMessage('No hay pagos registrados');
            }
            
            // Calcular total
            final total = payments.fold<double>(0, (sum, payment) => sum + payment.amount);
            
            return Column(
              children: [
                // Resumen de Ingresos
                _buildTotalCard(total, payments.length),
                
                // Lista de pagos
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return _buildPaymentCard(context, payment);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTotalCard(double total, int count) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyanAccent.withOpacity(0.2), Colors.blueAccent.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Text(
                  'Total de Ingresos Recientes',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(total),
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [const Shadow(color: Colors.cyanAccent, blurRadius: 15)],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count transacciones registradas',
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Payment payment) {
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
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Colors.cyanAccent.withOpacity(0.1),
                child: Text(
                  payment.studentName[0].toUpperCase(),
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                ),
              ),
              title: Text(
                '${payment.studentName} - ${payment.concept}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('dd/MM/yyyy HH:mm').format(payment.paidAt)} • ${payment.paymentMethod}',
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
                  ),
                  Text(
                    'Folio: ${payment.folio}',
                    style: GoogleFonts.robotoMono(color: Colors.cyanAccent.withOpacity(0.5), fontSize: 10),
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
              onTap: () => _showPaymentDetail(context, payment),
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDetail(BuildContext context, Payment payment) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
          title: Text('Detalle de Pago', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Folio', payment.folio),
              _detailRow('Alumna', payment.studentName),
              _detailRow('Concepto', payment.concept),
              _detailRow('Monto', '\$${payment.amount.toStringAsFixed(2)}'),
              _detailRow('Método', payment.paymentMethod),
              _detailRow('Fecha', DateFormat('dd/MM/yyyy HH:mm').format(payment.paidAt)),
              _detailRow('Registrado por', payment.registeredBy),
              if (payment.notes != null) _detailRow('Notas', payment.notes!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(msg, style: GoogleFonts.poppins(color: Colors.white54)),
        ],
      ),
    );
  }
}
