import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    if (!mounted || confirmar != true) return;

    await context.read<AppState>().logout();

    if (!mounted) return;

    context.go('/login');
  }

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
            // ── Cabeçalho ──────────────────────────────────────────────
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

            // ── Identificação ─────────────────────────────────────────
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

            const SizedBox(height: 20),

            // ── Código de vínculo ─────────────────────────────────────
            _CardCodigoVinculo(
              codigo: state.codigoVinculo,
            ),

            const SizedBox(height: 24),

            // ── Abas ──────────────────────────────────────────────────
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

            // ── Conteúdo da aba ───────────────────────────────────────
            if (_abaSelecionada == 0)
              _InformacoesPaciente(p: p)
            else if (_abaSelecionada == 1)
              const _Historico()
            else
              const _Documentos(),

            const SizedBox(height: 24),

            // ── Cuidador ──────────────────────────────────────────────
            if (_abaSelecionada == 0) _CardCuidador(p: p),

            const SizedBox(height: 12),

            // ── Sair ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmarSaida,
                icon: const Icon(
                  Icons.logout_outlined,
                  size: 19,
                ),
                label: const Text(
                  'Sair da conta',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(
                    color: Colors.red.withValues(alpha: 0.35),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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