import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../../models/app_state.dart';
import '../../../models/models.dart';
import '../../../widgets/shared.dart';

class RemediosTab extends StatefulWidget {
  const RemediosTab({super.key});

  @override
  State<RemediosTab> createState() => _RemediosTabState();
}

class _RemediosTabState extends State<RemediosTab> {
  int _filtro = 0;

  // ============================================================
  // UTILITÁRIOS DE DATA
  // ============================================================

  DateTime _inicioDoDia(DateTime data) {
    return DateTime(
      data.year,
      data.month,
      data.day,
    );
  }

  bool _estaAtivoNaData(
    Remedio remedio,
    DateTime data,
  ) {
    final dia = _inicioDoDia(data);

    final inicio = remedio.dataInicio == null
        ? null
        : _inicioDoDia(remedio.dataInicio!);

    final fim = remedio.dataFim == null
        ? null
        : _inicioDoDia(remedio.dataFim!);

    if (inicio != null && dia.isBefore(inicio)) {
      return false;
    }

    if (fim != null && dia.isAfter(fim)) {
      return false;
    }

    return true;
  }

  List<Remedio> _filtrarRemedios(
    List<Remedio> remedios,
  ) {
    final hoje = _inicioDoDia(DateTime.now());

    switch (_filtro) {
      // ========================================================
      // HOJE
      // ========================================================
      case 0:
        return remedios.where((remedio) {
          return _estaAtivoNaData(
            remedio,
            hoje,
          );
        }).toList();

      // ========================================================
      // SEMANA
      // ========================================================
      case 1:
        return remedios.where((remedio) {
          for (int i = 0; i < 7; i++) {
            final dia = hoje.add(
              Duration(days: i),
            );

            if (_estaAtivoNaData(
              remedio,
              dia,
            )) {
              return true;
            }
          }

          return false;
        }).toList();

      // ========================================================
      // TODOS
      // ========================================================
      default:
        return List<Remedio>.from(remedios);
    }
  }

  // ============================================================
  // DATA ATUAL
  // ============================================================

  String _dataAtualFormatada() {
    final agora = DateTime.now();

    const dias = [
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];

    const meses = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    return '${dias[agora.weekday - 1]}, '
        '${agora.day} de ${meses[agora.month - 1]}';
  }

  // ============================================================
  // HORÁRIO
  // ============================================================

