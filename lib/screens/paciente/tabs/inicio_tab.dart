import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';

import '../../../models/app_state.dart';

import '../../../models/models.dart';

import '../paciente_home.dart';

import '../alertas_screen.dart';

import '../criar_compromisso_screen.dart';

class InicioTab extends StatelessWidget {
  const InicioTab({super.key});

  static const List<String> _meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final p = state.paciente;

    final agora = DateTime.now();

    final pendentes =
        state.remedios.where((r) => !r.tomado).length;

    final compromissosFuturos =
        state.compromissos.where((compromisso) {
      final data = compromisso.data;

      return data != null && !data.isBefore(agora);
    }).length;

    final totalAlertas = pendentes + compromissosFuturos;

    final proximoCompromisso =
        _encontrarProximoCompromisso(
      state.compromissos,
      agora,
    );

    final diasComCompromisso = state.compromissos
        .where((c) => c.data != null)
        .where(
          (c) =>
              c.data!.year == agora.year &&
              c.data!.month == agora.month,
        )
        .map((c) => c.data!.day)
        .toSet();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // CABEÇALHO
            // =========================

            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    56,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7CC4B6),
                        Color(0xFF4EA596),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${p.nome.split(' ').first} !',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hoje é dia ${agora.day} de '
                        '${_meses[agora.month - 1]} de '
                        '${agora.year}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // =========================
                // CARD DO PACIENTE
                // =========================

                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -34,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const PacienteHome(
                            abaInicial: 4,
                          ),
                        ),
                      );
                    },
                    borderRadius:
                        BorderRadius.circular(16),
                    child: Container(
                      padding:
                          const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius:
                            BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset:
                                const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _avatar(56),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.nome,
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w700,
                                    color:
                                        AppTheme
                                            .textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.idade} anos  .  ID: ${p.id}',
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 12,
                                    color:
                                        AppTheme
                                            .textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color:
                                AppTheme.textLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =========================
                  // RESUMO DO DIA
                  // =========================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Resumo do dia',
                        style:
                            GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Ver tudo',
                        style:
                            GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              AppTheme.accent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // =========================
                  // MEDICAMENTOS
                  // =========================

                  _ResumoRow(
                    icone:
                        Icons.medication_outlined,
                    titulo: 'Medicamentos',
                    sub: '$pendentes pendentes',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const PacienteHome(
                            abaInicial: 3,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // =========================
                  // ALERTAS
                  // =========================

                  _ResumoRow(
                    icone:
                        Icons.notifications_none_rounded,
                    titulo: 'Alertas',
                    sub: totalAlertas == 0
                        ? 'Nenhum alerta'
                        : '$totalAlertas '
                            '${totalAlertas == 1 ? 'alerta' : 'alertas'}',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const AlertasScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 22),

                  // =========================
                  // PRÓXIMO COMPROMISSO
                  // =========================

                  Text(
                    'Próximo compromisso',
                    style:
                        GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =========================
                  // CALENDÁRIO
                  // =========================

                  _MiniCalendar(
                    mes: agora.month,
                    ano: agora.year,
                    diaDestaque: agora.day,
                    diasComCompromisso:
                        diasComCompromisso,
                  ),

                  const SizedBox(height: 12),

                  // =========================
                  // PRÓXIMO COMPROMISSO
                  // =========================

                  if (proximoCompromisso != null)
                    _CompromissoCard(
                      c: proximoCompromisso,
                      onEditar: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                CriarCompromissoScreen(
                              compromisso:
                                  proximoCompromisso,
                            ),
                          ),
                        );
                      },
                      onExcluir: () {
                        _confirmarExclusao(
                          context,
                          proximoCompromisso,
                        );
                      },
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius:
                            BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.divider,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons
                                .event_available_outlined,
                            size: 32,
                            color:
                                AppTheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nenhum compromisso agendado',
                            style:
                                GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w600,
                              color:
                                  AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Adicione um compromisso para acompanhar sua agenda.',
                            textAlign:
                                TextAlign.center,
                            style:
                                GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppTheme
                                  .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // =========================
                  // BOTÃO NOVO COMPROMISSO
                  // =========================

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const CriarCompromissoScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 20,
                      ),
                      label: Text(
                        'Novo compromisso',
                        style:
                            GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.primary,
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // CONFIRMAR EXCLUSÃO
  // =========================

  Future<void> _confirmarExclusao(
    BuildContext context,
    Compromisso compromisso,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Excluir compromisso?',
          ),
          content: Text(
            'Deseja realmente excluir '
            '"${compromisso.titulo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await context
          .read<AppState>()
          .removeCompromisso(compromisso.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compromisso excluído com sucesso.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível excluir o compromisso.',
          ),
        ),
      );
    }
  }

  // =========================
  // ENCONTRAR PRÓXIMO COMPROMISSO
  // =========================

  static Compromisso? _encontrarProximoCompromisso(
    List<Compromisso> compromissos,
    DateTime agora,
  ) {
    final futuros = compromissos
        .where((c) => c.data != null)
        .where((c) => !c.data!.isBefore(agora))
        .toList();

    if (futuros.isEmpty) {
      return null;
    }

    futuros.sort(
      (a, b) =>
          a.data!.compareTo(b.data!),
    );

    return futuros.first;
  }

  // =========================
  // AVATAR
  // =========================

  static Widget _avatar(double s) {
    return Container(
      width: s,
      height: s,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primary,
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

// =====================================================
// RESUMO ROW
// =====================================================

class _ResumoRow extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String sub;
  final VoidCallback? onTap;

  const _ResumoRow({
    required this.icone,
    required this.titulo,
    required this.sub,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icone,
              size: 20,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 12,
                      color:
                          AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// CARD DO COMPROMISSO
// =====================================================

class _CompromissoCard
    extends StatelessWidget {
  final Compromisso c;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _CompromissoCard({
    required this.c,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            padding:
                const EdgeInsets.symmetric(
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFE0F4F1),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  c.mesAbrev,
                  style:
                      GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppTheme.primary,
                  ),
                ),
                Text(
                  '${c.dia}',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    height: 1,
                    color:
                        AppTheme.primary,
                  ),
                ),
                Text(
                  c.diaAbrev,
                  style:
                      GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  c.titulo,
                  style:
                      GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppTheme.textPrimary,
                  ),
                ),
                Text(
                  c.local,
                  style:
                      GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                        AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Text(
            c.horario,
            style:
                GoogleFonts.poppins(
              fontSize: 14,
              fontWeight:
                  FontWeight.w700,
              color:
                  AppTheme.primary,
            ),
          ),

          // ÚNICA ADIÇÃO VISUAL:
          // menu de opções do compromisso.
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.more_vert,
              size: 20,
              color: AppTheme.textLight,
            ),
            onSelected: (opcao) {
              if (opcao == 'editar') {
                onEditar();
              } else if (opcao == 'excluir') {
                onExcluir();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 19,
                    ),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'excluir',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 19,
                    ),
                    SizedBox(width: 8),
                    Text('Excluir'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================
// MINI CALENDÁRIO
// =====================================================

class _MiniCalendar
    extends StatelessWidget {
  final int mes;
  final int ano;
  final int diaDestaque;
  final Set<int> diasComCompromisso;

  const _MiniCalendar({
    required this.mes,
    required this.ano,
    required this.diaDestaque,
    required this.diasComCompromisso,
  });

  static const List<String> _meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  Widget build(BuildContext context) {
    final primeiro = DateTime(
      ano,
      mes,
      1,
    );

    final diasNoMes =
        DateTime(ano, mes + 1, 0).day;

    final offset =
        primeiro.weekday - 1;

    final mesAntDias =
        DateTime(ano, mes, 0).day;

    const labels = [
      'Mo',
      'Tu',
      'We',
      'Th',
      'Fr',
      'Sa',
      'Su',
    ];

    final flat = <Map<String, int>>[];

    for (
      int i = 0;
      i < offset;
      i++
    ) {
      flat.add({
        'd': mesAntDias -
            offset +
            1 +
            i,
        'cur': 0,
      });
    }

    for (
      int d = 1;
      d <= diasNoMes;
      d++
    ) {
      flat.add({
        'd': d,
        'cur': 1,
      });
    }

    int prox = 1;

    while (flat.length < 42) {
      flat.add({
        'd': prox++,
        'cur': 0,
      });
    }

    return Container(
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment:
                Alignment.centerLeft,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFFFDF6E3),
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Text(
                _meses[mes - 1],
                style:
                    GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      AppTheme.accent,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: labels
                .map(
                  (l) => Expanded(
                    child: Center(
                      child: Text(
                        l,
                        style:
                            GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w700,
                          color: AppTheme
                              .textLight,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 4),

          for (
            int w = 0;
            w < 6;
            w++
          )
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 3,
              ),
              child: Row(
                children: [
                  for (
                    int dow = 0;
                    dow < 7;
                    dow++
                  )
                    _celula(
                      flat[w * 7 + dow],
                      dow,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _celula(
    Map<String, int> info,
    int dow,
  ) {
    final d = info['d']!;
    final cur = info['cur'] == 1;

    final destaque =
        cur && d == diaDestaque;

    final temCompromisso =
        cur &&
        diasComCompromisso.contains(d);

    final fimDeSemana =
        dow >= 5;

    Color cor;

    if (!cur) {
      cor =
          const Color(0xFFC4D3CE);
    } else if (destaque) {
      cor = Colors.white;
    } else if (fimDeSemana) {
      cor = AppTheme.primary;
    } else {
      cor = AppTheme.textPrimary;
    }

    return Expanded(
      child: Center(
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: destaque
              ? const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary,
                )
              : temCompromisso
                  ? BoxDecoration(
                      shape:
                          BoxShape.circle,
                      border: Border.all(
                        color:
                            AppTheme.primary,
                        width: 1.5,
                      ),
                    )
                  : null,
          child: Text(
            '$d',
            style:
                GoogleFonts.poppins(
              fontSize: 11,
              fontWeight:
                  destaque ||
                          temCompromisso
                      ? FontWeight.w700
                      : FontWeight.w500,
              color: cor,
            ),
          ),
        ),
      ),
    );
  }
}