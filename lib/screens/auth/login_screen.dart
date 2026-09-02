import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/app_state.dart';
import '../../widgets/shared.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _erro;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text;

    if (email.isEmpty || senha.isEmpty) {
      setState(() {
        _erro = 'Preencha seu email e sua senha.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      final appState = context.read<AppState>();

      await appState.login(email, senha);

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      // Depois do login, verifica se o usuário já possui perfil.
      if (appState.perfil.isEmpty) {
        context.go('/perfil');
      } else {
        context.go('/paciente');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _erro = e.toString().replaceFirst('Exception: ', '');
      });
    }
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(),

              const SizedBox(height: 36),

              Text(
                'Entrar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Acesse sua conta para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 28),

              HCField(
                hint: 'Email',
                controller: _emailCtrl,
                keyboard: TextInputType.emailAddress,
              ),

              const SizedBox(height: 14),

              HCField(
                hint: 'Senha',
                controller: _senhaCtrl,
                obscure: _obscure,
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),

              if (_erro != null) ...[
                const SizedBox(height: 12),

                Text(
                  _erro!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              HCButton(
                label: 'Entrar',
                onTap: _entrar,
                loading: _loading,
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        context.go('/register');
                      },
                child: Text(
                  'Ainda não tenho uma conta',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        // Recuperação de senha será implementada
                        // posteriormente com Firebase Auth.
                      },
                child: Text(
                  'Esqueci minha senha',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
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