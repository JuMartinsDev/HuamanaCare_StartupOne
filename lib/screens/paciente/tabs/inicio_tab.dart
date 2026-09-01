import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../models/app_state.dart';
import '../../../models/models.dart';
import '../../../data/mock_data.dart';

class InicioTab extends StatelessWidget {
  const InicioTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final p = state.paciente;
    final pendentes = state.remedios.where((r) => !r.tomado).length;
    final c = MockData.compromisso;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header verde + card do paciente sobreposto ──
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 56),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF7CC4B6), Color(0xFF4EA596)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Olá, ${p.nome.split(' ').first} !',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Hoje é dia 12 de maio de 2026',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9))),
                    ],
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -34,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Row(
                      children: [
                        _avatar(56),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.nome,
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary)),
                              const SizedBox(height: 2),
                              Text('${p.idade} anos  .  ID: ${p.id}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: AppTheme.textLight),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Resumo do dia',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      Text('Ver tudo',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accent)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ResumoRow(
                      icone: Icons.medication_outlined,
                      titulo: 'Medicamentos',
                      sub: '$pendentes pendentes'),
                  const SizedBox(height: 10),
                  _ResumoRow(
                      icone: Icons.notifications_none_rounded,
                      titulo: 'Alertas',
                      sub: '1 não lido'),
                  const SizedBox(height: 22),
                  Text('Próximo compromisso',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  const _MiniCalendar(mes: 5, ano: 2026, diaDestaque: 15),
                  const SizedBox(height: 12),
                  _CompromissoCard(c: c),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _avatar(double s) => Container(
        width: s,
        height: s,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary),
        child: const Icon(Icons.person, color: Colors.white, size: 26),
      );
}

class _ResumoRow extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String sub;
  const _ResumoRow(
      {required this.icone, required this.titulo, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Icon(icone, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(sub,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 14, color: AppTheme.textLight),
        ],
      ),
    );
  }
}

class _CompromissoCard extends StatelessWidget {
  final Compromisso c;
  const _CompromissoCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F4F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(c.mesAbrev,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary)),
                Text('${c.dia}',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        color: AppTheme.primary)),
                Text(c.diaAbrev,
                    style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.titulo,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                Text(c.local,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Text(c.horario,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary)),
        ],
      ),
    );
  }
}

class _MiniCalendar extends StatelessWidget {
  final int mes;
  final int ano;
  final int diaDestaque;
  const _MiniCalendar(
      {required this.mes, required this.ano, required this.diaDestaque});

  @override
  Widget build(BuildContext context) {
    final primeiro = DateTime(ano, mes, 1);
    final diasNoMes = DateTime(ano, mes + 1, 0).day;
    final offset = primeiro.weekday - 1; // Mon=1..Sun=7
    final mesAntDias = DateTime(ano, mes, 0).day;
    const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    final flat = <Map<String, int>>[];
    for (int i = 0; i < offset; i++) {
      flat.add({'d': mesAntDias - offset + 1 + i, 'cur': 0});
    }
    for (int d = 1; d <= diasNoMes; d++) {
      flat.add({'d': d, 'cur': 1});
    }
    int prox = 1;
    while (flat.length < 42) {
      flat.add({'d': prox++, 'cur': 0});
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF6E3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Maio',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accent)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: labels
                .map((l) => Expanded(
                      child: Center(
                        child: Text(l,
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textLight)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          for (int w = 0; w < 6; w++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  for (int dow = 0; dow < 7; dow++) _celula(flat[w * 7 + dow], dow),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _celula(Map<String, int> info, int dow) {
    final d = info['d']!;
    final cur = info['cur'] == 1;
    final destaque = cur && d == diaDestaque;
    final fimDeSemana = dow >= 5;
    Color cor;
    if (!cur) {
      cor = const Color(0xFFC4D3CE);
    } else if (destaque) {
      cor = Colors.white;
    } else if (fimDeSemana) {
      cor = AppTheme.primary;
    } else {
      cor = AppTheme.textPrimary;
    }
    return Expanded(
      child: Center(
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: destaque
              ? const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary)
              : null,
          child: Text('$d',
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: destaque ? FontWeight.w700 : FontWeight.w500,
                  color: cor)),
        ),
      ),
    );
  }
}
