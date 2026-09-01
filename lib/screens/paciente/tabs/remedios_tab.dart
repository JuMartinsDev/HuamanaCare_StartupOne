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
  int _filtro = 0; // Hoje / Semana / Todos (visual)

  void _abrirAdicionar() {
    final nome = TextEditingController();
    final tipo = TextEditingController(text: 'Comprimido');
    final horario = TextEditingController();
    String? erro;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(3)),
                  ),
                ),
                Text('Adicionar medicamento',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary)),
                const SizedBox(height: 16),
                HCFieldBorda(hint: 'Nome do medicamento', controller: nome),
                const SizedBox(height: 12),
                HCFieldBorda(hint: 'Tipo (ex.: Comprimido)', controller: tipo),
                const SizedBox(height: 12),
                HCFieldBorda(hint: 'Horário (HH:MM)', controller: horario),
                if (erro != null) ...[
                  const SizedBox(height: 8),
                  Text(erro!,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.error)),
                ],
                const SizedBox(height: 20),
                HCButton(
                  label: 'Salvar',
                  onTap: () {
                    final h = horario.text.trim();
                    final valido =
                        RegExp(r'^([01]?\d|2[0-3]):[0-5]\d$').hasMatch(h);
                    if (nome.text.trim().isEmpty || !valido) {
                      setSheet(() => erro =
                          'Informe um nome e um horário válido (HH:MM).');
                      return;
                    }
                    context.read<AppState>().addRemedio(
                          Remedio(
                            id: 'r${DateTime.now().millisecondsSinceEpoch}',
                            nome: nome.text.trim(),
                            tipo: tipo.text.trim().isEmpty
                                ? 'COMPRIMIDO'
                                : tipo.text.trim().toUpperCase(),
                            horario: h,
                          ),
                        );
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remedios = context.watch<AppState>().remedios;
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 14),
          Text('Remédios',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _Segmented(
              labels: const ['Hoje', 'Semana', 'Todos'],
              index: _filtro,
              onChange: (i) => setState(() => _filtro = i),
            ),
          ),
          const SizedBox(height: 8),
          Text('Sexta-feira, 12 de maio',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          Expanded(
            child: remedios.isEmpty
                ? _vazio()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    itemCount: remedios.length + 1,
                    itemBuilder: (_, i) {
                      if (i == remedios.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: HCButton(
                              label: '+  Adicionar medicamento',
                              onTap: _abrirAdicionar),
                        );
                      }
                      return _MedCard(r: remedios[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _vazio() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.medication_outlined,
                  size: 44, color: AppTheme.textLight),
              const SizedBox(height: 10),
              Text('Nenhum medicamento',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text('Cadastre o primeiro para receber lembretes de horário.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              HCButton(
                  label: '+  Adicionar medicamento', onTap: _abrirAdicionar),
            ],
          ),
        ),
      );
}

class _MedCard extends StatelessWidget {
  final Remedio r;
  const _MedCard({required this.r});

  @override
  Widget build(BuildContext context) {
    final tomado = r.tomado;
    return GestureDetector(
      onTap: () => context.read<AppState>().toggleRemedio(r.id),
      onLongPress: () => _confirmarRemover(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppTheme.primary),
              child:
                  const Icon(Icons.medication, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Text(r.nome,
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(r.tipo,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          letterSpacing: 0.5,
                          color: AppTheme.textSecondary)),
                  Text(r.horario,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            _pill(tomado),
          ],
        ),
      ),
    );
  }

  Widget _pill(bool tomado) {
    final bg = tomado ? const Color(0xFFBFE3CE) : const Color(0xFF8FC7BB);
    final fg = tomado ? const Color(0xFF1F6E5A) : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(tomado ? 'Tomado' : 'Pendente',
          style: GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  void _confirmarRemover(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remover ${r.nome}?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Esta ação não pode ser desfeita.',
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: GoogleFonts.poppins())),
          TextButton(
            onPressed: () {
              context.read<AppState>().removeRemedio(r.id);
              Navigator.pop(ctx);
            },
            child: Text('Remover',
                style: GoogleFonts.poppins(
                    color: AppTheme.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChange;
  const _Segmented(
      {required this.labels, required this.index, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onChange(i),
              child: Container(
                margin:
                    EdgeInsets.only(right: i < labels.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index == i ? const Color(0xFFFDF6E3) : AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: index == i
                          ? const Color(0xFFEFE2B6)
                          : AppTheme.divider),
                ),
                child: Text(labels[i],
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color:
                            index == i ? AppTheme.accent : AppTheme.textLight)),
              ),
            ),
          ),
      ],
    );
  }
}
