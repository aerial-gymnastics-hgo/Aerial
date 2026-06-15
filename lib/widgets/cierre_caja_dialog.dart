import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';
import '../services/cierre_service.dart';
import '../services/pdf_service.dart';
import '../utils/web_download.dart';

class CierreCajaDialog extends StatefulWidget {
  const CierreCajaDialog({super.key});

  @override
  State<CierreCajaDialog> createState() => _CierreCajaDialogState();
}

class _CierreCajaDialogState extends State<CierreCajaDialog> {
  String _turno = 'vespertino';
  bool _loading = true;
  bool _generating = false;
  List<Payment> _pagos = [];

  final _currencyFmt = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  final _timeFmt = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _loadPagos();
  }

  DateTime get _fechaInicio {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    switch (_turno) {
      case 'matutino':
        return dayStart.add(const Duration(hours: 6));
      case 'vespertino':
        return dayStart.add(const Duration(hours: 13));
      default:
        return dayStart;
    }
  }

  DateTime get _fechaFin => DateTime.now();

  Future<void> _loadPagos() async {
    setState(() => _loading = true);
    try {
      final pagos = await CierreService.getPagosDelPeriodo(
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
      );
      if (mounted) setState(() { _pagos = pagos; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _totalEfectivo =>
      _pagos.where((p) => p.paymentMethod == 'Efectivo').fold(0, (s, p) => s + p.amount);
  double get _totalTarjeta =>
      _pagos.where((p) => p.paymentMethod == 'Tarjeta').fold(0, (s, p) => s + p.amount);
  double get _totalTransferencia =>
      _pagos.where((p) => p.paymentMethod == 'Transferencia').fold(0, (s, p) => s + p.amount);
  double get _totalGeneral => _totalEfectivo + _totalTarjeta + _totalTransferencia;

  Future<void> _generarCierre() async {
    setState(() => _generating = true);
    try {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      final cajeroUid = user?.uid ?? 'unknown';
      final cajeroEmail = user?.email ?? 'caja';

      final docId = await CierreService.generarCierre(
        cajeroUid: cajeroUid,
        cajeroEmail: cajeroEmail,
        turno: _turno,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
      );

      // Generar y descargar PDF
      final now = DateTime.now();
      final cierreData = {
        'fecha': _fechaInicio,
        'cajero': cajeroEmail,
        'cajeroUid': cajeroUid,
        'turno': _turno,
        'totalEfectivo': _totalEfectivo,
        'totalTarjeta': _totalTarjeta,
        'totalTransferencia': _totalTransferencia,
        'totalGeneral': _totalGeneral,
        'totalPagos': _pagos.length,
        'pagos': _pagos.map((p) => {
          'folio': p.folio,
          'studentName': p.studentName,
          'concept': p.concept,
          'amount': p.amount,
          'paymentMethod': p.paymentMethod,
          'paidAt': p.paidAt,
        }).toList(),
      };

      final pdfBytes = await PdfService.generateCierrePdf(cierreData);
      final filename =
          'cierre_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_$_turno.pdf';
      triggerWebDownload(filename, pdfBytes, 'application/pdf');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cierre generado: $docId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _generating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar cierre: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        width: 520,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF3949AB).withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTurnoSelector(),
                    const SizedBox(height: 20),
                    if (_loading)
                      const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63)))
                    else ...[
                      _buildTotalesCard(),
                      const SizedBox(height: 16),
                      _buildPagosList(),
                    ],
                    const SizedBox(height: 20),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.summarize_outlined, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cierre de Caja',
                    style: GoogleFonts.inter(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Turno', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final t in ['matutino', 'vespertino', 'completo'])
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _turno = t);
                    _loadPagos();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _turno == t ? const Color(0xFF3949AB) : const Color(0xFF2A2A3E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _turno == t ? const Color(0xFF3949AB) : const Color(0xFF3A3A4E),
                      ),
                    ),
                    child: Text(
                      t[0].toUpperCase() + t.substring(1),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: _turno == t ? Colors.white : Colors.grey,
                        fontSize: 12,
                        fontWeight: _turno == t ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3A3A4E)),
      ),
      child: Column(
        children: [
          _totalRow('Efectivo', _totalEfectivo, Colors.greenAccent),
          _totalRow('Tarjeta', _totalTarjeta, Colors.blueAccent),
          _totalRow('Transferencia', _totalTransferencia, Colors.orangeAccent),
          const Divider(color: Colors.white12, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL GENERAL',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Text(_currencyFmt.format(_totalGeneral),
                  style: GoogleFonts.inter(
                      color: const Color(0xFF7B61FF),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text('${_pagos.length} pago${_pagos.length == 1 ? '' : 's'} en este turno',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
          ]),
          Text(_currencyFmt.format(amount),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPagosList() {
    if (_pagos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('Sin pagos en este turno',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PAGOS DEL TURNO',
            style: GoogleFonts.inter(
                color: Colors.white54, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...(_pagos.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A3E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.studentName,
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('${p.concept} · ${_timeFmt.format(p.paidAt)}',
                            style: GoogleFonts.inter(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_currencyFmt.format(p.amount),
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(p.paymentMethod,
                          style: GoogleFonts.inter(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ))),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (_generating || _loading) ? null : _generarCierre,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3949AB),
              disabledBackgroundColor: const Color(0xFF3949AB).withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: _generating
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.picture_as_pdf, color: Colors.white),
            label: Text(
              _generating ? 'Generando...' : 'Generar cierre y descargar PDF',
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _generating ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Cerrar sin generar',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
