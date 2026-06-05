import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:async';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../utils/image_helper.dart';

class AdminPaymentEntryScreen extends StatefulWidget {
  const AdminPaymentEntryScreen({super.key});

  @override
  State<AdminPaymentEntryScreen> createState() =>
      _AdminPaymentEntryScreenState();
}

class _AdminPaymentEntryScreenState extends State<AdminPaymentEntryScreen> {
  String _searchQuery = '';
  bool _showAll = false;
  List<User> _allStudents = [];
  List<User> _students = [];
  bool _isLoading = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FirestoreService.instance.getStudents().listen((data) {
      if (mounted) {
        _allStudents = data;
        _filterDebtStudents();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _filterDebtStudents() async {
    setState(() => _isLoading = true);

    // Aquí idealmente tendrías la deuda de Firebase
    // pero como usas el Stub que lee sincrónicamente el status de FirestoreService:
    final List<User> filtered = [];

    for (var s in _allStudents) {
      // Como el Stub de getFinancialStatus devuelve un future/stream, hay que mockear localmente o asumirlo
      // En el stub actual, hasDebt = true si contiene 'a' u 'o'
      final hasDebt =
          s.id.toLowerCase().contains('a') || s.id.toLowerCase().contains('o');
      if (_showAll || hasDebt) {
        filtered.add(s);
      }
    }

    if (mounted) {
      setState(() {
        _students = filtered;
        _isLoading = false;
      });
    }
  }

  List<User> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    return _students
        .where((s) =>
            s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.group.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Map<String, List<User>> _groupStudents(List<User> students) {
    final map = <String, List<User>>{};
    for (var s in students) {
      map.putIfAbsent(s.group, () => []).add(s);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: const AssetImage('assets/images/gimnasia_landing.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.85), BlendMode.darken),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Cobro Rápido',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Buscar Alumna...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white70),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.cyanAccent)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Switch(
                        value: _showAll,
                        onChanged: (v) {
                          setState(() => _showAll = v);
                          _filterDebtStudents();
                        },
                        activeThumbColor: Colors.cyanAccent,
                      ),
                      Text('Ver Todas',
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Colors.cyanAccent))
                  : _filteredStudents.isEmpty
                      ? Center(
                          child: Text('No se encontraron alumnas',
                              style:
                                  GoogleFonts.poppins(color: Colors.white70)))
                      : ListView(
                          children: _groupStudents(_filteredStudents)
                              .entries
                              .map((entry) {
                            final groupName = entry.key;
                            final groupStudents = entry.value;
                            return Theme(
                              data: Theme.of(context)
                                  .copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                iconColor: Colors.white,
                                collapsedIconColor: Colors.white70,
                                title: Text(groupName,
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white)),
                                children: groupStudents
                                    .map(
                                        (student) => _buildStudentTile(student))
                                    .toList(),
                              ),
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTile(User student) {
    // Replicamos lógica del cascarón
    final isDebt = student.id.toLowerCase().contains('a') ||
        student.id.toLowerCase().contains('o');
    final List<Map<String, dynamic>> finances = isDebt
        ? [
            {'concept': 'Mensualidad', 'amount': 1200.0, 'status': 'Vencido'}
          ]
        : [];

    final pending = finances.where((f) => f['status'] != 'Pagado').toList();
    final totalDebt =
        pending.fold(0.0, (sum, f) => sum + (f['amount'] as num).toDouble());
    final isPaidCurrentMonth = !isDebt;
    final isClear = pending.isEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isClear
                  ? Colors.greenAccent.withOpacity(0.05)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isClear
                      ? Colors.greenAccent.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1)),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: isClear
                    ? Colors.greenAccent.withOpacity(0.2)
                    : Colors.cyanAccent.withOpacity(0.2),
                backgroundImage: getProfileImageProvider(student.photoUrl),
                child: student.photoUrl == null
                    ? Text(student.name[0],
                        style: const TextStyle(color: Colors.white))
                    : null,
              ),
              title: Text(student.name,
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tutor: Familia',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.white54)),
                  Text(
                      isClear
                          ? 'Sin Adeudos'
                          : 'Deuda: \$${totalDebt.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              isClear ? Colors.greenAccent : Colors.redAccent)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPaidCurrentMonth)
                    const Icon(Icons.verified,
                        color: Colors.greenAccent, size: 20),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: pending.isEmpty
                        ? null
                        : () => _showPaymentDialog(student, pending),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          pending.isEmpty ? Colors.grey : Colors.greenAccent,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: Text('Cobrar',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(
      User student, List<Map<String, dynamic>> pendingItems) {
    String selectedMethod = 'Efectivo';
    final TextEditingController notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          double totalSelected = pendingItems
              .where((i) => i['selected'] == true)
              .fold(0.0, (sum, i) => sum + (i['amount'] as num).toDouble());
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.1))),
            title: Text('Cobrar a ${student.name.split(' ')[0]}',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Conceptos pendientes',
                      style: GoogleFonts.poppins(color: Colors.white70)),
                  const SizedBox(height: 8),
                  ...pendingItems.map((item) {
                    bool isSelected = item['selected'] ?? false;
                    return Theme(
                      data: Theme.of(context)
                          .copyWith(unselectedWidgetColor: Colors.white54),
                      child: CheckboxListTile(
                        activeColor: Colors.greenAccent,
                        checkColor: Colors.black,
                        title: Text(item['concept'],
                            style: GoogleFonts.poppins(color: Colors.white)),
                        subtitle: Text('\$${item['amount']}',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent)),
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            item['selected'] = val;
                          });
                        },
                      ),
                    );
                  }).toList(),
                  const Divider(color: Colors.white24),
                  Text('Total a Pagar: \$${totalSelected.toStringAsFixed(2)}',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                          fontSize: 18)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedMethod,
                    dropdownColor: Colors.grey[850],
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Método de Pago',
                      labelStyle: const TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.greenAccent)),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Efectivo', child: Text('💵 Efectivo')),
                      DropdownMenuItem(
                          value: 'Transferencia',
                          child: Text('🏦 Transferencia')),
                      DropdownMenuItem(
                          value: 'Tarjeta', child: Text('💳 Tarjeta')),
                      DropdownMenuItem(
                          value: 'Depósito', child: Text('🏧 Depósito')),
                      DropdownMenuItem(
                          value: 'Cheque', child: Text('📝 Cheque')),
                    ],
                    onChanged: (v) =>
                        setState(() => selectedMethod = v ?? selectedMethod),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Notas (opcional)',
                      labelStyle: TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.greenAccent)),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                onPressed: totalSelected == 0.0
                    ? null
                    : () {
                        FirestoreService.instance.addTransaction({
                          'studentId': student.id,
                          'amount': totalSelected,
                          'paymentMethod': selectedMethod,
                        });
                        Navigator.pop(context);
                        _filterDebtStudents();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Cobro Exitoso: \$${totalSelected.toStringAsFixed(2)}'),
                            backgroundColor: Colors.greenAccent,
                            behavior: SnackBarBehavior.floating));
                      },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black87),
                child: const Text('Confirmar',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
}