  Future<String?> _selecionarHorario(
    BuildContext context, {
    String? horarioInicial,
  }) async {
    TimeOfDay inicial = TimeOfDay.now();

    if (horarioInicial != null && horarioInicial.isNotEmpty) {
      final partes = horarioInicial.split(':');

      if (partes.length == 2) {
        final hora = int.tryParse(partes[0]);
        final minuto = int.tryParse(partes[1]);

        if (hora != null &&
            minuto != null &&
            hora >= 0 &&
            hora <= 23 &&
            minuto >= 0 &&
            minuto <= 59) {
          inicial = TimeOfDay(
            hour: hora,
            minute: minuto,
          );
        }
      }
    }

    final selecionado = await showTimePicker(
      context: context,
      initialTime: inicial,
      helpText: 'Selecione o horário',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      hourLabelText: 'Hora',
      minuteLabelText: 'Minuto',
    );

    if (selecionado == null) {
      return null;
    }

    final hora = selecionado.hour.toString().padLeft(2, '0');
    final minuto = selecionado.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  // ============================================================
  // ADICIONAR
  // ============================================================

  void _abrirAdicionar() {
    final nome = TextEditingController();
    final tipo = TextEditingController(
      text: 'Comprimido',
    );
    final horario = TextEditingController();

    DateTime dataInicio = _inicioDoDia(
      DateTime.now(),
    );

    DateTime? dataFim;

    String? erro;
    bool salvando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(
                        bottom: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius:
                            BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  Text(
                    'Adicionar medicamento',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  HCFieldBorda(
                    hint: 'Nome do medicamento',
                    controller: nome,
                  ),

                  const SizedBox(height: 12),

                  HCFieldBorda(
                    hint: 'Tipo (ex.: Comprimido)',
                    controller: tipo,
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // HORÁRIO COM RELÓGIO
                  // ==================================================

                  InkWell(
                    onTap: () async {
                      final selecionado =
                          await _selecionarHorario(
                        ctx,
                        horarioInicial:
                            horario.text,
                      );

                      if (selecionado != null) {
                        setSheet(() {
                          horario.text = selecionado;
                          erro = null;
                        });
                      }
                    },
                    borderRadius:
                        BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.divider,
                        ),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_outlined,
                            size: 20,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Horário',
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 11,
                                    color:
                                        AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  horario.text.isEmpty
                                      ? 'Selecionar horário'
                                      : horario.text,
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w600,
                                    color: horario.text.isEmpty
                                        ? AppTheme.textLight
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color:
                                AppTheme.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _DataSelector(
                    label: 'Início',
                    data: dataInicio,
                    onTap: () async {
                      final selecionada =
                          await _selecionarData(
                        ctx,
                        dataInicial: dataInicio,
                      );

                      if (selecionada != null) {
                        setSheet(() {
                          dataInicio = selecionada;

                          if (dataFim != null &&
                              dataFim!.isBefore(
                                dataInicio,
                              )) {
                            dataFim = null;
                          }
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  _DataSelector(
                    label: 'Término',
                    data: dataFim,
                    opcional: true,
                    onTap: () async {
                      final selecionada =
                          await _selecionarData(
                        ctx,
                        dataInicial:
                            dataFim ?? dataInicio,
                        primeiraData: dataInicio,
                      );

                      if (selecionada != null) {
                        setSheet(() {
                          dataFim = selecionada;
                        });
                      }
                    },
                    onClear: dataFim == null
                        ? null
                        : () {
                            setSheet(() {
                              dataFim = null;
                            });
                          },
                  ),

                  if (erro != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      erro!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.error,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  HCButton(
                    label: salvando
                        ? 'Salvando...'
                        : 'Salvar',
                    onTap: salvando
                        ? () {}
                        : () async {
                            final nomeTexto =
                                nome.text.trim();

                            final tipoTexto =
                                tipo.text.trim();

                            final horarioTexto =
                                horario.text.trim();

                            final valido =
                                RegExp(
                              r'^([01]?\d|2[0-3]):[0-5]\d$',
                            ).hasMatch(
                              horarioTexto,
                            );

                            if (nomeTexto.isEmpty ||
                                !valido) {
                              setSheet(
                                () => erro =
                                    'Informe um nome e selecione um horário válido.',
                              );
                              return;
                            }

                            setSheet(() {
                              salvando = true;
                              erro = null;
                            });

                            try {
                              await context
                                  .read<AppState>()
                                  .addRemedio(
                                    Remedio(
                                      id: '',
                                      nome: nomeTexto,
                                      tipo: tipoTexto.isEmpty
                                          ? 'COMPRIMIDO'
                                          : tipoTexto
                                              .toUpperCase(),
                                      horario:
                                          horarioTexto,
                                      dataInicio:
                                          dataInicio,
                                      dataFim:
                                          dataFim,
                                    ),
                                  );

                              if (!ctx.mounted) {
                                return;
                              }

                              Navigator.pop(ctx);

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Medicamento salvo com sucesso!',
                                  ),
                                  duration:
                                      Duration(seconds: 2),
                                ),
                              );
                            } catch (e) {
                              setSheet(() {
                                salvando = false;
                                erro =
                                    'Não foi possível salvar o medicamento.';
                              });
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EDITAR
  // ============================================================

  void _abrirEditar(Remedio remedio) {
    final nome = TextEditingController(
      text: remedio.nome,
    );

    final tipo = TextEditingController(
      text: remedio.tipo,
    );

    final horario = TextEditingController(
      text: remedio.horario,
    );

    DateTime dataInicio =
        remedio.dataInicio ??
            _inicioDoDia(DateTime.now());

    DateTime? dataFim = remedio.dataFim;

    String? erro;
    bool salvando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(
                        bottom: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius:
                            BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  Text(
                    'Editar medicamento',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  HCFieldBorda(
                    hint: 'Nome do medicamento',
                    controller: nome,
                  ),

                  const SizedBox(height: 12),

                  HCFieldBorda(
                    hint: 'Tipo (ex.: Comprimido)',
                    controller: tipo,
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // HORÁRIO COM RELÓGIO
                  // ==================================================

                  InkWell(
                    onTap: () async {
                      final selecionado =
                          await _selecionarHorario(
                        ctx,
                        horarioInicial:
                            horario.text,
                      );

                      if (selecionado != null) {
                        setSheet(() {
                          horario.text = selecionado;
                          erro = null;
                        });
                      }
                    },
                    borderRadius:
                        BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.divider,
                        ),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_outlined,
                            size: 20,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Horário',
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 11,
                                    color:
                                        AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  horario.text.isEmpty
                                      ? 'Selecionar horário'
                                      : horario.text,
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w600,
                                    color: horario.text.isEmpty
                                        ? AppTheme.textLight
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color:
                                AppTheme.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _DataSelector(
                    label: 'Início',
                    data: dataInicio,
                    onTap: () async {
                      final selecionada =
                          await _selecionarData(
                        ctx,
                        dataInicial: dataInicio,
                      );

                      if (selecionada != null) {
                        setSheet(() {
                          dataInicio = selecionada;

                          if (dataFim != null &&
                              dataFim!.isBefore(
                                dataInicio,
                              )) {
                            dataFim = null;
                          }
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  _DataSelector(
                    label: 'Término',
                    data: dataFim,
                    opcional: true,
                    onTap: () async {
                      final selecionada =
                          await _selecionarData(
                        ctx,
                        dataInicial:
                            dataFim ?? dataInicio,
                        primeiraData: dataInicio,
                      );

                      if (selecionada != null) {
                        setSheet(() {
                          dataFim = selecionada;
                        });
                      }
                    },
                    onClear: dataFim == null
                        ? null
                        : () {
                            setSheet(() {
                              dataFim = null;
                            });
                          },
                  ),

                  if (erro != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      erro!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.error,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  HCButton(
                    label: salvando
                        ? 'Salvando...'
                        : 'Salvar alterações',
                    onTap: salvando
                        ? () {}
                        : () async {
                            final nomeTexto =
                                nome.text.trim();

                            final tipoTexto =
                                tipo.text.trim();

                            final horarioTexto =
                                horario.text.trim();

                            final valido =
                                RegExp(
                              r'^([01]?\d|2[0-3]):[0-5]\d$',
                            ).hasMatch(
                              horarioTexto,
                            );

                            if (nomeTexto.isEmpty ||
                                !valido) {
                              setSheet(
                                () => erro =
                                    'Informe um nome e selecione um horário válido.',
                              );
                              return;
                            }

                            setSheet(() {
                              salvando = true;
                              erro = null;
                            });

                            try {
                              final atualizado =
                                  Remedio(
                                id: remedio.id,
                                nome: nomeTexto,
                                tipo: tipoTexto.isEmpty
                                    ? 'COMPRIMIDO'
                                    : tipoTexto
                                        .toUpperCase(),
                                horario: horarioTexto,
                                tomado: remedio.tomado,
                                dataInicio:
                                    dataInicio,
                                dataFim:
                                    dataFim,
                              );

                              await context
                                  .read<AppState>()
                                  .updateRemedio(
                                    atualizado,
                                  );

                              if (!ctx.mounted) {
                                return;
                              }

                              Navigator.pop(ctx);

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Medicamento atualizado com sucesso!',
                                  ),
                                  duration:
                                      Duration(seconds: 2),
                                ),
                              );
                            } catch (e) {
                              setSheet(() {
                                salvando = false;
                                erro =
                                    'Não foi possível atualizar o medicamento.';
                              });
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SELETOR DE DATA
  // ============================================================

  Future<DateTime?> _selecionarData(
    BuildContext context, {
    required DateTime dataInicial,
    DateTime? primeiraData,
  }) {
    return showDatePicker(
      context: context,
      initialDate: dataInicial,
      firstDate:
          primeiraData ?? DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
  }

  // ============================================================
  // REMOVER
  // ============================================================

  void _confirmarRemover(
    Remedio remedio,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Remover medicamento?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Deseja realmente remover ${remedio.nome}? '
          'Esta ação não pode ser desfeita.',
          style: GoogleFonts.poppins(
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context
                    .read<AppState>()
                    .removeRemedio(
                      remedio.id,
                    );

                if (!ctx.mounted) {
                  return;
                }

                Navigator.pop(ctx);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Medicamento removido com sucesso!',
                    ),
                    duration:
                        Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                if (!ctx.mounted) {
                  return;
                }

                Navigator.pop(ctx);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Não foi possível remover o medicamento.',
                    ),
                  ),
                );
              }
            },
            child: Text(
              'Remover',
              style: GoogleFonts.poppins(
                color: AppTheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final todos =
        context.watch<AppState>().remedios;

    final remedios =
        _filtrarRemedios(todos);

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 14),

          Text(
            'Remédios',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 14),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: _Segmented(
              labels: const [
                'Hoje',
                'Semana',
                'Todos',
              ],
              index: _filtro,
              onChange: (i) {
                setState(() {
                  _filtro = i;
                });
              },
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _dataAtualFormatada(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: remedios.isEmpty
                ? _vazio()
                : ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      16,
                    ),
                    itemCount:
                        remedios.length + 1,
                    itemBuilder: (_, i) {
                      if (i == remedios.length) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 8,
                          ),
                          child: HCButton(
                            label:
                                '+  Adicionar medicamento',
                            onTap:
                                _abrirAdicionar,
                          ),
                        );
                      }

                      return _MedCard(
                        r: remedios[i],
                        onEditar: () {
                          _abrirEditar(
                            remedios[i],
                          );
                        },
                        onRemover: () {
                          _confirmarRemover(
                            remedios[i],
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VAZIO
  // ============================================================

  Widget _vazio() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.medication_outlined,
              size: 44,
              color: AppTheme.textLight,
            ),

            const SizedBox(height: 10),

            Text(
              'Nenhum medicamento',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              _filtro == 0
                  ? 'Nenhum medicamento está programado para hoje.'
                  : _filtro == 1
                      ? 'Nenhum medicamento está programado para esta semana.'
                      : 'Cadastre o primeiro medicamento.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color:
                    AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            HCButton(
              label:
                  '+  Adicionar medicamento',
              onTap: _abrirAdicionar,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CARD
// ============================================================

class _MedCard extends StatelessWidget {
  final Remedio r;
  final VoidCallback onEditar;
  final VoidCallback onRemover;

  const _MedCard({
    required this.r,
    required this.onEditar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final tomado = r.tomado;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary,
            ),
            child: const Icon(
              Icons.medication,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  r.nome,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  r.tipo,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    letterSpacing: 0.5,
                    color:
                        AppTheme.textSecondary,
                  ),
                ),

                Text(
                  r.horario,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color:
                        AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // MENU
          // ======================================================

          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor:
                    AppTheme.surface,
                shape:
                    const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                builder: (_) => SafeArea(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      ListTile(
                        leading:
                            const Icon(
                          Icons.edit_outlined,
                        ),
                        title: Text(
                          'Editar',
                          style:
                              GoogleFonts.poppins(),
                        ),
                        onTap: () {
                          Navigator.pop(
                            context,
                          );
                          onEditar();
                        },
                      ),

                      ListTile(
                        leading: Icon(
                          Icons.delete_outline,
                          color:
                              AppTheme.error,
                        ),
                        title: Text(
                          'Excluir',
                          style:
                              GoogleFonts.poppins(
                            color:
                                AppTheme.error,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(
                            context,
                          );
                          onRemover();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            tooltip: 'Opções',
            icon: const Icon(
              Icons.more_vert,
              size: 22,
              color:
                  AppTheme.textSecondary,
            ),
          ),

          _pill(tomado),
        ],
      ),
    );
  }

  Widget _pill(bool tomado) {
    final bg = tomado
        ? const Color(0xFFBFE3CE)
        : const Color(0xFF8FC7BB);

    final fg = tomado
        ? const Color(0xFF1F6E5A)
        : Colors.white;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            BorderRadius.circular(999),
      ),
      child: Text(
        tomado ? 'Tomado' : 'Pendente',
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

// ============================================================
// SELETOR DE DATA
// ============================================================

class _DataSelector extends StatelessWidget {
  final String label;
  final DateTime? data;
  final bool opcional;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DataSelector({
    required this.label,
    required this.data,
    required this.onTap,
    this.opcional = false,
    this.onClear,
  });

  String _formatar(DateTime data) {
    final dia =
        data.day.toString().padLeft(2, '0');

    final mes =
        data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.divider,
          ),
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppTheme.primary,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color:
                          AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    data == null
                        ? 'Sem data'
                        : _formatar(data!),
                    style:
                        GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                      color: data == null
                          ? AppTheme.textLight
                          : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            if (data != null &&
                onClear != null)
              IconButton(
                onPressed: onClear,
                icon: const Icon(
                  Icons.close,
                  size: 18,
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                color:
                    AppTheme.textSecondary,
              ),

            if (opcional && data == null)
              Text(
                'opcional',
                style:
                    GoogleFonts.poppins(
                  fontSize: 10,
                  color:
                      AppTheme.textLight,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SEGMENTADO
// ============================================================

class _Segmented extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChange;

  const _Segmented({
    required this.labels,
    required this.index,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (
          int i = 0;
          i < labels.length;
          i++
        )
          Expanded(
            child: GestureDetector(
              onTap: () => onChange(i),
              child: Container(
                margin: EdgeInsets.only(
                  right:
                      i < labels.length - 1
                          ? 8
                          : 0,
                ),
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 9,
                ),
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(
                  color: index == i
                      ? const Color(
                          0xFFFDF6E3,
                        )
                      : AppTheme.surface,
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: index == i
                        ? const Color(
                            0xFFEFE2B6,
                          )
                        : AppTheme.divider,
                  ),
                ),
                child: Text(
                  labels[i],
                  style:
                      GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                    color: index == i
                        ? AppTheme.accent
                        : AppTheme.textLight,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}