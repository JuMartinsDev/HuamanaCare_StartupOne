import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/app_state.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';

class PerfilTab extends StatefulWidget {
  const PerfilTab({super.key});

  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  int _abaSelecionada = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final p = state.paciente;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabeçalho ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Perfil',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.push('/editar-perfil');
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                  tooltip: 'Editar perfil',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Identificação ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.nome.isEmpty ? 'Paciente' : p.nome,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.id.isEmpty ? '' : 'ID: ${p.id}',
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

            const SizedBox(height: 24),

            // ── Abas ──────────────────────────────────────────────────────
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.inputFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _TabButton(
                    label: 'Informações',
                    selecionada: _abaSelecionada == 0,
                    onTap: () {
                      setState(() => _abaSelecionada = 0);
                    },
                  ),
                  _TabButton(
                    label: 'Histórico',
                    selecionada: _abaSelecionada == 1,
                    onTap: () {
                      setState(() => _abaSelecionada = 1);
                    },
                  ),
                  _TabButton(
                    label: 'Documentos',
                    selecionada: _abaSelecionada == 2,
                    onTap: () {
                      setState(() => _abaSelecionada = 2);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Conteúdo da aba ────────────────────────────────────────────
            if (_abaSelecionada == 0)
              _InformacoesPaciente(p: p)
            else if (_abaSelecionada == 1)
              const _Historico()
            else
              const _Documentos(),

            const SizedBox(height: 24),

            // ── Cuidador ──────────────────────────────────────────────────
            if (_abaSelecionada == 0) _CardCuidador(p: p),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Aba de informações
// ─────────────────────────────────────────────────────────────────────────────

class _InformacoesPaciente extends StatelessWidget {
  final dynamic p;

  const _InformacoesPaciente({
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Informações pessoais',
      children: [
        _InfoRow(
          label: 'Data de nascimento',
          value: p.dataNascimento,
        ),
        _InfoRow(
          label: 'Sexo',
          value: p.sexo,
        ),
        _InfoRow(
          label: 'Estado civil',
          value: p.estadoCivil,
        ),
        _InfoRow(
          label: 'Endereço',
          value: p.endereco,
        ),
        _InfoRow(
          label: 'Telefone',
          value: p.telefone,
        ),
        _InfoRow(
          label: 'Tipo sanguíneo',
          value: p.tipoSanguineo,
        ),
        _InfoRow(
          label: 'Condição de saúde',
          value: p.condicaoSaude,
        ),
        _InfoRow(
          label: 'Alergias',
          value: p.alergias,
        ),
        _InfoRow(
          label: 'Dispositivos',
          value: p.dispositivos,
        ),
        _InfoRow(
          label: 'Observações',
          value: p.observacoes,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Histórico
// ─────────────────────────────────────────────────────────────────────────────

class _Historico extends StatelessWidget {
  const _Historico();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final historicos = state.historico;

    return _InfoCard(
      title: 'Histórico',
      children: [
        if (historicos.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 38,
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nenhum histórico disponível.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...historicos.map(
            (historico) => _HistoricoItem(
              historico: historico,
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item do histórico
// ─────────────────────────────────────────────────────────────────────────────

class _HistoricoItem extends StatelessWidget {
  final Historico historico;

  const _HistoricoItem({
    required this.historico,
  });

  @override
  Widget build(BuildContext context) {
    final data = historico.data;

    final dataFormatada =
        '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history,
              color: AppTheme.primary,
              size: 20,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  historico.descricao,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  dataFormatada,
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

// ─────────────────────────────────────────────────────────────────────────────
// Documentos
// ─────────────────────────────────────────────────────────────────────────────

class _Documentos extends StatelessWidget {
  const _Documentos();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Documentos',
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 38,
                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 10),
                Text(
                  'Nenhum documento disponível.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
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

// ─────────────────────────────────────────────────────────────────────────────
// Card do cuidador
// ─────────────────────────────────────────────────────────────────────────────

class _CardCuidador extends StatelessWidget {
  final dynamic p;

  const _CardCuidador({
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Cuidador',
      children: [
        _InfoRow(
          label: 'Nome',
          value: p.cuidadorNome,
        ),
        _InfoRow(
          label: 'Turno',
          value: p.cuidadorTurno,
        ),
        _InfoRow(
          label: 'Carga horária',
          value: p.cuidadorCarga,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Familiar',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Componentes auxiliares
// ─────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? 'Não informado' : value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selecionada;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selecionada ? AppTheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight:
                  selecionada ? FontWeight.w600 : FontWeight.w400,
              color: selecionada
                  ? AppTheme.primary
                  : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}