import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class FamiliarHome extends StatelessWidget {
  const FamiliarHome({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final paciente = state.paciente;

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,

        title: Text(
          'HumanaCare',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AppState>().logout();

              if (!context.mounted) return;

              context.go('/login');
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                'Olá, Familiar! 👋',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Acompanhe a saúde e o bem-estar de quem você ama.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 28),

              // ==========================================
              // PACIENTE VINCULADO
              // ==========================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius:
                      BorderRadius.circular(18),

                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,

                          decoration: BoxDecoration(
                            color: AppTheme.primary
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),

                          child: Icon(
                            Icons.favorite_border,
                            color: AppTheme.primary,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              Text(
                                'Paciente vinculado',
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 13,
                                  color:
                                      AppTheme.textSecondary,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                paciente.nome.isEmpty
                                    ? 'Paciente'
                                    : paciente.nome,
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.w600,
                                  color:
                                      AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Divider(),

                    const SizedBox(height: 12),

                    _InfoRow(
                      icon: Icons.cake_outlined,
                      label: 'Idade',
                      value:
                          '${paciente.idade} anos',
                    ),

                    const SizedBox(height: 10),

                    _InfoRow(
                      icon: Icons.favorite_border,
                      label: 'Condição',
                      value:
                          paciente.condicaoSaude.isEmpty
                              ? 'Não informado'
                              : paciente.condicaoSaude,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Acompanhar',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // RESUMO DE SAÚDE
              // ==========================================

              _ActionCard(
                icon: Icons.favorite_outline,
                title: 'Resumo de saúde',
                description:
                    'Veja informações importantes sobre o paciente.',
                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Resumo de saúde será implementado.',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // ==========================================
              // REMÉDIOS
              // ==========================================

              _ActionCard(
                icon: Icons.medication_outlined,
                title: 'Remédios',
                description:
                    'Acompanhe os medicamentos do paciente.',
                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tela de remédios do familiar será implementada.',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // ==========================================
              // COMPROMISSOS
              // ==========================================

              _ActionCard(
                icon: Icons.calendar_month_outlined,
                title: 'Compromissos',
                description:
                    'Veja consultas e próximos compromissos.',
                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tela de compromissos do familiar será implementada.',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // ==========================================
              // MENSAGENS
              // ==========================================

              _ActionCard(
                icon: Icons.chat_bubble_outline,
                title: 'Mensagens',
                description:
                    'Converse com o paciente e a equipe de cuidado.',
                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Mensagens do familiar serão implementadas.',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // ==========================================
              // HISTÓRICO
              // ==========================================

              _ActionCard(
                icon: Icons.history,
                title: 'Histórico',
                description:
                    'Acompanhe acontecimentos importantes.',
                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Histórico do familiar será implementado.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primary,
        ),

        const SizedBox(width: 10),

        Text(
          '$label:',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color:
                    AppTheme.primary.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: Icon(
                icon,
                color: AppTheme.primary,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color:
                          AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
            ),
          ],
        ),
      ),
    );
  }
}