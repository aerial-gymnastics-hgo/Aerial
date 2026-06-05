import 'dart:io';

void main() {
  final file = File(r'lib/screens/landing_page.dart');
  if (!file.existsSync()) {
    print('Error: File does not exist');
    exit(1);
  }

  String content = file.readAsStringSync();

  // Normalize line endings
  content = content.replaceAll('\r\n', '\n');

  // Replace _scrollToSection with null safety check
  final targetScroll = """  void _scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }""";

  final replacementScroll = """  void _scrollToSection(GlobalKey key) {
    if (key.currentContext == null) {
      debugPrint('Warning: GlobalKey context is null. Cannot scroll to section.');
      return;
    }
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }""";

  // Replace SliverList with SliverToBoxAdapter + Column
  final targetSliverList = """          SliverList(
            delegate: SliverChildListDelegate([
              _buildHeroSection(),
              _buildSobreNosotros(),
              _buildGruposYNiveles(),
              _buildGaleria(),
              _buildHorarios(),
              _buildCostos(),
              _buildBeneficios(),
              _buildInscripcion(),
              _buildReglamento(),
              _buildTestimonios(),
              _buildFAQ(),
              _buildFormularioClaseMuestra(),
              _buildFooter(),
            ]),
          ),""";

  final replacementSliverList = """          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeroSection(),
                _buildSobreNosotros(),
                _buildGruposYNiveles(),
                _buildGaleria(),
                _buildHorarios(),
                _buildCostos(),
                _buildBeneficios(),
                _buildInscripcion(),
                _buildReglamento(),
                _buildTestimonios(),
                _buildFAQ(),
                _buildFormularioClaseMuestra(),
                _buildFooter(),
              ],
            ),
          ),""";

  final normalizedTargetScroll = targetScroll.replaceAll('\r\n', '\n');
  final normalizedReplacementScroll = replacementScroll.replaceAll('\r\n', '\n');
  final normalizedTargetSliverList = targetSliverList.replaceAll('\r\n', '\n');
  final normalizedReplacementSliverList = replacementSliverList.replaceAll('\r\n', '\n');

  if (content.contains(normalizedTargetScroll)) {
    content = content.replaceFirst(normalizedTargetScroll, normalizedReplacementScroll);
    print('Scroll section modified successfully');
  } else {
    // If it was already replaced in the previous run
    print('Scroll section already modified or not found');
  }

  if (content.contains(normalizedTargetSliverList)) {
    content = content.replaceFirst(normalizedTargetSliverList, normalizedReplacementSliverList);
    print('SliverList modified successfully');
  } else {
    print('Error: SliverList target not found');
    exit(1);
  }

  file.writeAsStringSync(content.replaceAll('\n', Platform.isWindows ? '\r\n' : '\n'));
  print('landing_page.dart updated successfully');
}
