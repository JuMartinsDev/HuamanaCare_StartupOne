import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/app_state.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';

class AtividadesTab extends StatefulWidget {
  const AtividadesTab({super.key});

  @override
  State<AtividadesTab> createState() => _AtividadesTabState();
}

class _AtividadesTabState extends State<AtividadesTab> {
int coposAgua = 0;
int passos = 0;
int atividadesConcluidas = 0;

bool _carregandoMetas = true;

  static const int metaAgua = 6;
  static const int metaPassos = 5000;
  static const int metaAtividades = 3;

  late DateTime _diaAtual;
  Timer? _timer;

  static const List<Map<String, String>> _atividades = [
    {
      'label': 'Jogo da\nMemória',
      'icon': '🧩',
      'tipo': 'memoria',
    },
    {
      'label': 'Desafio de\nMultiplicação',
      'icon': '✖️',
      'tipo': 'multiplicacao',
    },
    {
      'label': 'Sudoku',
      'icon': '🔢',
      'tipo': 'sudoku',
    },
    {
      'label': 'Caça-\nPalavras',
      'icon': '🔍',
      'tipo': 'caca_palavras',
    },
    {
      'label': 'Quiz de\nMemória',
      'icon': '🧠',
      'tipo': 'quiz',
    },
    {
      'label': 'Palavras\nEmbaralhadas',
      'icon': '🔤',
      'tipo': 'palavras',
    },
  ];

@override
void initState() {
  super.initState();

  _diaAtual = _somenteData(DateTime.now());

  final appState = context.read<AppState>();

  appState.addListener(_atualizarMetasDoAppState);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    _carregarMetasDoAppState();
  });

  _timer = Timer.periodic(
    const Duration(minutes: 1),
    (_) => _verificarNovoDia(),
  );
}

void _carregarMetasDoAppState() {
  if (!mounted) return;

  final appState = context.read<AppState>();

  setState(() {
    coposAgua = appState.coposAguaHoje;
    passos = appState.passosHoje;
    atividadesConcluidas =
        appState.atividadesConcluidasHoje;
    _carregandoMetas = false;
  });
}

void _atualizarMetasDoAppState() {
  if (!mounted) return;

  final appState = context.read<AppState>();

  if (coposAgua == appState.coposAguaHoje &&
      passos == appState.passosHoje &&
      atividadesConcluidas ==
          appState.atividadesConcluidasHoje) {
    return;
  }

  setState(() {
    coposAgua = appState.coposAguaHoje;
    passos = appState.passosHoje;
    atividadesConcluidas =
        appState.atividadesConcluidasHoje;
    _carregandoMetas = false;
  });
}

  DateTime _somenteData(DateTime data) {
    return DateTime(
      data.year,
      data.month,
      data.day,
    );
  }

Future<void> _registrarAtividadeConcluida() async {
  _verificarNovoDia();

  if (!mounted) return;

  final novoValor = atividadesConcluidas + 1;

  setState(() {
    atividadesConcluidas = novoValor;
  });

  await context.read<AppState>().atualizarMetasAtividades(
        atividadesConcluidas: novoValor,
      );
}

  void _verificarNovoDia() {
    final hoje = _somenteData(DateTime.now());

    if (hoje != _diaAtual && mounted) {
      setState(() {
        _diaAtual = hoje;
        coposAgua = 0;
        passos = 0;
        atividadesConcluidas = 0;
      });
    }
  }

Future<void> _adicionarAgua() async {
  _verificarNovoDia();

  if (coposAgua >= metaAgua) {
    return;
  }

  final novoValor = coposAgua + 1;

  setState(() {
    coposAgua = novoValor;
  });

  await context.read<AppState>().atualizarMetasAtividades(
        coposAgua: novoValor,
      );
}

Future<void> _adicionarPassos() async {
  _verificarNovoDia();

  var novoValor = passos + 500;

  if (novoValor > metaPassos) {
    novoValor = metaPassos;
  }

  setState(() {
    passos = novoValor;
  });

  await context.read<AppState>().atualizarMetasAtividades(
        passos: novoValor,
      );
}

  void _abrirAtividade(
    BuildContext context,
    String tipo,
  ) {
    switch (tipo) {
      case 'memoria':
        showDialog(
          context: context,
          builder: (_) => _JogoMemoriaDialog(
            onResultado: (resultado) async {
              final appState = context.read<AppState>();

              await appState.registrarAtividadeCognitiva(
                resultado,
              );

              if (mounted) {
                _registrarAtividadeConcluida();
              }
            },
          ),
        );
        break;

      case 'multiplicacao':
        showDialog(
          context: context,
          builder: (_) => _MultiplicacaoDialog(
            onResultado: (resultado) async {
              final appState = context.read<AppState>();

              await appState.registrarAtividadeCognitiva(
                resultado,
              );

              if (mounted) {
                _registrarAtividadeConcluida();
              }
            },
          ),
        );
        break;

      case 'sudoku':
        showDialog(
          context: context,
          builder: (_) => _SudokuDialog(
            onResultado: (resultado) async {
              final appState = context.read<AppState>();

              await appState.registrarAtividadeCognitiva(
                resultado,
              );

              if (mounted) {
                _registrarAtividadeConcluida();
              }
            },
          ),
        );
        break;

      case 'caca_palavras':
        showDialog(
          context: context,
          builder: (_) => _CacaPalavrasDialog(
            onResultado: (resultado) async {
              final appState = context.read<AppState>();

              await appState.registrarAtividadeCognitiva(
                resultado,
              );

              if (mounted) {
                _registrarAtividadeConcluida();
              }
            },
          ),
        );
        break;

      case 'quiz':
        showDialog(
          context: context,
          builder: (_) => _QuizMemoriaDialog(
            onResultado: (resultado) async {
              final appState = context.read<AppState>();

              await appState.registrarAtividadeCognitiva(
                resultado,
              );

              if (mounted) {
                _registrarAtividadeConcluida();
              }
            },
          ),
        );
        break;

      case 'palavras':
        showDialog(
          context: context,
          builder: (_) => _PalavrasEmbaralhadasDialog(
            onResultado: (resultado) async {
              final appState = context.read<AppState>();

              await appState.registrarAtividadeCognitiva(
                resultado,
              );

              if (mounted) {
                _registrarAtividadeConcluida();
              }
            },
          ),
        );
        break;
    }
  }

