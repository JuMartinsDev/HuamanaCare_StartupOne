import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _dataNascimentoCtrl = TextEditingController();
  final _enderecoCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _condicaoSaudeCtrl = TextEditingController();
  final _alergiasCtrl = TextEditingController();
  final _dispositivosCtrl = TextEditingController();
  final _observacoesCtrl = TextEditingController();
  final _cuidadorNomeCtrl = TextEditingController();
  final _cuidadorTurnoCtrl = TextEditingController();
  final _cuidadorCargaCtrl = TextEditingController();

  static const List<String> _opcoesSexo = [
    'Feminino',
    'Masculino',
    'Outro',
    'Prefiro não informar',
  ];

  static const List<String> _opcoesEstadoCivil = [
    'Solteiro(a)',
    'Casado(a)',
    'União estável',
    'Divorciado(a)',
    'Viúvo(a)',
  ];

  static const List<String> _opcoesTipoSanguineo = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Não sei',
  ];

  String _sexo = '';
  String _estadoCivil = '';
  String _tipoSanguineo = '';

  bool _loading = false;
  String? _erro;

  @override
  void initState() {
    super.initState();

    final paciente = context.read<AppState>().paciente;
    _preencherCampos(paciente);
  }

  void _preencherCampos(Paciente p) {
    _dataNascimentoCtrl.text = p.dataNascimento;
    _enderecoCtrl.text = p.endereco;
    _telefoneCtrl.text = p.telefone;
    _condicaoSaudeCtrl.text = p.condicaoSaude;
    _alergiasCtrl.text = p.alergias;
    _dispositivosCtrl.text = p.dispositivos;
    _observacoesCtrl.text = p.observacoes;
    _cuidadorNomeCtrl.text = p.cuidadorNome;
    _cuidadorTurnoCtrl.text = p.cuidadorTurno;
    _cuidadorCargaCtrl.text = p.cuidadorCarga;

    // Só define o valor se ele realmente existir
    // nas opções disponíveis do dropdown.
    _sexo = _opcoesSexo.contains(p.sexo) ? p.sexo : '';

    _estadoCivil = _opcoesEstadoCivil.contains(p.estadoCivil)
        ? p.estadoCivil
        : '';

    _tipoSanguineo = _opcoesTipoSanguineo.contains(p.tipoSanguineo)
        ? p.tipoSanguineo
        : '';
  }

  Future<void> _salvar() async {
    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      await context.read<AppState>().atualizarPaciente(
            dataNascimento: _dataNascimentoCtrl.text.trim(),
            sexo: _sexo,
            estadoCivil: _estadoCivil,
            endereco: _enderecoCtrl.text.trim(),
            telefone: _telefoneCtrl.text.trim(),
            tipoSanguineo: _tipoSanguineo,
            condicaoSaude: _condicaoSaudeCtrl.text.trim(),
            alergias: _alergiasCtrl.text.trim(),
            dispositivos: _dispositivosCtrl.text.trim(),
            observacoes: _observacoesCtrl.text.trim(),
            cuidadorNome: _cuidadorNomeCtrl.text.trim(),
            cuidadorTurno: _cuidadorTurnoCtrl.text.trim(),
            cuidadorCarga: _cuidadorCargaCtrl.text.trim(),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Perfil atualizado com sucesso!',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = 'Não foi possível salvar os dados. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _selecionarData() async {
    DateTime inicial = DateTime.now();

    final atual = _dataNascimentoCtrl.text.trim();

    if (atual.isNotEmpty) {
      try {
        final partes = atual.split('/');

        if (partes.length == 3) {
          final dataConvertida = DateTime(
            int.parse(partes[2]),
            int.parse(partes[1]),
            int.parse(partes[0]),
          );

          // Garante que a data inicial do calendário
          // nunca fique no futuro.
          if (!dataConvertida.isAfter(DateTime.now())) {
            inicial = dataConvertida;
          }
        }
      } catch (_) {
        inicial = DateTime.now();
      }
    }

    final data = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecione sua data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (data == null) return;

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    setState(() {
      _dataNascimentoCtrl.text = '$dia/$mes/${data.year}';
    });
  }

  @override
  void dispose() {
    _dataNascimentoCtrl.dispose();
    _enderecoCtrl.dispose();
    _telefoneCtrl.dispose();
    _condicaoSaudeCtrl.dispose();
    _alergiasCtrl.dispose();
    _dispositivosCtrl.dispose();
    _observacoesCtrl.dispose();
    _cuidadorNomeCtrl.dispose();
    _cuidadorTurnoCtrl.dispose();
    _cuidadorCargaCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Editar perfil',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tituloSecao('Dados pessoais'),

              _label('Data de nascimento'),
              const SizedBox(height: 6),

              HCField(
                hint: 'DD/MM/AAAA',
                controller: _dataNascimentoCtrl,
                readOnly: true,
                onTap: _selecionarData,
                suffix: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppTheme.textLight,
                  size: 20,
                ),
              ),

              const SizedBox(height: 14),

              _label('Sexo'),
              const SizedBox(height: 6),

              _dropdown(
                value: _sexo.isEmpty ? null : _sexo,
                hint: 'Selecione',
                items: _opcoesSexo,
                onChanged: (value) {
                  setState(() {
                    _sexo = value ?? '';
                  });
                },
              ),

              const SizedBox(height: 14),

              _label('Estado civil'),
              const SizedBox(height: 6),

              _dropdown(
                value: _estadoCivil.isEmpty ? null : _estadoCivil,
                hint: 'Selecione',
                items: _opcoesEstadoCivil,
                onChanged: (value) {
                  setState(() {
                    _estadoCivil = value ?? '';
                  });
                },
              ),

              const SizedBox(height: 14),

              _label('Endereço'),
              const SizedBox(height: 6),

              HCField(
                hint: 'Rua, número, bairro...',
                controller: _enderecoCtrl,
              ),

              const SizedBox(height: 14),

              _label('Telefone'),
              const SizedBox(height: 6),

              HCField(
                hint: '(11) 99999-9999',
                controller: _telefoneCtrl,
                keyboard: TextInputType.phone,
              ),

              const SizedBox(height: 24),

              _tituloSecao('Informações de saúde'),

              _label('Tipo sanguíneo'),
              const SizedBox(height: 6),

              _dropdown(
                value: _tipoSanguineo.isEmpty ? null : _tipoSanguineo,
                hint: 'Selecione',
                items: _opcoesTipoSanguineo,
                onChanged: (value) {
                  setState(() {
                    _tipoSanguineo = value ?? '';
                  });
                },
              ),

              const SizedBox(height: 14),

              _label('Condições de saúde'),
              const SizedBox(height: 6),

              HCField(
                hint: 'Ex.: hipertensão, diabetes...',
                controller: _condicaoSaudeCtrl,
              ),

              const SizedBox(height: 14),

              _label('Alergias'),
              const SizedBox(height: 6),

              HCField(
                hint: 'Informe suas alergias',
                controller: _alergiasCtrl,
              ),

              const SizedBox(height: 14),

              _label('Uso de dispositivos'),
              const SizedBox(height: 6),

              HCField(
                hint: 'Ex.: marcapasso, aparelho auditivo...',
                controller: _dispositivosCtrl,
              ),

              const SizedBox(height: 14),

              _label('Observações'),
              const SizedBox(height: 6),

              HCField(
                hint: 'Outras informações importantes',
                controller: _observacoesCtrl,
              ),

              const SizedBox(height: 24),

              _tituloSecao('Cuidador principal'),

              _label('Nome do cuidador'),
              const SizedBox(height: 6),

              HCField(
                hint: 'Nome completo',
                controller: _cuidadorNomeCtrl,
              ),

              const SizedBox(height: 14),

              _label('Turno'),
              const SizedBox(height: 6),

              HCField(
                hint: 'Ex.: manhã, tarde ou noite',
                controller: _cuidadorTurnoCtrl,
              ),

              const SizedBox(height: 14),

              _label('Carga horária'),
              const SizedBox(height: 6),

              HCField(
                hint: 'Ex.: 8 horas',
                controller: _cuidadorCargaCtrl,
              ),

              if (_erro != null) ...[
                const SizedBox(height: 16),
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
                label: 'Salvar alterações',
                onTap: _salvar,
                loading: _loading,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tituloSecao(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _label(String texto) {
    return Text(
      texto,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        hint: Text(
          hint,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textLight,
          ),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: AppTheme.textLight,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppTheme.textPrimary,
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}