import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';

/// Widget visual del recibo de pago. Puede ser capturado como imagen PNG.
class PaymentReceipt extends StatelessWidget {
  final Payment payment;

  const PaymentReceipt({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'es_MX');

    return Container(
      width: 420,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Cabecera con degradado ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  width: 70,
                  height: 70,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Casa Pädi',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Gimnasia Artística · Pachuca, Hgo.',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'RECIBO DE PAGO',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),

          // ── Folio ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            color: const Color(0xFFF5F5F5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long,
                    size: 14, color: Color(0xFF3949AB)),
                const SizedBox(width: 6),
                Text(
                  'Folio: ${payment.folio}',
                  style: GoogleFonts.robotoMono(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A237E),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // ── Cuerpo del recibo ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('DATOS DE LA ALUMNA', [
                  _InfoRow(label: 'Nombre', value: payment.studentName),
                  _InfoRow(
                      label: 'Grupo',
                      value: payment.groupId.toUpperCase()),
                ]),
                const SizedBox(height: 20),
                _buildSection('DETALLE DEL PAGO', [
                  _InfoRow(label: 'Concepto', value: payment.concept),
                  _InfoRow(
                      label: 'Método', value: payment.paymentMethod),
                  _InfoRow(
                      label: 'Fecha',
                      value: dateFormat.format(payment.paidAt)),
                  if (payment.notes != null && payment.notes!.isNotEmpty)
                    _InfoRow(label: 'Notas', value: payment.notes!),
                ]),
                const SizedBox(height: 24),

                // ── Monto ─────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF3949AB).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL PAGADO',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A237E),
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        currencyFormat.format(payment.amount),
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A237E),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 16),

                // ── Estado ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF43A047), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Pago completado',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF43A047),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Registrado por: ${payment.registeredBy}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF9E9E9E),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF757575),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
