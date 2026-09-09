import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
          'HumanaCare',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
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
    final remediosVisiveis = remedios.take(3).toList();
    final compromissosVisiveis = compromissos.take(3).toList();

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async {
        await Future<void>.delayed(
          const Duration(milliseconds: 300),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, Familiar!',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Acompanhe a saúde e o bem-estar de quem você ama.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 22),

            _PacienteCard(
              paciente: paciente,
            ),

            const SizedBox(height: 20),

            Text(
              'Acompanhamento',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            _ResumoSaudeCard(
              paciente: paciente,
              onTap: onAbrirSaude,
            ),

            const SizedBox(height: 12),

            _ResumoRemediosCard(
              remedios: remediosVisiveis,
              total: remedios.length,
              onTap: onAbrirRemedios,
            ),

            const SizedBox(height: 12),

            _ResumoAgendaCard(
              compromissos: compromissosVisiveis,
              total: compromissos.length,
              onTap: onAbrirAgenda,
            ),

            const SizedBox(height: 12),

            _SosCard(
              ativado: sosAtivado,
            ),

            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.history_outlined,
              title: 'Histórico',
              description:
                  'Acompanhe acontecimentos importantes.',
              onTap: onAbrirHistorico,
            ),

            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.chat_bubble_outline,
              title: 'Mensagens',
              description:
                  'Converse com o paciente pelo HumanaCare.',
              onTap: onAbrirChat,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// REMÉDIOS
// ============================================================

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
    return Container(
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
            child: const Icon(
              Icons.medication_outlined,
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
                  remedio.nome,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),

                if (remedio.tipo.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    remedio.tipo,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: 15,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      remedio.horario,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          _StatusRemedio(
            tomado: remedio.tomado,
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
          color: tomado
              ? Colors.green
              : Colors.orange,
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
    return Container(
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
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  compromisso.dia.toString(),
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

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                      Icons.schedule_outlined,
                      size: 15,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      compromisso.horario,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),

                if (compromisso.local.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          compromisso.local,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color:
                                AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
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
// HISTÓRICO
// ============================================================

class _HistoricoFamiliarTab extends StatelessWidget {
  final List<Historico> historicos;

  const _HistoricoFamiliarTab({
    required this.historicos,
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
              'Histórico',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Acompanhe acontecimentos importantes.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            if (historicos.isEmpty)
              const _EmptyCard(
                icon: Icons.history_outlined,
                message:
                    'Nenhum acontecimento registrado.',
              )
            else
              ...historicos.map(
                (historico) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: _HistoricoCard(
                    historico: historico,
                  ),
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

  @override
  Widget build(BuildContext context) {
    final dia = historico.data.day
        .toString()
        .padLeft(2, '0');

    final mes = historico.data.month
        .toString()
        .padLeft(2, '0');

    final ano = historico.data.year.toString();

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.history,
              color: AppTheme.primary,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  historico.titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),

                if (historico.descricao.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    historico.descricao,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                Text(
                  '$dia/$mes/$ano',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textLight,
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
// PERFIL
// ============================================================

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
                  valor: paciente.nome.isEmpty
                      ? 'Paciente'
                      : paciente.nome,
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
  State<_FamiliarChatTab> createState() =>
      _FamiliarChatTabState();
}

class _FamiliarChatTabState
    extends State<_FamiliarChatTab> {
  final TextEditingController _input =
      TextEditingController();

  final ScrollController _scroll =
      ScrollController();

  bool _enviando = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _horaAgora() {
    final agora = TimeOfDay.now();

    return '${agora.hour.toString().padLeft(2, '0')}:'
        '${agora.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _enviar() async {
    final texto = _input.text.trim();

    if (texto.isEmpty || _enviando) {
      return;
    }

    final state = context.read<AppState>();

    setState(() {
      _enviando = true;
    });

    try {
      await state.addMensagem(
        'familia',
        Mensagem(
          id: 'u${DateTime.now().millisecondsSinceEpoch}',
          texto: texto,
          recebido: false,
          hora: _horaAgora(),
        ),
      );

      _input.clear();

      _rolarParaFim();
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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final paciente = state.paciente;
    final mensagens = state.mensagens('familia');

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
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
            // ======================================================
            // PACIENTE VINCULADO
            // ======================================================

            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(
                16,
                4,
                16,
                12,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
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
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppTheme.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conversando com',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color:
                                AppTheme.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          paciente.nome.isNotEmpty
                              ? paciente.nome
                              : 'Paciente',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
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
            ),

            // ======================================================
            // MENSAGENS
            // ======================================================

            Expanded(
              child: mensagens.isEmpty
                  ? const _EmptyChatFamiliar()
                  : ListView.builder(
                      controller: _scroll,
                      padding:
                          const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        16,
                      ),
                      itemCount: mensagens.length,
                      itemBuilder:
                          (context, index) {
                        final mensagem =
                            mensagens[index];

                        return _FamiliarMessageBubble(
                          mensagem: mensagem,
                        );
                      },
                    ),
            ),

            // ======================================================
            // CAMPO DE MENSAGEM
            // ======================================================

            Container(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.05,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      textCapitalization:
                          TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => _enviar(),
                      decoration: InputDecoration(
                        hintText:
                            'Digite uma mensagem...',
                        hintStyle: GoogleFonts.poppins(
                          color:
                              AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor:
                            AppTheme.background,
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),
                          borderSide: BorderSide(
                            color: AppTheme.primary
                                .withValues(
                              alpha: 0.30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Material(
                    color: AppTheme.primary,
                    borderRadius:
                        BorderRadius.circular(24),
                    child: InkWell(
                      onTap: _enviando
                          ? null
                          : _enviar,
                      borderRadius:
                          BorderRadius.circular(24),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: _enviando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color:
                                      Colors.white,
                                  size: 21,
                                ),
                        ),
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
// BOLHA DA MENSAGEM DO FAMILIAR
// ============================================================

class _FamiliarMessageBubble
    extends StatelessWidget {
  final Mensagem mensagem;

  const _FamiliarMessageBubble({
    required this.mensagem,
  });

  @override
  Widget build(BuildContext context) {
    final eu = !mensagem.recebido;

    return Align(
      alignment: eu
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 320,
        ),
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: eu
              ? AppTheme.primary
              : AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(
              eu ? 16 : 4,
            ),
            bottomRight: Radius.circular(
              eu ? 4 : 16,
            ),
          ),
          border: eu
              ? null
              : Border.all(
                  color: Colors.black.withValues(
                    alpha: 0.06,
                  ),
                ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            if (!eu &&
                mensagem.remetente != null &&
                mensagem.remetente!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 4,
                ),
                child: Text(
                  mensagem.remetente!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),

            Text(
              mensagem.texto,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: eu
                    ? Colors.white
                    : AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                mensagem.hora,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: eu
                      ? Colors.white.withValues(
                          alpha: 0.75,
                        )
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CHAT VAZIO
// ============================================================

class _EmptyChatFamiliar
    extends StatelessWidget {
  const _EmptyChatFamiliar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                  paciente.nome.isEmpty
                      ? 'Paciente'
                      : paciente.nome,
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

class _ResumoSaudeCard
    extends StatelessWidget {
  final Paciente paciente;
  final VoidCallback onTap;

  const _ResumoSaudeCard({
    required this.paciente,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ActionCard(
      icon: Icons.favorite_outline,
      title: 'Resumo de saúde',
      description: paciente.condicaoSaude.isEmpty
          ? 'Veja informações importantes sobre o paciente.'
          : paciente.condicaoSaude,
      onTap: onTap,
    );
  }
}

class _ResumoRemediosCard
    extends StatelessWidget {
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

class _ResumoAgendaCard
    extends StatelessWidget {
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

class _SosCard extends StatelessWidget {
  final bool ativado;

  const _SosCard({
    required this.ativado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: ativado
            ? AppTheme.error.withValues(
                alpha: 0.08,
              )
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ativado
              ? AppTheme.error.withValues(
                  alpha: 0.30,
                )
              : AppTheme.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ativado
                  ? AppTheme.error.withValues(
                      alpha: 0.12,
                    )
                  : AppTheme.primary.withValues(
                      alpha: 0.10,
                    ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.sos_outlined,
              color: ativado
                  ? AppTheme.error
                  : AppTheme.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Status do SOS',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  ativado
                      ? 'Alerta de emergência ativado.'
                      : 'Nenhum alerta de emergência ativo.',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: ativado
                        ? AppTheme.error
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            ativado
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            color: ativado
                ? AppTheme.error
                : AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class _ActionCard
    extends StatelessWidget {
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    description,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color:
                          AppTheme.textSecondary,
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

class _EmptyCard
    extends StatelessWidget {
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

class _InformacaoSaude
    extends StatelessWidget {
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
    final valorFinal =
        valor.isEmpty ? 'Não informado' : valor;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
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

class _PerfilInfoRow
    extends StatelessWidget {
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
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

class _Handle
    extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: AppTheme.divider,
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
    );
  }
}

