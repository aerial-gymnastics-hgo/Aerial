import 'dart:io';

void main() {
  final file = File(r'lib/widgets/excel_table_view.dart');
  if (!file.existsSync()) {
    print('Error: File does not exist');
    exit(1);
  }

  String content = file.readAsStringSync();

  // Replace target 1 (StreamBuilder builder prints + try-catch)
  final target1 = """      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: \${snapshot.error}', style: const TextStyle(color: Colors.red)));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        // --- LOGS SOLICITADOS ---
        print('🔍 Total documentos de Firestore: \${snapshot.data?.docs.length ?? 0}');
        print('🔍 Día seleccionado: \${widget.selectedDay}');

        final allSlots = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return RotationSlot.fromJson({...data, 'id': doc.id});
        }).toList();

        print('🔍 Total slots parseados: \${allSlots.length}');

        final filteredSlots = allSlots.where((slot) => 
          slot.day.trim().toLowerCase() == widget.selectedDay.trim().toLowerCase()
        ).toList();

        print('🔍 Slots después de filtrar por día: \${filteredSlots.length}');
        print('🔍 Primeros 5 slots:');
        for (var slot in filteredSlots.take(5)) {
          print('  - \${slot.startTime} \${slot.groupId} \${slot.apparatus}');
        }
        // -------------------------

        final timeRows = _generateTimeSlotRows();
        final physicalCols = _getPhysicalColumns();

        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: MediaQuery.of(context).size.width * 0.95,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ROTACIONES - \${widget.selectedDay.toUpperCase()}',
                      style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Colors.white24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTimeColumn(timeRows),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: physicalCols.map((col) => _buildGroupColumn(col, timeRows, filteredSlots)).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },""";

  final replacement1 = """      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: \${snapshot.error}', style: const TextStyle(color: Colors.red)));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        try {
          final allSlots = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return RotationSlot.fromJson({...data, 'id': doc.id});
          }).toList();

          final filteredSlots = allSlots.where((slot) => 
            slot.day.trim().toLowerCase() == widget.selectedDay.trim().toLowerCase()
          ).toList();

          final timeRows = _generateTimeSlotRows();
          final physicalCols = _getPhysicalColumns();

          return Dialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
                maxWidth: MediaQuery.of(context).size.width * 0.95,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ROTACIONES - \${widget.selectedDay.toUpperCase()}',
                        style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Colors.white24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTimeColumn(timeRows),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: physicalCols.map((col) => _buildGroupColumn(col, timeRows, filteredSlots)).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } catch (e, stack) {
          debugPrint('CRITICAL ERROR inside ExcelTableView builder: \$e');
          debugPrintStack(stackTrace: stack);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error al construir la tabla: \$e',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),
          );
        }
      },""";

  // Replace target 2 (Gap debug and prints in _buildGroupColumn)
  final target2 = """    // Debug de Gaps
    final sortedSlots = List<RotationSlot>.from(colSlots)..sort((a, b) => a.startTime.compareTo(b.startTime));
    for (int i = 0; i < sortedSlots.length - 1; i++) {
      final current = sortedSlots[i];
      final next = sortedSlots[i + 1];
      if (current.endTime != next.startTime) {
        print('⚠️ GAP DETECTADO en \${current.groupId}:');
        print('   \${current.apparatus} termina: \${current.endTime}');
        print('   \${next.apparatus} inicia: \${next.startTime}');
        print('   Diferencia: \${_timeDiff(current.endTime, next.startTime)} min');
      }
    }

    print('🔍 DEBUG - Columna: \${col.displayName}');
    print('🔍 DEBUG - Slots después de filtrar: \${colSlots.length}');
    if (colSlots.isNotEmpty) {
      print('🔍 DEBUG - Primer slot: \${colSlots.first.day} - \${colSlots.first.groupId}');
    }""";

  // Normalize all line endings to \n for robust replacement
  content = content.replaceAll('\r\n', '\n');
  final normalizedTarget1 = target1.replaceAll('\r\n', '\n');
  final normalizedReplacement1 = replacement1.replaceAll('\r\n', '\n');
  final normalizedTarget2 = target2.replaceAll('\r\n', '\n');

  if (content.contains(normalizedTarget1)) {
    content = content.replaceFirst(normalizedTarget1, normalizedReplacement1);
    print('Target 1 replaced successfully');
  } else {
    print('Error: Target 1 not found in content.');
    exit(1);
  }

  if (content.contains(normalizedTarget2)) {
    content = content.replaceFirst(normalizedTarget2, '');
    print('Target 2 replaced successfully');
  } else {
    print('Warning: Target 2 not found in content.');
  }

  // Write back with local platform line endings
  file.writeAsStringSync(content.replaceAll('\n', Platform.isWindows ? '\r\n' : '\n'));
  print('File written successfully.');
}
