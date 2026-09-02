import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../models/app_state.dart';
import '../../models/models.dart';

class CriarCompromissoScreen extends StatefulWidget {
  const CriarCompromissoScreen({super.key});

  @override
  State<CriarCompromissoScreen> createState() =>
      _CriarCompromissoScreenState();
}

class _CriarCompromissoScreenState
    extends State<CriarCompromissoScreen> {
  final _tituloController = TextEditingController();
  final _localController = TextEditingController();

  DateTime? _data;
  TimeOfDay? _horario;
  bool _salvando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _localController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final agora = DateTime.now();

    final data = await showDatePicker(
      context: context,
      initialDate: _data ?? agora,
      firstDate: agora,
      lastDate: DateTime(agora.year + 5),
      locale: const Locale('pt', 'BR'),
    );

    if (data != null) {
      setState(() {
        _data = data;
      });
    }
  }

  Future<void> _selecionarHorario() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: _horario ?? TimeOfDay.now(),
    );

    if (horario != null) {
      setState(() {
        _horario = horario;
      });
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String _formatarHorario(TimeOfDay horario) {
    return '${horario.hour.toString().padLeft(2, '0')}:'
        '${horario.minute.toString().padLeft(2, '0')}';
  }

  String _mesAbreviado(int mes) {
    const meses = [
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ];

    return meses[mes - 1];
  }

  String _diaAbreviado(DateTime data) {
    const dias = [
      'SEG',
      'TER',
      'QUA',
      'QUI',
      'SEX',
      'SÁB',
      'DOM',
    ];

    return dias[data.weekday - 1];
  }

  Future<void> _salvar() async {
    final titulo = _tituloController.text.trim();
    final local = _localController.text.trim();

    if (titulo.isEmpty || _data == null || _horario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha o título, a data e o horário.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final dataCompleta = DateTime(
        _data!.year,
        _data!.month,
        _data!.day,
        _horario!.hour,
        _horario!.minute,
      );

      final compromisso = Compromisso(
        titulo: titulo,
        horario: _formatarHorario(_horario!),
        local: local.isEmpty ? 'Local não informado' : local,
        dia: _data!.day,
        mesAbrev: _mesAbreviado(_data!.month),
        diaAbrev: _diaAbreviado(_data!),
        data: dataCompleta,
      );

      await context.read<AppState>().addCompromisso(
        compromisso,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível criar o compromisso.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppTheme.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Novo compromisso',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Título',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _campo(
                controller: _tituloController,
                hint: 'Ex.: Consulta médica',
                icon: Icons.event_note_outlined,
              ),

              const SizedBox(height: 20),

              Text(
                'Data',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _seletor(
                texto: _data == null
                    ? 'Selecione a data'
                    : _formatarData(_data!),
                icon: Icons.calendar_today_outlined,
                onTap: _selecionarData,
              ),

              const SizedBox(height: 20),

              Text(
                'Horário',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _seletor(
                texto: _horario == null
                    ? 'Selecione o horário'
                    : _formatarHorario(_horario!),
                icon: Icons.access_time_outlined,
                onTap: _selecionarHorario,
              ),

              const SizedBox(height: 20),

              Text(
                'Local',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _campo(
                controller: _localController,
                hint: 'Ex.: Hospital ou clínica',
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _salvando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Adicionar compromisso',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: AppTheme.primary,
            size: 21,
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textLight,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _seletor({
    required String texto,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primary,
              size: 21,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: texto.startsWith('Selecione')
                      ? AppTheme.textLight
                      : AppTheme.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}