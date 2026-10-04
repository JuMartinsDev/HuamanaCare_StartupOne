import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../services/gemini_service.dart';

import '../../models/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class CuidadorHome extends StatefulWidget {
  const CuidadorHome({super.key});

  @override
  State<CuidadorHome> createState() => _CuidadorHomeState();
}

class _CuidadorHomeState extends State<CuidadorHome> {
  int _abaAtual = 0;

  List<Widget> get _abas => [
        _CuidadorInicioTab(
          onIrParaAba: (indice) {
            setState(() {
              _abaAtual = indice;
            });
          },
        ),
        const _CuidadorRemediosTab(),
        const _CuidadorCompromissosTab(),
        const _CuidadorChatTab(),
        const _CuidadorPerfilTab(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _abaAtual,
        children: _abas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaAtual,
        onDestinationSelected: (index) {
          setState(() {
            _abaAtual = index;
          });
        },
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Remédios',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INÍCIO
// ============================================================

class _CuidadorInicioTab extends StatelessWidget {
  final void Function(int indice) onIrParaAba;

  const _CuidadorInicioTab({
    required this.onIrParaAba,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final paciente = state.paciente;
    final remedios = state.remedios;
    final compromissos = state.compromissos;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7F4F2),
        elevation: 0,
        title: Text(
          'Milo',
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
        child: Container(
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
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<AppState>().inicializar();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, ${state.usuarioAtualNome.isNotEmpty ? state.usuarioAtualNome : 'Cuidador'}! 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paciente.nome.isEmpty
                        ? 'Acompanhe o cuidado do paciente.'
                        : 'Acompanhe o cuidado de ${paciente.nome}.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 26),
                  _PacienteResumoCard(
                    paciente: paciente,
                    onTap: () {
                      _mostrarDadosPaciente(context, paciente);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Resumo de saúde',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ResumoCard(
                          icon: Icons.medication_outlined,
                          titulo: 'Remédios',
                          valor: '${remedios.length}',
                          descricao: 'cadastrados',
                          onTap: () => onIrParaAba(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ResumoCard(
                          icon: Icons.calendar_month_outlined,
                          titulo: 'Agenda',
                          valor: '${compromissos.length}',
                          descricao: 'compromissos',
                          onTap: () => onIrParaAba(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _AlertasCuidadorCard(
  onAbrirRemedios: () => onIrParaAba(1),
  onAbrirAgenda: () => onIrParaAba(2),
),

const SizedBox(height: 20),

                  _InformacoesSaudeCard(
                    paciente: paciente,
                  ),
                  const SizedBox(height: 16),
                  _CuidadosIntensivosCard(
                    paciente: paciente,
                  ),
                  const SizedBox(height: 20),
                  const _TimelineCuidador(),
                  const SizedBox(height: 20),
                  const _HistoricoAcompanhamentoCard(),
                  const SizedBox(height: 20),
                  const _AcompanhamentoCognitivoCard(),
                  const SizedBox(height: 20),
                  Text(
                    'Emergência',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SosCard(
                    ativado: state.sosAtivado,
                    status: state.sosStatus,
                    dataHora: state.sosDataHora,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDadosPaciente(
    BuildContext context,
    Paciente paciente,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFE7F4F2),
      builder: (context) {
        return _DadosPacienteSheet(
          paciente: paciente,
        );
      },
    );
  }
}

class _AlertasCuidadorCard extends StatelessWidget {
  final VoidCallback onAbrirRemedios;
  final VoidCallback onAbrirAgenda;

  const _AlertasCuidadorCard({
    required this.onAbrirRemedios,
    required this.onAbrirAgenda,
  });

  int _horarioEmMinutos(String horario) {
    final partes = horario.split(':');

    if (partes.length != 2) {
      return 9999;
    }

    final hora = int.tryParse(partes[0]);
    final minuto = int.tryParse(partes[1]);

    if (hora == null || minuto == null) {
      return 9999;
    }

    return hora * 60 + minuto;
  }

  DateTime _semHorario(DateTime data) {
    return DateTime(
      data.year,
      data.month,
      data.day,
    );
  }

  bool _mesmoDia(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool _estaNoPeriodo(
    DateTime hoje,
    DateTime? inicio,
    DateTime? fim,
  ) {
    final data = _semHorario(hoje);

    if (inicio != null &&
        _semHorario(inicio).isAfter(data)) {
      return false;
    }

    if (fim != null &&
        _semHorario(fim).isBefore(data)) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final agora = DateTime.now();
    final minutosAgora =
        agora.hour * 60 + agora.minute;

    final alertas = <_AlertaCuidadorItem>[];

    // ============================================================
    // MEDICAMENTOS ATRASADOS
    // ============================================================

    for (final remedio in state.remedios) {
      if (!_estaNoPeriodo(
        agora,
        remedio.dataInicio,
        remedio.dataFim,
      )) {
        continue;
      }

      if (remedio.tomado) {
        continue;
      }

      final minutos =
          _horarioEmMinutos(remedio.horario);

      if (minutos != 9999 &&
          minutos < minutosAgora) {
        alertas.add(
          _AlertaCuidadorItem(
            titulo:
                '${remedio.nome} ainda não foi registrado',
            descricao:
                'Horário previsto: ${remedio.horario}',
            icon: Icons.medication_outlined,
            cor: Colors.orange,
            onTap: onAbrirRemedios,
          ),
        );
      }
    }

    // ============================================================
    // COMPROMISSOS
    // ============================================================

    for (final compromisso
        in state.compromissos) {
      final data = compromisso.data;

      if (data == null ||
          !_mesmoDia(data, agora) ||
          compromisso.status == 'cancelado' ||
          compromisso.status == 'concluido') {
        continue;
      }

      final minutos =
          _horarioEmMinutos(
        compromisso.horario,
      );

      if (minutos == 9999) {
        continue;
      }

      final diferenca =
          minutos - minutosAgora;

      if (diferenca < 0) {
        alertas.add(
          _AlertaCuidadorItem(
            titulo:
                'Compromisso possivelmente perdido',
            descricao:
                '${compromisso.titulo} • ${compromisso.horario}',
            icon:
                Icons.event_busy_outlined,
            cor: Colors.redAccent,
            onTap: onAbrirAgenda,
          ),
        );
      } else if (diferenca <= 120) {
        alertas.add(
          _AlertaCuidadorItem(
            titulo:
                'Compromisso próximo',
            descricao:
                '${compromisso.titulo} • ${compromisso.horario}',
            icon:
                Icons.event_outlined,
            cor: AppTheme.primary,
            onTap: onAbrirAgenda,
          ),
        );
      }
    }

    // ============================================================
    // CUIDADOS INTENSIVOS ATRASADOS
    // ============================================================

    for (final cuidado in state.cuidados) {
      if (!cuidado.ativo ||
          !_estaNoPeriodo(
            agora,
            cuidado.dataInicio,
            cuidado.dataFim,
          ) ||
          cuidado.concluidoEm(agora)) {
        continue;
      }

      final minutos =
          _horarioEmMinutos(
        cuidado.horario,
      );

      if (minutos != 9999 &&
          minutos < minutosAgora) {
        alertas.add(
          _AlertaCuidadorItem(
            titulo:
                'Cuidado pendente',
            descricao:
                '${cuidado.tipo} • ${cuidado.horario}',
            icon:
                Icons.health_and_safety_outlined,
            cor: Colors.orange,
          ),
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: alertas.isEmpty
              ? Colors.green.shade200
              : Colors.orange.shade200,
        ),
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
                decoration: BoxDecoration(
                  color: alertas.isEmpty
                      ? Colors.green.withOpacity(
                          0.10,
                        )
                      : Colors.orange.withOpacity(
                          0.10,
                        ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  alertas.isEmpty
                      ? Icons
                          .check_circle_outline
                      : Icons
                          .notifications_active_outlined,
                  color: alertas.isEmpty
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Atenção de hoje',
                      style:
                          GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      alertas.isEmpty
                          ? 'Nenhuma situação exige atenção agora.'
                          : '${alertas.length} ${alertas.length == 1 ? 'situação precisa' : 'situações precisam'} de atenção.',
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
            ],
          ),

          if (alertas.isNotEmpty) ...[
            const SizedBox(height: 14),

            ...alertas.take(4).map(
                  (alerta) =>
                      _AlertaCuidadorLinha(
                    alerta: alerta,
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _AlertaCuidadorItem {
  final String titulo;
  final String descricao;
  final IconData icon;
  final Color cor;
  final VoidCallback? onTap;

  const _AlertaCuidadorItem({
    required this.titulo,
    required this.descricao,
    required this.icon,
    required this.cor,
    this.onTap,
  });
}

class _AlertaCuidadorLinha
    extends StatelessWidget {
  final _AlertaCuidadorItem alerta;

  const _AlertaCuidadorLinha({
    required this.alerta,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: alerta.onTap,
      borderRadius:
          BorderRadius.circular(12),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              alerta.icon,
              size: 19,
              color: alerta.cor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    alerta.titulo,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alerta.descricao,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 10,
                      color:
                          AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (alerta.onTap != null)
              const Icon(
                Icons.chevron_right,
                size: 19,
                color:
                    AppTheme.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// TIMELINE DO CUIDADOR
// =====================================================

class _TimelineCuidador extends StatefulWidget {
  const _TimelineCuidador();

  @override
  State<_TimelineCuidador> createState() => _TimelineCuidadorState();
}

class _TimelineCuidadorState extends State<_TimelineCuidador> {
  int _filtroTimeline = 0;

  DateTime _dataSemHorario(DateTime data) =>
      DateTime(data.year, data.month, data.day);

  int _converterHorarioEmMinutos(String horario) {
    final partes = horario.split(':');
    if (partes.length != 2) return 9999;

    final hora = int.tryParse(partes[0]);
    final minuto = int.tryParse(partes[1]);

    if (hora == null ||
        minuto == null ||
        hora < 0 ||
        hora > 23 ||
        minuto < 0 ||
        minuto > 59) {
      return 9999;
    }

    return hora * 60 + minuto;
  }

  bool _estaNoPeriodo(
    DateTime dia,
    DateTime? inicio,
    DateTime? fim,
  ) {
    final data = _dataSemHorario(dia);

    final inicioValido =
        inicio == null || !_dataSemHorario(inicio).isAfter(data);

    final fimValido = fim == null || !_dataSemHorario(fim).isBefore(data);

    return inicioValido && fimValido;
  }

  List<Map<String, dynamic>> _montarAtividades({
    required AppState state,
    required DateTime hoje,
    required DateTime agora,
    required bool semanal,
  }) {
    final atividades = <Map<String, dynamic>>[];
    final inicioSemana = hoje.subtract(
      Duration(days: hoje.weekday - 1),
    );

    final quantidadeDias = semanal ? 7 : 1;

    for (int i = 0; i < quantidadeDias; i++) {
      final dia = _dataSemHorario(
        semanal ? inicioSemana.add(Duration(days: i)) : hoje,
      );

      final ehHoje = dia == hoje;
      final diaJaPassou = dia.isBefore(hoje);
      final agoraMinutos = agora.hour * 60 + agora.minute;

      // MEDICAMENTOS
      for (final remedio in state.remedios) {
        if (!_estaNoPeriodo(
          dia,
          remedio.dataInicio,
          remedio.dataFim,
        )) {
          continue;
        }

        final minutos = _converterHorarioEmMinutos(
          remedio.horario,
        );

        // O estado "tomado" só representa o dia atual.
        final tomado = ehHoje && remedio.tomado;
        final atrasado =
            ehHoje && !tomado && minutos != 9999 && minutos < agoraMinutos;

        atividades.add({
          'tipo': 'medicamento',
          'titulo': remedio.nome,
          'horario': remedio.horario,
          'minutos': minutos,
          'data': dia,
          'concluido': tomado,
          'naoRegistrado': atrasado || diaJaPassou,
          'detalhe': tomado
              ? 'Tomado'
              : (atrasado || diaJaPassou)
                  ? 'Não registrado'
                  : 'Programado',
        });
      }

      // COMPROMISSOS
      for (final compromisso in state.compromissos) {
        final dataCompromisso = compromisso.data;
        if (dataCompromisso == null) continue;

        if (_dataSemHorario(dataCompromisso) != dia) {
          continue;
        }

        if (compromisso.status == 'cancelado') continue;

        final local = compromisso.local.trim();
        final concluido = compromisso.status == 'concluido';

        atividades.add({
          'tipo': 'compromisso',
          'titulo': compromisso.titulo,
          'horario': compromisso.horario,
          'minutos': _converterHorarioEmMinutos(
            compromisso.horario,
          ),
          'data': dia,
          'concluido': concluido,
          'naoRegistrado': false,
          'detalhe': concluido
              ? 'Concluído'
              : (local.isEmpty ? 'Compromisso agendado' : local),
        });
      }

      // CUIDADOS INTENSIVOS
      for (final cuidado in state.cuidados) {
        if (!cuidado.ativo) continue;

        if (!_estaNoPeriodo(
          dia,
          cuidado.dataInicio,
          cuidado.dataFim,
        )) {
          continue;
        }

        final concluido = cuidado.concluidoEm(dia);
        final horario = cuidado.horario;

        atividades.add({
          'tipo': 'cuidado',
          'titulo': cuidado.tipo,
          'horario': horario,
          'minutos': _converterHorarioEmMinutos(horario),
          'data': dia,
          'concluido': concluido,
          'naoRegistrado': false,
          'detalhe': concluido
              ? 'Concluído'
              : (cuidado.observacao.trim().isEmpty
                  ? 'Cuidado pendente'
                  : cuidado.observacao.trim()),
          'cuidadoId': cuidado.id,
        });
      }
    }

    atividades.sort((a, b) {
      final dataA = a['data'] as DateTime;
      final dataB = b['data'] as DateTime;

      final comparacaoData = dataA.compareTo(dataB);
      if (comparacaoData != 0) return comparacaoData;

      return (a['minutos'] as int).compareTo(
        b['minutos'] as int,
      );
    });

    return atividades;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final agora = DateTime.now();
    final hoje = _dataSemHorario(agora);

    final atividades = _montarAtividades(
      state: state,
      hoje: hoje,
      agora: agora,
      semanal: _filtroTimeline == 1,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _filtroTimeline == 0
                      ? 'Linha do tempo de hoje'
                      : 'Linha do tempo da semana',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _botaoFiltro('Hoje', 0),
              const SizedBox(width: 8),
              _botaoFiltro('Esta semana', 1),
            ],
          ),
          const SizedBox(height: 16),
          if (atividades.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  _filtroTimeline == 0
                      ? 'Nenhuma atividade programada para hoje.'
                      : 'Nenhuma atividade programada para esta semana.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...List.generate(atividades.length, (index) {
              final atividade = atividades[index];
              final tipo = atividade['tipo'] as String;
              final titulo = atividade['titulo'] as String;
              final horario = atividade['horario'] as String;
              final detalhe = atividade['detalhe'] as String;
              final data = atividade['data'] as DateTime;
              final concluido = atividade['concluido'] as bool;
              final naoRegistrado =
                  atividade['naoRegistrado'] as bool? ?? false;

              final cor = concluido
                  ? Colors.green
                  : naoRegistrado
                      ? Colors.orange
                      : tipo == 'medicamento'
                          ? AppTheme.primary
                          : tipo == 'cuidado'
                              ? Colors.teal
                              : Colors.blueGrey;

              final mostrarCabecalho = _filtroTimeline == 1 &&
                  (index == 0 ||
                      !(atividades[index - 1]['data'] as DateTime)
                          .isAtSameMomentAs(data));

              final nomeDia = [
                'SEGUNDA',
                'TERÇA',
                'QUARTA',
                'QUINTA',
                'SEXTA',
                'SÁBADO',
                'DOMINGO',
              ][data.weekday - 1];

              final nomeMes = [
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
              ][data.month - 1];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mostrarCabecalho)
                    Padding(
                      padding: EdgeInsets.only(
                        top: index == 0 ? 0 : 18,
                        bottom: 10,
                      ),
                      child: Text(
                        '$nomeDia, ${data.day} DE ${nomeMes.toUpperCase()}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 48,
                        child: Column(
                          children: [
                            Text(
                              horario.isEmpty ? '--:--' : horario,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: cor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (index < atividades.length - 1 &&
                                (atividades[index + 1]['data'] as DateTime)
                                    .isAtSameMomentAs(data))
                              Container(
                                width: 2,
                                height: 48,
                                color: AppTheme.divider,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      titulo,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                        decoration: concluido
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${tipo == 'medicamento' ? 'Medicamento' : tipo == 'cuidado' ? 'Cuidado' : 'Compromisso'} • $detalhe',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: naoRegistrado
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: naoRegistrado
                                            ? Colors.orange
                                            : concluido
                                                ? Colors.green
                                                : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (concluido)
                                const Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _botaoFiltro(String texto, int valor) {
    final selecionado = _filtroTimeline == valor;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filtroTimeline = valor;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selecionado ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selecionado ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REMÉDIOS
// ============================================================

class _CuidadorRemediosTab extends StatelessWidget {
  const _CuidadorRemediosTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final paciente = state.paciente;
    final remedios = state.remedios;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7F4F2),
        elevation: 0,
        title: Text(
          'Remédios',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paciente.nome.isEmpty
                    ? 'Medicamentos do paciente'
                    : 'Medicamentos de ${paciente.nome}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              if (remedios.isEmpty)
                const _EmptyCard(
                  icon: Icons.medication_outlined,
                  texto: 'Nenhum remédio cadastrado.',
                )
              else
                ...remedios.map(
                  (remedio) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RemedioGerenciavelCard(
                      remedio: remedio,
                      onEditar: () {
                        _abrirFormularioRemedio(
                          context,
                          remedio: remedio,
                        );
                      },
                      onExcluir: () {
                        _confirmarExclusao(
                          context,
                          remedio,
                        );
                      },
                      onToggle: () async {
                        await context
                            .read<AppState>()
                            .toggleRemedio(remedio.id);
                      },
                      onConcluir: () async {
                        await context
                            .read<AppState>()
                            .toggleRemedio(remedio.id);
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _abrirFormularioRemedio(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Cadastrar remédio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirFormularioRemedio(
    BuildContext context, {
    Remedio? remedio,
  }) async {
    final resultado = await showModalBottomSheet<Remedio>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      builder: (context) {
        return _FormularioRemedioSheet(
          remedio: remedio,
        );
      },
    );

    if (resultado == null || !context.mounted) return;

    final state = context.read<AppState>();

    try {
      if (remedio == null) {
        await state.addRemedio(resultado);
      } else {
        await state.updateRemedio(resultado);
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            remedio == null
                ? 'Remédio cadastrado com sucesso.'
                : 'Remédio atualizado com sucesso.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível salvar o remédio: $e',
          ),
        ),
      );
    }
  }

  Future<void> _confirmarExclusao(
    BuildContext context,
    Remedio remedio,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir remédio'),
          content: Text(
            'Tem certeza que deseja excluir "${remedio.nome}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) return;

    try {
      await context.read<AppState>().removeRemedio(remedio.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remédio excluído com sucesso.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível excluir o remédio: $e',
          ),
        ),
      );
    }
  }
}

// ============================================================
// FORMULÁRIO DE REMÉDIO
// ============================================================

class _FormularioRemedioSheet extends StatefulWidget {
  final Remedio? remedio;

  const _FormularioRemedioSheet({
    this.remedio,
  });

  @override
  State<_FormularioRemedioSheet> createState() =>
      _FormularioRemedioSheetState();
}

class _FormularioRemedioSheetState extends State<_FormularioRemedioSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _tipoController;
  late final TextEditingController _horarioController;

  DateTime? _dataInicio;
  DateTime? _dataFim;
  bool _tomado = false;

  bool get _editando => widget.remedio != null;

  @override
  void initState() {
    super.initState();

    final remedio = widget.remedio;

    _nomeController = TextEditingController(
      text: remedio?.nome ?? '',
    );

    _tipoController = TextEditingController(
      text: remedio?.tipo ?? '',
    );

    _horarioController = TextEditingController(
      text: remedio?.horario ?? '',
    );

    _dataInicio = remedio?.dataInicio;
    _dataFim = remedio?.dataFim;
    _tomado = remedio?.tomado ?? false;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tipoController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24 + bottomInset,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Handle(),
                const SizedBox(height: 24),
                Text(
                  _editando ? 'Editar remédio' : 'Cadastrar remédio',
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _editando
                      ? 'Atualize as informações do medicamento.'
                      : 'Cadastre um medicamento para o paciente.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nomeController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nome do remédio',
                    hintText: 'Ex.: Dipirona',
                    prefixIcon: Icon(Icons.medication_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do remédio.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tipoController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    hintText: 'Ex.: Analgésico',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o tipo do remédio.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _horarioController,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: 'Horário',
                    hintText: 'Ex.: 08:00',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o horário.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _DataSelecionavel(
                  titulo: 'Data de início',
                  data: _dataInicio,
                  onSelecionar: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: _dataInicio ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (data != null) {
                      setState(() {
                        _dataInicio = data;
                      });
                    }
                  },
                  onLimpar: _dataInicio == null
                      ? null
                      : () {
                          setState(() {
                            _dataInicio = null;
                          });
                        },
                ),
                const SizedBox(height: 12),
                _DataSelecionavel(
                  titulo: 'Data de término',
                  data: _dataFim,
                  onSelecionar: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: _dataFim ?? _dataInicio ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (data != null) {
                      setState(() {
                        _dataFim = data;
                      });
                    }
                  },
                  onLimpar: _dataFim == null
                      ? null
                      : () {
                          setState(() {
                            _dataFim = null;
                          });
                        },
                ),
                if (_editando) ...[
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Remédio já tomado',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    value: _tomado,
                    onChanged: (value) {
                      setState(() {
                        _tomado = value;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _salvar,
                    child: Text(
                      _editando ? 'Salvar alterações' : 'Cadastrar remédio',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dataInicio != null &&
        _dataFim != null &&
        _dataFim!.isBefore(_dataInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A data de término não pode ser anterior à data de início.',
          ),
        ),
      );
      return;
    }

    final original = widget.remedio;

    final remedio = Remedio(
      id: original?.id ?? '',
      nome: _nomeController.text.trim(),
      tipo: _tipoController.text.trim(),
      horario: _horarioController.text.trim(),
      tomado: _tomado,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
    );

    Navigator.of(context).pop(remedio);
  }
}

// ============================================================
// COMPROMISSOS
// ============================================================

class _CuidadorCompromissosTab extends StatelessWidget {
  const _CuidadorCompromissosTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final paciente = state.paciente;
    final compromissos = state.compromissos;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7F4F2),
        elevation: 0,
        title: Text(
          'Agenda',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paciente.nome.isEmpty
                    ? 'Agenda do paciente'
                    : 'Agenda de ${paciente.nome}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              if (compromissos.isEmpty)
                const _EmptyCard(
                  icon: Icons.calendar_month_outlined,
                  texto: 'Nenhum compromisso cadastrado.',
                )
              else
                ...compromissos.map(
                  (compromisso) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CompromissoGerenciavelCard(
                      compromisso: compromisso,
                      onEditar: () {
                        _abrirFormularioCompromisso(
                          context,
                          compromisso: compromisso,
                        );
                      },
                      onExcluir: () {
                        _confirmarExclusao(
                          context,
                          compromisso,
                        );
                      },
                      onConcluir: () async {
                        final novoStatus = compromisso.status == 'concluido'
                            ? 'pendente'
                            : 'concluido';

                        try {
                          await context.read<AppState>().updateCompromisso(
                                compromisso.copyWith(
                                  status: novoStatus,
                                ),
                              );
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Não foi possível atualizar o compromisso: $e',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _abrirFormularioCompromisso(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Cadastrar compromisso'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirFormularioCompromisso(
    BuildContext context, {
    Compromisso? compromisso,
  }) async {
    final resultado = await showModalBottomSheet<Compromisso>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      builder: (context) {
        return _FormularioCompromissoSheet(
          compromisso: compromisso,
        );
      },
    );

    if (resultado == null || !context.mounted) return;

    final state = context.read<AppState>();

    try {
      if (compromisso == null) {
        await state.addCompromisso(resultado);
      } else {
        await state.updateCompromisso(resultado);
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            compromisso == null
                ? 'Compromisso cadastrado com sucesso.'
                : 'Compromisso atualizado com sucesso.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível salvar o compromisso: $e',
          ),
        ),
      );
    }
  }

  Future<void> _confirmarExclusao(
    BuildContext context,
    Compromisso compromisso,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir compromisso'),
          content: Text(
            'Tem certeza que deseja excluir '
            '"${compromisso.titulo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) return;

    try {
      await context.read<AppState>().removeCompromisso(compromisso.id);

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
        SnackBar(
          content: Text(
            'Não foi possível excluir o compromisso: $e',
          ),
        ),
      );
    }
  }
}

// ============================================================
// FORMULÁRIO DE COMPROMISSO
// ============================================================

class _FormularioCompromissoSheet extends StatefulWidget {
  final Compromisso? compromisso;

  const _FormularioCompromissoSheet({
    this.compromisso,
  });

  @override
  State<_FormularioCompromissoSheet> createState() =>
      _FormularioCompromissoSheetState();
}

class _FormularioCompromissoSheetState
    extends State<_FormularioCompromissoSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tituloController;
  late final TextEditingController _horarioController;
  late final TextEditingController _localController;

  DateTime? _data;

  bool get _editando => widget.compromisso != null;

  @override
  void initState() {
    super.initState();

    final compromisso = widget.compromisso;

    _tituloController = TextEditingController(
      text: compromisso?.titulo ?? '',
    );

    _horarioController = TextEditingController(
      text: compromisso?.horario ?? '',
    );

    _localController = TextEditingController(
      text: compromisso?.local ?? '',
    );

    _data = compromisso?.data;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _horarioController.dispose();
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24 + bottomInset,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Handle(),
                const SizedBox(height: 24),
                Text(
                  _editando ? 'Editar compromisso' : 'Cadastrar compromisso',
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _editando
                      ? 'Atualize as informações do compromisso.'
                      : 'Cadastre um compromisso para o paciente.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _tituloController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ex.: Consulta médica',
                    prefixIcon: Icon(
                      Icons.event_note_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o título.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _DataSelecionavel(
                  titulo: 'Data',
                  data: _data,
                  onSelecionar: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: _data ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (data != null) {
                      setState(() {
                        _data = data;
                      });
                    }
                  },
                  onLimpar: _data == null
                      ? null
                      : () {
                          setState(() {
                            _data = null;
                          });
                        },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _horarioController,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: 'Horário',
                    hintText: 'Ex.: 14:30',
                    prefixIcon: Icon(
                      Icons.access_time,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o horário.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _localController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Local',
                    hintText: 'Ex.: Hospital / Clínica',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o local.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _salvar,
                    child: Text(
                      _editando ? 'Salvar alterações' : 'Cadastrar compromisso',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione a data do compromisso.',
          ),
        ),
      );
      return;
    }

    final original = widget.compromisso;

    final compromisso = Compromisso(
      id: original?.id ?? '',
      titulo: _tituloController.text.trim(),
      horario: _horarioController.text.trim(),
      local: _localController.text.trim(),
      dia: _data!.day,
      mesAbrev: _mesAbreviado(_data!.month),
      diaAbrev: _diaAbreviado(_data!.weekday),
      data: _data,
    );

    Navigator.of(context).pop(compromisso);
  }

  String _mesAbreviado(int mes) {
    const meses = [
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ];

    return meses[mes - 1];
  }

  String _diaAbreviado(int dia) {
    const dias = [
      'SEG',
      'TER',
      'QUA',
      'QUI',
      'SEX',
      'SÁB',
      'DOM',
    ];

    return dias[dia - 1];
  }
}

// ============================================================
// CARD GERENCIÁVEL DE COMPROMISSO
// ============================================================

class _CompromissoGerenciavelCard extends StatelessWidget {
  final Compromisso compromisso;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  final VoidCallback onConcluir;

  const _CompromissoGerenciavelCard({
    required this.compromisso,
    required this.onEditar,
    required this.onExcluir,
    required this.onConcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: compromisso.status == 'concluido'
              ? Colors.green.shade200
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 62,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${compromisso.dia}',
                  style: GoogleFonts.poppins(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  compromisso.mesAbrev,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  compromisso.titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 15,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      compromisso.horario,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        compromisso.local,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onConcluir,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        compromisso.status == 'concluido'
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 19,
                        color: compromisso.status == 'concluido'
                            ? Colors.green
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        compromisso.status == 'concluido'
                            ? 'Feito'
                            : 'Marcar como feito',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: compromisso.status == 'concluido'
                              ? Colors.green.shade700
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (compromisso.diaAbrev.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    compromisso.diaAbrev,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (opcao) {
              if (opcao == 'editar') {
                onEditar();
              } else if (opcao == 'excluir') {
                onExcluir();
              } else if (opcao == 'concluir') {
                onConcluir();
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
              PopupMenuItem<String>(
                value: 'concluir',
                child: Row(
                  children: [
                    Icon(
                      compromisso.status == 'concluido'
                          ? Icons.undo_rounded
                          : Icons.check_circle_outline,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      compromisso.status == 'concluido'
                          ? 'Marcar como pendente'
                          : 'Marcar como feito',
                    ),
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

// ============================================================
// CARD GERENCIÁVEL DE REMÉDIO
// ============================================================

class _RemedioGerenciavelCard extends StatelessWidget {
  final Remedio remedio;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  final VoidCallback onToggle;
  final VoidCallback onConcluir;

  const _RemedioGerenciavelCard({
    required this.remedio,
    required this.onEditar,
    required this.onExcluir,
    required this.onToggle,
    required this.onConcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: remedio.tomado ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remedio.nome.isEmpty ? 'Remédio' : remedio.nome,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  remedio.tipo.isEmpty ? 'Tipo não informado' : remedio.tipo,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      remedio.horario.isEmpty
                          ? 'Horário não informado'
                          : remedio.horario,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (remedio.dataInicio != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Início: ${_formatarData(remedio.dataInicio!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                if (remedio.dataFim != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Término: ${_formatarData(remedio.dataFim!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onToggle,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        remedio.tomado
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 19,
                        color: remedio.tomado
                            ? Colors.green
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        remedio.tomado ? 'Tomado' : 'Marcar como tomado',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: remedio.tomado
                              ? Colors.green.shade700
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'editar') {
                onEditar();
              } else if (value == 'excluir') {
                onExcluir();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 10),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'excluir',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 10),
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

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();

    return '$dia/$mes/$ano';
  }
}

// ============================================================
// DATA
// ============================================================

class _DataSelecionavel extends StatelessWidget {
  final String titulo;
  final DateTime? data;
  final VoidCallback onSelecionar;
  final VoidCallback? onLimpar;

  const _DataSelecionavel({
    required this.titulo,
    required this.data,
    required this.onSelecionar,
    required this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelecionar,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppTheme.primary,
              size: 21,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data == null ? 'Não informado' : _formatarData(data!),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (onLimpar != null)
              IconButton(
                onPressed: onLimpar,
                icon: const Icon(Icons.close),
                tooltip: 'Limpar',
              )
            else
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();

    return '$dia/$mes/$ano';
  }
}

// ============================================================
// CHAT
// ============================================================
class _CuidadorChatTab extends StatefulWidget {
  const _CuidadorChatTab();

  @override
  State<_CuidadorChatTab> createState() => _CuidadorChatTabState();
}

class _CuidadorChatTabState extends State<_CuidadorChatTab> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  String _canal = 'cuidador';
  bool _enviando = false;

  String _canalFirestore(
    AppState state,
  ) {
    if (_canal == 'cuidador') {
      return state.canalCuidadorPaciente;
    }

    if (_canal == 'familia') {
      return state.canalFamilia;
    }

    if (_canal == 'milo') {
      return state.canalMiloUsuarioAtual ?? '';
    }

    if (_canal.startsWith(
      'familiar:',
    )) {
      final familiarUid = _canal.substring(
        'familiar:'.length,
      );

      return state.canalCuidadorFamiliar(
        familiarUid,
      );
    }

    return '';
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _horaAgora() {
    final t = TimeOfDay.now();

    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  bool _mesmoDia(Mensagem a, Mensagem b) {
    return a.criadaEm.year == b.criadaEm.year &&
        a.criadaEm.month == b.criadaEm.month &&
        a.criadaEm.day == b.criadaEm.day;
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  Future<void> _enviar() async {
    final texto = _input.text.trim();

    if (texto.isEmpty || _enviando) {
      return;
    }

    final state = context.read<AppState>();

    final canalFirestore = _canalFirestore(state);

    if (canalFirestore.isEmpty) {
      return;
    }

    setState(() {
      _enviando = true;
    });

    try {
      await state.addMensagem(
        canalFirestore,
        Mensagem(
          id: 'u${DateTime.now().millisecondsSinceEpoch}',
          texto: texto,
          recebido: false,
          hora: _horaAgora(),
        ),
      );

      _input.clear();
      _rolarParaFim();

      // Resposta automática somente no canal do Milo.
      if (_canal != 'milo') {
        return;
      }

      try {
        final paciente = state.paciente;
        final remedios = state.remedios;
        final compromissos = state.compromissos;

        final resposta = await GeminiService.enviarMensagem(
          mensagemUsuario: texto,
          historico: const [],
          paciente: paciente,
          remedios: remedios,
          compromissos: compromissos,
        );

        if (!mounted) return;

        await state.addMensagem(
          canalFirestore,
          Mensagem(
            id: 'a${DateTime.now().millisecondsSinceEpoch}',
            texto: resposta,
            recebido: true,
            hora: _horaAgora(),
            isMilo: true,
            remetente: 'Milo',
          ),
        );

        _rolarParaFim();
      } catch (e) {
        debugPrint(
          'Erro ao obter resposta do Milo: $e',
        );

        if (!mounted) return;

        await state.addMensagem(
          canalFirestore,
          Mensagem(
            id: 'a${DateTime.now().millisecondsSinceEpoch}',
            texto: 'Não foi possível obter a resposta do Milo agora. '
                'Tente novamente.',
            recebido: true,
            hora: _horaAgora(),
            isMilo: true,
            remetente: 'Milo',
          ),
        );

        _rolarParaFim();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível enviar a mensagem: $e',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _enviando = false;
      });
    }
  }

  void _rolarParaFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;

      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _canalChip(
    String label,
    String id,
  ) {
    final selecionado = _canal == id;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _canal = id;
          });

          _rolarParaFim();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 9,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selecionado ? const Color(0xFFFDF6E3) : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selecionado ? const Color(0xFFEFE2B6) : AppTheme.divider,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selecionado ? AppTheme.accent : AppTheme.textLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _separadorData(DateTime data) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _formatarData(data),
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _bubble(
    Mensagem mensagem,
  ) {
    final minhaMensagem = !mensagem.recebido;

    return Align(
      alignment: minhaMensagem ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: minhaMensagem ? AppTheme.primary : const Color(0xFFE0F4F1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(
              minhaMensagem ? 16 : 4,
            ),
            bottomRight: Radius.circular(
              minhaMensagem ? 4 : 16,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!minhaMensagem && mensagem.remetente != null)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 2,
                ),
                child: Text(
                  mensagem.remetente!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: mensagem.isMilo
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            Text(
              mensagem.texto,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.3,
                color: minhaMensagem ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mensagem.hora,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: minhaMensagem ? Colors.white70 : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final paciente = state.paciente;
    final canalFirestore = _canalFirestore(state);

    final mensagens = canalFirestore.isEmpty
        ? <Mensagem>[]
        : state.mensagens(
            canalFirestore,
          );

    final familiarUid =
    state.familiaresVinculados.isNotEmpty
        ? state.familiaresVinculados.first['uid'] ?? ''
        : '';
    
    final familiarNome =
    state.familiaresVinculados.isNotEmpty
        ? state.familiaresVinculados.first['nome'] ?? 'Familiar'
        : 'Familiar';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7F4F2),
        elevation: 0,
        title: Text(
          'Chat',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --------------------------------------------------
            // PACIENTE
            // --------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                16,
                24,
                16,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primary.withValues(
                      alpha: 0.10,
                    ),
                    child: Icon(
                      _canal == 'milo'
                          ? Icons.smart_toy_outlined
                          : _canal == 'familia'
                              ? Icons.groups_outlined
                              : Icons.person,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                        _canal == 'milo'
                            ? 'Milo'
                            : _canal == 'familia'
                                ? 'Família'
                                : _canal.startsWith('familiar:')
                                    ? 'Familiar'
                                    : paciente.nome.isEmpty
                                        ? 'Paciente'
                                        : paciente.nome,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      Text(
                        _canal == 'milo'
                            ? 'Assistente virtual'
                            : _canal == 'familia'
                                ? paciente.nome.isEmpty
                                    ? 'Grupo da família'
                                    : 'Grupo da família de ${paciente.nome}'
                                : _canal.startsWith('familiar:')
                                    ? familiarNome
                                    : 'Paciente',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------
// CANAIS
// --------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                4,
              ),
              child: Row(
                children: [
                  _canalChip(
                    'Paciente',
                    'cuidador',
                  ),
                  const SizedBox(width: 5),
                  _canalChip(
                    'Família',
                    'familia',
                  ),

                   if (familiarUid.isNotEmpty) ...[
      _canalChip(
        'Familiar',
        'familiar:$familiarUid',
      ),
      const SizedBox(width: 5),
    ],

                  const SizedBox(width: 5),
                  _canalChip(
                    'Milo',
                    'milo',
                  ),
                ],
              ),
            ),

            // --------------------------------------------------
            // MENSAGENS
            // --------------------------------------------------
            Expanded(
              child: mensagens.isEmpty
                  ? const _EmptyChat()
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        16,
                      ),
                      itemCount: mensagens.length,
                      itemBuilder: (context, index) {
                        final mensagem = mensagens[index];

                        final mostrarData = index == 0 ||
                            !_mesmoDia(
                              mensagens[index - 1],
                              mensagem,
                            );

                        return Column(
                          children: [
                            if (mostrarData)
                              _separadorData(
                                mensagem.criadaEm,
                              ),
                            _bubble(mensagem),
                          ],
                        );
                      },
                    ),
            ),

            // --------------------------------------------------
            // CAMPO DE MENSAGEM
            // --------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _enviar(),
                      enabled: !_enviando,
                      decoration: InputDecoration(
                        hintText: _canal == 'milo'
                            ? 'Pergunte ao Milo…'
                            : 'Digite uma mensagem...',
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            24,
                          ),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        _enviando ? AppTheme.textLight : AppTheme.primary,
                    child: IconButton(
                      onPressed: _enviando ? null : _enviar,
                      icon: _enviando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PERFIL
// ============================================================

class _CuidadorPerfilTab extends StatelessWidget {
  const _CuidadorPerfilTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final paciente = state.paciente;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7F4F2),
        elevation: 0,
        title: Text(
          'Perfil',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppTheme.primary.withValues(
                        alpha: 0.10,
                      ),
                      child: const Icon(
                        Icons.health_and_safety_outlined,
                        size: 40,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.usuarioAtualNome.isNotEmpty
                          ? state.usuarioAtualNome
                          : 'Cuidador',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Paciente vinculado',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      paciente.nome.isEmpty ? 'Nenhum paciente' : paciente.nome,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),


                _PerfilInfoCard(
  titulo: 'Função',
  icon:
      Icons.badge_outlined,
  texto: 'Cuidador',
),

const SizedBox(height: 12),

_PerfilInfoCard(
  titulo: 'Turno',
  icon:
      Icons.schedule_outlined,
  texto:
      paciente.cuidadorTurno
              .trim()
              .isEmpty
          ? 'Não informado'
          : paciente.cuidadorTurno,
),

const SizedBox(height: 12),

_PerfilInfoCard(
  titulo: 'Carga',
  icon:
      Icons.access_time_outlined,
  texto:
      paciente.cuidadorCarga
              .trim()
              .isEmpty
          ? 'Não informada'
          : paciente.cuidadorCarga,
),

const SizedBox(height: 12),

_PerfilInfoCard(
  titulo: 'Vínculo',
  icon: Icons.link,
  texto: paciente.nome.isEmpty
      ? 'Nenhum paciente vinculado.'
      : 'Você está vinculado a ${paciente.nome}.',
),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<AppState>().logout();

                    if (!context.mounted) return;

                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair da conta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PACIENTE
// ============================================================

class _PacienteResumoCard extends StatelessWidget {
  final Paciente paciente;
  final VoidCallback onTap;

  const _PacienteResumoCard({
    required this.paciente,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.primary.withValues(
              alpha: 0.18,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paciente vinculado',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    paciente.nome.isEmpty ? 'Paciente' : paciente.nome,
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    paciente.condicaoSaude.isEmpty
                        ? 'Condição não informada'
                        : paciente.condicaoSaude,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// RESUMO
// ============================================================

class _ResumoCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;
  final String descricao;
  final VoidCallback? onTap;

  const _ResumoCard({
    required this.icon,
    required this.titulo,
    required this.valor,
    required this.descricao,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppTheme.primary,
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              valor,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              descricao,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SAÚDE
// ============================================================

class _InformacoesSaudeCard extends StatelessWidget {
  final Paciente paciente;

  const _InformacoesSaudeCard({
    required this.paciente,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações importantes',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.bloodtype_outlined,
            label: 'Tipo sanguíneo',
            value: paciente.tipoSanguineo.isEmpty
                ? 'Não informado'
                : paciente.tipoSanguineo,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.warning_amber_outlined,
            label: 'Alergias',
            value: paciente.alergias.isEmpty
                ? 'Nenhuma informada'
                : paciente.alergias,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.medical_services_outlined,
            label: 'Dispositivos',
            value: paciente.dispositivos.isEmpty
                ? 'Nenhum informado'
                : paciente.dispositivos,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.notes_outlined,
            label: 'Observações',
            value: paciente.observacoes.isEmpty
                ? 'Nenhuma observação'
                : paciente.observacoes,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CARDS
// ============================================================

class _RemedioResumoCard extends StatelessWidget {
  final Remedio remedio;

  const _RemedioResumoCard({
    required this.remedio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remedio.nome.isEmpty ? 'Remédio' : remedio.nome,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  remedio.tipo.isEmpty ? 'Tipo não informado' : remedio.tipo,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      remedio.horario.isEmpty
                          ? 'Horário não informado'
                          : remedio.horario,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            remedio.tomado ? Icons.check_circle : Icons.radio_button_unchecked,
            color: remedio.tomado ? Colors.green : AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _CompromissoResumoCard extends StatelessWidget {
  final Compromisso compromisso;

  const _CompromissoResumoCard({
    required this.compromisso,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            width: 50,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${compromisso.dia}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  compromisso.mesAbrev,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  compromisso.titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  compromisso.local.isEmpty
                      ? 'Local não informado'
                      : compromisso.local,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      compromisso.horario,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
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

class _HistoricoAcompanhamentoCard extends StatefulWidget {
  const _HistoricoAcompanhamentoCard();

  @override
  State<_HistoricoAcompanhamentoCard> createState() =>
      _HistoricoAcompanhamentoCardState();
}

class _HistoricoAcompanhamentoCardState
    extends State<_HistoricoAcompanhamentoCard> {
  bool _mostrarHoje = true;
  bool _listaExpandida = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final historicos = state.historicoAtividades;
    final agora = DateTime.now();

    final inicioHoje = DateTime(
      agora.year,
      agora.month,
      agora.day,
    );

    final inicioSemana = inicioHoje.subtract(
      Duration(days: agora.weekday - 1),
    );

    // ============================================================
    // PERÍODOS
    // ============================================================

    final atividadesHoje = historicos.where((item) {
      final data = item.dataRealizada;

      if (data == null) {
        return false;
      }

      return data.year == agora.year &&
          data.month == agora.month &&
          data.day == agora.day;
    }).toList();

    final atividadesSemana = historicos.where((item) {
      final data = item.dataRealizada;

      if (data == null) {
        return false;
      }

      return !data.isBefore(inicioSemana);
    }).toList();

    final atividadesSelecionadas =
        _mostrarHoje ? atividadesHoje : atividadesSemana;

    // ============================================================
    // RESUMO DO PERÍODO SELECIONADO
    // ============================================================

    final total = atividadesSelecionadas.length;

    final concluidas = atividadesSelecionadas.where((item) {
      final realizado = item.dataRealizada;
      final previsto = item.dataPrevista;

      if (realizado == null || previsto == null) {
        return item.resultado == 'concluido';
      }

      final realizadoMinuto = DateTime(
        realizado.year,
        realizado.month,
        realizado.day,
        realizado.hour,
        realizado.minute,
      );

      final previstoMinuto = DateTime(
        previsto.year,
        previsto.month,
        previsto.day,
        previsto.hour,
        previsto.minute,
      );

      return !realizadoMinuto.isAfter(previstoMinuto);
    }).length;

    final atrasadas = atividadesSelecionadas.where((item) {
      final realizado = item.dataRealizada;
      final previsto = item.dataPrevista;

      if (realizado == null || previsto == null) {
        return item.resultado == 'atrasado';
      }

      final realizadoMinuto = DateTime(
        realizado.year,
        realizado.month,
        realizado.day,
        realizado.hour,
        realizado.minute,
      );

      final previstoMinuto = DateTime(
        previsto.year,
        previsto.month,
        previsto.day,
        previsto.hour,
        previsto.minute,
      );

      return realizadoMinuto.isAfter(previstoMinuto);
    }).length;

    // Adesão representa a proporção de atividades
    // realizadas no horário.
    final adesao = total == 0 ? 0 : ((concluidas / total) * 100).round();

    final adesaoPorDia = List.generate(
  7,
  (index) {
    final dia = inicioSemana.add(
      Duration(days: index),
    );

    final itensDia =
        historicos.where((item) {
      final realizada =
          item.dataRealizada;

      if (realizada == null) {
        return false;
      }

      return realizada.year ==
              dia.year &&
          realizada.month ==
              dia.month &&
          realizada.day ==
              dia.day;
    }).toList();

    if (itensDia.isEmpty) {
      return 0;
    }

    final noHorario =
        itensDia.where((item) {
      final realizado =
          item.dataRealizada;
      final previsto =
          item.dataPrevista;

      if (realizado == null ||
          previsto == null) {
        return item.resultado ==
            'concluido';
      }

      return !realizado.isAfter(
        previsto,
      );
    }).length;

    return ((noHorario /
                itensDia.length) *
            100)
        .round();
  },
);

    // ============================================================
    // LISTA
    // ============================================================

    final atividadesExibidas = [...atividadesSelecionadas];

    atividadesExibidas.sort(
      (a, b) =>
          (b.dataRealizada ?? b.data).compareTo(a.dataRealizada ?? a.data),
    );

    // ============================================================
    // TÍTULOS DO PERÍODO
    // ============================================================

    final tituloPeriodo = _mostrarHoje ? 'Hoje' : 'Esta semana';

    final subtituloPeriodo = _mostrarHoje
        ? 'Resumo das atividades de hoje'
        : 'Resumo das atividades da semana';

    // ============================================================
    // CARD
    // ============================================================

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // CABEÇALHO
          // ======================================================

          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights_outlined,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Histórico e acompanhamento',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtituloPeriodo,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ======================================================
          // RESUMO
          // ======================================================

          Row(
            children: [
              Expanded(
                child: _ResumoHistoricoItem(
                  valor: '$total',
                  titulo: 'Atividades',
                  icone: Icons.list_alt_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ResumoHistoricoItem(
                  valor: '$concluidas',
                  titulo: 'No horário',
                  icone: Icons.check_circle_outline,
                  cor: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ResumoHistoricoItem(
                  valor: '$atrasadas',
                  titulo: 'Atrasadas',
                  icone: Icons.schedule_outlined,
                  cor: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ======================================================
          // ADESÃO
          // ======================================================

          Row(
            children: [
              Expanded(
                child: Text(
                  'Adesão $tituloPeriodo',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              Text(
                '$adesao%',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: adesao / 100,
              minHeight: 7,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(
                AppTheme.primary,
              ),
            ),
          ),

          if (!_mostrarHoje) ...[
  const SizedBox(height: 20),

  Text(
    'Adesão ao longo da semana',
    style: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppTheme.textPrimary,
    ),
  ),

  const SizedBox(height: 12),

  _HistoricoAdesaoGrafico(
    valores: adesaoPorDia,
  ),
],

          const SizedBox(height: 18),

          // ======================================================
          // ABAS
          // ======================================================

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _mostrarHoje = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _mostrarHoje
                            ? AppTheme.surface
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _mostrarHoje
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'Hoje',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _mostrarHoje
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _mostrarHoje = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: !_mostrarHoje
                            ? AppTheme.surface
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !_mostrarHoje
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'Esta semana',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: !_mostrarHoje
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ======================================================
          // LISTA DE ATIVIDADES
          // ======================================================

          Row(
            children: [
              Expanded(
                child: Text(
                  _mostrarHoje ? 'Atividades de hoje' : 'Atividades da semana',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _listaExpandida = !_listaExpandida;
                  });
                },
                icon: Icon(
                  _listaExpandida ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.primary,
                ),
                tooltip: _listaExpandida ? 'Recolher' : 'Expandir',
              ),
            ],
          ),

          if (_listaExpandida) ...[
            const SizedBox(height: 4),
            if (atividadesExibidas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: Text(
                  _mostrarHoje
                      ? 'Nenhuma atividade registrada hoje.'
                      : 'Nenhuma atividade registrada nesta semana.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              )
            else
              ...atividadesExibidas.map(
                (item) => _HistoricoAtividadeItem(
                  item: item,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _HistoricoAdesaoGrafico
    extends StatelessWidget {
  final List<int> valores;

  const _HistoricoAdesaoGrafico({
    required this.valores,
  });

  @override
  Widget build(BuildContext context) {
    const dias = [
      'Seg',
      'Ter',
      'Qua',
      'Qui',
      'Sex',
      'Sáb',
      'Dom',
    ];

    return SizedBox(
      height: 145,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: List.generate(
          7,
          (index) {
            final valor =
                valores[index].clamp(0, 100);

            return Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                child: Column(
                  children: [
                    Text(
                      '$valor%',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: Container(
                        width: 22,
                        alignment:
                            Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          color:
                              Colors.grey.shade100,
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child:
                            FractionallySizedBox(
                          heightFactor:
                              valor / 100,
                          widthFactor: 1,
                          alignment:
                              Alignment.bottomCenter,
                          child: Container(
                            decoration:
                                BoxDecoration(
                              color:
                                  AppTheme.primary,
                              borderRadius:
                                  BorderRadius.circular(
                                8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dias[index],
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color:
                            AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AcompanhamentoCognitivoCard extends StatelessWidget {
  const _AcompanhamentoCognitivoCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final resultados = state.resultadosAtividadesCognitivas;

    if (resultados.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.psychology_outlined,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Acompanhamento cognitivo',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Nenhuma atividade cognitiva realizada ainda.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final agora = DateTime.now();

    // ============================================================
    // RESULTADOS DE HOJE
    // ============================================================

    final resultadosHoje = resultados.where((resultado) {
      return resultado.data.year == agora.year &&
          resultado.data.month == agora.month &&
          resultado.data.day == agora.day;
    }).toList();

    // ============================================================
    // RESULTADOS DOS ÚLTIMOS 7 DIAS
    // ============================================================

    final inicioPeriodo = DateTime(
      agora.year,
      agora.month,
      agora.day,
    ).subtract(const Duration(days: 6));

    final resultados7Dias = resultados.where((resultado) {
      return !resultado.data.isBefore(inicioPeriodo) &&
          !resultado.data.isAfter(agora);
    }).toList();

    final totalHoje = resultadosHoje.length;
    final total7Dias = resultados7Dias.length;

    // ============================================================
    // MÉDIA DE HOJE
    // ============================================================

    final mediaHoje = resultadosHoje.isEmpty
        ? 0.0
        : resultadosHoje.fold<double>(
              0,
              (total, item) => total + item.pontuacao,
            ) /
            resultadosHoje.length;

    // ============================================================
    // MÉDIA DOS ÚLTIMOS 7 DIAS
    // ============================================================

    final media7Dias = resultados7Dias.isEmpty
        ? 0.0
        : resultados7Dias.fold<double>(
              0,
              (total, item) => total + item.pontuacao,
            ) /
            resultados7Dias.length;

    // ============================================================
    // TEMPO MÉDIO DOS ÚLTIMOS 7 DIAS
    // ============================================================

    final mediaTempo7Dias = resultados7Dias.isEmpty
        ? 0.0
        : resultados7Dias.fold<double>(
              0,
              (total, item) => total + item.tempoSegundos,
            ) /
            resultados7Dias.length;

    // ============================================================
    // ORDENAÇÃO
    // ============================================================

    final resultadosOrdenados = [...resultados7Dias]
      ..sort((a, b) => a.data.compareTo(b.data));

    final ultimosResultados = [...resultadosOrdenados]
      ..sort((a, b) => b.data.compareTo(a.data));

    final ultimos5 = ultimosResultados.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // CABEÇALHO
          // ======================================================

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acompanhamento cognitivo',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Hoje e últimos 7 dias',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ======================================================
          // HOJE
          // ======================================================

          Text(
            'Hoje',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 10),

          if (resultadosHoje.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Nenhuma atividade cognitiva realizada hoje.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _CognitivoResumoItem(
                    valor: '$totalHoje',
                    titulo: 'Atividades',
                    icone: Icons.extension_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CognitivoResumoItem(
                    valor: '${mediaHoje.toStringAsFixed(0)}%',
                    titulo: 'Média',
                    icone: Icons.star_outline,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 22),

          // ======================================================
          // ÚLTIMOS 7 DIAS
          // ======================================================

          Text(
            'Últimos 7 dias',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _CognitivoResumoItem(
                  valor: '$total7Dias',
                  titulo: 'Atividades',
                  icone: Icons.extension_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CognitivoResumoItem(
                  valor: '${media7Dias.toStringAsFixed(0)}%',
                  titulo: 'Pontuação média',
                  icone: Icons.star_outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CognitivoResumoItem(
                  valor: _formatarTempo(
                    mediaTempo7Dias.round(),
                  ),
                  titulo: 'Tempo médio',
                  icone: Icons.timer_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ======================================================
          // GRÁFICO
          // ======================================================

          Text(
            'Evolução nos últimos 7 dias',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 180,
            width: double.infinity,
            child: resultados7Dias.length < 2
                ? Center(
                    child: Text(
                      'Realize mais atividades para visualizar a evolução.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  )
                : _CognitivoGrafico(
                    resultados: resultadosOrdenados,
                  ),
          ),

          const SizedBox(height: 24),

          // ======================================================
          // ÚLTIMAS ATIVIDADES
          // ======================================================

          Text(
            'Últimas atividades',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          if (ultimos5.isEmpty)
            Text(
              'Nenhuma atividade nos últimos 7 dias.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            )
          else
            ...ultimos5.map(
              (resultado) => _CognitivoResultadoItem(
                resultado: resultado,
              ),
            ),
        ],
      ),
    );
  }

  String _formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segundosRestantes = segundos % 60;

    if (minutos == 0) {
      return '${segundosRestantes}s';
    }

    return '${minutos}min';
  }
}

class _CognitivoResumoItem extends StatelessWidget {
  final String valor;
  final String titulo;
  final IconData icone;

  const _CognitivoResumoItem({
    required this.valor,
    required this.titulo,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            icone,
            size: 20,
            color: AppTheme.primary,
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CognitivoGrafico extends StatelessWidget {
  final List<AtividadeCognitivaResultado> resultados;

  const _CognitivoGrafico({
    required this.resultados,
  });

  @override
  Widget build(BuildContext context) {
    if (resultados.length < 2) {
      return Center(
        child: Text(
          'Realize mais uma atividade para visualizar a evolução.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    return CustomPaint(
      painter: _CognitivoGraficoPainter(
        resultados: resultados,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _CognitivoGraficoPainter extends CustomPainter {
  final List<AtividadeCognitivaResultado> resultados;

  _CognitivoGraficoPainter({
    required this.resultados,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const esquerda = 32.0;
    const direita = 8.0;
    const topo = 10.0;
    const baixo = 28.0;

    final larguraGrafico = size.width - esquerda - direita;

    final alturaGrafico = size.height - topo - baixo;

    // Linhas horizontais de referência.
    for (int i = 0; i <= 4; i++) {
      final y = topo + alturaGrafico - (alturaGrafico * i / 4);

      canvas.drawLine(
        Offset(esquerda, y),
        Offset(size.width - direita, y),
        gridPaint,
      );

      final valor = (i * 25).toString();

      textPainter.text = TextSpan(
        text: '$valor',
        style: GoogleFonts.poppins(
          fontSize: 9,
          color: AppTheme.textSecondary,
        ),
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          0,
          y - textPainter.height / 2,
        ),
      );
    }

    // Linha da evolução.
    final path = Path();

    for (int i = 0; i < resultados.length; i++) {
      final resultado = resultados[i];

      final x = resultados.length == 1
          ? esquerda
          : esquerda + larguraGrafico * i / (resultados.length - 1);

      final pontuacao = resultado.pontuacao.clamp(0, 100);

      final y = topo + alturaGrafico - (alturaGrafico * pontuacao / 100);

      final ponto = Offset(x, y);

      if (i == 0) {
        path.moveTo(
          ponto.dx,
          ponto.dy,
        );
      } else {
        path.lineTo(
          ponto.dx,
          ponto.dy,
        );
      }
    }

    paint.color = AppTheme.primary;

    canvas.drawPath(
      path,
      paint,
    );

    // Pontos.
    final pontoPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppTheme.primary;

    for (int i = 0; i < resultados.length; i++) {
      final pontuacao = resultados[i].pontuacao.clamp(0, 100);

      final x = resultados.length == 1
          ? esquerda
          : esquerda + larguraGrafico * i / (resultados.length - 1);

      final y = topo + alturaGrafico - (alturaGrafico * pontuacao / 100);

      canvas.drawCircle(
        Offset(x, y),
        4,
        pontoPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _CognitivoGraficoPainter oldDelegate,
  ) {
    return oldDelegate.resultados != resultados;
  }
}

class _CognitivoResultadoItem extends StatelessWidget {
  final AtividadeCognitivaResultado resultado;

  const _CognitivoResultadoItem({
    required this.resultado,
  });

  @override
  Widget build(BuildContext context) {
    final pontuacao =
    resultado.pontuacao;

final String desempenho;
final Color corDesempenho;
final IconData iconeDesempenho;

if (pontuacao >= 80) {
  desempenho =
      'Bom desempenho';
  corDesempenho =
      Colors.green;
  iconeDesempenho =
      Icons.trending_up;
} else if (pontuacao >= 60) {
  desempenho =
      'Desempenho estável';
  corDesempenho =
      Colors.orange;
  iconeDesempenho =
      Icons.trending_flat;
} else {
  desempenho =
      'Acompanhar evolução';
  corDesempenho =
      Colors.redAccent;
  iconeDesempenho =
      Icons.trending_down;
}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.extension_outlined,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resultado.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${resultado.acertos} acertos · '
                  '${resultado.erros} erros · '
                  '${_formatarTempo(resultado.tempoSegundos)}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 7),

Row(
  children: [
    Icon(
      iconeDesempenho,
      size: 14,
      color: corDesempenho,
    ),
    const SizedBox(width: 4),
    Text(
      desempenho,
      style: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: corDesempenho,
      ),
    ),
  ],
),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${resultado.pontuacao}%',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              Text(
                _formatarData(resultado.data),
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segundosRestantes = segundos % 60;

    if (minutos == 0) {
      return '${segundosRestantes}s';
    }

    return '${minutos}min ${segundosRestantes}s';
  }

String _formatarData(
  DateTime data,
) {
  return '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')} '
      '${data.hour.toString().padLeft(2, '0')}:'
      '${data.minute.toString().padLeft(2, '0')}';
}
}

class _HistoricoAtividadeItem extends StatelessWidget {
  final Historico item;

  const _HistoricoAtividadeItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final atrasado = item.dataRealizada != null &&
        item.dataPrevista != null &&
        DateTime(
          item.dataRealizada!.year,
          item.dataRealizada!.month,
          item.dataRealizada!.day,
          item.dataRealizada!.hour,
          item.dataRealizada!.minute,
        ).isAfter(
          DateTime(
            item.dataPrevista!.year,
            item.dataPrevista!.month,
            item.dataPrevista!.day,
            item.dataPrevista!.hour,
            item.dataPrevista!.minute,
          ),
        );

    final realizado = item.dataRealizada;
    final previsto = item.dataPrevista;

    int? atrasoMinutos;

    if (realizado != null && previsto != null) {
      final realizadoMinuto = DateTime(
        realizado.year,
        realizado.month,
        realizado.day,
        realizado.hour,
        realizado.minute,
      );

      final previstoMinuto = DateTime(
        previsto.year,
        previsto.month,
        previsto.day,
        previsto.hour,
        previsto.minute,
      );

      final diferenca = realizadoMinuto.difference(previstoMinuto).inMinutes;

      if (diferenca > 0) {
        atrasoMinutos = diferenca;
      }
    }

    final cor = atrasado ? Colors.orange : Colors.green;

    final icone =
        atrasado ? Icons.schedule_outlined : Icons.check_circle_outline;

    String tipo;

    switch (item.tipo) {
      case 'medicamento':
        tipo = 'Medicamento';
        break;
      case 'compromisso':
        tipo = 'Compromisso';
        break;
      case 'cuidado':
        tipo = 'Cuidado';
        break;
      default:
        tipo = 'Atividade';
    }

    String formatarHora(DateTime? data) {
      if (data == null) {
        return '--:--';
      }

      return '${data.hour.toString().padLeft(2, '0')}:'
          '${data.minute.toString().padLeft(2, '0')}';
    }

    String textoStatus;

    if (atrasado) {
      if (atrasoMinutos != null) {
        final horas = atrasoMinutos ~/ 60;
        final minutos = atrasoMinutos % 60;

        if (horas > 0) {
          textoStatus =
              'Atrasado em ${horas}h${minutos > 0 ? ' ${minutos}min' : ''}';
        } else {
          textoStatus = 'Atrasado em ${minutos}min';
        }
      } else {
        textoStatus = 'Atrasado';
      }
    } else {
      textoStatus = 'Realizado no horário';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cor.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 20,
            color: cor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.titulo,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      tipo,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: cor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (previsto != null)
                  Text(
                    'Previsto: ${formatarHora(previsto)}'
                    '${realizado != null ? '  •  Realizado: ${formatarHora(realizado)}' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                const SizedBox(height: 3),
                Text(
                  textoStatus,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: cor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoHistoricoItem extends StatelessWidget {
  final String valor;
  final String titulo;
  final IconData icone;
  final Color? cor;

  const _ResumoHistoricoItem({
    required this.valor,
    required this.titulo,
    required this.icone,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final corFinal = cor ?? AppTheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: corFinal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icone,
            size: 18,
            color: corFinal,
          ),
          const SizedBox(height: 5),
          Text(
            valor,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SOS
// ============================================================

class _SosCard extends StatelessWidget {
  final bool ativado;
  final String? status;
  final DateTime? dataHora;

  const _SosCard({
    required this.ativado,
    required this.status,
    required this.dataHora,
  });

  String _formatarDataHora(DateTime data) {
    final agora = DateTime.now();

    final mesmaData = agora.year == data.year &&
        agora.month == data.month &&
        agora.day == data.day;

    final hora = '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}';

    if (mesmaData) {
      return 'Hoje, $hora';
    }

    final dia = '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';

    return '$dia, $hora';
  }

  String _textoStatus() {
    switch (status) {
      case 'acionado':
        return 'Ativo';
      case 'atendido':
        return 'Atendido';
      case 'finalizado':
        return 'Encerrado';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final temHistorico = dataHora != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ativado ? Colors.red.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: ativado
                  ? Colors.red.withValues(alpha: 0.10)
                  : AppTheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sos,
              color: ativado ? Colors.red : AppTheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ativado ? 'SOS acionado' : 'Nenhum SOS ativo',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ativado ? Colors.red.shade700 : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ativado
                      ? 'O paciente acionou uma emergência.'
                      : temHistorico
                          ? 'Último SOS: ${_formatarDataHora(dataHora!)}'
                          : 'Não há emergência registrada.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (temHistorico) ...[
                  const SizedBox(height: 6),
                  Text(
                    _textoStatus(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ativado
                          ? Colors.red.shade700
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DADOS DO PACIENTE
// ============================================================

class _DadosPacienteSheet extends StatelessWidget {
  final Paciente paciente;

  const _DadosPacienteSheet({
    required this.paciente,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              24,
              12,
              24,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Handle(),
                const SizedBox(height: 24),
                Text(
                  'Dados do paciente',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  paciente.nome,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _SecaoDados(
                  titulo: 'Informações pessoais',
                  children: [
                    _CampoPaciente(
                      titulo: 'Nome',
                      valor: paciente.nome,
                    ),
                    _CampoPaciente(
                      titulo: 'Idade',
                      valor: '${paciente.idade} anos',
                    ),
                    _CampoPaciente(
                      titulo: 'Data de nascimento',
                      valor: paciente.dataNascimento,
                    ),
                    _CampoPaciente(
                      titulo: 'Sexo',
                      valor: paciente.sexo,
                    ),
                    _CampoPaciente(
                      titulo: 'Estado civil',
                      valor: paciente.estadoCivil,
                    ),
                    _CampoPaciente(
                      titulo: 'Telefone',
                      valor: paciente.telefone,
                    ),
                    _CampoPaciente(
                      titulo: 'Endereço',
                      valor: paciente.endereco,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SecaoDados(
                  titulo: 'Informações de saúde',
                  children: [
                    _CampoPaciente(
                      titulo: 'Tipo sanguíneo',
                      valor: paciente.tipoSanguineo,
                    ),
                    _CampoPaciente(
                      titulo: 'Condição de saúde',
                      valor: paciente.condicaoSaude,
                    ),
                    _CampoPaciente(
                      titulo: 'Alergias',
                      valor: paciente.alergias,
                    ),
                    _CampoPaciente(
                      titulo: 'Dispositivos',
                      valor: paciente.dispositivos,
                    ),
                    _CampoPaciente(
                      titulo: 'Observações',
                      valor: paciente.observacoes,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SecaoDados(
                  titulo: 'Informações do cuidador',
                  children: [
                    _CampoPaciente(
                      titulo: 'Cuidador',
                      valor: paciente.cuidadorNome,
                    ),
                    _CampoPaciente(
                      titulo: 'Turno',
                      valor: paciente.cuidadorTurno,
                    ),
                    _CampoPaciente(
                      titulo: 'Carga',
                      valor: paciente.cuidadorCarga,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SecaoDados(
                  titulo: 'Documentos',
                  children: [
                    _CampoPaciente(
                      titulo: 'CPF',
                      valor: paciente.cpf,
                    ),
                    _CampoPaciente(
                      titulo: 'RG/CIN',
                      valor: paciente.rgCin,
                    ),
                    _CampoPaciente(
                      titulo: 'Órgão expedidor',
                      valor: paciente.orgaoExpedidor,
                    ),
                    _CampoPaciente(
                      titulo: 'Data de emissão',
                      valor: paciente.dataEmissaoDocumento,
                    ),
                    _CampoPaciente(
                      titulo: 'Cartão SUS',
                      valor: paciente.cartaoSus,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// AUXILIARES
// ============================================================

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _SecaoDados extends StatelessWidget {
  final String titulo;
  final List<Widget> children;

  const _SecaoDados({
    required this.titulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _CampoPaciente extends StatelessWidget {
  final String titulo;
  final String valor;

  const _CampoPaciente({
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final valorFinal = valor.trim().isEmpty ? 'Não informado' : valor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            valorFinal,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: AppTheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _EmptyCard({
    required this.icon,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 34,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 54,
              color: AppTheme.primary.withValues(
                alpha: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma mensagem ainda',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Comece uma conversa com o paciente.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerfilInfoCard extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final String texto;

  const _PerfilInfoCard({
    required this.titulo,
    required this.icon,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  texto,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CuidadosIntensivosCard extends StatelessWidget {
  final Paciente paciente;

  const _CuidadosIntensivosCard({
    required this.paciente,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cuidados = state.cuidados;

    final hoje = DateTime.now();

    final dataHoje = DateTime(
      hoje.year,
      hoje.month,
      hoje.day,
    );

    final cuidadosHoje = cuidados.where((cuidado) {
      if (cuidado.dataInicio == null || cuidado.dataFim == null) {
        return false;
      }

      final inicio = DateTime(
        cuidado.dataInicio!.year,
        cuidado.dataInicio!.month,
        cuidado.dataInicio!.day,
      );

      final fim = DateTime(
        cuidado.dataFim!.year,
        cuidado.dataFim!.month,
        cuidado.dataFim!.day,
      );

      return !inicio.isAfter(dataHoje) && !fim.isBefore(dataHoje);
    }).toList();

    final proximosCuidados = cuidados.where((cuidado) {
      if (cuidado.dataInicio == null) {
        return false;
      }

      final inicio = DateTime(
        cuidado.dataInicio!.year,
        cuidado.dataInicio!.month,
        cuidado.dataInicio!.day,
      );

      return inicio.isAfter(dataHoje);
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.health_and_safety_outlined,
                color: AppTheme.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cuidados intensivos',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _mostrarFormularioCuidado(context);
                },
                icon: const Icon(Icons.add),
                tooltip: 'Adicionar cuidado',
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (cuidados.isEmpty)
            Text(
              'Nenhum cuidado intensivo configurado.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            )
          else ...[
            // ==================================================
            // HOJE
            // ==================================================
            if (cuidadosHoje.isNotEmpty) ...[
              Text(
                'Hoje',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...cuidadosHoje.map(
                (cuidado) {
                  final concluido = cuidado.concluidoEm(dataHoje);

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      concluido
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: concluido ? Colors.green : AppTheme.primary,
                    ),
                    title: Text(
                      cuidado.tipo,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration:
                            concluido ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      '${cuidado.horario}'
                      '${concluido ? ' • Feito' : ' • Pendente'}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                            concluido ? Colors.green : AppTheme.textSecondary,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!concluido)
                          IconButton(
                            onPressed: () async {
                              await context.read<AppState>().concluirCuidado(
                                    cuidado.id,
                                    dataHoje,
                                  );
                            },
                            icon: const Icon(Icons.check),
                            tooltip: 'Marcar como feito',
                          ),
                        PopupMenuButton<String>(
                          onSelected: (opcao) {
                            if (opcao == 'editar') {
                              _mostrarFormularioCuidado(
                                context,
                                cuidado: cuidado,
                              );
                            }

                            if (opcao == 'excluir') {
                              final appState = context.read<AppState>();

                              Future.microtask(() async {
                                await appState.removeCuidado(
                                  cuidado.id,
                                );
                              });
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),
                            PopupMenuItem(
                              value: 'excluir',
                              child: Text('Excluir'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],

            // ==================================================
            // PRÓXIMOS CUIDADOS
            // ==================================================
            if (proximosCuidados.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Próximos cuidados',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...proximosCuidados.map(
                (cuidado) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppTheme.primary,
                  ),
                  title: Text(
                    cuidado.tipo,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Começa em '
                    '${_formatarData(cuidado.dataInicio!)}'
                    ' • ${cuidado.horario}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (opcao) {
                      if (opcao == 'editar') {
                        _mostrarFormularioCuidado(
                          context,
                          cuidado: cuidado,
                        );
                      }

                      if (opcao == 'excluir') {
                        final appState = context.read<AppState>();

                        Future.microtask(() async {
                          await appState.removeCuidado(
                            cuidado.id,
                          );
                        });
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'editar',
                        child: Text('Editar'),
                      ),
                      PopupMenuItem(
                        value: 'excluir',
                        child: Text('Excluir'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _mostrarFormularioCuidado(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar cuidado'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  void _mostrarFormularioCuidado(
    BuildContext context, {
    Cuidado? cuidado,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FormularioCuidadoSheet(
        cuidado: cuidado,
      ),
    );
  }
}

class _FormularioCuidadoSheet extends StatefulWidget {
  final Cuidado? cuidado;

  const _FormularioCuidadoSheet({
    this.cuidado,
  });

  @override
  State<_FormularioCuidadoSheet> createState() =>
      _FormularioCuidadoSheetState();
}

class _FormularioCuidadoSheetState extends State<_FormularioCuidadoSheet> {
  final _observacaoController = TextEditingController();

  String _tipoSelecionado = 'Banho e higiene';
  DateTime? _dataInicio;
  DateTime? _dataFim;
  TimeOfDay? _horario;

  @override
  void initState() {
    super.initState();

    final cuidado = widget.cuidado;

    if (cuidado != null) {
      _tipoSelecionado = cuidado.tipo;

      _dataInicio = cuidado.dataInicio;
      _dataFim = cuidado.dataFim;

      _observacaoController.text = cuidado.observacao;

      final partes = cuidado.horario.split(':');

      if (partes.length == 2) {
        final hora = int.tryParse(partes[0]);

        final minuto = int.tryParse(
          partes[1].replaceAll(RegExp(r'[^0-9]'), ''),
        );

        if (hora != null && minuto != null) {
          _horario = TimeOfDay(
            hour: hora,
            minute: minuto,
          );
        }
      }
    }
  }

  final List<String> _tipos = [
    'Banho e higiene',
    'Alimentação',
    'Troca de fraldas',
    'Fisioterapia',
    'Hidratação',
    'Medicação / cuidados prescritos',
    'Acompanhamento / atividade',
  ];

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarHorario() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (horario != null) {
      setState(() {
        _horario = horario;
      });
    }
  }

  Future<void> _selecionarDataInicio() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataInicio ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (data != null) {
      setState(() {
        _dataInicio = data;

        if (_dataFim != null && _dataFim!.isBefore(data)) {
          _dataFim = data;
        }
      });
    }
  }

  Future<void> _selecionarDataFim() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataFim ?? _dataInicio ?? DateTime.now(),
      firstDate: _dataInicio ?? DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (data != null) {
      setState(() {
        _dataFim = data;
      });
    }
  }

  Future<void> _salvar() async {
    if (_dataInicio == null || _dataFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione a data de início e a data de fim.',
          ),
        ),
      );
      return;
    }

    if (_horario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um horário.'),
        ),
      );
      return;
    }

    final horarioFormatado = _horario!.format(context);
    final cuidadoExistente = widget.cuidado;

    if (cuidadoExistente == null) {
      final cuidado = Cuidado(
        tipo: _tipoSelecionado,
        horario: horarioFormatado,
        frequencia: 'diaria',
        dataInicio: _dataInicio,
        dataFim: _dataFim,
        observacao: _observacaoController.text.trim(),
      );

      await context.read<AppState>().addCuidado(cuidado);
    } else {
      final cuidadoAtualizado = cuidadoExistente.copyWith(
        tipo: _tipoSelecionado,
        horario: horarioFormatado,
        frequencia: 'diaria',
        dataInicio: _dataInicio,
        dataFim: _dataFim,
        observacao: _observacaoController.text.trim(),
      );

      await context.read<AppState>().updateCuidado(cuidadoAtualizado);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.cuidado == null ? 'Adicionar cuidado' : 'Editar cuidado',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tipo de cuidado',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _tipoSelecionado,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: _tipos.map(
                (tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  );
                },
              ).toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() {
                    _tipoSelecionado = valor;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Data de início',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _selecionarDataInicio,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  _dataInicio == null
                      ? 'Selecionar data de início'
                      : '${_dataInicio!.day.toString().padLeft(2, '0')}/'
                          '${_dataInicio!.month.toString().padLeft(2, '0')}/'
                          '${_dataInicio!.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Data de fim',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _selecionarDataFim,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  _dataFim == null
                      ? 'Selecionar data de fim'
                      : '${_dataFim!.day.toString().padLeft(2, '0')}/'
                          '${_dataFim!.month.toString().padLeft(2, '0')}/'
                          '${_dataFim!.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Horário',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _selecionarHorario,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                child: Text(
                  _horario == null
                      ? 'Selecionar horário'
                      : _horario!.format(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Observação',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _observacaoController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ex.: exercícios conforme orientação',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _salvar,
                child: Text(
                  widget.cuidado == null
                      ? 'Salvar cuidado'
                      : 'Salvar alterações',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
