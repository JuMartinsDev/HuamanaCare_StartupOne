import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _confirmarSaida() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Sair da conta',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Tem certeza de que deseja sair da sua conta?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true) {
      return;
    }

    await context.read<AppState>().logout();

    if (!mounted) {
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final p = state.paciente;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // CABEÇALHO
            // ============================================================

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meu perfil',
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
                  tooltip: 'Editar perfil',
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ============================================================
            // IDENTIFICAÇÃO
            // ============================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.textPrimary.withValues(
                      alpha: 0.06,
                    ),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await context
                          .read<AppState>()
                          .selecionarFotoPerfil();
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary,
                            image: p.fotoPerfilUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(
                                      p.fotoPerfilUrl,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: p.fotoPerfilUrl.isEmpty
                              ? const Icon(
                                  Icons.person_outline,
                                  color: Colors.white,
                                  size: 40,
                                )
                              : null,
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    p.nome.isEmpty
                        ? 'Paciente'
                        : p.nome,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    p.idade > 0
                        ? '${p.idade} anos'
                        : 'Perfil do paciente',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  if (p.id.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'ID: ${p.id}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push('/editar-perfil');
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                      ),
                      label: Text(
                        'Editar informações',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ============================================================
            // RESUMO DE SAÚDE
            // ============================================================

            _ResumoSaudePerfil(
              tipoSanguineo: p.tipoSanguineo,
              condicaoSaude: p.condicaoSaude,
              alergias: p.alergias,
            ),

            const SizedBox(height: 18),

            // ============================================================
            // CÓDIGO DE VÍNCULO
            // ============================================================

            _CardCodigoVinculo(
              codigo: state.codigoVinculo,
            ),

            const SizedBox(height: 22),

            // ============================================================
            // ABAS
            // ============================================================

            Container(
              height: 46,
              padding: const EdgeInsets.all(4),
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
                      setState(() {
                        _abaSelecionada = 0;
                      });
                    },
                  ),
                  _TabButton(
                    label: 'Histórico',
                    selecionada: _abaSelecionada == 1,
                    onTap: () {
                      setState(() {
                        _abaSelecionada = 1;
                      });
                    },
                  ),
                  _TabButton(
                    label: 'Documentos',
                    selecionada: _abaSelecionada == 2,
                    onTap: () {
                      setState(() {
                        _abaSelecionada = 2;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ============================================================
            // CONTEÚDO DAS ABAS
            // ============================================================

            if (_abaSelecionada == 0) ...[
              _InformacoesPaciente(
                p: p,
              ),

              const SizedBox(height: 16),

              const _CardRedeCuidado(),
            ] else if (_abaSelecionada == 1)
              const _Historico()
            else
              const _Documentos(),

            const SizedBox(height: 28),

            // ============================================================
            // SAIR
            // ============================================================

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _confirmarSaida,
                icon: const Icon(
                  Icons.logout,
                  size: 18,
                ),
                label: Text(
                  'Sair da conta',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoSaudePerfil extends StatelessWidget {
  final String tipoSanguineo;
  final String condicaoSaude;
  final String alergias;

  const _ResumoSaudePerfil({
    required this.tipoSanguineo,
    required this.condicaoSaude,
    required this.alergias,
  });

  String _valorOuPadrao(
    String valor,
  ) {
    return valor.trim().isEmpty
        ? 'Não informado'
        : valor.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primary.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite_outline,
                  color: AppTheme.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo de saúde',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Informações importantes do paciente',
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

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ResumoSaudeItem(
                  icon: Icons.bloodtype_outlined,
                  titulo: 'Tipo sanguíneo',
                  valor: _valorOuPadrao(
                    tipoSanguineo,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ResumoSaudeItem(
                  icon:
                      Icons.medical_information_outlined,
                  titulo: 'Condição',
                  valor: _valorOuPadrao(
                    condicaoSaude,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _ResumoSaudeItem(
            icon: Icons.warning_amber_outlined,
            titulo: 'Alergias',
            valor: _valorOuPadrao(
              alergias,
            ),
            larguraTotal: true,
          ),
        ],
      ),
    );
  }
}

class _ResumoSaudeItem extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;
  final bool larguraTotal;

  const _ResumoSaudeItem({
    required this.icon,
    required this.titulo,
    required this.valor,
    this.larguraTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: larguraTotal
          ? double.infinity
          : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color:
                        AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  maxLines: larguraTotal
                      ? 3
                      : 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Código de vínculo
// ─────────────────────────────────────────────────────────────────────────────

class _CardCodigoVinculo extends StatelessWidget {
  final String? codigo;

  const _CardCodigoVinculo({
    required this.codigo,
  });

  Future<void> _copiarCodigo(BuildContext context) async {
    if (codigo == null || codigo!.trim().isEmpty) return;

    await Clipboard.setData(
      ClipboardData(text: codigo!),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Código de vínculo copiado!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final codigoValido =
        codigo != null && codigo!.trim().isNotEmpty;

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
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.link,
                  color: AppTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Código de vínculo',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Para compartilhar com familiar ou cuidador',
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

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppTheme.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    codigoValido
                        ? codigo!
                        : 'Código indisponível',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: codigoValido
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: codigoValido
                      ? () => _copiarCodigo(context)
                      : null,
                  tooltip: 'Copiar código',
                  icon: const Icon(
                    Icons.copy_outlined,
                    size: 21,
                  ),
                  color: AppTheme.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Compartilhe este código com seu familiar ou cuidador '
            'para que ele possa se vincular à sua conta.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              height: 1.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Aba de informações
// ─────────────────────────────────────────────────────────────────────────────

class _InformacoesPaciente
    extends StatelessWidget {
  final dynamic p;

  const _InformacoesPaciente({
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoCard(
          title: 'Dados pessoais',
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
              label: 'Telefone',
              value: p.telefone,
            ),
            _InfoRow(
              label: 'Endereço',
              value: p.endereco,
            ),
          ],
        ),

        const SizedBox(height: 16),

        _InfoCard(
          title: 'Informações de saúde',
          children: [
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
                    color: AppTheme.textSecondary.withValues(
                      alpha: 0.6,
                    ),
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
    final paciente = context.watch<AppState>().paciente;

    return _InfoCard(
      title: 'Documentos',
      children: [
        _DocumentoItem(
          icone: Icons.badge_outlined,
          titulo: 'CPF',
          valor: paciente.cpf,
        ),
        _DocumentoItem(
          icone: Icons.credit_card_outlined,
          titulo: 'RG / CIN',
          valor: paciente.rgCin,
        ),
        _DocumentoItem(
          icone: Icons.account_balance_outlined,
          titulo: 'Órgão expedidor',
          valor: paciente.orgaoExpedidor,
        ),
        _DocumentoItem(
          icone: Icons.calendar_today_outlined,
          titulo: 'Data de emissão',
          valor: paciente.dataEmissaoDocumento,
        ),
        _DocumentoItem(
          icone: Icons.health_and_safety_outlined,
          titulo: 'Cartão SUS',
          valor: paciente.cartaoSus,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const _EditarDocumentosDialog(),
              );
            },
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
            ),
            label: const Text(
              'Editar documentos',
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item de documento
// ─────────────────────────────────────────────────────────────────────────────

class _DocumentoItem extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;

  const _DocumentoItem({
    required this.icone,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final informado = valor.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icone,
              size: 20,
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
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  informado ? valor : 'Não informado',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: informado
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
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
// Modal para editar documentos
// ─────────────────────────────────────────────────────────────────────────────

class _EditarDocumentosDialog extends StatefulWidget {
  const _EditarDocumentosDialog();

  @override
  State<_EditarDocumentosDialog> createState() =>
      _EditarDocumentosDialogState();
}

class _EditarDocumentosDialogState
    extends State<_EditarDocumentosDialog> {
  late final TextEditingController _cpfController;
  late final TextEditingController _rgCinController;
  late final TextEditingController _orgaoController;
  late final TextEditingController _dataEmissaoController;
  late final TextEditingController _cartaoSusController;

  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    final paciente = context.read<AppState>().paciente;

    _cpfController = TextEditingController(
      text: paciente.cpf,
    );

    _rgCinController = TextEditingController(
      text: paciente.rgCin,
    );

    _orgaoController = TextEditingController(
      text: paciente.orgaoExpedidor,
    );

    _dataEmissaoController = TextEditingController(
      text: paciente.dataEmissaoDocumento,
    );

    _cartaoSusController = TextEditingController(
      text: paciente.cartaoSus,
    );
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _rgCinController.dispose();
    _orgaoController.dispose();
    _dataEmissaoController.dispose();
    _cartaoSusController.dispose();

    super.dispose();
  }

  Future<void> _salvar() async {
    setState(() {
      _salvando = true;
    });

    try {
      await context.read<AppState>().atualizarDocumentos(
            cpf: _cpfController.text,
            rgCin: _rgCinController.text,
            orgaoExpedidor: _orgaoController.text,
            dataEmissaoDocumento: _dataEmissaoController.text,
            cartaoSus: _cartaoSusController.text,
          );

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Documentos atualizados com sucesso!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível atualizar os documentos.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Editar documentos',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Preencha apenas os documentos que deseja informar.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cpfController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'CPF',
                hintText: '000.000.000-00',
                prefixIcon: Icon(
                  Icons.badge_outlined,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rgCinController,
              decoration: const InputDecoration(
                labelText: 'RG / CIN',
                prefixIcon: Icon(
                  Icons.credit_card_outlined,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _orgaoController,
              decoration: const InputDecoration(
                labelText: 'Órgão expedidor',
                hintText: 'Ex.: SSP-SP',
                prefixIcon: Icon(
                  Icons.account_balance_outlined,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dataEmissaoController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Data de emissão',
                hintText: 'DD/MM/AAAA',
                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cartaoSusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cartão SUS',
                prefixIcon: Icon(
                  Icons.health_and_safety_outlined,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text(
            'Cancelar',
          ),
        ),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          child: _salvando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Salvar',
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card do cuidador
// ─────────────────────────────────────────────────────────────────────────────

class _CardRedeCuidado
    extends StatelessWidget {
  const _CardRedeCuidado();

  Future<void> _abrirWhatsApp(
    BuildContext context,
  ) async {
    final uri = Uri.parse(
      'https://wa.me/',
    );

    try {
      final abriu = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!abriu && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível abrir o WhatsApp.',
              style: GoogleFonts.poppins(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.white,
            behavior:
                SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível abrir o WhatsApp.',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state =
        context.watch<AppState>();
    final p = state.paciente;

    return _InfoCard(
      title: 'Minha rede de cuidado',
      children: [
        // ========================================================
        // CUIDADOR
        // ========================================================

        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primary
                    .withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons
                    .health_and_safety_outlined,
                size: 20,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cuidador',
                style:
                    GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      AppTheme.textPrimary,
                ),
              ),
            ),
            if (state.temCuidador)
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  'Vinculado',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppTheme.primary,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        if (state.temCuidador) ...[
          _InfoRow(
            label: 'Nome',
            value:
                state.cuidadorNome ??
                    'Cuidador',
          ),
          _InfoRow(
            label: 'Turno',
            value: p.cuidadorTurno,
          ),
          _InfoRow(
            label: 'Carga horária',
            value: p.cuidadorCarga,
          ),
        ] else ...[
          Text(
            'Nenhum cuidador vinculado.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color:
                  AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              _abrirWhatsApp(context);
            },
            icon: const Icon(
              Icons.chat_outlined,
              size: 18,
            ),
            label: Text(
              'Compartilhar código',
              style:
                  GoogleFonts.poppins(
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],

        const Padding(
          padding:
              EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Divider(
            height: 1,
          ),
        ),

        // ========================================================
        // FAMILIARES
        // ========================================================

        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primary
                    .withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.people_outline,
                size: 20,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Familiares',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight:
                    FontWeight.w700,
                color:
                    AppTheme.textPrimary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (state
            .familiaresVinculados
            .isEmpty)
          Text(
            'Nenhum familiar vinculado.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color:
                  AppTheme.textSecondary,
            ),
          )
        else
          ...state.familiaresVinculados
              .map(
            (familiar) {
              final nome =
                  familiar['nome'] ??
                      'Familiar';

              return Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 8,
                ),
                padding:
                    const EdgeInsets.all(
                  11,
                ),
                decoration: BoxDecoration(
                  color:
                      AppTheme.background,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          AppTheme.primary,
                      child: Icon(
                        Icons
                            .person_outline,
                        color:
                            Colors.white,
                        size: 17,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        nome,
                        style:
                            GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight:
                              FontWeight
                                  .w600,
                          color: AppTheme
                              .textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      'Familiar',
                      style:
                          GoogleFonts.poppins(
                        fontSize: 9,
                        color: AppTheme
                            .textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
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
            color: selecionada
                ? AppTheme.surface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: selecionada
                  ? FontWeight.w600
                  : FontWeight.w400,
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