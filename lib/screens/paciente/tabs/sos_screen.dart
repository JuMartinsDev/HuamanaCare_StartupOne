import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/app_state.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  static const Color _vermelho = Color(0xFFB23A36);

  @override
  Widget build(BuildContext context) {
    final acionado = context.watch<AppState>().sosAtivado;
    return Scaffold(
      backgroundColor: _vermelho,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 26),
                ),
              ),
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.16)),
                child: Icon(
                    acionado ? Icons.check_rounded : Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 64),
              ),
              const SizedBox(height: 28),
              Text(acionado ? 'Emergência acionada' : 'Acionar emergência',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 12),
              Text(
                acionado
                    ? 'O contato de emergência e o cuidador principal foram notificados.'
                    : 'Vamos ligar para o contato de emergência e avisar o cuidador principal de Gustavo.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.white.withOpacity(0.9)),
              ),
              const Spacer(),
              if (!acionado)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.read<AppState>().acionarSos(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _vermelho,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26)),
                    ),
                    child: Text('Ligar agora',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: Text('Voltar',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
