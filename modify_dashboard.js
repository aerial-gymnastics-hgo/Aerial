const fs = require('fs');
const path = require('path');

const filePath = 'C:/Users/jorge/.gemini/antigravity/Aerial-Gimnastics/lib/screens/caja_dashboard.dart';
if (!fs.existsSync(filePath)) {
  console.error("File does not exist: " + filePath);
  process.exit(1);
}

let content = fs.readFileSync(filePath, 'utf8');

// 1. Add imports
const importTarget = "import '../models/user_model.dart';";
const importReplacement = "import '../models/user_model.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport '../models/payment_model.dart';\nimport '../services/payment_service.dart';";
if (content.includes(importTarget)) {
  if (!content.includes("payment_model.dart")) {
    content = content.replace(importTarget, importReplacement);
    console.log("Imports added successfully.");
  } else {
    console.log("Imports already present.");
  }
} else {
  console.error("Could not find import target line!");
  process.exit(1);
}

// 2. Replace _buildQuickAction for History
const historyTarget = "_buildQuickAction(Icons.history, 'Historial', Colors.orange, () {}),";
const historyReplacement = "_buildQuickAction(Icons.history, 'Historial', Colors.orange, () => _showPaymentHistory(student)),";
if (content.includes(historyTarget)) {
  content = content.replace(historyTarget, historyReplacement);
  console.log("History action updated successfully.");
} else {
  console.log("History action target not found (might already be updated or code is different).");
}

// 3. Find and replace _showPaymentDialog
const startKey = 'void _showPaymentDialog(User student) {';
const endKey = 'void _showEditStudentDialog(User student) {';

const startIndex = content.indexOf(startKey);
const endIndex = content.indexOf(endKey);

if (startIndex === -1 || endIndex === -1) {
  console.error("Could not find start or end key in file for _showPaymentDialog replacement!");
  process.exit(1);
}

const replacementCode = `void _showPaymentDialog(User student) {
    final amountController = TextEditingController(text: student.monthlyFee?.toStringAsFixed(0) ?? '0');
    final conceptController = TextEditingController();
    String selectedCategory = 'Mensualidad';
    String method = 'efectivo';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final currentMonth = DateFormat('MMMM yyyy', 'es').format(DateTime.now());
          final displayMonth = currentMonth.isNotEmpty 
              ? currentMonth[0].toUpperCase() + currentMonth.substring(1)
              : '';

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text('Generar Cobro', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(student.name, style: GoogleFonts.poppins(color: Colors.white70)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      labelStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Concepto de Pago',
                      labelStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    ),
                    items: [
                      DropdownMenuItem(value: 'Mensualidad', child: Text('Mensualidad (' + displayMonth + ')')),
                      const DropdownMenuItem(value: 'Inscripción', child: Text('Inscripción')),
                      const DropdownMenuItem(value: 'Uniforme', child: Text('Uniforme')),
                      const DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        selectedCategory = v!;
                      });
                    },
                  ),
                  if (selectedCategory == 'Otro') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: conceptController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Especificar Concepto',
                        labelStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: method,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Método de Pago',
                      labelStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'efectivo', child: Text('Efectivo')),
                      DropdownMenuItem(value: 'tarjeta', child: Text('Tarjeta')),
                      DropdownMenuItem(value: 'transferencia', child: Text('Transferencia')),
                    ],
                    onChanged: (v) => setState(() => method = v!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.green.withOpacity(0.5),
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        final parsedAmount = double.tryParse(amountController.text);
                        if (parsedAmount == null || parsedAmount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor ingresa un monto válido mayor a 0.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        String finalConcept = '';
                        if (selectedCategory == 'Mensualidad') {
                          finalConcept = 'Mensualidad ' + displayMonth;
                        } else if (selectedCategory == 'Otro') {
                          finalConcept = conceptController.text.trim();
                          if (finalConcept.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Por favor especifica el concepto.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        } else {
                          finalConcept = selectedCategory;
                        }

                        setState(() => isSaving = true);

                        try {
                          final now = DateTime.now();
                          final folio = await PaymentService.generateFolio();

                          final paymentData = {
                            'studentId': student.id,
                            'studentName': student.name,
                            'groupId': student.group,
                            'amount': parsedAmount,
                            'concept': finalConcept,
                            'paymentMethod': method,
                            'receivedBy': widget.currentUser.id,
                            'receivedByName': widget.currentUser.name,
                            'status': 'completed',
                            'receiptNumber': folio,
                            'folio': folio,
                            'paidAt': Timestamp.fromDate(now),
                            'timestamp': FieldValue.serverTimestamp(),
                            'registeredBy': widget.currentUser.id,
                            'currency': 'MXN',
                          };

                          await FirestoreService.instance.addPayment(paymentData);
                          if (context.mounted) {
                            Navigator.pop(context);
                            _showReceipt(paymentData);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setState(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al procesar el pago: ' + e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('CONFIRMAR PAGO', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPaymentHistory(User student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historial de Pagos',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          student.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: StreamBuilder<List<Payment>>(
                  stream: PaymentService.getStudentPayments(student.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(color: Colors.green),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar pagos: ' + snapshot.error.toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    final payments = snapshot.data ?? [];
                    if (payments.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.payment_outlined, size: 48, color: Colors.white24),
                              const SizedBox(height: 12),
                              Text(
                                'No hay pagos registrados para esta alumna.',
                                style: GoogleFonts.poppins(color: Colors.white30, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Limitar a los últimos 4 pagos
                    final displayPayments = payments.take(4).toList();

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: displayPayments.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                      itemBuilder: (context, index) {
                        final payment = displayPayments[index];
                        
                        IconData methodIcon = Icons.money;
                        if (payment.paymentMethod == 'tarjeta') {
                          methodIcon = Icons.credit_card;
                        } else if (payment.paymentMethod == 'transferencia') {
                          methodIcon = Icons.account_balance;
                        }

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(methodIcon, color: Colors.green, size: 20),
                          ),
                          title: Text(
                            payment.concept,
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(payment.paidAt) + ' • ' + payment.folio,
                            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+$' + payment.amount.toStringAsFixed(0),
                                style: GoogleFonts.poppins(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.receipt_long, color: Colors.white54, size: 20),
                                tooltip: 'Reimprimir Recibo',
                                onPressed: () {
                                  final receiptData = {
                                    'receiptNumber': payment.folio,
                                    'studentName': payment.studentName,
                                    'groupId': payment.groupId,
                                    'concept': payment.concept,
                                    'paymentMethod': payment.paymentMethod,
                                    'amount': payment.amount,
                                    'receivedByName': 'Personal Administrativo',
                                  };
                                  _showReceipt(receiptData);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  `;

const finalContent = content.substring(0, startIndex) + replacementCode + content.substring(endIndex);
fs.writeFileSync(filePath, finalContent, 'utf8');
console.log("caja_dashboard.dart updated successfully.");
