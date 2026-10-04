import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../../models/app_state.dart';
import '../../../models/models.dart';
import '../../../services/gemini_service.dart';

class ChatTab extends StatefulWidget {
  final String canalInicial;

  const ChatTab({
    super.key,
    this.canalInicial = 'familia',
  });

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  late String _canal;

String _canalFirestore(
  AppState state,
) {
  switch (_canal) {
    case 'familia':
      return state.canalFamilia;

    case 'cuidador':
      return state.canalCuidadorPaciente;

    case 'familiar':
      return state
              .canalPacienteFamiliarUsuarioAtual ??
          '';

    case 'milo':
      return state
              .canalMiloUsuarioAtual ??
          '';

    default:
      return '';
  }
}

  @override
  void initState() {
    super.initState();
    _canal = widget.canalInicial;
  }

  final _input = TextEditingController();
  final _scroll = ScrollController();

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

  Future<void> _enviar() async {
    final txt = _input.text.trim();

    if (txt.isEmpty) return;

    final state = context.read<AppState>();

    final canalFirestore = _canalFirestore(state);

    if (canalFirestore.isEmpty) {
      return;
    }

    final idMensagemUsuario = 'u${DateTime.now().millisecondsSinceEpoch}';

    try {
      await state.addMensagem(
        canalFirestore,
        Mensagem(
          id: idMensagemUsuario,
          texto: txt,
          recebido: false,
          hora: _horaAgora(),
        ),
      );

      _input.clear();
      _rolarParaFim();

      // Resposta automática apenas no canal Milo.
      if (_canal != 'milo') return;

      try {
        final paciente = state.paciente;
        final remedios = state.remedios;
        final compromissos = state.compromissos;

        // Monta o histórico sem repetir a mensagem atual.
        final historico = <Map<String, String>>[];

        final resposta = await GeminiService.enviarMensagem(
          mensagemUsuario: txt,
          historico: historico,
          paciente: paciente,
          remedios: remedios,
          compromissos: compromissos,
        );

        debugPrint(
          '[ChatTab] Resposta recebida: '
          '${resposta.substring(0, resposta.length > 80 ? 80 : resposta.length)}',
        );

        debugPrint('[ChatTab] Canal atual: $_canal');

        if (!mounted) return;

        debugPrint('[ChatTab] Salvando resposta do Milo...');

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

        debugPrint(
          '[ChatTab] Resposta salva. Total de mensagens: '
          '${state.mensagens(_canal).length}',
        );

        _rolarParaFim();
      } catch (e, stackTrace) {
        debugPrint('Erro no fluxo do Milo: $e');
        debugPrintStack(stackTrace: stackTrace);

        if (!mounted) return;

        try {
          await state.addMensagem(
            canalFirestore,
            Mensagem(
              id: 'a${DateTime.now().millisecondsSinceEpoch}',
              texto:
                  'Não foi possível obter a resposta do Milo agora. Tente novamente.',
              recebido: true,
              hora: _horaAgora(),
              isMilo: true,
              remetente: 'Milo',
            ),
          );
        } catch (erroSalvar) {
          debugPrint(
            'Erro ao salvar resposta do Milo: $erroSalvar',
          );
        }

        _rolarParaFim();
      }
    } catch (e, stackTrace) {
      debugPrint('Erro ao enviar mensagem: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível enviar a mensagem.'),
        ),
      );
    }
  }

  void _rolarParaFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
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

  Widget _separadorData(DateTime data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
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
      ),
    );
  }

String _nomeChat(AppState state) {
  switch (_canal) {
    case 'cuidador':
      final nomeCuidador = state.cuidadorNome;

      if (nomeCuidador != null &&
          nomeCuidador.trim().isNotEmpty) {
        return nomeCuidador;
      }

      if (state.paciente.cuidadorNome.trim().isNotEmpty) {
        return state.paciente.cuidadorNome;
      }

      return 'Cuidador';

    case 'familiar':
      return 'Familiar';

    case 'milo':
      return 'Milo';

    case 'familia':
      return 'Família';

    default:
      return 'Chat';
  }
}

String _subtituloChat(
  AppState state,
) {
  switch (_canal) {
    case 'cuidador':
      return 'Cuidador';

    case 'familiar':
      if (state.familiaresVinculados.isNotEmpty) {
        final nome =
            state.familiaresVinculados.first['nome'] ?? '';

        if (nome.trim().isNotEmpty) {
          return nome;
        }
      }

      return 'Familiar vinculado';

    case 'milo':
      return 'Assistente virtual';

    case 'familia':
      return 'Grupo da família';

    default:
      return '';
  }
}

  Widget _cabecalhoChat(AppState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F4F1),
              borderRadius: BorderRadius.circular(14),
            ),
child: Icon(
  _canal == 'familia'
      ? Icons.groups_rounded
      : _canal == 'milo'
          ? Icons.smart_toy_rounded
          : Icons.person_rounded,
              color: AppTheme.primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nomeChat(state),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                    _subtituloChat(state),
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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final canalFirestore = _canalFirestore(state);

    final msgs = canalFirestore.isEmpty
        ? <Mensagem>[]
        : state.mensagens(
            canalFirestore,
          );

    for (final m in msgs) {
      debugPrint(
        '[ORDEM] id=${m.id} | recebido=${m.recebido} | '
        'milo=${m.isMilo} | hora=${m.hora} | '
        'criadaEm=${m.criadaEm} | texto=${m.texto}',
      );
    }

    return SafeArea(
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
        child: Column(
          children: [
            _cabecalhoChat(state),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
  children: [
    _canalChip(
      'Família',
      'familia',
    ),
    const SizedBox(width: 5),

    _canalChip(
      'Cuidador',
      'cuidador',
    ),
    const SizedBox(width: 5),

    _canalChip(
      'Familiar',
      'familiar',
    ),
    const SizedBox(width: 5),

    _canalChip(
      'Milo',
      'milo',
    ),
  ],
),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: msgs.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma mensagem ainda.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textLight,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        16,
                      ),
                      itemCount: msgs.length,
                      itemBuilder: (_, i) {
                        final mensagem = msgs[i];

                        final mostrarData = i == 0 ||
                            !_mesmoDia(
                              msgs[i - 1],
                              mensagem,
                            );

                        return Column(
                          children: [
                            if (mostrarData)
                              _separadorData(
                                mensagem.criadaEm,
                              ),
                            _Bubble(
                              m: mensagem,
                            ),
                          ],
                        );
                      },
                    ),
            ),
            _barra(),
          ],
        ),
      ),
    );
  }

  Widget _canalChip(
    String label,
    String id,
  ) {
    final on = _canal == id;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _canal = id);
          _rolarParaFim();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 9,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? const Color(0xFFFDF6E3) : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: on ? const Color(0xFFEFE2B6) : AppTheme.divider,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: on ? AppTheme.accent : AppTheme.textLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _barra() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _input,
                onSubmitted: (_) => _enviar(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: _canal == 'milo'
                      ? 'Pergunte ao Milo…'
                      : 'Escreva uma mensagem…',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textLight,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _enviar,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Mensagem m;

  const _Bubble({
    required this.m,
  });

  @override
  Widget build(BuildContext context) {
    final eu = !m.recebido;

    return Align(
      alignment: eu ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: eu ? AppTheme.primary : const Color(0xFFE0F4F1),
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.recebido && m.remetente != null)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 2,
                ),
                child: Text(
                  m.remetente!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: m.isMilo ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ),
              ),
            Text(
              m.texto,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.3,
                color: eu ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                m.hora,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: eu
                      ? Colors.white.withOpacity(0.75)
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
