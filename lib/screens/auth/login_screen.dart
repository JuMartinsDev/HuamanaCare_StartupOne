import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> _esqueciMinhaSenha() async {
    final emailController = TextEditingController(
      text: _emailCtrl.text.trim(),
    );

    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Redefinir senha',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Digite o email da sua conta. Enviaremos um link para você criar uma nova senha.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'seuemail@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final email = emailController.text.trim();

                if (email.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(email);
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    emailController.dispose();

    if (!mounted || email == null || email.isEmpty) {
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email de redefinição enviado! Verifique sua caixa de entrada.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensagem;

      switch (e.code) {
        case 'invalid-email':
          mensagem = 'Informe um email válido.';
          break;
        case 'user-not-found':
          mensagem = 'Não encontramos uma conta com esse email.';
          break;
        case 'too-many-requests':
          mensagem =
              'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
          break;
        default:
          mensagem =
              'Não foi possível enviar o email. Tente novamente.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível enviar o email. Tente novamente.',
          ),
        ),
      );
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
                    : _esqueciMinhaSenha,
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