import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class AlertasScreen extends StatelessWidget {
  const AlertasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final medicamentosPendentes =
        state.remedios.where((remedio) => !remedio.tomado).toList();

final agora = DateTime.now();

    final compromissos = state.compromissos.where((compromisso) {
      final data = compromisso.data;
      return data != null && !data.isBefore(agora);
    }).toList();

    final totalAlertas =
        medicamentosPendentes.length + compromissos.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Alertas',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: totalAlertas == 0
            ? _EstadoVazio()
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ResumoAlertas(total: totalAlertas),

                    const SizedBox(height: 24),

                    if (medicamentosPendentes.isNotEmpty) ...[
                      _tituloSecao('Medicamentos'),

                      const SizedBox(height: 12),

                      for (final remedio in medicamentosPendentes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AlertaCard(
                            icone: Icons.medication_outlined,
                            titulo: remedio.nome,
                            descricao:
                                'Medicamento pendente às ${remedio.horario}',
                            cor: AppTheme.primary,
                          ),
                        ),

                      const SizedBox(height: 14),
                    ],

                    if (compromissos.isNotEmpty) ...[
                      _tituloSecao('Compromissos'),

                      const SizedBox(height: 12),

                      for (final compromisso in compromissos)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AlertaCard(
                            icone: Icons.calendar_today_outlined,
                            titulo: compromisso.titulo,
                            descricao:
                                '${compromisso.diaAbrev}, ${compromisso.dia} de ${compromisso.mesAbrev} • ${compromisso.horario}',
                            detalhe: compromisso.local,
                            cor: AppTheme.accent,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _tituloSecao(String texto) {
    return Text(
      texto,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _ResumoAlertas extends StatelessWidget {
  final int total;

  const _ResumoAlertas({
    required this.total,
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
          color: AppTheme.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppTheme.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total ${total == 1 ? 'alerta' : 'alertas'}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Itens que precisam da sua atenção',
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

class _AlertaCard extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final String? detalhe;
  final Color cor;

  const _AlertaCard({
    required this.icone,
    required this.titulo,
    required this.descricao,
    this.detalhe,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icone,
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
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  descricao,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (detalhe != null && detalhe!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    detalhe!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textLight,
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

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

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
                color: AppTheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppTheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Tudo em dia!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Não há alertas no momento.',
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