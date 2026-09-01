import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'tabs/inicio_tab.dart';
import 'tabs/remedios_tab.dart';
import 'tabs/chat_tab.dart';
import 'tabs/atividades_tab.dart';
import 'tabs/perfil_tab.dart';

class PacienteHome extends StatefulWidget {
  const PacienteHome({super.key});
  @override
  State<PacienteHome> createState() => _PacienteHomeState();
}

class _PacienteHomeState extends State<PacienteHome> {
  int _aba = 2; // Início por padrão

  static const _telas = [
    ChatTab(),
    AtividadesTab(),
    InicioTab(),
    RemediosTab(),
    PerfilTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(index: _aba, children: _telas),
      bottomNavigationBar: _BottomNav(
        aba: _aba,
        onChange: (i) {
          if (i == 4) {
            // SOS: push para tela dedicada (não muda a aba)
            context.push('/sos');
          } else {
            setState(() => _aba = i);
          }
        },
      ),
    );
  }
}

// ─── Bottom Nav ──────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int aba;
  final ValueChanged<int> onChange;

  const _BottomNav({required this.aba, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              _NavItem(icon: Icons.chat_bubble_outline,   label: 'Chat',       idx: 0, aba: aba, onChange: onChange),
              _NavItem(icon: Icons.grid_view_outlined,    label: 'Atividades', idx: 1, aba: aba, onChange: onChange),
              _NavCenter(idx: 2, aba: aba, onChange: onChange),
              _NavItem(icon: Icons.medication_outlined,   label: 'Remédios',   idx: 3, aba: aba, onChange: onChange),
              _NavItemSos(onChange: onChange),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int idx;
  final int aba;
  final ValueChanged<int> onChange;

  const _NavItem({required this.icon, required this.label, required this.idx, required this.aba, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final sel = aba == idx;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChange(idx),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: sel ? AppTheme.primary : AppTheme.textLight),
            const SizedBox(height: 3),
            Text(label, style: GoogleFonts.poppins(
              fontSize: 10, fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              color: sel ? AppTheme.primary : AppTheme.textLight)),
          ],
        ),
      ),
    );
  }
}

class _NavCenter extends StatelessWidget {
  final int idx;
  final int aba;
  final ValueChanged<int> onChange;

  const _NavCenter({required this.idx, required this.aba, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final sel = aba == idx;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChange(idx),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sel ? AppTheme.primary : AppTheme.primary.withOpacity(0.13),
              ),
              child: Icon(Icons.home_outlined, size: 24, color: sel ? Colors.white : AppTheme.primary),
            ),
            const SizedBox(height: 2),
            Text('Início', style: GoogleFonts.poppins(
              fontSize: 10, fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
              color: sel ? AppTheme.primary : AppTheme.textLight)),
          ],
        ),
      ),
    );
  }
}

class _NavItemSos extends StatelessWidget {
  final ValueChanged<int> onChange;
  const _NavItemSos({required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChange(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 22, color: AppTheme.error),
            const SizedBox(height: 3),
            Text('SOS', style: GoogleFonts.poppins(
              fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.error)),
          ],
        ),
      ),
    );
  }
}
