import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../models/app_state.dart';
import '../../widgets/shared.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _erro;

  Future<void> _criar() async {
    final nome = _nomeCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text;

    // Validação básica
    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      setState(() {
        _erro = 'Preencha todos os campos.';
      });
      return;
    }

    if (senha.length < 6) {
      setState(() {
        _erro = 'A senha deve ter pelo menos 6 caracteres.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      // 1. Cria o usuário no Firebase Authentication
      final credencial = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final user = credencial.user;

      if (user == null) {
        throw Exception('Não foi possível criar o usuário.');
      }

      // 2. Atualiza o nome do usuário no Firebase Auth
      await user.updateDisplayName(nome);

      // 3. Salva os dados básicos no AppState
      if (!mounted) return;

      context.read<AppState>().usuarioCriado(
        nome: nome,
        email: email,
      );

      // 4. Vai para escolha do perfil
      context.go('/perfil');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensagem;

      switch (e.code) {
        case 'email-already-in-use':
          mensagem = 'Este email já está cadastrado.';
          break;

        case 'invalid-email':
          mensagem = 'Digite um email válido.';
          break;

        case 'weak-password':
          mensagem = 'A senha é muito fraca. Use pelo menos 6 caracteres.';
          break;

        case 'operation-not-allowed':
          mensagem = 'O cadastro por email e senha não está habilitado no Firebase.';
          break;

        case 'network-request-failed':
          mensagem = 'Erro de conexão. Verifique sua internet.';
          break;

        default:
          mensagem = 'Não foi possível criar a conta. Tente novamente.';
      }

      setState(() {
        _erro = mensagem;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = 'Ocorreu um erro ao criar a conta.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
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
            children: [
              const SizedBox(height: 32),

              const AuthHeader(),

              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Criar conta',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _label('Nome completo'),

              const SizedBox(height: 6),

              HCField(
                hint: 'João Silva',
                controller: _nomeCtrl,
              ),

              const SizedBox(height: 14),

              _label('Email'),

              const SizedBox(height: 6),

              HCField(
                hint: 'seuemail@exemplo.com',
                controller: _emailCtrl,
                keyboard: TextInputType.emailAddress,
              ),

              const SizedBox(height: 14),

              _label('Senha'),

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

              if (_erro != null) ...[
                const SizedBox(height: 12),

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

              HCButton(
                label: 'Criar conta',
                onTap: _criar,
                loading: _loading,
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Já tenho conta',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),

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

  Widget _label(String texto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        texto,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

