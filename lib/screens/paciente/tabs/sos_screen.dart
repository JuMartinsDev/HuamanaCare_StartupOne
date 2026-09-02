import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/app_state.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  static const Color _vermelho = Color(0xFFB23A36);

  // ============================================================
  // CONFIRMAÇÃO DO SOS
  // ============================================================

  Future<void> _confirmarSos(
    BuildContext context,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _vermelho.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: _vermelho,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Acionar emergência?',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'O SOS será registrado e o contato de emergência e o cuidador principal serão avisados.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.4,
              color: Colors.black54,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _vermelho,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                'Acionar SOS',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      await context.read<AppState>().acionarSos();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'SOS acionado com sucesso.',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível acionar o SOS. Tente novamente.',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final acionado =
        context.watch<AppState>().sosAtivado;

    return Scaffold(
      backgroundColor: _vermelho,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
          ),
          child: Column(
            children: [
              // ==================================================
              // FECHAR
              // ==================================================

              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),

              const Spacer(),

              // ==================================================
              // ÍCONE
              // ==================================================

              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 250,
                ),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(
                    acionado ? 0.24 : 0.16,
                  ),
                ),
                child: Icon(
                  acionado
                      ? Icons.check_rounded
                      : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // TÍTULO
              // ==================================================

              Text(
                acionado
                    ? 'Emergência acionada'
                    : 'Acionar emergência',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // DESCRIÇÃO
              // ==================================================

              Text(
                acionado
                    ? 'O contato de emergência e o cuidador principal foram notificados.'
                    : 'Vamos registrar o SOS e avisar o contato de emergência e o cuidador principal.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),

              const Spacer(),

              // ==================================================
              // BOTÃO SOS
              // ==================================================

              if (!acionado)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _confirmarSos(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _vermelho,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(26),
                      ),
                    ),
                    child: Text(
                      'Acionar SOS',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              // ==================================================
              // ESTADO ACIONADO
              // ==================================================

              if (acionado)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(
                        0.25,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'O atendimento de emergência está sendo acionado.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            height: 1.35,
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // ==================================================
              // VOLTAR
              // ==================================================

              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text(
                  acionado ? 'Voltar' : 'Cancelar',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}