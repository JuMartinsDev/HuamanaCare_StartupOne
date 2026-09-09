import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../models/app_state.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String? _sel;

  final _codigoController = TextEditingController();

  bool _carregando = false;

  final _opcoes = [
    {
      'id': 'familiar',
      'titulo': 'Familiar',
      'desc': 'Acompanhe e gerencie a saúde de quem você ama.',
    },
    {
      'id': 'cuidador',
      'titulo': 'Cuidador',
      'desc': 'Gerencie tarefas e cuide do bem-estar de alguém.',
    },
    {
      'id': 'paciente',
      'titulo': 'Paciente',
      'desc': 'Acompanhe sua saúde e melhore seu dia a dia.',
    },
  ];

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _continuar() async {
    if (_sel == null || _carregando) return;

    setState(() {
      _carregando = true;
    });

    try {
      final state = context.read<AppState>();

      // Salva o perfil escolhido.
      await state.definirPerfil(_sel!);

      // Familiar e cuidador precisam estar vinculados
      // a um paciente através do código.
      if (_sel == 'familiar' || _sel == 'cuidador') {
        final codigo = _codigoController.text.trim();

        if (codigo.isEmpty) {
          throw Exception(
            'Digite o código de vínculo do paciente.',
          );
        }

        await state.vincularPacientePorCodigo(codigo);
      }

      if (!mounted) return;

      // Redirecionamento de acordo com o perfil escolhido.
      if (_sel == 'paciente') {
        context.go('/paciente');
      } else if (_sel == 'cuidador') {
        context.go('/cuidador');
      } else if (_sel == 'familiar') {
        context.go('/familiar');
      }
    } catch (e) {
      if (!mounted) return;

      String mensagem =
          'Não foi possível concluir o cadastro. Tente novamente.';

      if (e is Exception) {
        mensagem = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final precisaCodigo =
        _sel == 'familiar' || _sel == 'cuidador';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Text(
                'Escolha seu perfil',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Como você deseja utilizar o HumanaCare?',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 32),

              Expanded(
                child: ListView.builder(
                  itemCount: _opcoes.length,
                  itemBuilder: (context, index) {
                    final opcao = _opcoes[index];

                    final id = opcao['id']!;

                    final selecionado = _sel == id;

                    return GestureDetector(
                      onTap: _carregando
                          ? null
                          : () {
                              setState(() {
                                _sel = id;
                              });
                            },
                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: selecionado
                                ? AppTheme.primary
                                : Colors.grey.shade300,
                            width: selecionado ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selecionado
                                      ? AppTheme.primary
                                      : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: selecionado
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration:
                                            BoxDecoration(
                                          shape:
                                              BoxShape.circle,
                                          color:
                                              AppTheme.primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opcao['titulo']!,
                                    style:
                                        GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.w600,
                                      color:
                                          AppTheme.textPrimary,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    opcao['desc']!,
                                    style:
                                        GoogleFonts.poppins(
                                      fontSize: 13,
                                      color:
                                          AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (precisaCodigo) ...[
                const SizedBox(height: 8),

                Text(
                  'Código do paciente',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: _codigoController,
                  textCapitalization:
                      TextCapitalization.characters,
                  enabled: !_carregando,
                  decoration: InputDecoration(
                    hintText: 'Ex.: HC-7K4P9M',
                    prefixIcon:
                        const Icon(Icons.link),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      _sel == null || _carregando
                          ? null
                          : _continuar,
                  child: _carregando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Continuar',
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