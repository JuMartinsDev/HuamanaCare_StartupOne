import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../models/app_state.dart';
import '../../widgets/shared.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(
    text: 'gustavo@exemplo.com',
  );

  final _senhaCtrl = TextEditingController(
    text: '123456',
  );

  bool _obscure = true;
  bool _loading = false;
  String? _erro;

  Future<void> _entrar() async {
    // Validação dos campos
    if (_emailCtrl.text.trim().isEmpty || _senhaCtrl.text.isEmpty) {
      setState(() {
        _erro = 'Preencha email e senha.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      // Login real usando Firebase Authentication
      final sucesso = await context.read<AppState>().loginFirebase(
            _emailCtrl.text.trim(),
            _senhaCtrl.text,
          );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      if (sucesso) {
        context.go('/paciente');
      } else {
        setState(() {
          _erro = 'Email ou senha incorretos.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _erro = 'Não foi possível realizar o login. Tente novamente.';
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              const AuthHeader(),

              const SizedBox(height: 48),

              // Título
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Login',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Email
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              HCField(
                hint: 'seuemail@exemplo.com',
                controller: _emailCtrl,
                keyboard: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // Senha
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Senha',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              HCField(
                hint: '••••••••',
                controller: _senhaCtrl,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.textLight,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                ),
              ),

              // Erro
              if (_erro != null) ...[
                const SizedBox(height: 10),
                Text(
                  _erro!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: AppTheme.error,
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Entrar
              HCButton(
                label: 'Entrar',
                onTap: _entrar,
                loading: _loading,
              ),

              const SizedBox(height: 12),

              // Esqueci a senha
              TextButton(
                onPressed: () {},
                child: Text(
                  'Esqueci a senha',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),

              const Divider(
                height: 32,
                color: AppTheme.divider,
              ),

              // Criar conta
              HCOutlineButton(
                label: 'Cria conta',
                onTap: () => context.go('/register'),
              ),

              const SizedBox(height: 16),

              // Termos
              TextButton(
                onPressed: () {},
                child: Text(
                  'Termos de uso',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textLight,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

