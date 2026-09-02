import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../models/app_state.dart';

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

    try {
      await context.read<AppState>().definirPerfil(
            _sel!,
          );

      if (!mounted) return;

      context.go('/paciente');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível salvar o perfil. Tente novamente.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Escolha seu perfil',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Como você deseja utilizar o HumanaCare?',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _opcoes.length,
                  itemBuilder: (context, index) {
                    final opcao = _opcoes[index];
                    final id = opcao['id']!;
                    final selecionado = _sel == id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _sel = id;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selecionado
                                ? AppTheme.primary
                                : Colors.grey.shade300,
                            width: selecionado ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selecionado
                                      ? AppTheme.primary
                                      : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: selecionado
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opcao['titulo']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    opcao['desc']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _sel == null ? null : _continuar,
                  child: const Text(
                    'Continuar',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}