import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../services/gemini_service.dart';
import '../../models/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class FamiliarHome extends StatefulWidget {
  const FamiliarHome({super.key});

  @override
  State<FamiliarHome> createState() => _FamiliarHomeState();
}

class _FamiliarHomeState extends State<FamiliarHome> {
  int _indiceSelecionado = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final paciente = state.paciente;

    final telas = [
      _InicioFamiliarTab(
        paciente: paciente,
        remedios: state.remedios,
        compromissos: state.compromissos,
        sosAtivado: state.sosAtivado,
        onAbrirRemedios: () {
          setState(() {
            _indiceSelecionado = 1;
          });
        },
        onAbrirAgenda: () {
          setState(() {
            _indiceSelecionado = 2;
          });
        },
        onAbrirSaude: () {
          _mostrarResumoSaude(context, paciente);
        },
        onAbrirHistorico: () {
          setState(() {
            _indiceSelecionado = 3;
          });
        },
        onAbrirChat: () {
          setState(() {
            _indiceSelecionado = 4;
          });
        },
      ),

      // ============================================================
      // REMÉDIOS
      // ============================================================

      _RemediosFamiliarTab(
        remedios: state.remedios,
      ),

      // ============================================================
      // AGENDA
      // ============================================================

      _AgendaFamiliarTab(
        compromissos: state.compromissos,
      ),

      // ============================================================
      // HISTÓRICO
      // ============================================================

      _HistoricoFamiliarTab(
        historicos: state.historico,
      ),

      // ============================================================
      // CHAT
      // ============================================================

      const _FamiliarChatTab(),

      // ============================================================
      // PERFIL
      // ============================================================

      _PerfilFamiliarTab(
        paciente: paciente,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _indiceSelecionado == 0
              ? 'Milo'
              : _tituloAba(_indiceSelecionado),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: _indiceSelecionado == 0
                ? AppTheme.primary
                : AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(
              Icons.logout,
              color: AppTheme.textPrimary,
            ),
            onPressed: () async {
              await context.read<AppState>().logout();

              if (!context.mounted) return;

              context.go('/login');
            },
          ),
        ],
      ),

      // ============================================================
      // CONTEÚDO
      // ============================================================

      body: SafeArea(
        child: IndexedStack(
          index: _indiceSelecionado,
          children: telas,
        ),
      ),

      // ============================================================
      // NAVEGAÇÃO INFERIOR
      // ============================================================

      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSelecionado,
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.primary.withValues(
          alpha: 0.12,
        ),
        onDestinationSelected: (index) {
          setState(() {
            _indiceSelecionado = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(
              Icons.home_outlined,
            ),
            selectedIcon: const Icon(
              Icons.home,
              color: AppTheme.primary,
            ),
            label: 'Início',
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.medication_outlined,
            ),
            selectedIcon: const Icon(
              Icons.medication,
              color: AppTheme.primary,
            ),
            label: 'Remédios',
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.calendar_month_outlined,
            ),
            selectedIcon: const Icon(
              Icons.calendar_month,
              color: AppTheme.primary,
            ),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.history_outlined,
            ),
            selectedIcon: const Icon(
              Icons.history,
              color: AppTheme.primary,
            ),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.chat_bubble_outline,
            ),
            selectedIcon: const Icon(
              Icons.chat_bubble,
              color: AppTheme.primary,
            ),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.person_outline,
            ),
            selectedIcon: const Icon(
              Icons.person,
              color: AppTheme.primary,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  String _tituloAba(int indice) {
    switch (indice) {
      case 1:
        return 'Remédios';
      case 2:
        return 'Agenda';
      case 3:
        return 'Histórico';
      case 4:
        return 'Chat';
      case 5:
        return 'Perfil';
      default:
        return 'HumanaCare';
    }
  }
  // ================================================================
  // RESUMO DE SAÚDE
  // ================================================================

  void _mostrarResumoSaude(
    BuildContext context,
    Paciente paciente,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Handle(),
                const SizedBox(height: 12),
                Text(
                  'Resumo de saúde',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 18),
                _InformacaoSaude(
                  titulo: 'Tipo sanguíneo',
                  valor: paciente.tipoSanguineo,
                  icon: Icons.bloodtype_outlined,
                ),
                _InformacaoSaude(
                  titulo: 'Condições de saúde',
                  valor: paciente.condicaoSaude,
                  icon: Icons.favorite_outline,
                ),
                _InformacaoSaude(
                  titulo: 'Alergias',
                  valor: paciente.alergias,
                  icon: Icons.warning_amber_outlined,
                ),
                _InformacaoSaude(
                  titulo: 'Dispositivos',
                  valor: paciente.dispositivos,
                  icon: Icons.devices_other_outlined,
                ),
                _InformacaoSaude(
                  titulo: 'Observações',
                  valor: paciente.observacoes,
                  icon: Icons.notes_outlined,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// INÍCIO
// ============================================================

class _InicioFamiliarTab extends StatelessWidget {
  final Paciente paciente;
  final List<Remedio> remedios;
  final List<Compromisso> compromissos;
  final bool sosAtivado;
  final VoidCallback onAbrirRemedios;
  final VoidCallback onAbrirAgenda;
  final VoidCallback onAbrirSaude;
  final VoidCallback onAbrirHistorico;
  final VoidCallback onAbrirChat;

  const _InicioFamiliarTab({
    required this.paciente,
    required this.remedios,
    required this.compromissos,
    required this.sosAtivado,
    required this.onAbrirRemedios,
    required this.onAbrirAgenda,
    required this.onAbrirSaude,
    required this.onAbrirHistorico,
    required this.onAbrirChat,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => state.inicializar(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${state.usuarioAtualNome.trim().isNotEmpty ? state.usuarioAtualNome : 'Familiar'}!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Acompanhe a rotina, a saúde e os cuidados de ${paciente.nome.isEmpty ? 'quem você ama' : paciente.nome}.',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            _PacienteCard(paciente: paciente),
            const SizedBox(height: 18),
            _ResumoRotinaFamiliarCard(
              remedios: remedios,
              compromissos: compromissos,
              cuidados: state.cuidados,
              onAbrirRemedios: onAbrirRemedios,
              onAbrirAgenda: onAbrirAgenda,
            ),
            const SizedBox(height: 22),
            _SecaoHomeFamiliar(
              titulo: 'Informações de saúde',
              subtitulo: 'Dados importantes para o acompanhamento do paciente.',
            ),
            const SizedBox(height: 10),
            _ResumoSaudeCard(
              paciente: paciente,
              onTap: onAbrirSaude,
            ),
            const SizedBox(height: 22),
            _SecaoHomeFamiliar(
              titulo: 'Cuidados intensivos',
              subtitulo:
                  'Veja quais cuidados estão ativos, seus horários e o status de hoje.',
            ),
            const SizedBox(height: 10),
            _CuidadosResumoFamiliar(
              cuidados: state.cuidados,
            ),
            const SizedBox(height: 22),
            _SecaoHomeFamiliar(
              titulo: 'Linha do tempo',
              subtitulo:
                  'Acompanhe realizados, pendentes, atrasos e próximos registros.',
            ),
            const SizedBox(height: 10),
            _ResumoDiaFamiliar(
              remedios: remedios,
              compromissos: compromissos,
            ),
            const SizedBox(height: 22),
            _SecaoHomeFamiliar(
              titulo: 'Histórico de acompanhamento',
              subtitulo:
                  'Últimos registros de medicamentos, compromissos e cuidados.',
            ),
            const SizedBox(height: 10),
            _HistoricoResumoHomeFamiliar(
              onAbrirHistorico: onAbrirHistorico,
            ),
            const SizedBox(height: 22),
            _SecaoHomeFamiliar(
              titulo: 'Acompanhamento cognitivo',
              subtitulo:
                  'Desempenho de hoje, últimos 7 dias e atividades recentes.',
            ),
            const SizedBox(height: 10),
            _CognitivoResumoFamiliar(
              resultados: state.resultadosAtividadesCognitivas,
            ),
            const SizedBox(height: 22),
            _SecaoHomeFamiliar(
              titulo: 'Atividades do dia',
              subtitulo: 'Indicadores rápidos da rotina diária.',
            ),
            const SizedBox(height: 10),
            _AtividadesResumoFamiliar(
              coposAgua: state.coposAguaHoje,
              passos: state.passosHoje,
              atividadesConcluidas: state.atividadesConcluidasHoje,
            ),
            const SizedBox(height: 22),
            _SecaoHomeFamiliar(
              titulo: 'Emergência / SOS',
              subtitulo:
                  'Acompanhe o status do último acionamento de emergência.',
            ),
            const SizedBox(height: 10),
            _SosFamiliarCard(
              ativado: sosAtivado,
              dataHora: state.sosDataHora,
              status: state.sosStatus ?? '',
            ),
            const SizedBox(height: 22),
            _SecaoHomeFamiliar(
              titulo: 'Acesso rápido',
              subtitulo: 'Consulte os detalhes das principais áreas.',
            ),
            const SizedBox(height: 10),
            _ActionCard(
              icon: Icons.medication_outlined,
              title: 'Remédios',
              description: 'Veja medicamentos, horários, período e status.',
              onTap: onAbrirRemedios,
            ),
            const SizedBox(height: 10),
            _ActionCard(
              icon: Icons.calendar_month_outlined,
              title: 'Agenda',
              description: 'Veja compromissos, datas, locais e status.',
              onTap: onAbrirAgenda,
            ),
            const SizedBox(height: 10),
            _ActionCard(
              icon: Icons.history_outlined,
              title: 'Histórico',
              description: 'Veja previsto × realizado e identifique atrasos.',
              onTap: onAbrirHistorico,
            ),
            const SizedBox(height: 10),
            _ActionCard(
              icon: Icons.chat_bubble_outline,
              title: 'Chat',
              description: 'Converse pelos canais Cuidador, Família e Milo.',
              onTap: onAbrirChat,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecaoHomeFamiliar extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  const _SecaoHomeFamiliar({
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitulo,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            color: AppTheme.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _ResumoRotinaFamiliarCard extends StatelessWidget {
  final List<Remedio> remedios;
  final List<Compromisso> compromissos;
  final List<Cuidado> cuidados;
  final VoidCallback onAbrirRemedios;
  final VoidCallback onAbrirAgenda;

  const _ResumoRotinaFamiliarCard({
    required this.remedios,
    required this.compromissos,
    required this.cuidados,
    required this.onAbrirRemedios,
    required this.onAbrirAgenda,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final hoje = _famDataSemHorario(DateTime.now());

    final remediosHoje = remedios.where((remedio) {
      return _famDataDentroDoPeriodo(
        hoje,
        remedio.dataInicio,
        remedio.dataFim,
      );
    }).toList();

    final compromissosHoje = compromissos.where((compromisso) {
      final data = compromisso.data;
      return data != null && _famMesmaData(data, hoje);
    }).toList();

    final cuidadosHoje = cuidados.where((cuidado) {
      return cuidado.ativo &&
          _famDataDentroDoPeriodo(
            hoje,
            cuidado.dataInicio,
            cuidado.dataFim,
          );
    }).toList();

    final remediosTomados = remediosHoje
        .where((r) => _famRemedioTomadoNoDia(state, r, hoje))
        .length;
    final compromissosConcluidos = compromissosHoje
        .where((c) => c.status.toLowerCase() == 'concluido')
        .length;
    final cuidadosConcluidos =
        cuidadosHoje.where((c) => c.concluidoEm(hoje)).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.today_outlined,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo de hoje',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      _famFormatarDataCompleta(hoje),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ResumoRotinaMiniFamiliar(
                  titulo: 'Remédios',
                  valor: '${remediosTomados}/${remediosHoje.length}',
                  detalhe: remediosHoje.isEmpty
                      ? 'Nenhum hoje'
                      : '${remediosHoje.length - remediosTomados} pendente(s)',
                  icon: Icons.medication_outlined,
                  onTap: onAbrirRemedios,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ResumoRotinaMiniFamiliar(
                  titulo: 'Agenda',
                  valor: '${compromissosConcluidos}/${compromissosHoje.length}',
                  detalhe: compromissosHoje.isEmpty
                      ? 'Sem agenda'
                      : '${compromissosHoje.length - compromissosConcluidos} pendente(s)',
                  icon: Icons.calendar_month_outlined,
                  onTap: onAbrirAgenda,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ResumoRotinaMiniFamiliar(
                  titulo: 'Cuidados',
                  valor: '${cuidadosConcluidos}/${cuidadosHoje.length}',
                  detalhe: cuidadosHoje.isEmpty
                      ? 'Nenhum hoje'
                      : '${cuidadosHoje.length - cuidadosConcluidos} pendente(s)',
                  icon: Icons.favorite_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResumoRotinaMiniFamiliar extends StatelessWidget {
  final String titulo;
  final String valor;
  final String detalhe;
  final IconData icon;
  final VoidCallback? onTap;

  const _ResumoRotinaMiniFamiliar({
    required this.titulo,
    required this.valor,
    required this.detalhe,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(height: 6),
          Text(
            valor,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            detalhe,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 8.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: child,
    );
  }
}

class _HistoricoResumoHomeFamiliar extends StatelessWidget {
  final VoidCallback onAbrirHistorico;

  const _HistoricoResumoHomeFamiliar({
    required this.onAbrirHistorico,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final itens = <Historico>[
      ...state.historico,
      ...state.historicoAtividades,
    ];

    itens.sort((a, b) {
      final dataA = a.dataRealizada ?? a.dataPrevista ?? a.data;
      final dataB = b.dataRealizada ?? b.dataPrevista ?? b.data;
      return dataB.compareTo(dataA);
    });

    final realizados = itens.where((item) => item.dataRealizada != null).length;
    final atrasados = itens.where((item) {
      final prevista = item.dataPrevista;
      final realizada = item.dataRealizada;
      return prevista != null &&
          realizada != null &&
          realizada.isAfter(prevista);
    }).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _ResumoHistoricoMiniFamiliar(
                  valor: '${itens.length}',
                  titulo: 'Registros',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ResumoHistoricoMiniFamiliar(
                  valor: '$realizados',
                  titulo: 'Realizados',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ResumoHistoricoMiniFamiliar(
                  valor: '$atrasados',
                  titulo: 'Atrasados',
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          if (itens.isEmpty)
            Text(
              'Nenhum registro de acompanhamento disponível.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            )
          else
            ...itens.take(3).map(
                  (item) => _HistoricoLinhaHomeFamiliar(
                    historico: item,
                  ),
                ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onAbrirHistorico,
              icon: const Icon(Icons.history_outlined, size: 17),
              label: const Text('Ver histórico completo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoHistoricoMiniFamiliar extends StatelessWidget {
  final String valor;
  final String titulo;

  const _ResumoHistoricoMiniFamiliar({
    required this.valor,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 7),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          Text(
            titulo,
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

class _HistoricoLinhaHomeFamiliar extends StatelessWidget {
  final Historico historico;

  const _HistoricoLinhaHomeFamiliar({
    required this.historico,
  });

  @override
  Widget build(BuildContext context) {
    final prevista = historico.dataPrevista;
    final realizada = historico.dataRealizada;
    final atrasado =
        prevista != null && realizada != null && realizada.isAfter(prevista);
    final pendente = realizada == null;

    final cor = atrasado
        ? Colors.orange
        : pendente
            ? AppTheme.textSecondary
            : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Icon(
            pendente
                ? Icons.schedule_outlined
                : atrasado
                    ? Icons.warning_amber_outlined
                    : Icons.check_circle_outline,
            size: 18,
            color: cor,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  historico.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  pendente
                      ? 'Pendente / não realizado'
                      : atrasado
                          ? 'Realizado com atraso'
                          : 'Realizado',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: cor,
                    fontWeight: FontWeight.w600,
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

class _RemediosFamiliarTab extends StatelessWidget {
  final List<Remedio> remedios;

  const _RemediosFamiliarTab({
    required this.remedios,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async {
          await Future<void>.delayed(
            const Duration(milliseconds: 300),
          );
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24,
          ),
          children: [
            Text(
              'Remédios',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Acompanhe os medicamentos do paciente.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (remedios.isEmpty)
              const _EmptyCard(
                icon: Icons.medication_outlined,
                message: 'Nenhum medicamento cadastrado.',
              )
            else
              ...remedios.map(
                (remedio) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: _RemedioFamiliarCard(
                    remedio: remedio,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RemedioFamiliarCard extends StatelessWidget {
  final Remedio remedio;

  const _RemedioFamiliarCard({
    required this.remedio,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final hoje = _famDataSemHorario(DateTime.now());
    final tomadoHoje = _famRemedioTomadoNoDia(state, remedio, hoje);

    final periodo = _famFormatarPeriodo(
      remedio.dataInicio,
      remedio.dataFim,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      remedio.nome,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (remedio.tipo.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        remedio.tipo,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusRemedio(tomado: tomadoHoje),
            ],
          ),
          const SizedBox(height: 13),
          _DetalheLeituraFamiliar(
            icon: Icons.schedule_outlined,
            label: 'Horário',
            value: remedio.horario,
          ),
          _DetalheLeituraFamiliar(
            icon: Icons.date_range_outlined,
            label: 'Período',
            value: periodo,
          ),
          _DetalheLeituraFamiliar(
            icon: tomadoHoje
                ? Icons.check_circle_outline
                : Icons.schedule_outlined,
            label: 'Status de hoje',
            value: tomadoHoje ? 'Tomado' : 'Pendente',
            valueColor: tomadoHoje ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 5),
          Text(
            'O perfil familiar acompanha os registros; alterações ficam com os perfis responsáveis.',
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              color: AppTheme.textLight,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRemedio extends StatelessWidget {
  final bool tomado;

  const _StatusRemedio({
    required this.tomado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: tomado
            ? Colors.green.withValues(alpha: 0.10)
            : Colors.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        tomado ? 'Tomado' : 'Pendente',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: tomado ? Colors.green : Colors.orange,
        ),
      ),
    );
  }
}

// ============================================================
// AGENDA
// ============================================================

class _AgendaFamiliarTab extends StatelessWidget {
  final List<Compromisso> compromissos;

  const _AgendaFamiliarTab({
    required this.compromissos,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async {
          await Future<void>.delayed(
            const Duration(milliseconds: 300),
          );
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24,
          ),
          children: [
            Text(
              'Agenda',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Acompanhe consultas e próximos compromissos.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (compromissos.isEmpty)
              const _EmptyCard(
                icon: Icons.calendar_month_outlined,
                message: 'Nenhum compromisso cadastrado.',
              )
            else
              ...compromissos.map(
                (compromisso) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: _CompromissoFamiliarCard(
                    compromisso: compromisso,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompromissoFamiliarCard extends StatelessWidget {
  final Compromisso compromisso;

  const _CompromissoFamiliarCard({
    required this.compromisso,
  });

  @override
  Widget build(BuildContext context) {
    final status = compromisso.status.trim().toLowerCase();
    final concluido = status == 'concluido';
    final cancelado = status == 'cancelado';

    final corStatus = concluido
        ? Colors.green
        : cancelado
            ? AppTheme.textSecondary
            : Colors.orange;

    final textoStatus = concluido
        ? 'Concluído'
        : cancelado
            ? 'Cancelado'
            : 'Pendente';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      compromisso.dia.toString().padLeft(2, '0'),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      compromisso.mesAbrev,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compromisso.titulo,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _DetalheLeituraFamiliar(
                      icon: Icons.schedule_outlined,
                      label: 'Horário',
                      value: compromisso.horario,
                    ),
                    if (compromisso.local.trim().isNotEmpty)
                      _DetalheLeituraFamiliar(
                        icon: Icons.location_on_outlined,
                        label: 'Local',
                        value: compromisso.local,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _DetalheLeituraFamiliar(
            icon: concluido
                ? Icons.check_circle_outline
                : cancelado
                    ? Icons.cancel_outlined
                    : Icons.schedule_outlined,
            label: 'Status',
            value: textoStatus,
            valueColor: corStatus,
          ),
        ],
      ),
    );
  }
}

class _HistoricoFamiliarTab extends StatelessWidget {
  final List<Historico> historicos;

  const _HistoricoFamiliarTab({
    required this.historicos,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final itens = <Historico>[
      ...historicos,
      ...state.historicoAtividades,
    ];

    itens.sort((a, b) {
      final dataA = a.dataRealizada ?? a.dataPrevista ?? a.data;
      final dataB = b.dataRealizada ?? b.dataPrevista ?? b.data;
      return dataB.compareTo(dataA);
    });

    final realizados = itens.where((item) => item.dataRealizada != null).length;
    final atrasados = itens.where((item) {
      final prevista = item.dataPrevista;
      final realizada = item.dataRealizada;
      return prevista != null &&
          realizada != null &&
          realizada.isAfter(prevista);
    }).length;
    final pendentes = itens.where((item) => item.dataRealizada == null).length;

    return SafeArea(
      child: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => state.inicializar(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(
              'Histórico de acompanhamento',
              style: GoogleFonts.poppins(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Medicamentos, compromissos e cuidados com horário previsto × realizado.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ResumoHistoricoMiniFamiliar(
                    valor: '$realizados',
                    titulo: 'Realizados',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ResumoHistoricoMiniFamiliar(
                    valor: '$atrasados',
                    titulo: 'Atrasados',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ResumoHistoricoMiniFamiliar(
                    valor: '$pendentes',
                    titulo: 'Pendentes',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (itens.isEmpty)
              const _EmptyCard(
                icon: Icons.history_outlined,
                message: 'Nenhum acontecimento registrado.',
              )
            else
              ...itens.map(
                (historico) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HistoricoCard(historico: historico),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoricoCard extends StatelessWidget {
  final Historico historico;

  const _HistoricoCard({
    required this.historico,
  });

  String _tipoFormatado() {
    switch (historico.tipo.toLowerCase()) {
      case 'medicamento':
        return 'Medicamento';
      case 'compromisso':
        return 'Compromisso';
      case 'cuidado':
        return 'Cuidado';
      default:
        return historico.tipo.trim().isEmpty ? 'Atividade' : historico.tipo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prevista = historico.dataPrevista;
    final realizada = historico.dataRealizada;

    final atrasado =
        prevista != null && realizada != null && realizada.isAfter(prevista);
    final pendente = realizada == null;

    final cor = pendente
        ? AppTheme.textSecondary
        : atrasado
            ? Colors.orange
            : Colors.green;

    String status;
    if (pendente) {
      status = 'Pendente / não realizado';
    } else if (atrasado) {
      final diferenca = realizada.difference(prevista!);
      status = diferenca.inHours > 0
          ? 'Atrasado em ${diferenca.inHours}h ${diferenca.inMinutes % 60}min'
          : 'Atrasado em ${diferenca.inMinutes}min';
    } else {
      status = 'Realizado no horário';
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              pendente
                  ? Icons.schedule_outlined
                  : atrasado
                      ? Icons.warning_amber_outlined
                      : Icons.check_circle_outline,
              color: cor,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  historico.titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _tipoFormatado(),
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (historico.descricao.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    historico.descricao,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: AppTheme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 7),
                Text(
                  'Data: ${_famFormatarData(realizada ?? prevista ?? historico.data)}',
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (prevista != null || realizada != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Previsto: ${_famFormatarHora(prevista)}  •  '
                    'Realizado: ${_famFormatarHora(realizada)}',
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 5),
                Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
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

class _PerfilFamiliarTab extends StatelessWidget {
  final Paciente paciente;

  const _PerfilFamiliarTab({
    required this.paciente,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          24,
        ),
        children: [
          Center(
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 42,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'Perfil do familiar',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              'Acompanhando ${paciente.nome.isEmpty ? 'paciente' : paciente.nome}',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.divider,
              ),
            ),
            child: Column(
              children: [
                _PerfilInfoRow(
                  icon: Icons.favorite_outline,
                  titulo: 'Paciente vinculado',
                  valor: paciente.nome.isEmpty ? 'Paciente' : paciente.nome,
                ),
                const Divider(height: 24),
                _PerfilInfoRow(
                  icon: Icons.cake_outlined,
                  titulo: 'Idade',
                  valor: '${paciente.idade} anos',
                ),
                const Divider(height: 24),
                _PerfilInfoRow(
                  icon: Icons.people_outline,
                  titulo: 'Tipo de acesso',
                  valor: 'Acompanhamento familiar',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(
                alpha: 0.07,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.primary,
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'O acesso do familiar é voltado para acompanhamento. '
                    'Alterações de medicamentos, compromissos e dados '
                    'do paciente ficam restritas aos perfis responsáveis.',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
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

// ============================================================
// CHAT DO FAMILIAR
// ============================================================

class _FamiliarChatTab extends StatefulWidget {
  const _FamiliarChatTab();

  @override
  State<_FamiliarChatTab> createState() => _FamiliarChatTabState();
}

class _FamiliarChatTabState extends State<_FamiliarChatTab> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  String _canal = 'cuidador';
  bool _enviando = false;

  String _canalFirestore(
    AppState state,
  ) {
    switch (_canal) {
      case 'cuidador':
        return state.canalCuidadorUsuarioAtual ?? '';

      case 'paciente':
        return state.canalPacienteFamiliarUsuarioAtual ?? '';

      case 'familia':
        return state.canalFamilia;

      case 'milo':
        return state.canalMiloUsuarioAtual ?? '';

      default:
        return '';
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _horaAgora() {
    final agora = DateTime.now();

    return '${agora.hour.toString().padLeft(2, '0')}:'
        '${agora.minute.toString().padLeft(2, '0')}';
  }

  bool _mesmoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String _tituloCanal() {
    switch (_canal) {
      case 'cuidador':
        return 'Cuidador';

      case 'familia':
        return 'Família';

      case 'milo':
        return 'Milo';

      case 'paciente':
        return 'Paciente';

      default:
        return 'Chat';
    }
  }

  String _subtituloCanal(AppState state) {
    switch (_canal) {
      case 'cuidador':
        final nomeCuidador = state.cuidadorNome;

        if (nomeCuidador != null && nomeCuidador.trim().isNotEmpty) {
          return 'Você e $nomeCuidador';
        }

        return 'Você e o cuidador';

      case 'paciente':
        final nomePaciente = state.paciente.nome.trim();

        return nomePaciente.isEmpty
            ? 'Você e o paciente'
            : 'Você e $nomePaciente';

      case 'familia':
        return 'Conversa da família';

      case 'milo':
        return 'Você e o Milo';

      default:
        return '';
    }
  }

  IconData _iconeCanal() {
    switch (_canal) {
      case 'cuidador':
        return Icons.health_and_safety_outlined;

      case 'familia':
        return Icons.groups_outlined;

      case 'milo':
        return Icons.smart_toy_outlined;

      case 'paciente':
        return Icons.person_outline;

      default:
        return Icons.chat_bubble_outline;
    }
  }

  Future<void> _enviar() async {
    final texto = _input.text.trim();

    if (texto.isEmpty || _enviando) {
      return;
    }

    final state = context.read<AppState>();

    final mensagemUsuario = Mensagem(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      texto: texto,
      recebido: false,
      hora: _horaAgora(),
    );

    _input.clear();

    final canalFirestore = _canalFirestore(state);

    if (canalFirestore.isEmpty) {
      return;
    }

    await state.addMensagem(
      canalFirestore,
      mensagemUsuario,
    );

    _rolarParaFim();

    // Apenas o canal Milo gera resposta automática.
    if (_canal != 'milo') {
      return;
    }

    setState(() {
      _enviando = true;
    });

    try {
      final resposta = await GeminiService.enviarMensagem(
        mensagemUsuario: texto,
        historico: const [],
        paciente: state.paciente,
        remedios: state.remedios,
        compromissos: state.compromissos,
      );

      await state.addMensagem(
        canalFirestore,
        Mensagem(
          id: 'm_${DateTime.now().microsecondsSinceEpoch}',
          texto: resposta,
          recebido: true,
          hora: _horaAgora(),
          isMilo: true,
          remetente: 'Milo',
        ),
      );

      _rolarParaFim();
    } catch (_) {
      await state.addMensagem(
        canalFirestore,
        Mensagem(
          id: 'm_${DateTime.now().microsecondsSinceEpoch}',
          texto: 'Não consegui processar a mensagem agora. Tente novamente.',
          recebido: true,
          hora: _horaAgora(),
          isMilo: true,
          remetente: 'Milo',
        ),
      );

      _rolarParaFim();
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }

  void _rolarParaFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) {
        return;
      }

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
  IconData icon,
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
          color: selecionado
              ? const Color(0xFFFDF6E3)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado
                ? const Color(0xFFEFE2B6)
                : AppTheme.divider,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selecionado
                ? AppTheme.accent
                : AppTheme.textLight,
          ),
        ),
      ),
    ),
  );
}

  Widget _separadorData(DateTime data) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            _formatarData(data),
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bubble(Mensagem mensagem) {
    final minhaMensagem = !mensagem.recebido;

    return Align(
      alignment: minhaMensagem ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(
          bottom: 7,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: minhaMensagem ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(
              minhaMensagem ? 15 : 4,
            ),
            bottomRight: Radius.circular(
              minhaMensagem ? 4 : 15,
            ),
          ),
          border: minhaMensagem
              ? null
              : Border.all(
                  color: AppTheme.textSecondary.withOpacity(0.08),
                ),
        ),
        child: Column(
          crossAxisAlignment:
              minhaMensagem ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!minhaMensagem &&
                mensagem.remetente != null &&
                mensagem.remetente!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 3,
                ),
                child: Text(
                  mensagem.remetente!,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            Text(
              mensagem.texto,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: minhaMensagem ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              mensagem.hora,
              style: GoogleFonts.poppins(
                fontSize: 8,
                color: minhaMensagem
                    ? Colors.white.withOpacity(0.75)
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final canalFirestore = _canalFirestore(state);

        final mensagens = canalFirestore.isEmpty
            ? <Mensagem>[]
            : state.mensagens(
                canalFirestore,
              );

        return Scaffold(
          backgroundColor: AppTheme.background,

          // NÃO colocamos outro AppBar aqui,
          // porque o FamiliarHome já possui o AppBar principal.
          body: Column(
            children: [
              // =====================================================
              // CABEÇALHO DA CONVERSA
              // =====================================================

              Container(
                width: double.infinity,
                color: AppTheme.background,
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  10,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _iconeCanal(),
                            color: AppTheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tituloCanal(),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _subtituloCanal(state),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _canalChip(
                          'Cuidador',
                          'cuidador',
                          Icons.health_and_safety_outlined,
                        ),
                        const SizedBox(width: 5),
                        _canalChip(
                          'Paciente',
                          'paciente',
                          Icons.person_outline,
                        ),
                        const SizedBox(width: 5),
                        _canalChip(
                          'Família',
                          'familia',
                          Icons.groups_outlined,
                        ),
                        const SizedBox(width: 5),
                        _canalChip(
                          'Milo',
                          'milo',
                          Icons.smart_toy_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // =====================================================
              // MENSAGENS
              // =====================================================

              Expanded(
                child: mensagens.isEmpty
                    ? const _EmptyChatFamiliar()
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          12,
                        ),
                        itemCount: mensagens.length,
                        itemBuilder: (context, index) {
                          final mensagem = mensagens[index];

                          final mostrarData = index == 0 ||
                              !_mesmoDia(
                                mensagens[index - 1].criadaEm,
                                mensagem.criadaEm,
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

              // =====================================================
              // CAMPO DE MENSAGEM
              // =====================================================

              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    8,
                    12,
                    8,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          minLines: 1,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: _canal == 'milo'
                                ? 'Pergunte ao Milo...'
                                : 'Digite uma mensagem...',
                            border: InputBorder.none,
                            filled: false,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: _enviando ? null : _enviar,
                        child: Container(
                          width: 43,
                          height: 43,
                          decoration: BoxDecoration(
                            color: _enviando
                                ? AppTheme.textSecondary
                                : AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: _enviando
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  size: 19,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FamiliarMessageBubble extends StatelessWidget {
  final Mensagem mensagem;
  final String nomeRecebido;

  const _FamiliarMessageBubble({
    required this.mensagem,
    required this.nomeRecebido,
  });

  @override
  Widget build(BuildContext context) {
    final eu = !mensagem.recebido;
    final nome = mensagem.remetente?.trim().isNotEmpty == true
        ? mensagem.remetente!
        : eu
            ? 'Você'
            : nomeRecebido;

    return Align(
      alignment: eu ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: eu ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(eu ? 16 : 4),
            bottomRight: Radius.circular(eu ? 4 : 16),
          ),
          border: eu ? null : Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment:
              eu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              nome,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: eu
                    ? Colors.white.withValues(alpha: 0.82)
                    : AppTheme.primary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              mensagem.texto,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: eu ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mensagem.hora,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: eu
                    ? Colors.white.withValues(alpha: 0.72)
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChatFamiliar extends StatelessWidget {
  const _EmptyChatFamiliar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 34,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma mensagem ainda',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Envie uma mensagem para começar '
              'a conversa com o paciente.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
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
// CARDS DA HOME
// ============================================================

class _PacienteCard extends StatelessWidget {
  final Paciente paciente;

  const _PacienteCard({
    required this.paciente,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.divider,
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
              Icons.favorite_border,
              size: 28,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 14),
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${paciente.idade} anos',
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
    );
  }
}

class _ResumoSaudeCard extends StatelessWidget {
  final Paciente paciente;
  final VoidCallback onTap;

  const _ResumoSaudeCard({
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetalheLeituraFamiliar(
              icon: Icons.bloodtype_outlined,
              label: 'Tipo sanguíneo',
              value: paciente.tipoSanguineo.trim().isEmpty
                  ? 'Não informado'
                  : paciente.tipoSanguineo,
            ),
            _DetalheLeituraFamiliar(
              icon: Icons.medical_information_outlined,
              label: 'Condição de saúde',
              value: paciente.condicaoSaude.trim().isEmpty
                  ? 'Não informada'
                  : paciente.condicaoSaude,
            ),
            _DetalheLeituraFamiliar(
              icon: Icons.warning_amber_outlined,
              label: 'Alergias',
              value: paciente.alergias.trim().isEmpty
                  ? 'Nenhuma informada'
                  : paciente.alergias,
            ),
            _DetalheLeituraFamiliar(
              icon: Icons.devices_outlined,
              label: 'Dispositivos',
              value: paciente.dispositivos.trim().isEmpty
                  ? 'Nenhum informado'
                  : paciente.dispositivos,
            ),
            if (paciente.observacoes.trim().isNotEmpty)
              _DetalheLeituraFamiliar(
                icon: Icons.notes_outlined,
                label: 'Observações',
                value: paciente.observacoes,
              ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Toque para ver o resumo completo',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoRemediosCard extends StatelessWidget {
  final List<Remedio> remedios;
  final int total;
  final VoidCallback onTap;

  const _ResumoRemediosCard({
    required this.remedios,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ActionCard(
      icon: Icons.medication_outlined,
      title: 'Remédios',
      description: total == 0
          ? 'Nenhum medicamento cadastrado.'
          : '$total medicamento${total == 1 ? '' : 's'} cadastrado${total == 1 ? '' : 's'}.',
      onTap: onTap,
    );
  }
}

class _ResumoAgendaCard extends StatelessWidget {
  final List<Compromisso> compromissos;
  final int total;
  final VoidCallback onTap;

  const _ResumoAgendaCard({
    required this.compromissos,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ActionCard(
      icon: Icons.calendar_month_outlined,
      title: 'Agenda',
      description: total == 0
          ? 'Nenhum compromisso cadastrado.'
          : '$total compromisso${total == 1 ? '' : 's'} agendado${total == 1 ? '' : 's'}.',
      onTap: onTap,
    );
  }
}

class _SosFamiliarCard extends StatelessWidget {
  final bool ativado;
  final DateTime? dataHora;
  final String status;

  const _SosFamiliarCard({
    required this.ativado,
    required this.dataHora,
    required this.status,
  });

  String _formatarDataHora(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano às $hora:$minuto';
  }

  String _statusFormatado() {
    final valor = status.trim().toLowerCase();

    switch (valor) {
      case 'atendido':
        return 'Atendido';
      case 'finalizado':
      case 'resolvido':
      case 'encerrado':
        return 'Finalizado';
      case 'cancelado':
        return 'Cancelado';
      case 'acionado':
      case 'ativo':
        return 'Acionado';
      default:
        return ativado
            ? 'Acionado'
            : valor.isEmpty
                ? 'Nenhum alerta ativo'
                : status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusAtual = _statusFormatado();
    final acionado = statusAtual == 'Acionado';
    final atendido = statusAtual == 'Atendido';

    final cor = acionado
        ? AppTheme.error
        : atendido
            ? Colors.orange
            : Colors.green;

    final titulo = acionado
        ? 'SOS acionado'
        : atendido
            ? 'SOS em atendimento'
            : dataHora == null
                ? 'SOS'
                : 'Último SOS';

    final descricao = dataHora == null
        ? 'Nenhum acionamento registrado.'
        : acionado
            ? 'Emergência acionada em ${_formatarDataHora(dataHora!)}.'
            : atendido
                ? 'O acionamento de ${_formatarDataHora(dataHora!)} está em atendimento.'
                : 'Último acionamento em ${_formatarDataHora(dataHora!)}.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              acionado
                  ? Icons.sos_outlined
                  : atendido
                      ? Icons.health_and_safety_outlined
                      : Icons.check_circle_outline,
              color: cor,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descricao,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Status: $statusAtual',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppTheme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// COMPONENTES AUXILIARES
// ============================================================

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyCard({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 38,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InformacaoSaude extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icon;

  const _InformacaoSaude({
    required this.titulo,
    required this.valor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final valorFinal = valor.isEmpty ? 'Não informado' : valor;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 10),
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
                const SizedBox(height: 2),
                Text(
                  valorFinal,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
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

class _PerfilInfoRow extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;

  const _PerfilInfoRow({
    required this.icon,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 21,
          color: AppTheme.primary,
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
              const SizedBox(height: 2),
              Text(
                valor,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: AppTheme.divider,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _ResumoDiaFamiliar extends StatefulWidget {
  final List<Remedio> remedios;
  final List<Compromisso> compromissos;

  const _ResumoDiaFamiliar({
    required this.remedios,
    required this.compromissos,
  });

  @override
  State<_ResumoDiaFamiliar> createState() => _ResumoDiaFamiliarState();
}

class _ResumoDiaFamiliarState extends State<_ResumoDiaFamiliar> {
  int _filtro = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final agora = DateTime.now();
    final hoje = _famDataSemHorario(agora);

    final inicioSemana = hoje.subtract(Duration(days: hoje.weekday - 1));
    final fimSemana = inicioSemana.add(const Duration(days: 6));

    final inicio = _filtro == 0 ? hoje : inicioSemana;
    final fim = _filtro == 0 ? hoje : fimSemana;

    final itens = <_ItemDiaFamiliar>[];

    for (final remedio in widget.remedios) {
      for (DateTime dia = inicio;
          !dia.isAfter(fim);
          dia = dia.add(const Duration(days: 1))) {
        if (!_famDataDentroDoPeriodo(
          dia,
          remedio.dataInicio,
          remedio.dataFim,
        )) {
          continue;
        }

        final tomado = _famRemedioTomadoNoDia(
          state,
          remedio,
          dia,
        );
        final horarioMin = _famHorarioEmMinutos(remedio.horario);
        final ehHoje = _famMesmaData(dia, hoje);
        final passado = dia.isBefore(hoje);
        final futuro = dia.isAfter(hoje);

        final atrasado = !tomado &&
            ehHoje &&
            horarioMin != 9999 &&
            horarioMin < agora.hour * 60 + agora.minute;

        final naoRegistrado = !tomado && passado;

        final status = tomado
            ? 'Tomado'
            : atrasado
                ? 'Atrasado'
                : naoRegistrado
                    ? 'Não registrado'
                    : futuro
                        ? 'Programado'
                        : 'Pendente';

        itens.add(
          _ItemDiaFamiliar(
            data: dia,
            horario: remedio.horario,
            titulo: remedio.nome,
            descricao: status,
            concluido: tomado,
            atencao: atrasado || naoRegistrado,
            icon: Icons.medication_outlined,
            tipo: 'Medicamento',
          ),
        );
      }
    }

    for (final compromisso in widget.compromissos) {
      final data = compromisso.data;
      if (data == null) continue;

      final dia = _famDataSemHorario(data);
      if (dia.isBefore(inicio) || dia.isAfter(fim)) continue;
      if (compromisso.status.toLowerCase() == 'cancelado') continue;

      final concluido = compromisso.status.toLowerCase() == 'concluido';
      final horarioMin = _famHorarioEmMinutos(compromisso.horario);
      final ehHoje = _famMesmaData(dia, hoje);
      final atrasado = !concluido &&
          (dia.isBefore(hoje) ||
              (ehHoje &&
                  horarioMin != 9999 &&
                  horarioMin < agora.hour * 60 + agora.minute));

      final status = concluido
          ? 'Concluído'
          : atrasado
              ? 'Pendente / não realizado'
              : dia.isAfter(hoje)
                  ? 'Programado'
                  : 'Pendente';

      itens.add(
        _ItemDiaFamiliar(
          data: dia,
          horario: compromisso.horario,
          titulo: compromisso.titulo,
          descricao: compromisso.local.trim().isEmpty
              ? status
              : '$status • ${compromisso.local}',
          concluido: concluido,
          atencao: atrasado,
          icon: Icons.calendar_month_outlined,
          tipo: 'Compromisso',
        ),
      );
    }

    for (final cuidado in state.cuidados) {
      if (!cuidado.ativo) continue;

      for (DateTime dia = inicio;
          !dia.isAfter(fim);
          dia = dia.add(const Duration(days: 1))) {
        if (!_famDataDentroDoPeriodo(
          dia,
          cuidado.dataInicio,
          cuidado.dataFim,
        )) {
          continue;
        }

        final concluido = cuidado.concluidoEm(dia);
        final horarioMin = _famHorarioEmMinutos(cuidado.horario);
        final ehHoje = _famMesmaData(dia, hoje);

        final atrasado = !concluido &&
            (dia.isBefore(hoje) ||
                (ehHoje &&
                    horarioMin != 9999 &&
                    horarioMin < agora.hour * 60 + agora.minute));

        final status = concluido
            ? 'Concluído'
            : atrasado
                ? 'Pendente / não registrado'
                : dia.isAfter(hoje)
                    ? 'Programado'
                    : 'Pendente';

        itens.add(
          _ItemDiaFamiliar(
            data: dia,
            horario: cuidado.horario,
            titulo: cuidado.tipo,
            descricao: cuidado.observacao.trim().isEmpty
                ? status
                : '$status • ${cuidado.observacao}',
            concluido: concluido,
            atencao: atrasado,
            icon: Icons.favorite_outline,
            tipo: 'Cuidado',
          ),
        );
      }
    }

    itens.sort((a, b) {
      final dataCompare = a.data.compareTo(b.data);
      if (dataCompare != 0) return dataCompare;
      return _famHorarioEmMinutos(a.horario)
          .compareTo(_famHorarioEmMinutos(b.horario));
    });

    final realizados = itens.where((item) => item.concluido).length;
    final atencao = itens.where((item) => item.atencao).length;
    final pendentes =
        itens.where((item) => !item.concluido && !item.atencao).length;

    final grupos = <DateTime, List<_ItemDiaFamiliar>>{};
    for (final item in itens) {
      final dia = _famDataSemHorario(item.data);
      grupos.putIfAbsent(dia, () => []);
      grupos[dia]!.add(item);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _FiltroTimelineFamiliar(
                    titulo: 'Hoje',
                    selecionado: _filtro == 0,
                    onTap: () => setState(() => _filtro = 0),
                  ),
                ),
                Expanded(
                  child: _FiltroTimelineFamiliar(
                    titulo: 'Esta semana',
                    selecionado: _filtro == 1,
                    onTap: () => setState(() => _filtro = 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ResumoTimelineFamiliar(
                  valor: '$realizados',
                  titulo: 'Realizadas',
                  cor: Colors.green,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _ResumoTimelineFamiliar(
                  valor: '$pendentes',
                  titulo: 'Pendentes',
                  cor: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _ResumoTimelineFamiliar(
                  valor: '$atencao',
                  titulo: 'Atenção',
                  cor: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (itens.isEmpty)
            Text(
              'Nenhuma atividade encontrada para o período.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            )
          else
            ...grupos.entries.map(
              (entry) => _GrupoDiaTimelineFamiliar(
                dia: entry.key,
                hoje: hoje,
                itens: entry.value,
              ),
            ),
        ],
      ),
    );
  }
}

class _FiltroTimelineFamiliar extends StatelessWidget {
  final String titulo;
  final bool selecionado;
  final VoidCallback onTap;

  const _FiltroTimelineFamiliar({
    required this.titulo,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? AppTheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          titulo,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
            color: selecionado ? AppTheme.primary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ResumoTimelineFamiliar extends StatelessWidget {
  final String valor;
  final String titulo;
  final Color cor;

  const _ResumoTimelineFamiliar({
    required this.valor,
    required this.titulo,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cor,
            ),
          ),
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 8.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrupoDiaTimelineFamiliar extends StatelessWidget {
  final DateTime dia;
  final DateTime hoje;
  final List<_ItemDiaFamiliar> itens;

  const _GrupoDiaTimelineFamiliar({
    required this.dia,
    required this.hoje,
    required this.itens,
  });

  @override
  Widget build(BuildContext context) {
    final titulo = _famMesmaData(dia, hoje) ? 'Hoje' : _famFormatarData(dia);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 8),
          child: Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        ...itens.map(
          (item) => _LinhaDiaFamiliar(
            item: item,
            ultimo: item == itens.last,
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}

class _ItemDiaFamiliar {
  final DateTime data;
  final String horario;
  final String titulo;
  final String descricao;
  final bool concluido;
  final bool atencao;
  final IconData icon;
  final String tipo;

  const _ItemDiaFamiliar({
    required this.data,
    required this.horario,
    required this.titulo,
    required this.descricao,
    required this.concluido,
    required this.atencao,
    required this.icon,
    required this.tipo,
  });
}

class _LinhaDiaFamiliar extends StatelessWidget {
  final _ItemDiaFamiliar item;
  final bool ultimo;

  const _LinhaDiaFamiliar({
    required this.item,
    required this.ultimo,
  });

  @override
  Widget build(BuildContext context) {
    final cor = item.atencao
        ? Colors.orange
        : item.concluido
            ? Colors.green
            : AppTheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 45,
          child: Text(
            item.horario,
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.concluido ? Icons.check : item.icon,
                size: 15,
                color: cor,
              ),
            ),
            if (!ultimo)
              Container(
                width: 1,
                height: 44,
                color: AppTheme.divider,
              ),
          ],
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: item.atencao
                  ? Colors.orange.withValues(alpha: 0.05)
                  : AppTheme.background,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: item.atencao
                    ? Colors.orange.withValues(alpha: 0.18)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      item.tipo,
                      style: GoogleFonts.poppins(
                        fontSize: 8.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.descricao,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: cor,
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

class _CognitivoResumoFamiliar extends StatelessWidget {
  final List resultados;

  const _CognitivoResumoFamiliar({
    required this.resultados,
  });

  String _formatarTempo(int segundos) {
    if (segundos <= 0) return '0s';
    final minutos = segundos ~/ 60;
    final resto = segundos % 60;
    if (minutos == 0) return '${resto}s';
    return resto == 0 ? '${minutos}min' : '${minutos}m ${resto}s';
  }

  @override
  Widget build(BuildContext context) {
    if (resultados.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.psychology_outlined,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ainda não há atividades cognitivas registradas.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final agora = DateTime.now();
    final hoje = _famDataSemHorario(agora);
    final inicioSeteDias = hoje.subtract(const Duration(days: 6));

    final resultadosOrdenados = [...resultados]
      ..sort((a, b) => b.data.compareTo(a.data));

    final resultadosHoje = resultados.where((item) {
      return _famMesmaData(item.data, hoje);
    }).toList();

    final resultadosSeteDias = resultados.where((item) {
      final dia = _famDataSemHorario(item.data);
      return !dia.isBefore(inicioSeteDias) && !dia.isAfter(hoje);
    }).toList();

    double mediaPontuacao(List lista) {
      if (lista.isEmpty) return 0;
      final total = lista.fold<double>(
        0,
        (soma, item) => soma + (item.pontuacao as num).toDouble(),
      );
      return total / lista.length;
    }

    double mediaTempo(List lista) {
      if (lista.isEmpty) return 0;
      final total = lista.fold<double>(
        0,
        (soma, item) => soma + (item.tempoSegundos as num).toDouble(),
      );
      return total / lista.length;
    }

    int somaAcertos(List lista) => lista.fold<int>(
          0,
          (soma, item) => soma + (item.acertos as int),
        );

    int somaErros(List lista) => lista.fold<int>(
          0,
          (soma, item) => soma + (item.erros as int),
        );

    final mediaHoje = mediaPontuacao(resultadosHoje);
    final tempoMedioHoje = mediaTempo(resultadosHoje).round();
    final acertosHoje = somaAcertos(resultadosHoje);
    final errosHoje = somaErros(resultadosHoje);
    final respostasHoje = acertosHoje + errosHoje;
    final aproveitamentoHoje =
        respostasHoje == 0 ? 0.0 : acertosHoje / respostasHoje * 100;

    final mediaSeteDias = mediaPontuacao(resultadosSeteDias);
    final tempoMedioSeteDias = mediaTempo(resultadosSeteDias).round();
    final acertosSeteDias = somaAcertos(resultadosSeteDias);
    final errosSeteDias = somaErros(resultadosSeteDias);
    final respostasSeteDias = acertosSeteDias + errosSeteDias;
    final aproveitamentoSeteDias = respostasSeteDias == 0
        ? 0.0
        : acertosSeteDias / respostasSeteDias * 100;

    final grafico = [...resultadosSeteDias]
      ..sort((a, b) => a.data.compareTo(b.data));

    final recentes = resultadosOrdenados.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoje',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _MetricaCognitivaFamiliar(
                  valor: '${resultadosHoje.length}',
                  titulo: 'Atividades',
                  detalhe: 'realizadas',
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _MetricaCognitivaFamiliar(
                  valor: '${mediaHoje.toStringAsFixed(0)}%',
                  titulo: 'Pontuação',
                  detalhe: 'média',
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _MetricaCognitivaFamiliar(
                  valor: _formatarTempo(tempoMedioHoje),
                  titulo: 'Tempo',
                  detalhe: 'médio',
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          _IndicadoresCognitivosFamiliar(
            acertos: acertosHoje,
            erros: errosHoje,
            aproveitamento: aproveitamentoHoje,
            respostas: respostasHoje,
          ),
          const SizedBox(height: 16),
          Text(
            'Últimos 7 dias',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _MetricaCognitivaFamiliar(
                  valor: '${resultadosSeteDias.length}',
                  titulo: 'Atividades',
                  detalhe: 'total',
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _MetricaCognitivaFamiliar(
                  valor: '${mediaSeteDias.toStringAsFixed(0)}%',
                  titulo: 'Pontuação',
                  detalhe: 'média',
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _MetricaCognitivaFamiliar(
                  valor: _formatarTempo(tempoMedioSeteDias),
                  titulo: 'Tempo',
                  detalhe: 'médio',
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          _IndicadoresCognitivosFamiliar(
            acertos: acertosSeteDias,
            erros: errosSeteDias,
            aproveitamento: aproveitamentoSeteDias,
            respostas: respostasSeteDias,
          ),
          if (grafico.isNotEmpty) ...[
            const SizedBox(height: 17),
            Text(
              'Evolução da pontuação',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pontuação das atividades realizadas nos últimos 7 dias.',
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            _GraficoCognitivoFamiliar(resultados: grafico),
          ],
          const SizedBox(height: 17),
          Text(
            'Atividades recentes',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...recentes.map(
            (resultado) => _ResultadoCognitivoFamiliar(
              resultado: resultado,
              formatarTempo: _formatarTempo,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricaCognitivaFamiliar extends StatelessWidget {
  final String valor;
  final String titulo;
  final String detalhe;

  const _MetricaCognitivaFamiliar({
    required this.valor,
    required this.titulo,
    required this.detalhe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            detalhe,
            style: GoogleFonts.poppins(
              fontSize: 7.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicadoresCognitivosFamiliar extends StatelessWidget {
  final int acertos;
  final int erros;
  final double aproveitamento;
  final int respostas;

  const _IndicadoresCognitivosFamiliar({
    required this.acertos,
    required this.erros,
    required this.aproveitamento,
    required this.respostas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _IndicadorTextoFamiliar(
                  label: 'Acertos',
                  valor: '$acertos',
                  cor: Colors.green,
                ),
              ),
              Expanded(
                child: _IndicadorTextoFamiliar(
                  label: 'Erros',
                  valor: '$erros',
                  cor: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: _IndicadorTextoFamiliar(
                  label: 'Aproveitamento',
                  valor: '${aproveitamento.toStringAsFixed(0)}%',
                  cor: AppTheme.primary,
                ),
              ),
              Expanded(
                child: _IndicadorTextoFamiliar(
                  label: 'Respostas',
                  valor: '$respostas',
                  cor: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IndicadorTextoFamiliar extends StatelessWidget {
  final String label;
  final String valor;
  final Color cor;

  const _IndicadorTextoFamiliar({
    required this.label,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: cor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 8.5,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _GraficoCognitivoFamiliar extends StatelessWidget {
  final List resultados;

  const _GraficoCognitivoFamiliar({
    required this.resultados,
  });

  @override
  Widget build(BuildContext context) {
    final itens = resultados.length > 7
        ? resultados.sublist(resultados.length - 7)
        : resultados;

    return Container(
      height: 150,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: itens.map((item) {
          final pontuacao = (item.pontuacao as num).toDouble().clamp(0, 100);
          final altura = 20 + 78 * (pontuacao / 100);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${pontuacao.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    height: altura,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.60),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.data.day.toString().padLeft(2, '0')}/'
                    '${item.data.month.toString().padLeft(2, '0')}',
                    style: GoogleFonts.poppins(
                      fontSize: 7,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ResultadoCognitivoFamiliar extends StatelessWidget {
  final dynamic resultado;
  final String Function(int) formatarTempo;

  const _ResultadoCognitivoFamiliar({
    required this.resultado,
    required this.formatarTempo,
  });

  @override
  Widget build(BuildContext context) {
    final totalRespostas =
        (resultado.acertos as int) + (resultado.erros as int);
    final aproveitamento = totalRespostas == 0
        ? 0.0
        : (resultado.acertos as int) / totalRespostas * 100;

    final Map<String, dynamic> detalhes =
        Map<String, dynamic>.from(resultado.detalhes as Map);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 1),
          childrenPadding: const EdgeInsets.fromLTRB(11, 0, 11, 11),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: AppTheme.primary,
              size: 19,
            ),
          ),
          title: Text(
            resultado.titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          subtitle: Text(
            '${resultado.pontuacao}% • ${_famFormatarData(resultado.data)} • '
            '${formatarTempo(resultado.tempoSegundos)}',
            style: GoogleFonts.poppins(
              fontSize: 8.5,
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: _DetalheCognitivoBoxFamiliar(
                    titulo: 'Acertos',
                    valor: '${resultado.acertos}',
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _DetalheCognitivoBoxFamiliar(
                    titulo: 'Erros',
                    valor: '${resultado.erros}',
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _DetalheCognitivoBoxFamiliar(
                    titulo: 'Tempo',
                    valor: formatarTempo(resultado.tempoSegundos),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _DetalheLeituraFamiliar(
              icon: Icons.category_outlined,
              label: 'Tipo',
              value: '${resultado.tipo}',
            ),
            _DetalheLeituraFamiliar(
              icon: Icons.percent_outlined,
              label: 'Pontuação',
              value: '${resultado.pontuacao}%',
            ),
            _DetalheLeituraFamiliar(
              icon: Icons.insights_outlined,
              label: 'Aproveitamento',
              value: '${aproveitamento.toStringAsFixed(0)}%',
            ),
            if (detalhes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Detalhes da atividade',
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ...detalhes.entries.map(
                (entry) => _DetalheLeituraFamiliar(
                  icon: Icons.circle_outlined,
                  label: entry.key,
                  value: '${entry.value}',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetalheCognitivoBoxFamiliar extends StatelessWidget {
  final String titulo;
  final String valor;

  const _DetalheCognitivoBoxFamiliar({
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 8,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AtividadesResumoFamiliar extends StatelessWidget {
  final int coposAgua;
  final int passos;
  final int atividadesConcluidas;

  const _AtividadesResumoFamiliar({
    required this.coposAgua,
    required this.passos,
    required this.atividadesConcluidas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MiniAtividade(
              icon: '💧',
              valor: '$coposAgua/6',
              titulo: 'Água',
            ),
          ),
          Container(
            width: 1,
            height: 42,
            color: AppTheme.divider,
          ),
          Expanded(
            child: _MiniAtividade(
              icon: '🚶',
              valor: '$passos',
              titulo: 'Passos',
            ),
          ),
          Container(
            width: 1,
            height: 42,
            color: AppTheme.divider,
          ),
          Expanded(
            child: _MiniAtividade(
              icon: '🎯',
              valor: '$atividadesConcluidas/3',
              titulo: 'Atividades',
            ),
          ),
        ],
      ),
    );
  }
}

class _CuidadosResumoFamiliar extends StatelessWidget {
  final List<Cuidado> cuidados;

  const _CuidadosResumoFamiliar({
    required this.cuidados,
  });

  @override
  Widget build(BuildContext context) {
    final hoje = _famDataSemHorario(DateTime.now());

    final cuidadosAtivos = cuidados.where((cuidado) {
      return cuidado.ativo &&
          _famDataDentroDoPeriodo(
            hoje,
            cuidado.dataInicio,
            cuidado.dataFim,
          );
    }).toList();

    cuidadosAtivos.sort(
      (a, b) => _famHorarioEmMinutos(a.horario)
          .compareTo(_famHorarioEmMinutos(b.horario)),
    );

    final concluidosHoje =
        cuidadosAtivos.where((cuidado) => cuidado.concluidoEm(hoje)).length;
    final pendentesHoje = cuidadosAtivos.length - concluidosHoje;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _ResumoCuidadoItem(
                  valor: '${cuidadosAtivos.length}',
                  titulo: 'Ativos hoje',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ResumoCuidadoItem(
                  valor: '$concluidosHoje',
                  titulo: 'Concluídos',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ResumoCuidadoItem(
                  valor: '$pendentesHoje',
                  titulo: 'Pendentes',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (cuidadosAtivos.isEmpty)
            Text(
              'Nenhum cuidado intensivo programado para hoje.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            )
          else
            ...cuidadosAtivos.map(
              (cuidado) => _CuidadoFamiliarDetalhado(
                cuidado: cuidado,
                data: hoje,
              ),
            ),
        ],
      ),
    );
  }
}

class _CuidadoFamiliarDetalhado extends StatelessWidget {
  final Cuidado cuidado;
  final DateTime data;

  const _CuidadoFamiliarDetalhado({
    required this.cuidado,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final concluido = cuidado.concluidoEm(data);
    final periodo = _famFormatarPeriodo(
      cuidado.dataInicio,
      cuidado.dataFim,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: concluido
            ? Colors.green.withValues(alpha: 0.04)
            : AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: concluido
              ? Colors.green.withValues(alpha: 0.14)
              : Colors.transparent,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(11, 0, 11, 11),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (concluido ? Colors.green : AppTheme.primary)
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              concluido ? Icons.check_circle_outline : Icons.favorite_outline,
              color: concluido ? Colors.green : AppTheme.primary,
              size: 19,
            ),
          ),
          title: Text(
            cuidado.tipo,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          subtitle: Text(
            '${cuidado.horario} • ${concluido ? 'Concluído' : 'Pendente'}',
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: concluido ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            _DetalheLeituraFamiliar(
              icon: Icons.schedule_outlined,
              label: 'Horário',
              value: cuidado.horario,
            ),
            _DetalheLeituraFamiliar(
              icon: Icons.date_range_outlined,
              label: 'Período',
              value: periodo,
            ),
            if (cuidado.frequencia.trim().isNotEmpty)
              _DetalheLeituraFamiliar(
                icon: Icons.repeat_outlined,
                label: 'Frequência',
                value: cuidado.frequencia,
              ),
            if (cuidado.observacao.trim().isNotEmpty)
              _DetalheLeituraFamiliar(
                icon: Icons.notes_outlined,
                label: 'Observação',
                value: cuidado.observacao,
              ),
            _DetalheLeituraFamiliar(
              icon: concluido
                  ? Icons.check_circle_outline
                  : Icons.schedule_outlined,
              label: 'Status de hoje',
              value: concluido ? 'Concluído' : 'Pendente',
              valueColor: concluido ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoCuidadoItem extends StatelessWidget {
  final String valor;
  final String titulo;

  const _ResumoCuidadoItem({
    required this.valor,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
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

class _MiniAtividade extends StatelessWidget {
  final String icon;
  final String valor;
  final String titulo;

  const _MiniAtividade({
    required this.icon,
    required this.valor,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          titulo,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// HELPERS DO FAMILIAR
// ============================================================

DateTime _famDataSemHorario(DateTime data) {
  return DateTime(data.year, data.month, data.day);
}

bool _famMesmaData(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool _famDataDentroDoPeriodo(
  DateTime data,
  DateTime? inicio,
  DateTime? fim,
) {
  final dia = _famDataSemHorario(data);

  if (inicio != null && dia.isBefore(_famDataSemHorario(inicio))) {
    return false;
  }

  if (fim != null && dia.isAfter(_famDataSemHorario(fim))) {
    return false;
  }

  return true;
}

int _famHorarioEmMinutos(String horario) {
  final partes = horario.split(':');
  if (partes.length < 2) return 9999;

  final hora = int.tryParse(partes[0]);
  final minuto = int.tryParse(partes[1]);

  if (hora == null || minuto == null) return 9999;
  return hora * 60 + minuto;
}

String _famFormatarData(DateTime data) {
  return '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/'
      '${data.year}';
}

String _famFormatarHora(DateTime? data) {
  if (data == null) return '--:--';
  return '${data.hour.toString().padLeft(2, '0')}:'
      '${data.minute.toString().padLeft(2, '0')}';
}

String _famFormatarDataCompleta(DateTime data) {
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

  return '${dias[data.weekday - 1]}, ${data.day} de '
      '${meses[data.month - 1]} de ${data.year}';
}

String _famFormatarPeriodo(DateTime? inicio, DateTime? fim) {
  if (inicio == null && fim == null) {
    return 'Sem período definido';
  }

  final textoInicio = inicio == null ? 'Sem início' : _famFormatarData(inicio);
  final textoFim = fim == null ? 'sem data final' : _famFormatarData(fim);

  return '$textoInicio até $textoFim';
}

bool _famRemedioTomadoNoDia(
  AppState state,
  Remedio remedio,
  DateTime dia,
) {
  final data = _famDataSemHorario(dia);
  final hoje = _famDataSemHorario(DateTime.now());

  if (_famMesmaData(data, hoje) && remedio.tomado) {
    return true;
  }

  final historicos = <Historico>[
    ...state.historico,
    ...state.historicoAtividades,
  ];

  return historicos.any((item) {
    final realizada = item.dataRealizada;
    if (realizada == null || !_famMesmaData(realizada, data)) {
      return false;
    }

    final tipo = item.tipo.toLowerCase();
    final titulo = item.titulo.toLowerCase();
    final nome = remedio.nome.toLowerCase();

    final ehMedicamento =
        tipo == 'medicamento' || titulo.contains('medicamento');

    return (ehMedicamento || titulo.contains(nome)) && titulo.contains(nome);
  });
}

class _DetalheLeituraFamiliar extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetalheLeituraFamiliar({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 7),
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value.trim().isEmpty ? 'Não informado' : value,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppTheme.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