@override
void dispose() {
  _timer?.cancel();

  context.read<AppState>().removeListener(
        _atualizarMetasDoAppState,
      );

  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE7F4F2),
            Color(0xFFF7FBFA),
            Color(0xFFF9FBFA),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Atividades',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Exercite a memória e mantenha a mente ativa.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _atividades.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              itemBuilder: (context, index) {
                final atividade = _atividades[index];

                return _AtividadeCard(
                  label: atividade['label']!,
                  icon: atividade['icon']!,
                  onTap: () => _abrirAtividade(
                    context,
                    atividade['tipo']!,
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            _DesempenhoCognitivoCard(
              resultados:
                  context.watch<AppState>().resultadosAtividadesCognitivas,
            ),

            const SizedBox(height: 28),

            Text(
              'Minhas metas',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Acompanhe pequenas metas do seu dia.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),

            _MetaCard(
              icon: '💧',
              title: 'Água',
              value: '$coposAgua / $metaAgua copos',
              progress: coposAgua / metaAgua,
              buttonLabel:
                  coposAgua >= metaAgua ? 'Concluída' : '+ 1 copo',
              onPressed:
                  coposAgua >= metaAgua ? null : _adicionarAgua,
            ),

            const SizedBox(height: 10),

            _MetaCard(
              icon: '🚶',
              title: 'Caminhada',
              value: '$passos / $metaPassos passos',
              progress: passos / metaPassos,
              buttonLabel:
                  passos >= metaPassos ? 'Concluída' : '+ 500',
              onPressed:
                  passos >= metaPassos ? null : _adicionarPassos,
            ),

            const SizedBox(height: 10),

            _MetaCard(
              icon: '🎯',
              title: 'Atividades',
              value:
                  '${min(atividadesConcluidas, metaAtividades)} / $metaAtividades hoje',
              progress:
                  atividadesConcluidas / metaAtividades,
              buttonLabel:
                  atividadesConcluidas >= metaAtividades
                      ? 'Concluída'
                      : 'Automática',
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// DESEMPENHO COGNITIVO
// ============================================================

class _DesempenhoCognitivoCard extends StatelessWidget {
  final List<AtividadeCognitivaResultado> resultados;

  const _DesempenhoCognitivoCard({
    required this.resultados,
  });

  bool _mesmoDia(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String _formatarTempo(int segundos) {
    if (segundos < 60) {
      return '${segundos}s';
    }

    final minutos = segundos ~/ 60;
    final resto = segundos % 60;

    return resto == 0
        ? '${minutos}min'
        : '${minutos}min ${resto}s';
  }

  String _formatarHorario(DateTime data) {
    final hora =
        data.hour.toString().padLeft(2, '0');
    final minuto =
        data.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();

    final resultadosHoje = resultados
        .where(
          (resultado) =>
              _mesmoDia(
            resultado.data,
            agora,
          ),
        )
        .toList()
      ..sort(
        (a, b) =>
            b.data.compareTo(a.data),
      );

    final mediaHoje =
        resultadosHoje.isEmpty
            ? 0
            : (resultadosHoje
                        .map(
                          (resultado) =>
                              resultado
                                  .pontuacao,
                        )
                        .reduce(
                          (a, b) =>
                              a + b,
                        ) /
                    resultadosHoje.length)
                .round();

    final recentes =
        resultadosHoje.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primary
              .withValues(
            alpha: 0.12,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
              alpha: 0.03,
            ),
            blurRadius: 10,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color: AppTheme.primary
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  color: AppTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Desempenho cognitivo',
                      style:
                          GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Resultados das atividades realizadas hoje.',
                      style:
                          GoogleFonts.poppins(
                        fontSize: 10,
                        color:
                            Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child:
                    _CognitivoResumoItem(
                  titulo: 'Atividades',
                  valor:
                      '${resultadosHoje.length}',
                  subtitulo:
                      resultadosHoje.length ==
                              1
                          ? 'realizada hoje'
                          : 'realizadas hoje',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child:
                    _CognitivoResumoItem(
                  titulo: 'Média',
                  valor:
                      resultadosHoje.isEmpty
                          ? '--'
                          : '$mediaHoje%',
                  subtitulo:
                      'pontuação de hoje',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (recentes.isEmpty)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                14,
              ),
              decoration:
                  BoxDecoration(
                color: AppTheme.primary
                    .withValues(
                  alpha: 0.05,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons
                        .psychology_alt_outlined,
                    size: 28,
                    color:
                        AppTheme.primary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Nenhuma atividade cognitiva realizada hoje.',
                    textAlign:
                        TextAlign.center,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 11,
                      color:
                          Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Escolha um dos jogos acima para começar.',
                    textAlign:
                        TextAlign.center,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 9,
                      color:
                          Colors.black45,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              'Últimos resultados',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight:
                    FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 9),
            ...recentes.map(
              (resultado) =>
                  _ResultadoCognitivoItem(
                resultado: resultado,
                horario:
                    _formatarHorario(
                  resultado.data,
                ),
                tempo:
                    _formatarTempo(
                  resultado
                      .tempoSegundos,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CognitivoResumoItem
    extends StatelessWidget {
  final String titulo;
  final String valor;
  final String subtitulo;

  const _CognitivoResumoItem({
    required this.titulo,
    required this.valor,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary
            .withValues(
          alpha: 0.06,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style:
                GoogleFonts.poppins(
              fontSize: 9,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style:
                GoogleFonts.poppins(
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
              color:
                  AppTheme.primary,
            ),
          ),
          Text(
            subtitulo,
            style:
                GoogleFonts.poppins(
              fontSize: 8.5,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultadoCognitivoItem
    extends StatelessWidget {
  final AtividadeCognitivaResultado
      resultado;
  final String horario;
  final String tempo;

  const _ResultadoCognitivoItem({
    required this.resultado,
    required this.horario,
    required this.tempo,
  });

  @override
  Widget build(BuildContext context) {
    final pontuacao =
        resultado.pontuacao;

    final String desempenho;
    final IconData icone;

    if (pontuacao >= 80) {
      desempenho =
          'Bom desempenho';
      icone =
          Icons.trending_up_rounded;
    } else if (pontuacao >= 60) {
      desempenho =
          'Desempenho estável';
      icone =
          Icons.trending_flat_rounded;
    } else {
      desempenho =
          'Acompanhar evolução';
      icone =
          Icons.trending_down_rounded;
    }

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),
      padding:
          const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color:
            AppTheme.background,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(
              color: AppTheme.primary
                  .withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: const Icon(
              Icons
                  .extension_outlined,
              size: 18,
              color:
                  AppTheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        resultado.titulo,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style: GoogleFonts
                            .poppins(
                          fontSize: 11,
                          fontWeight:
                              FontWeight
                                  .w600,
                          color: Colors
                              .black87,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      '${resultado.pontuacao}%',
                      style: GoogleFonts
                          .poppins(
                        fontSize: 12,
                        fontWeight:
                            FontWeight
                                .w700,
                        color: AppTheme
                            .primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${resultado.acertos} acertos • '
                  '${resultado.erros} erros • $tempo',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 9,
                    color:
                        Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      icone,
                      size: 13,
                      color: AppTheme
                          .primary,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      child: Text(
                        '$desempenho • $horario',
                        style: GoogleFonts
                            .poppins(
                          fontSize: 8.5,
                          fontWeight:
                              FontWeight
                                  .w500,
                          color: AppTheme
                              .primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CARD DA ATIVIDADE
// ============================================================

class _AtividadeCard extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;

  const _AtividadeCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 23),
                ),
              ),
              const Spacer(),
              Text(
                label,
                maxLines: 2,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    'Jogar',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// METAS
// ============================================================

class _MetaCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final double progress;
  final String buttonLabel;
  final VoidCallback? onPressed;

  const _MetaCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.progress,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final progresso = progress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 21),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (onPressed != null)
                TextButton(
                  onPressed: onPressed,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    buttonLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                )
              else
                Text(
                  buttonLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 6,
              backgroundColor:
                  AppTheme.primary.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// JOGO DA MEMÓRIA
// ============================================================

class _JogoMemoriaDialog extends StatefulWidget {
  final Future<void> Function(
    AtividadeCognitivaResultado resultado,
  ) onResultado;


  const _JogoMemoriaDialog({
    required this.onResultado,
  });

  @override
  State<_JogoMemoriaDialog> createState() =>
      _JogoMemoriaDialogState();
}

class _JogoMemoriaDialogState
    extends State<_JogoMemoriaDialog> {
  final Random _random = Random();

  final List<String> _simbolos = [
    '🌸',
    '⭐',
    '🍎',
    '🦋',
    '🌈',
    '🍀',
    '🐶',
    '🌻',
  ];

  int nivel = 1;

  List<String> cartas = [];
  List<bool> reveladas = [];
  List<int> selecionadas = [];

  int paresEncontrados = 0;
  int movimentos = 0;
  bool bloqueado = false;

  // Início da sessão completa.
  DateTime? _inicioSessao;

  // Soma dos movimentos dos três níveis.
  int _movimentosTotais = 0;
  int _paresTotaisConcluidos = 0;

  int get quantidadePares {
    if (nivel == 1) return 4;
    if (nivel == 2) return 6;
    return 8;
  }

  @override
  void initState() {
    super.initState();

    _inicioSessao = DateTime.now();

    _iniciarJogoInicial();
  }

  void _iniciarJogoInicial() {
    final simbolosNivel =
        _simbolos.take(quantidadePares).toList();

    cartas = [
      ...simbolosNivel,
      ...simbolosNivel,
    ];

    cartas.shuffle(_random);

    reveladas =
        List.filled(cartas.length, false);

    selecionadas = [];
    paresEncontrados = 0;
    movimentos = 0;
    bloqueado = false;
  }

  void _iniciarJogo() {
    final simbolosNivel =
        _simbolos.take(quantidadePares).toList();

    cartas = [
      ...simbolosNivel,
      ...simbolosNivel,
    ];

    cartas.shuffle(_random);

    reveladas =
        List.filled(cartas.length, false);

    selecionadas = [];
    paresEncontrados = 0;
    movimentos = 0;
    bloqueado = false;

    setState(() {});
  }

  void _tocarCarta(int index) {
    if (bloqueado ||
        reveladas[index] ||
        selecionadas.contains(index)) {
      return;
    }

    setState(() {
      reveladas[index] = true;
      selecionadas.add(index);
    });

    if (selecionadas.length == 2) {
  movimentos++;
  _movimentosTotais++;

  bloqueado = true;

  final primeira = selecionadas[0];
  final segunda = selecionadas[1];

  if (cartas[primeira] == cartas[segunda]) {
    Future.delayed(
      const Duration(milliseconds: 400),
      () {
        if (!mounted) return;

        setState(() {
          paresEncontrados++;
          _paresTotaisConcluidos++;
          selecionadas.clear();
          bloqueado = false;
        });

        if (paresEncontrados == quantidadePares) {
          _mostrarVitoria();
        }
      },
    );
  } else {
    Future.delayed(
      const Duration(milliseconds: 800),
      () {
        if (!mounted) return;

        setState(() {
          reveladas[primeira] = false;
          reveladas[segunda] = false;
          selecionadas.clear();
          bloqueado = false;
        });
      },
    );
  }
}
  }

  Future<void> _salvarResultadoFinal() async {
    final inicio =
        _inicioSessao ?? DateTime.now();

    final tempoSegundos =
        DateTime.now()
            .difference(inicio)
            .inSeconds;

final acertos = _paresTotaisConcluidos;

    final erros =
        (_movimentosTotais - acertos)
            .clamp(0, 999999);

    final totalTentativas =
        acertos + erros;

    final pontuacao =
        totalTentativas == 0
            ? 0
            : ((acertos /
                        totalTentativas) *
                    100)
                .round();

    final resultado =
        AtividadeCognitivaResultado(
      tipo: 'memoria',
      titulo: 'Jogo da Memória',
      data: DateTime.now(),
      pontuacao: pontuacao,
      acertos: acertos,
      erros: erros,
      tempoSegundos: tempoSegundos,
      detalhes: {
        'nivel': nivel,
        'pares': quantidadePares,
        'movimentosNivel': movimentos,
        'movimentosTotais': _movimentosTotais,
      },
    );

    await widget.onResultado(resultado);
  }

  void _mostrarVitoria() {
    final ultimoNivel = nivel == 3;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            ultimoNivel
                ? 'Parabéns!'
                : 'Nível concluído!',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            ultimoNivel
                ? 'Você completou todos os níveis em $_movimentosTotais movimentos.'
                : 'Você encontrou todos os pares em $movimentos movimentos.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            if (!ultimoNivel)
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);

                  setState(() {
                    nivel++;
                  });

                  _iniciarJogo();
                },
                child: Text(
                  'Próximo nível',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),

            TextButton(
onPressed: () async {
  Navigator.pop(dialogContext);

  try {
    await _salvarResultadoFinal();
  } catch (e) {
    debugPrint(
      'ERRO AO SALVAR JOGO DA MEMÓRIA: $e',
    );
  }

  if (!mounted) return;

  Navigator.pop(this.context);
},
              child: Text(
                ultimoNivel
                    ? 'Fechar'
                    : 'Sair',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Jogo da Memória',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 330,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nível $nivel • $quantidadePares pares',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              itemCount: cartas.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 7,
                mainAxisSpacing: 7,
              ),
              itemBuilder:
                  (context, index) {
                final visivel =
                    reveladas[index];

                return GestureDetector(
                  onTap: () =>
                      _tocarCarta(index),
                  child: Container(
                    decoration:
                        BoxDecoration(
                      color: visivel
                          ? AppTheme.primary
                              .withValues(
                              alpha: 0.10,
                            )
                          : AppTheme.primary,
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    alignment:
                        Alignment.center,
                    child: Text(
                      visivel
                          ? cartas[index]
                          : '?',
                      style: TextStyle(
                        fontSize:
                            visivel
                                ? 25
                                : 22,
                        fontWeight:
                            FontWeight.w700,
                        color: visivel
                            ? Colors.black87
                            : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text(
                  'Movimentos: $movimentos',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                        Colors.black54,
                  ),
                ),
                Text(
                  'Pares: $paresEncontrados/$quantidadePares',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                        Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
          setState(() {
            nivel = 1;
            _movimentosTotais = 0;
            _paresTotaisConcluidos = 0;
            _inicioSessao = DateTime.now();
          });

            _iniciarJogo();
          },
          child: Text(
            'Recomeçar',
            style: GoogleFonts.poppins(
              color: AppTheme.primary,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: Text(
            'Fechar',
            style:
                GoogleFonts.poppins(),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MULTIPLICAÇÃO
// ============================================================

class _MultiplicacaoDialog extends StatefulWidget {
  final Future<void> Function(
    AtividadeCognitivaResultado resultado,
  ) onResultado;

  const _MultiplicacaoDialog({
    required this.onResultado,
  });

  @override
  State<_MultiplicacaoDialog> createState() =>
      _MultiplicacaoDialogState();
}

class _MultiplicacaoDialogState
    extends State<_MultiplicacaoDialog> {
  final Random _random = Random();
  final TextEditingController _controller =
      TextEditingController();

  int rodada = 0;
  int acertos = 0;
  int numero1 = 0;
  int numero2 = 0;
  bool respondida = false;
  bool acertou = false;
  int? respostaCorreta;

  DateTime? _inicioAtividade;

  @override
  void initState() {
    super.initState();

    _inicioAtividade = DateTime.now();

    _novaPergunta();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _novaPergunta() {
    numero1 = _random.nextInt(9) + 2;
    numero2 = _random.nextInt(9) + 2;
    respostaCorreta = numero1 * numero2;

    _controller.clear();

    setState(() {
      respondida = false;
      acertou = false;
    });
  }

  void _responder() {
    if (respondida) return;

    final resposta =
        int.tryParse(_controller.text.trim());

    if (resposta == null) return;

    setState(() {
      respondida = true;
      acertou = resposta == respostaCorreta;

      if (acertou) {
        acertos++;
      }
    });
  }

  void _proximaQuestao() {
    if (rodada >= 4) {
      _mostrarResultado();
      return;
    }

    setState(() {
      rodada++;
    });

    _novaPergunta();
  }

  Future<void> _salvarResultado() async {
    final inicio =
        _inicioAtividade ?? DateTime.now();

    final tempoSegundos =
        DateTime.now()
            .difference(inicio)
            .inSeconds;

    final erros = 5 - acertos;

    final pontuacao =
        ((acertos / 5) * 100).round();

    final resultado =
        AtividadeCognitivaResultado(
      tipo: 'multiplicacao',
      titulo: 'Desafio de Multiplicação',
      data: DateTime.now(),
      pontuacao: pontuacao,
      acertos: acertos,
      erros: erros,
      tempoSegundos: tempoSegundos,
      detalhes: {
        'questoes': 5,
        'acertos': acertos,
        'erros': erros,
      },
    );

    await widget.onResultado(resultado);
  }

  void _mostrarResultado() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Resultado',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Você acertou $acertos de 5 questões.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  rodada = 0;
                  acertos = 0;
                  _inicioAtividade =
                      DateTime.now();
                });

                _novaPergunta();
              },
              child: Text(
                'Jogar novamente',
                style: GoogleFonts.poppins(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await _salvarResultado();
                } catch (e) {
                  debugPrint(
                    'ERRO AO SALVAR MULTIPLICAÇÃO: $e',
                  );
                }

                if (!mounted) return;

                Navigator.pop(this.context);
              },
              child: Text(
                'Fechar',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Desafio de Multiplicação',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 310,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Questão ${rodada + 1} de 5',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '$numero1 × $numero2 = ?',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              enabled: !respondida,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Digite a resposta',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              onSubmitted: (_) => _responder(),
            ),
            if (respondida) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: acertou
                      ? Colors.green
                          .withValues(alpha: 0.10)
                      : Colors.red
                          .withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Text(
                  acertou
                      ? 'Correto! Muito bem!'
                      : 'Errado! O correto é $respostaCorreta.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: acertou
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: Text(
            'Fechar',
            style: GoogleFonts.poppins(),
          ),
        ),
        if (!respondida)
          ElevatedButton(
            onPressed: _responder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Responder',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          ElevatedButton(
            onPressed: _proximaQuestao,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              rodada == 4
                  ? 'Ver resultado'
                  : 'Próxima',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================
// SUDOKU
// ============================================================


class _SudokuDialog extends StatefulWidget {
  final Future<void> Function(
    AtividadeCognitivaResultado resultado,
  ) onResultado;

  const _SudokuDialog({
    required this.onResultado,
  });

  @override
  State<_SudokuDialog> createState() => _SudokuDialogState();
}

class _SudokuDialogState extends State<_SudokuDialog> {
  final List<List<int>> _solucao = [
    [1, 2, 3, 4],
    [3, 4, 1, 2],
    [2, 1, 4, 3],
    [4, 3, 2, 1],
  ];

  final List<List<int>> _inicial = [
    [1, 0, 3, 0],
    [0, 4, 0, 2],
    [2, 0, 4, 0],
    [0, 3, 0, 1],
  ];

  late List<List<int>> _tabuleiro;
  DateTime? _inicioAtividade;
  bool _finalizando = false;

  @override
  void initState() {
    super.initState();

    _inicioAtividade = DateTime.now();

    _tabuleiro = _inicial
        .map((linha) => List<int>.from(linha))
        .toList();
  }

  // Verifica apenas se todos os espaços foram preenchidos.
  bool _tabuleiroPreenchido() {
    for (int linha = 0; linha < 4; linha++) {
      for (int coluna = 0; coluna < 4; coluna++) {
        if (_tabuleiro[linha][coluna] == 0) {
          return false;
        }
      }
    }

    return true;
  }

  // Verifica se todos os números estão corretos.
  bool _tabuleiroCorreto() {
    for (int linha = 0; linha < 4; linha++) {
      for (int coluna = 0; coluna < 4; coluna++) {
        if (_tabuleiro[linha][coluna] !=
            _solucao[linha][coluna]) {
          return false;
        }
      }
    }

    return true;
  }

  void _selecionarNumero(int linha, int coluna) {
    if (_inicial[linha][coluna] != 0 ||
        _finalizando) {
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Escolha um número',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    final numero = index + 1;

                    return InkWell(
                      onTap: () {
                        Navigator.pop(sheetContext);

                        if (!mounted) return;

                        setState(() {
                          _tabuleiro[linha][coluna] =
                              numero;
                        });

                        debugPrint(
                          'SUDOKU TABULEIRO: $_tabuleiro',
                        );
                        debugPrint(
                          'SUDOKU PREENCHIDO: '
                          '${_tabuleiroPreenchido()}',
                        );
                      },
                      borderRadius:
                          BorderRadius.circular(14),
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: AppTheme.primary
                              .withValues(alpha: 0.10),
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$numero',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _finalizarSudoku() {
    if (!_tabuleiroPreenchido() || _finalizando) {
      return;
    }

    if (_tabuleiroCorreto()) {
      _mostrarVitoria();
    } else {
      _mostrarErro();
    }
  }

  void _mostrarErro() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Tente novamente',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'O tabuleiro está preenchido, mas existem '
            'números incorretos. Corrija as respostas '
            'e tente finalizar novamente.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Continuar corrigindo',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _salvarResultado() async {
    final inicio = _inicioAtividade ?? DateTime.now();

    final tempoSegundos =
        DateTime.now().difference(inicio).inSeconds;

    final resultado = AtividadeCognitivaResultado(
      tipo: 'sudoku',
      titulo: 'Sudoku',
      data: DateTime.now(),
      pontuacao: 100,
      acertos: 1,
      erros: 0,
      tempoSegundos: tempoSegundos,
      detalhes: {
        'tamanho': '4x4',
        'concluido': true,
      },
    );

    await widget.onResultado(resultado);
  }

  void _mostrarVitoria() {
    if (_finalizando) return;

    setState(() {
      _finalizando = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Sudoku concluído!',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Parabéns! Você completou o Sudoku '
            'corretamente.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                if (!mounted) return;

                setState(() {
                  _tabuleiro = _inicial
                      .map((linha) => List<int>.from(linha))
                      .toList();

                  _inicioAtividade = DateTime.now();
                  _finalizando = false;
                });
              },
              child: Text(
                'Jogar novamente',
                style: GoogleFonts.poppins(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _salvarResultado();

                  debugPrint(
                    'SUDOKU: RESULTADO SALVO COM SUCESSO!',
                  );
                } catch (e) {
                  debugPrint(
                    'ERRO AO SALVAR SUDOKU: $e',
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Não foi possível salvar o resultado. '
                        'Tente novamente.',
                      ),
                    ),
                  );

                  return;
                }

                if (!mounted) return;

                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Finalizar',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final preenchido = _tabuleiroPreenchido();

    return AlertDialog(
      title: Text(
        'Sudoku',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Complete os espaços vazios e toque em '
              'Finalizar para conferir suas respostas.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: 16,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemBuilder: (context, index) {
                  final linha = index ~/ 4;
                  final coluna = index % 4;

                  final fixo =
                      _inicial[linha][coluna] != 0;

                  final numero =
                      _tabuleiro[linha][coluna];

                  return GestureDetector(
                    onTap: () => _selecionarNumero(
                      linha,
                      coluna,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: fixo
                            ? AppTheme.primary
                                .withValues(alpha: 0.12)
                            : Colors.white,
                        border: Border.all(
                          color: AppTheme.primary
                              .withValues(alpha: 0.30),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        numero == 0 ? '' : '$numero',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: fixo
                              ? AppTheme.primary
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _finalizando
              ? null
              : () => Navigator.pop(context),
          child: Text(
            'Sair',
            style: GoogleFonts.poppins(),
          ),
        ),
        ElevatedButton(
          onPressed: preenchido && !_finalizando
              ? _finalizarSudoku
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
          ),
          child: Text(
            'Finalizar',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// CAÇA-PALAVRAS
// ============================================================

class _CacaPalavrasDialog extends StatefulWidget {
  final Future<void> Function(
    AtividadeCognitivaResultado resultado,
  ) onResultado;

  const _CacaPalavrasDialog({
    required this.onResultado,
  });

  @override
  State<_CacaPalavrasDialog> createState() =>
      _CacaPalavrasDialogState();
}

class _CacaPalavrasDialogState
    extends State<_CacaPalavrasDialog> {
  final List<List<String>> _grade = [
    ['C', 'A', 'S', 'A', 'T', 'P', 'L', 'M'],
    ['Q', 'B', 'N', 'R', 'U', 'D', 'E', 'E'],
    ['S', 'A', 'U', 'D', 'E', 'F', 'G', 'M'],
    ['H', 'J', 'K', 'L', 'P', 'Q', 'W', 'O'],
    ['F', 'A', 'M', 'I', 'L', 'I', 'A', 'R'],
    ['X', 'Y', 'Z', 'T', 'C', 'V', 'B', 'I'],
    ['C', 'A', 'R', 'I', 'N', 'H', 'O', 'A'],
    ['D', 'E', 'F', 'G', 'H', 'J', 'K', 'L'],
  ];

  final List<String> _palavras = [
    'CASA',
    'MEMORIA',
    'SAUDE',
    'FAMILIA',
    'CARINHO',
  ];

  final Set<String> _encontradas = {};
  final List<_Posicao> _selecionadas = [];

  DateTime? _inicioAtividade;

  @override
  void initState() {
    super.initState();

    _inicioAtividade = DateTime.now();
  }

  void _selecionarLetra(
    int linha,
    int coluna,
  ) {
    final novaPosicao = _Posicao(
      linha,
      coluna,
    );

    if (_selecionadas.contains(novaPosicao)) {
      return;
    }

    // Primeira letra.
    if (_selecionadas.isEmpty) {
      setState(() {
        _selecionadas.add(novaPosicao);
      });
      return;
    }

    // Segunda letra precisa ser vizinha.
    if (_selecionadas.length == 1) {
      final anterior = _selecionadas.last;

      final linhaValida =
          (linha - anterior.linha).abs() <= 1;

      final colunaValida =
          (coluna - anterior.coluna).abs() <= 1;

      if (!linhaValida || !colunaValida) {
        setState(() {
          _selecionadas.clear();
          _selecionadas.add(novaPosicao);
        });
        return;
      }

      setState(() {
        _selecionadas.add(novaPosicao);
      });

      _verificarSequencia();
      return;
    }

    // A partir da terceira letra, mantém a mesma direção.
    final primeira = _selecionadas[0];
    final segunda = _selecionadas[1];
    final anterior = _selecionadas.last;

    final direcaoLinha =
        (segunda.linha - primeira.linha).sign;

    final direcaoColuna =
        (segunda.coluna - primeira.coluna).sign;

    final proximaLinha =
        anterior.linha + direcaoLinha;

    final proximaColuna =
        anterior.coluna + direcaoColuna;

    if (linha != proximaLinha ||
        coluna != proximaColuna) {
      setState(() {
        _selecionadas.clear();
        _selecionadas.add(novaPosicao);
      });
      return;
    }

    setState(() {
      _selecionadas.add(novaPosicao);
    });

    _verificarSequencia();
  }

  void _verificarSequencia() {
    final palavraAtual = _selecionadas
        .map(
          (posicao) =>
              _grade[posicao.linha][posicao.coluna],
        )
        .join();

    // Palavra encontrada.
    if (_palavras.contains(palavraAtual)) {
      setState(() {
        _encontradas.add(palavraAtual);
        _selecionadas.clear();
      });

      if (_encontradas.length == _palavras.length) {
        Future.delayed(
          const Duration(milliseconds: 300),
          _mostrarVitoria,
        );
      }

      return;
    }

    // Ainda pode formar alguma palavra.
    final existePrefixo = _palavras.any(
      (palavra) =>
          palavra.startsWith(palavraAtual),
    );

    // Não existe nenhuma palavra começando assim.
    if (!existePrefixo) {
      Future.delayed(
        const Duration(milliseconds: 250),
        () {
          if (!mounted) return;

          setState(() {
            _selecionadas.clear();
          });
        },
      );
    }
  }

  bool _estaSelecionada(
    int linha,
    int coluna,
  ) {
    return _selecionadas.contains(
      _Posicao(linha, coluna),
    );
  }

  Future<void> _salvarResultado() async {
    final inicio =
        _inicioAtividade ?? DateTime.now();

    final tempoSegundos =
        DateTime.now()
            .difference(inicio)
            .inSeconds;

    final acertos = _encontradas.length;

    final erros = 0;

    final pontuacao =
        ((acertos / _palavras.length) * 100)
            .round();

    final resultado =
        AtividadeCognitivaResultado(
      tipo: 'caca_palavras',
      titulo: 'Caça-Palavras',
      data: DateTime.now(),
      pontuacao: pontuacao,
      acertos: acertos,
      erros: erros,
      tempoSegundos: tempoSegundos,
      detalhes: {
        'palavras': _palavras.length,
        'encontradas': acertos,
      },
    );

    await widget.onResultado(resultado);
  }

  void _mostrarVitoria() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Parabéns!',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Você encontrou todas as palavras.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  _encontradas.clear();
                  _selecionadas.clear();
                  _inicioAtividade =
                      DateTime.now();
                });
              },
              child: Text(
                'Jogar novamente',
                style: GoogleFonts.poppins(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await _salvarResultado();
                } catch (e) {
                  debugPrint(
                    'ERRO AO SALVAR CAÇA-PALAVRAS: $e',
                  );
                }

                if (!mounted) return;

                Navigator.pop(this.context);
              },
              child: Text(
                'Fechar',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Caça-Palavras',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Toque nas letras na sequência correta.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children:
                  _palavras.map((palavra) {
                final encontrada =
                    _encontradas.contains(palavra);

                return Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: encontrada
                        ? AppTheme.primary
                            .withValues(alpha: 0.12)
                        : Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Text(
                    palavra,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w600,
                      decoration: encontrada
                          ? TextDecoration.lineThrough
                          : null,
                      color: encontrada
                          ? AppTheme.primary
                          : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: 64,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  final linha = index ~/ 8;
                  final coluna = index % 8;
                  final letra =
                      _grade[linha][coluna];

                  final selecionada =
                      _estaSelecionada(
                    linha,
                    coluna,
                  );

                  return GestureDetector(
                    onTap: () =>
                        _selecionarLetra(
                      linha,
                      coluna,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selecionada
                            ? AppTheme.primary
                            : AppTheme.primary
                                .withValues(
                                alpha: 0.07,
                              ),
                        borderRadius:
                            BorderRadius.circular(7),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letra,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w700,
                          color: selecionada
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${_encontradas.length} de ${_palavras.length} encontradas',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: Text(
            'Fechar',
            style: GoogleFonts.poppins(),
          ),
        ),
      ],
    );
  }
}

class _Posicao {
  final int linha;
  final int coluna;

  const _Posicao(
    this.linha,
    this.coluna,
  );

  @override
  bool operator ==(Object other) {
    return other is _Posicao &&
        other.linha == linha &&
        other.coluna == coluna;
  }

  @override
  int get hashCode =>
      Object.hash(linha, coluna);
}

// ============================================================
// QUIZ DE MEMÓRIA
// ============================================================

class _QuizMemoriaDialog extends StatefulWidget {
  final Future<void> Function(
    AtividadeCognitivaResultado resultado,
  ) onResultado;

  const _QuizMemoriaDialog({
    required this.onResultado,
  });

  @override
  State<_QuizMemoriaDialog> createState() =>
      _QuizMemoriaDialogState();
}

class _QuizMemoriaDialogState
    extends State<_QuizMemoriaDialog> {
  final List<Map<String, dynamic>> _perguntas = [
    {
      'pergunta': 'Qual destas opções é uma fruta?',
      'opcoes': [
        'Maçã',
        'Cadeira',
        'Sapato',
        'Relógio',
      ],
      'resposta': 'Maçã',
    },
    {
      'pergunta':
          'Qual animal é conhecido por latir?',
      'opcoes': [
        'Gato',
        'Cachorro',
        'Peixe',
        'Coelho',
      ],
      'resposta': 'Cachorro',
    },
    {
      'pergunta':
          'Qual destas cores é formada pela mistura de azul e amarelo?',
      'opcoes': [
        'Verde',
        'Rosa',
        'Preto',
        'Branco',
      ],
      'resposta': 'Verde',
    },
    {
      'pergunta':
          'Quantos dias existem em uma semana?',
      'opcoes': [
        '5',
        '6',
        '7',
        '8',
      ],
      'resposta': '7',
    },
    {
      'pergunta':
          'Qual objeto usamos normalmente para saber as horas?',
      'opcoes': [
        'Relógio',
        'Prato',
        'Livro',
        'Chave',
      ],
      'resposta': 'Relógio',
    },
  ];

  int perguntaAtual = 0;
  int acertos = 0;
  bool respondida = false;

  DateTime? _inicioAtividade;

  @override
  void initState() {
    super.initState();

    _inicioAtividade = DateTime.now();
  }

  void _responder(String resposta) {
    if (respondida) return;

    final correta =
        resposta ==
        _perguntas[perguntaAtual]['resposta'];

    setState(() {
      respondida = true;

      if (correta) {
        acertos++;
      }
    });

    Future.delayed(
      const Duration(milliseconds: 700),
      () {
        if (!mounted) return;

        if (perguntaAtual ==
            _perguntas.length - 1) {
          _mostrarResultado();
        } else {
          setState(() {
            perguntaAtual++;
            respondida = false;
          });
        }
      },
    );
  }

  Future<void> _salvarResultado() async {
    final inicio =
        _inicioAtividade ?? DateTime.now();

    final tempoSegundos =
        DateTime.now()
            .difference(inicio)
            .inSeconds;

    final erros =
        _perguntas.length - acertos;

    final pontuacao =
        ((acertos / _perguntas.length) * 100)
            .round();

    final resultado =
        AtividadeCognitivaResultado(
      tipo: 'quiz',
      titulo: 'Quiz de Memória',
      data: DateTime.now(),
      pontuacao: pontuacao,
      acertos: acertos,
      erros: erros,
      tempoSegundos: tempoSegundos,
      detalhes: {
        'perguntas': _perguntas.length,
        'acertos': acertos,
        'erros': erros,
      },
    );

    await widget.onResultado(resultado);
  }

  void _mostrarResultado() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Resultado',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Você acertou $acertos de ${_perguntas.length} perguntas.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  perguntaAtual = 0;
                  acertos = 0;
                  respondida = false;
                  _inicioAtividade =
                      DateTime.now();
                });
              },
              child: Text(
                'Jogar novamente',
                style: GoogleFonts.poppins(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await _salvarResultado();
                } catch (e) {
                  debugPrint(
                    'ERRO AO SALVAR QUIZ DE MEMÓRIA: $e',
                  );
                }

                if (!mounted) return;

                Navigator.pop(this.context);
              },
              child: Text(
                'Fechar',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pergunta =
        _perguntas[perguntaAtual];

    return AlertDialog(
      title: Text(
        'Quiz de Memória',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pergunta ${perguntaAtual + 1} de ${_perguntas.length}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              pergunta['pergunta'],
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ...List<String>.from(
              pergunta['opcoes'],
            ).map(
              (opcao) => Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: respondida
                        ? null
                        : () =>
                            _responder(opcao),
                    style:
                        OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      side: BorderSide(
                        color: AppTheme.primary
                            .withValues(
                          alpha: 0.35,
                        ),
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    child: Text(
                      opcao,
                      style:
                          GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: Text(
            'Fechar',
            style: GoogleFonts.poppins(),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PALAVRAS EMBARALHADAS
// ============================================================

class _PalavrasEmbaralhadasDialog
    extends StatefulWidget {
  final Future<void> Function(
    AtividadeCognitivaResultado resultado,
  ) onResultado;

  const _PalavrasEmbaralhadasDialog({
    required this.onResultado,
  });

  @override
  State<_PalavrasEmbaralhadasDialog> createState() =>
      _PalavrasEmbaralhadasDialogState();
}

class _PalavrasEmbaralhadasDialogState
    extends State<_PalavrasEmbaralhadasDialog> {
  final Random _random = Random();

  final List<String> _palavras = [
    'SAUDE',
    'FAMILIA',
    'CARINHO',
    'MEMORIA',
    'AMIZADE',
  ];

  int rodada = 0;
  int acertos = 0;

  late String palavraAtual;
  late String embaralhada;

  final TextEditingController _controller =
      TextEditingController();

  bool respondida = false;
  bool acertou = false;

  late DateTime _inicioAtividade;

  @override
  void initState() {
    super.initState();

    _inicioAtividade = DateTime.now();

    _novaPalavraInicial();
  }

  void _novaPalavraInicial() {
    palavraAtual = _palavras[rodada];

    final letras = palavraAtual.split('');

    do {
      letras.shuffle(_random);
      embaralhada = letras.join();
    } while (embaralhada == palavraAtual);
  }

  void _novaPalavra() {
    palavraAtual = _palavras[rodada];

    final letras = palavraAtual.split('');

    do {
      letras.shuffle(_random);
      embaralhada = letras.join();
    } while (embaralhada == palavraAtual);

    _controller.clear();

    setState(() {
      respondida = false;
      acertou = false;
    });
  }

  void _responder() {
    if (respondida) return;

    final resposta =
        _controller.text.trim().toUpperCase();

    if (resposta.isEmpty) return;

    final acertouAgora =
        resposta == palavraAtual;

    setState(() {
      respondida = true;
      acertou = acertouAgora;

      if (acertouAgora) {
        acertos++;
      }
    });

    // Se foi a última palavra,
    // mostra o resultado automaticamente.
    if (rodada == _palavras.length - 1) {
      Future.delayed(
        const Duration(milliseconds: 700),
        () {
          if (!mounted) return;

          _mostrarResultado();
        },
      );
    }
  }

  void _proximaPalavra() {
    if (rodada >= _palavras.length - 1) {
      _mostrarResultado();
      return;
    }

    setState(() {
      rodada++;
    });

    _novaPalavra();
  }

  Future<void> _salvarResultado() async {
    final tempoSegundos =
        DateTime.now()
            .difference(_inicioAtividade)
            .inSeconds;

    final totalPalavras = _palavras.length;

    final erros = totalPalavras - acertos;

    final pontuacao =
        ((acertos / totalPalavras) * 100).round();

    final resultado =
        AtividadeCognitivaResultado(
      tipo: 'palavras',
      titulo: 'Palavras Embaralhadas',
      data: DateTime.now(),
      pontuacao: pontuacao,
      acertos: acertos,
      erros: erros,
      tempoSegundos: tempoSegundos,
      detalhes: {
        'palavras': totalPalavras,
        'acertos': acertos,
        'erros': erros,
      },
    );

    await widget.onResultado(resultado);
  }

  void _mostrarResultado() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Resultado',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Você acertou $acertos de ${_palavras.length} palavras.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  rodada = 0;
                  acertos = 0;
                  _inicioAtividade = DateTime.now();
                });

                _novaPalavra();
              },
              child: Text(
                'Jogar novamente',
                style: GoogleFonts.poppins(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await _salvarResultado();
                } catch (e) {
                  debugPrint(
                    'ERRO AO SALVAR PALAVRAS EMBARALHADAS: $e',
                  );
                }

                if (!mounted) return;

                Navigator.pop(this.context);
              },
              child: Text(
                'Fechar',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Palavras Embaralhadas',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rodada ${rodada + 1} de ${_palavras.length}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              embaralhada,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Desembaralhe a palavra.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              enabled: !respondida,
              textAlign: TextAlign.center,
              textCapitalization:
                  TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Digite a palavra',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              onSubmitted: (_) => _responder(),
            ),
            if (respondida) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: acertou
                      ? Colors.green
                          .withValues(alpha: 0.10)
                      : Colors.red
                          .withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Text(
                  acertou
                      ? 'Correto! Muito bem!'
                      : 'Errado! A palavra correta é $palavraAtual.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: acertou
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Fechar',
            style: GoogleFonts.poppins(),
          ),
        ),
        if (!respondida)
          ElevatedButton(
            onPressed: _responder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Responder',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          ElevatedButton(
            onPressed: _proximaPalavra,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              rodada == _palavras.length - 1
                  ? 'Ver resultado'
                  : 'Próxima',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}