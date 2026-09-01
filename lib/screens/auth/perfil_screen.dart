import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../models/app_state.dart';
import '../../widgets/shared.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String? _sel;

  final _opcoes = [
    {
      'id': 'familiar',
      'titulo': 'Familiar',
      'desc': 'Acompanhe e gerencie a saúde de quem você ama.',
    },
    {
      'id': 'cuidador',
      'titulo': 'Cuidador',
      'desc': 'Gerencie tarefas e cuide do bem-estar de alguém.',
    },
    {
      'id': 'paciente',
      'titulo': 'Paciente',
      'desc': 'Acompanhe sua saúde e melhore seu dia a dia.',
    },
  ];

  Future<void> _continuar() async {
    if (_sel == null) return;
      await context.read<AppState>().definirPerfil(_sel!);
    if (!mounted) return;
      context.go('/paciente');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: AppTheme.textPrimary,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),

              const SizedBox(height: 16),

              const AuthHeader(),

              const SizedBox(height: 36),

              Text(
                'Como você deseja usar o\nHumanaCare?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Selecione o perfil que melhor te\nrepresenta',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.primary,
                ),
              ),

              const SizedBox(height: 28),

              ..._opcoes.map(
                (o) => _PerfilTile(
                  titulo: o['titulo']!,
                  desc: o['desc']!,
                  sel: _sel == o['id'],
                  onTap: () {
                    setState(() {
                      _sel = o['id'];
                    });
                  },
                ),
              ),

              const Spacer(),

              HCButton(
                label: 'Continuar',
                onTap: _sel == null ? null : _continuar,
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerfilTile extends StatelessWidget {
  final String titulo;
  final String desc;
  final bool sel;
  final VoidCallback onTap;

  const _PerfilTile({
    required this.titulo,
    required this.desc,
    required this.sel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: sel
              ? const Color(0xFFE0F4F1)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sel
                ? AppTheme.primary
                : AppTheme.divider,
            width: sel ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: sel
                          ? AppTheme.primary
                          : AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    desc,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: sel
                  ? AppTheme.primary
                  : AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

