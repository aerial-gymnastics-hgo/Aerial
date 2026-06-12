import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_fonts/google_fonts.dart';
import '../models/payment_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/payment_service.dart';
import '../services/receipt_capture_service.dart';
import '../widgets/payment_receipt.dart';

enum PaymentConcept { mensualidad, visita, inscripcion }

/// Modal para registrar un pago y generar el recibo visual.
class PaymentDialog extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String groupId;
  final PaymentConcept concept;
  final double? monthlyFee;

  const PaymentDialog({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.groupId,
    this.concept = PaymentConcept.mensualidad,
    this.monthlyFee,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _conceptController = TextEditingController();
  final _notesController = TextEditingController();
  final _hermanaSearchController = TextEditingController();

  String _paymentMethod = 'Efectivo';
  bool _processing = false;
  String? _errorMessage;

  Payment? _completedPayment;
  Uint8List? _receiptPreview;

  // Estado 2×1 — solo aplica cuando concept == inscripcion
  bool _hermanaToggle = false;
  User? _hermanaSelected;
  String _hermanaQuery = '';

  static const _months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  @override
  void initState() {
    super.initState();
    _initFromConcept();
  }

  void _initFromConcept() {
    final now = DateTime.now();
    switch (widget.concept) {
      case PaymentConcept.mensualidad:
        _amountController.text = (widget.monthlyFee ?? 800.0).toStringAsFixed(0);
        _conceptController.text = 'Mensualidad';
        _notesController.text = 'Mensualidad ${_months[now.month - 1]} ${now.year}';
      case PaymentConcept.visita:
        _amountController.text = '150';
        _conceptController.text = 'Clase de visita';
        _notesController.text = 'Clase de visita';
      case PaymentConcept.inscripcion:
        _amountController.text = '500';
        _conceptController.text = 'Inscripción';
        _notesController.text = 'Inscripción';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    _notesController.dispose();
    _hermanaSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: _completedPayment != null ? _buildReceiptView() : _buildFormView(),
    );
  }

  // ── Vista del formulario ──────────────────────────────────────────

  Widget _buildFormView() {
    return Container(
      width: 500,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3949AB).withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFormHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField(
                      controller: _amountController,
                      label: 'Monto (MXN)',
                      prefixText: '\$ ',
                      keyboardType: TextInputType.number,
                      icon: Icons.attach_money,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (double.tryParse(v) == null) return 'Monto inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _conceptController,
                      label: 'Concepto',
                      icon: Icons.description_outlined,
                      validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildPaymentMethodRow(),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _notesController,
                      label: 'Notas (opcional)',
                      icon: Icons.notes,
                      maxLines: 2,
                    ),
                    if (widget.concept == PaymentConcept.inscripcion) ...[
                      const SizedBox(height: 14),
                      _buildHermanaSection(),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorBanner(),
                    ],
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormHeader() {
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
          const Icon(Icons.receipt_long, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrar Pago',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.studentName} · ${widget.groupId.toUpperCase()}',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                ),
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

  Widget _buildPaymentMethodRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Método de Pago',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        Row(
          children: ['Efectivo', 'Transferencia', 'Tarjeta'].map((method) {
            final selected = _paymentMethod == method;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _paymentMethod = method),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF3949AB)
                        : const Color(0xFF2A2A3E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF3949AB)
                          : const Color(0xFF3A3A4E),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(_methodIcon(method),
                          color: selected ? Colors.white : Colors.grey,
                          size: 18),
                      const SizedBox(height: 4),
                      Text(method,
                          style: GoogleFonts.inter(
                              color: selected ? Colors.white : Colors.grey,
                              fontSize: 11),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Sección 2×1 hermana ───────────────────────────────────────────

  Widget _buildHermanaSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3A3A4E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Switch(
                value: _hermanaToggle,
                activeColor: Colors.orangeAccent,
                onChanged: (val) {
                  setState(() {
                    _hermanaToggle = val;
                    if (!val) {
                      _hermanaSelected = null;
                      _hermanaQuery = '';
                      _hermanaSearchController.clear();
                      _notesController.text = 'Inscripción';
                    }
                  });
                },
              ),
              Expanded(
                child: Text(
                  '¿Inscripción con hermana? (2×1 — \$500 total)',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          if (_hermanaToggle) ...[
            const SizedBox(height: 8),
            _hermanaSelected == null
                ? _buildHermanaSearch()
                : _buildHermanaChip(),
          ],
        ],
      ),
    );
  }

  Widget _buildHermanaSearch() {
    return Column(
      children: [
        TextField(
          controller: _hermanaSearchController,
          onChanged: (v) => setState(() => _hermanaQuery = v),
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Buscar alumna por nombre...',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
            filled: true,
            fillColor: const Color(0xFF1E1E2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        if (_hermanaQuery.length >= 2)
          StreamBuilder<List<User>>(
            stream: FirestoreService.instance.getStudents(),
            builder: (ctx, snap) {
              if (!snap.hasData) return const SizedBox.shrink();
              final results = snap.data!
                  .where((s) =>
                      s.id != widget.studentId &&
                      s.name.toLowerCase().contains(_hermanaQuery.toLowerCase()))
                  .take(5)
                  .toList();
              if (results.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Sin resultados',
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
                );
              }
              return Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: results
                      .map((s) => ListTile(
                            dense: true,
                            title: Text(s.name,
                                style: GoogleFonts.inter(
                                    color: Colors.white, fontSize: 13)),
                            subtitle: Text(s.group,
                                style: GoogleFonts.inter(
                                    color: Colors.white54, fontSize: 11)),
                            onTap: () {
                              setState(() {
                                _hermanaSelected = s;
                                _notesController.text = 'Inscripción familiar 2×1';
                              });
                            },
                          ))
                      .toList(),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildHermanaChip() {
    return Row(
      children: [
        const Icon(Icons.person_add, color: Colors.orangeAccent, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _hermanaSelected!.name,
            style: GoogleFonts.inter(
                color: Colors.orangeAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white38, size: 16),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            setState(() {
              _hermanaSelected = null;
              _hermanaQuery = '';
              _hermanaSearchController.clear();
              _notesController.text = 'Inscripción';
            });
          },
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _processing ? null : _registerPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3949AB),
          disabledBackgroundColor: const Color(0xFF3949AB).withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: _processing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.receipt, color: Colors.white),
        label: Text(
          _processing ? 'Procesando...' : 'Registrar y Generar Recibo',
          style: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }

  // ── Vista del recibo generado ─────────────────────────────────────

  Widget _buildReceiptView() {
    final payment = _completedPayment!;
    return Container(
      width: 480,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF43A047),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  '¡Pago registrado exitosamente!',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_receiptPreview != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(_receiptPreview!),
                    )
                  else
                    PaymentReceipt(payment: payment),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          icon: Icons.share,
                          label: 'Compartir',
                          color: const Color(0xFF3949AB),
                          onTap: () => ReceiptCaptureService.shareReceipt(
                              payment,
                              context: context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionButton(
                          icon: Icons.save_alt,
                          label: 'Guardar',
                          color: const Color(0xFF00897B),
                          onTap: () async {
                            final path =
                                await ReceiptCaptureService.saveReceipt(payment);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(path != null
                                      ? '✅ Guardado en Documentos'
                                      : '❌ Error al guardar'),
                                  backgroundColor:
                                      path != null ? Colors.green : Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionButton(
                          icon: Icons.close,
                          label: 'Cerrar',
                          color: const Color(0xFF616161),
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, color: Colors.white, size: 16),
      label: Text(label,
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefixText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          validator: validator,
          decoration: InputDecoration(
            prefixText: prefixText,
            prefixStyle: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.white38, size: 18),
            filled: true,
            fillColor: const Color(0xFF2A2A3E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3A3A4E)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3A3A4E)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3949AB)),
            ),
            errorStyle: GoogleFonts.inter(color: Colors.red.shade300, fontSize: 11),
          ),
        ),
      ],
    );
  }

  IconData _methodIcon(String method) {
    switch (method) {
      case 'Efectivo':
        return Icons.payments_outlined;
      case 'Transferencia':
        return Icons.account_balance_outlined;
      case 'Tarjeta':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  // ── Lógica de registro ────────────────────────────────────────────

  Future<void> _registerPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final bool is2x1 = widget.concept == PaymentConcept.inscripcion &&
        _hermanaToggle &&
        _hermanaSelected != null;

    if (widget.concept == PaymentConcept.inscripcion &&
        _hermanaToggle &&
        _hermanaSelected == null) {
      setState(() => _errorMessage = 'Selecciona la hermana para el 2×1.');
      return;
    }

    setState(() {
      _processing = true;
      _errorMessage = null;
    });

    try {
      final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
      final registeredBy = currentUser?.email ?? 'caja';

      final double amount = is2x1 ? 250.0 : double.parse(_amountController.text);
      final String concept = is2x1 ? 'Inscripción 2×1' : _conceptController.text.trim();

      final payment = await PaymentService.registerPayment(
        studentId: widget.studentId,
        studentName: widget.studentName,
        groupId: widget.groupId,
        amount: amount,
        concept: concept,
        paymentMethod: _paymentMethod,
        notes: _notesController.text.trim(),
        registeredBy: registeredBy,
      );

      if (is2x1) {
        await PaymentService.registerPayment(
          studentId: _hermanaSelected!.id,
          studentName: _hermanaSelected!.name,
          groupId: _hermanaSelected!.group,
          amount: 250.0,
          concept: 'Inscripción 2×1',
          paymentMethod: _paymentMethod,
          notes: 'Inscripción familiar 2×1',
          registeredBy: registeredBy,
          folioOverride: '${payment.folio}-B',
        );
      }

      Uint8List? previewBytes;
      try {
        previewBytes = await ReceiptCaptureService.getReceiptBytes(payment);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _completedPayment = payment;
          _receiptPreview = previewBytes;
          _processing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _processing = false;
          _errorMessage = 'Error al registrar pago: $e';
        });
      }
    }
  }
}
