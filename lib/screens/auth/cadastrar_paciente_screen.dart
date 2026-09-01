import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared.dart';

class CadastrarPacienteScreen extends StatefulWidget {
  const CadastrarPacienteScreen({super.key});
  @override
  State<CadastrarPacienteScreen> createState() => _CadastrarPacienteScreenState();
}

class _CadastrarPacienteScreenState extends State<CadastrarPacienteScreen> {
  final _nome       = TextEditingController();
  final _dataNasc   = TextEditingController();
  final _alergias   = TextEditingController();
  final _medicamentos = TextEditingController();
  final _condicao   = TextEditingController();
  final _obs        = TextEditingController();
  bool _loading = false;

  Future<void> _salvar() async {
    if (_nome.text.isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) { setState(() => _loading = false); context.go('/paciente'); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.go('/perfil'),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppTheme.textPrimary),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 12),

              Text('Cadrastrar Paciente',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text('Preencha as informações\nprincipais do paciente',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.primary)),
              const SizedBox(height: 24),

              // Avatar
              Stack(
                children: [
                  Container(
                    width: 88, height: 88,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary),
                    child: const Icon(Icons.person, size: 44, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.accent),
                      child: const Icon(Icons.add, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              HCFieldBorda(hint: 'Nome completo',      controller: _nome),
              const SizedBox(height: 12),
              HCFieldBorda(hint: 'Data de nascimento', controller: _dataNasc),
              const SizedBox(height: 12),
              HCFieldBorda(hint: 'Alergias',           controller: _alergias),
              const SizedBox(height: 12),
              HCFieldBorda(hint: 'Medicamentos em uso',controller: _medicamentos),
              const SizedBox(height: 12),
              HCFieldBorda(hint: 'Condição de saúde',  controller: _condicao),
              const SizedBox(height: 12),
              HCFieldBorda(hint: 'Observações',        controller: _obs, maxLines: 3),
              const SizedBox(height: 28),

              HCButton(label: 'Salvar paciente', onTap: _salvar, loading: _loading),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
