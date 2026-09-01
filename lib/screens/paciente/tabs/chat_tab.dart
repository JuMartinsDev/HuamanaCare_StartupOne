import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../models/app_state.dart';
import '../../../models/models.dart';
import '../../../services/gemini_service.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});
  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  String _canal = 'familia';
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _rng = Random();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _horaAgora() {
    final t = TimeOfDay.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _enviar() {
    final txt = _input.text.trim();
    if (txt.isEmpty) return;
    final state = context.read<AppState>();
    state.addMensagem(
      _canal,
      Mensagem(
          id: 'u${DateTime.now().millisecondsSinceEpoch}',
          texto: txt,
          recebido: false,
          hora: _horaAgora()),
    );
    _input.clear();
    _rolarParaFim();

    // Resposta automática APENAS no canal "milo" (Gemini / demo).
    // Para remover completamente as falas mockadas dos outros canais,
    // não geramos respostas para "familia" e "cuidador".
    if (_canal != 'milo') return;

    () async {
      try {
        // Monte o histórico simples (texto + papel) a partir das mensagens do canal atual.
        // O AppState guarda um Map de mensagens por canal.
        final historico = <Map<String, String>>[];
        final msgs = state.mensagens(_canal);

        for (final m in msgs) {
          historico.add({
            'role': (m.recebido ? 'model' : 'user'),
            'text': m.texto,
          });
        }

        final resposta = await GeminiService.enviarMensagem(
          mensagemUsuario: txt,
          historico: historico,
        );

        if (!mounted) return;
        state.addMensagem(
          _canal,
          Mensagem(
            id: 'a${DateTime.now().millisecondsSinceEpoch}',
            texto: resposta,
            recebido: true,
            hora: _horaAgora(),
            isMilo: true,
            remetente: 'Milo',
          ),
        );
      } catch (_) {
        if (!mounted) return;
        state.addMensagem(
          _canal,
          Mensagem(
            id: 'a${DateTime.now().millisecondsSinceEpoch}',
            texto: 'Não foi possível obter a resposta do Milo agora. Tente novamente.',
            recebido: true,
            hora: _horaAgora(),
            isMilo: true,
            remetente: 'Milo',
          ),
        );
      } finally {
        _rolarParaFim();
      }
    }();

  }


  void _rolarParaFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final msgs = context.watch<AppState>().mensagens(_canal);
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 14),
          Text('Chat',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _canalChip('Família', 'familia'),
                const SizedBox(width: 8),
                _canalChip('Cuidador', 'cuidador'),
                const SizedBox(width: 8),
                _canalChip('Milo', 'milo'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: msgs.isEmpty
                ? Center(
                    child: Text('Nenhuma mensagem ainda.',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppTheme.textLight)))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    itemCount: msgs.length,
                    itemBuilder: (_, i) => _Bubble(m: msgs[i]),
                  ),
          ),
          _barra(),
        ],
      ),
    );
  }

  Widget _canalChip(String label, String id) {
    final on = _canal == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _canal = id);
          _rolarParaFim();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? const Color(0xFFFDF6E3) : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: on ? const Color(0xFFEFE2B6) : AppTheme.divider),
          ),
          child: Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: on ? AppTheme.accent : AppTheme.textLight)),
        ),
      ),
    );
  }

  Widget _barra() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _input,
                onSubmitted: (_) => _enviar(),
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: _canal == 'milo'
                      ? 'Pergunte ao Milo…'
                      : 'Escreva uma mensagem…',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 14, color: AppTheme.textLight),
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
                  shape: BoxShape.circle, color: AppTheme.primary),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Mensagem m;
  const _Bubble({required this.m});

  @override
  Widget build(BuildContext context) {
    final eu = !m.recebido;
    return Align(
      alignment: eu ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: eu ? AppTheme.primary : const Color(0xFFE0F4F1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(eu ? 16 : 4),
            bottomRight: Radius.circular(eu ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.recebido && m.remetente != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(m.remetente!,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: m.isMilo
                            ? AppTheme.primary
                            : AppTheme.textSecondary)),
              ),
            Text(m.texto,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.3,
                    color: eu ? Colors.white : AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}
