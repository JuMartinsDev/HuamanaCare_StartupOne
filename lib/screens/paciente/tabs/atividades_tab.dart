import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class AtividadesTab extends StatelessWidget {
  const AtividadesTab({super.key});

  static const _atividades = [
    {'label': 'Palavras\nCruzadas', 'icon': '📝'},
    {'label': 'Sudoku',            'icon': '🔢'},
    {'label': 'Colorir',           'icon': '🎨'},
    {'label': 'Exercícios\nleves', 'icon': '🏃'},
    {'label': 'Jogo da\nMemória',  'icon': '🧩'},
    {'label': 'Caça-\nPalavras',   'icon': '🔍'},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.textPrimary),
                const SizedBox(width: 8),
                Text('Atividades',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text('Escolha uma atividade para\nestimular seu dia',
                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.primary, height: 1.5)),
            ),
            const SizedBox(height: 24),

            // Grid 2 colunas
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.1,
                ),
                itemCount: _atividades.length,
                itemBuilder: (_, i) => _AtividadeCard(
                  label: _atividades[i]['label']!,
                  icon: _atividades[i]['icon']!,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Em breve!', style: GoogleFonts.poppins(fontSize: 13)),
                      backgroundColor: AppTheme.primary,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _AtividadeCard extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;

  const _AtividadeCard({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 38)),
            const SizedBox(height: 12),
            Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: Colors.white, height: 1.3)),
          ],
        ),
      ),
    );
  }
}
