import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class CuidadorHome extends StatefulWidget {
  const CuidadorHome({super.key});

  @override
  State<CuidadorHome> createState() => _CuidadorHomeState();
}

class _CuidadorHomeState extends State<CuidadorHome> {
  int _abaAtual = 0;

  final List<Widget> _abas = const [
    _CuidadorInicioTab(),
    _CuidadorRemediosTab(),
    _CuidadorCompromissosTab(),
    _CuidadorChatTab(),
    _CuidadorPerfilTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _abaAtual,
        children: _abas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaAtual,
        onDestinationSelected: (index) {
          setState(() {
            _abaAtual = index;
          });
        },
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Remédios',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INÍCIO
// ============================================================

class _CuidadorInicioTab extends StatelessWidget {
  const _CuidadorInicioTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final paciente = state.paciente;
    final remedios = state.remedios;
    final compromissos = state.compromissos;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'HumanaCare',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AppState>().logout();

              if (!context.mounted) return;

              context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<AppState>().inicializar();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, Cuidador! 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  paciente.nome.isEmpty
                      ? 'Acompanhe o cuidado do paciente.'
                      : 'Acompanhe o cuidado de ${paciente.nome}.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 26),

                _PacienteResumoCard(
                  paciente: paciente,
                  onTap: () {
                    _mostrarDadosPaciente(context, paciente);
                  },
                ),

                const SizedBox(height: 20),

                Text(
                  'Resumo de saúde',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _ResumoCard(
                        icon: Icons.medication_outlined,
                        titulo: 'Remédios',
                        valor: '${remedios.length}',
                        descricao: 'cadastrados',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ResumoCard(
                        icon: Icons.calendar_month_outlined,
                        titulo: 'Agenda',
                        valor: '${compromissos.length}',
                        descricao: 'compromissos',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _InformacoesSaudeCard(
                  paciente: paciente,
                ),

                const SizedBox(height: 20),

                Text(
                  'Remédios',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                if (remedios.isEmpty)
                  const _EmptyCard(
                    icon: Icons.medication_outlined,
                    texto: 'Nenhum remédio cadastrado.',
                  )
                else
                  ...remedios.take(3).map(
                        (remedio) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _RemedioResumoCard(
                            remedio: remedio,
                          ),
                        ),
                      ),

                const SizedBox(height: 14),

                Text(
                  'Próximos compromissos',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                if (compromissos.isEmpty)
                  const _EmptyCard(
                    icon: Icons.calendar_month_outlined,
                    texto: 'Nenhum compromisso cadastrado.',
                  )
                else
                  ...compromissos.take(3).map(
                        (compromisso) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CompromissoResumoCard(
                            compromisso: compromisso,
                          ),
                        ),
                      ),

                const SizedBox(height: 20),

                Text(
                  'Emergência',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                _SosCard(
                  ativado: state.sosAtivado,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDadosPaciente(
    BuildContext context,
    Paciente paciente,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      builder: (context) {
        return _DadosPacienteSheet(
          paciente: paciente,
        );
      },
    );
  }
}

// ============================================================
// REMÉDIOS
// ============================================================

class _CuidadorRemediosTab extends StatelessWidget {
  const _CuidadorRemediosTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final paciente = state.paciente;
    final remedios = state.remedios;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'Remédios',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paciente.nome.isEmpty
                    ? 'Medicamentos do paciente'
                    : 'Medicamentos de ${paciente.nome}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              if (remedios.isEmpty)
                const _EmptyCard(
                  icon: Icons.medication_outlined,
                  texto: 'Nenhum remédio cadastrado.',
                )
              else
                ...remedios.map(
                  (remedio) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RemedioGerenciavelCard(
                      remedio: remedio,
                      onEditar: () {
                        _abrirFormularioRemedio(
                          context,
                          remedio: remedio,
                        );
                      },
                      onExcluir: () {
                        _confirmarExclusao(
                          context,
                          remedio,
                        );
                      },
                      onToggle: () async {
                        await context
                            .read<AppState>()
                            .toggleRemedio(remedio.id);
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _abrirFormularioRemedio(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Cadastrar remédio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirFormularioRemedio(
    BuildContext context, {
    Remedio? remedio,
  }) async {
    final resultado = await showModalBottomSheet<Remedio>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      builder: (context) {
        return _FormularioRemedioSheet(
          remedio: remedio,
        );
      },
    );

    if (resultado == null || !context.mounted) return;

    final state = context.read<AppState>();

    try {
      if (remedio == null) {
        await state.addRemedio(resultado);
      } else {
        await state.updateRemedio(resultado);
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            remedio == null
                ? 'Remédio cadastrado com sucesso.'
                : 'Remédio atualizado com sucesso.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível salvar o remédio: $e',
          ),
        ),
      );
    }
  }

  Future<void> _confirmarExclusao(
    BuildContext context,
    Remedio remedio,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir remédio'),
          content: Text(
            'Tem certeza que deseja excluir "${remedio.nome}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) return;

    try {
      await context.read<AppState>().removeRemedio(remedio.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remédio excluído com sucesso.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível excluir o remédio: $e',
          ),
        ),
      );
    }
  }
}

// ============================================================
// FORMULÁRIO DE REMÉDIO
// ============================================================

class _FormularioRemedioSheet extends StatefulWidget {
  final Remedio? remedio;

  const _FormularioRemedioSheet({
    this.remedio,
  });

  @override
  State<_FormularioRemedioSheet> createState() =>
      _FormularioRemedioSheetState();
}

class _FormularioRemedioSheetState
    extends State<_FormularioRemedioSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _tipoController;
  late final TextEditingController _horarioController;

  DateTime? _dataInicio;
  DateTime? _dataFim;
  bool _tomado = false;

  bool get _editando => widget.remedio != null;

  @override
  void initState() {
    super.initState();

    final remedio = widget.remedio;

    _nomeController = TextEditingController(
      text: remedio?.nome ?? '',
    );

    _tipoController = TextEditingController(
      text: remedio?.tipo ?? '',
    );

    _horarioController = TextEditingController(
      text: remedio?.horario ?? '',
    );

    _dataInicio = remedio?.dataInicio;
    _dataFim = remedio?.dataFim;
    _tomado = remedio?.tomado ?? false;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tipoController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24 + bottomInset,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Handle(),

                const SizedBox(height: 24),

                Text(
                  _editando
                      ? 'Editar remédio'
                      : 'Cadastrar remédio',
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _editando
                      ? 'Atualize as informações do medicamento.'
                      : 'Cadastre um medicamento para o paciente.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _nomeController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nome do remédio',
                    hintText: 'Ex.: Dipirona',
                    prefixIcon: Icon(Icons.medication_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do remédio.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _tipoController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    hintText: 'Ex.: Analgésico',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o tipo do remédio.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _horarioController,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: 'Horário',
                    hintText: 'Ex.: 08:00',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o horário.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _DataSelecionavel(
                  titulo: 'Data de início',
                  data: _dataInicio,
                  onSelecionar: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate:
                          _dataInicio ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (data != null) {
                      setState(() {
                        _dataInicio = data;
                      });
                    }
                  },
                  onLimpar: _dataInicio == null
                      ? null
                      : () {
                          setState(() {
                            _dataInicio = null;
                          });
                        },
                ),

                const SizedBox(height: 12),

                _DataSelecionavel(
                  titulo: 'Data de término',
                  data: _dataFim,
                  onSelecionar: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate:
                          _dataFim ??
                          _dataInicio ??
                          DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (data != null) {
                      setState(() {
                        _dataFim = data;
                      });
                    }
                  },
                  onLimpar: _dataFim == null
                      ? null
                      : () {
                          setState(() {
                            _dataFim = null;
                          });
                        },
                ),

                if (_editando) ...[
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Remédio já tomado',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    value: _tomado,
                    onChanged: (value) {
                      setState(() {
                        _tomado = value;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _salvar,
                    child: Text(
                      _editando
                          ? 'Salvar alterações'
                          : 'Cadastrar remédio',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dataInicio != null &&
        _dataFim != null &&
        _dataFim!.isBefore(_dataInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A data de término não pode ser anterior à data de início.',
          ),
        ),
      );
      return;
    }

    final original = widget.remedio;

    final remedio = Remedio(
      id: original?.id ?? '',
      nome: _nomeController.text.trim(),
      tipo: _tipoController.text.trim(),
      horario: _horarioController.text.trim(),
      tomado: _tomado,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
    );

    Navigator.of(context).pop(remedio);
  }
}

// ============================================================
// COMPROMISSOS
// ============================================================

class _CuidadorCompromissosTab extends StatelessWidget {
  const _CuidadorCompromissosTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final paciente = state.paciente;
    final compromissos = state.compromissos;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'Agenda',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paciente.nome.isEmpty
                    ? 'Agenda do paciente'
                    : 'Agenda de ${paciente.nome}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              if (compromissos.isEmpty)
                const _EmptyCard(
                  icon: Icons.calendar_month_outlined,
                  texto: 'Nenhum compromisso cadastrado.',
                )
              else
                ...compromissos.map(
                  (compromisso) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CompromissoGerenciavelCard(
                      compromisso: compromisso,
                      onEditar: () {
                        _abrirFormularioCompromisso(
                          context,
                          compromisso: compromisso,
                        );
                      },
                      onExcluir: () {
                        _confirmarExclusao(
                          context,
                          compromisso,
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _abrirFormularioCompromisso(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Cadastrar compromisso'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirFormularioCompromisso(
    BuildContext context, {
    Compromisso? compromisso,
  }) async {
    final resultado =
        await showModalBottomSheet<Compromisso>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      builder: (context) {
        return _FormularioCompromissoSheet(
          compromisso: compromisso,
        );
      },
    );

    if (resultado == null || !context.mounted) return;

    final state = context.read<AppState>();

    try {
      if (compromisso == null) {
        await state.addCompromisso(resultado);
      } else {
        await state.updateCompromisso(resultado);
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            compromisso == null
                ? 'Compromisso cadastrado com sucesso.'
                : 'Compromisso atualizado com sucesso.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível salvar o compromisso: $e',
          ),
        ),
      );
    }
  }

  Future<void> _confirmarExclusao(
    BuildContext context,
    Compromisso compromisso,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir compromisso'),
          content: Text(
            'Tem certeza que deseja excluir '
            '"${compromisso.titulo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) return;

    try {
      await context
          .read<AppState>()
          .removeCompromisso(compromisso.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compromisso excluído com sucesso.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível excluir o compromisso: $e',
          ),
        ),
      );
    }
  }
}

// ============================================================
// FORMULÁRIO DE COMPROMISSO
// ============================================================

class _FormularioCompromissoSheet extends StatefulWidget {
  final Compromisso? compromisso;

  const _FormularioCompromissoSheet({
    this.compromisso,
  });

  @override
  State<_FormularioCompromissoSheet> createState() =>
      _FormularioCompromissoSheetState();
}

class _FormularioCompromissoSheetState
    extends State<_FormularioCompromissoSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tituloController;
  late final TextEditingController _horarioController;
  late final TextEditingController _localController;

  DateTime? _data;

  bool get _editando => widget.compromisso != null;

  @override
  void initState() {
    super.initState();

    final compromisso = widget.compromisso;

    _tituloController = TextEditingController(
      text: compromisso?.titulo ?? '',
    );

    _horarioController = TextEditingController(
      text: compromisso?.horario ?? '',
    );

    _localController = TextEditingController(
      text: compromisso?.local ?? '',
    );

    _data = compromisso?.data;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _horarioController.dispose();
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24 + bottomInset,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Handle(),

                const SizedBox(height: 24),

                Text(
                  _editando
                      ? 'Editar compromisso'
                      : 'Cadastrar compromisso',
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _editando
                      ? 'Atualize as informações do compromisso.'
                      : 'Cadastre um compromisso para o paciente.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _tituloController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ex.: Consulta médica',
                    prefixIcon: Icon(
                      Icons.event_note_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Informe o título.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _DataSelecionavel(
                  titulo: 'Data',
                  data: _data,
                  onSelecionar: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate:
                          _data ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (data != null) {
                      setState(() {
                        _data = data;
                      });
                    }
                  },
                  onLimpar: _data == null
                      ? null
                      : () {
                          setState(() {
                            _data = null;
                          });
                        },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _horarioController,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: 'Horário',
                    hintText: 'Ex.: 14:30',
                    prefixIcon: Icon(
                      Icons.access_time,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Informe o horário.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _localController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Local',
                    hintText: 'Ex.: Hospital / Clínica',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Informe o local.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _salvar,
                    child: Text(
                      _editando
                          ? 'Salvar alterações'
                          : 'Cadastrar compromisso',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione a data do compromisso.',
          ),
        ),
      );
      return;
    }

    final original = widget.compromisso;

    final compromisso = Compromisso(
      id: original?.id ?? '',
      titulo: _tituloController.text.trim(),
      horario: _horarioController.text.trim(),
      local: _localController.text.trim(),
      dia: _data!.day,
      mesAbrev: _mesAbreviado(_data!.month),
      diaAbrev: _diaAbreviado(_data!.weekday),
      data: _data,
    );

    Navigator.of(context).pop(compromisso);
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

  String _diaAbreviado(int dia) {
    const dias = [
      'SEG',
      'TER',
      'QUA',
      'QUI',
      'SEX',
      'SÁB',
      'DOM',
    ];

    return dias[dia - 1];
  }
}

// ============================================================
// CARD GERENCIÁVEL DE COMPROMISSO
// ============================================================

class _CompromissoGerenciavelCard extends StatelessWidget {
  final Compromisso compromisso;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _CompromissoGerenciavelCard({
    required this.compromisso,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 62,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  '${compromisso.dia}',
                  style: GoogleFonts.poppins(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  compromisso.mesAbrev,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  compromisso.titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 15,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      compromisso.horario,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        compromisso.local,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color:
                              AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                if (compromisso.diaAbrev.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    compromisso.diaAbrev,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'editar') {
                onEditar();
              } else if (value == 'excluir') {
                onExcluir();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 10),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'excluir',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 10),
                    Text('Excluir'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CARD GERENCIÁVEL DE REMÉDIO
// ============================================================

class _RemedioGerenciavelCard extends StatelessWidget {
  final Remedio remedio;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  final VoidCallback onToggle;

  const _RemedioGerenciavelCard({
    required this.remedio,
    required this.onEditar,
    required this.onExcluir,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: remedio.tomado
              ? Colors.green.shade200
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: AppTheme.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  remedio.nome.isEmpty
                      ? 'Remédio'
                      : remedio.nome,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  remedio.tipo.isEmpty
                      ? 'Tipo não informado'
                      : remedio.tipo,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      remedio.horario.isEmpty
                          ? 'Horário não informado'
                          : remedio.horario,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),

                if (remedio.dataInicio != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Início: ${_formatarData(remedio.dataInicio!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],

                if (remedio.dataFim != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Término: ${_formatarData(remedio.dataFim!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: onToggle,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        remedio.tomado
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 19,
                        color: remedio.tomado
                            ? Colors.green
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        remedio.tomado
                            ? 'Tomado'
                            : 'Marcar como tomado',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: remedio.tomado
                              ? Colors.green.shade700
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'editar') {
                onEditar();
              } else if (value == 'excluir') {
                onExcluir();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 10),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'excluir',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 10),
                    Text('Excluir'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();

    return '$dia/$mes/$ano';
  }
}

// ============================================================
// DATA
// ============================================================

class _DataSelecionavel extends StatelessWidget {
  final String titulo;
  final DateTime? data;
  final VoidCallback onSelecionar;
  final VoidCallback? onLimpar;

  const _DataSelecionavel({
    required this.titulo,
    required this.data,
    required this.onSelecionar,
    required this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelecionar,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppTheme.primary,
              size: 21,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data == null
                        ? 'Não informado'
                        : _formatarData(data!),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (onLimpar != null)
              IconButton(
                onPressed: onLimpar,
                icon: const Icon(Icons.close),
                tooltip: 'Limpar',
              )
            else
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();

    return '$dia/$mes/$ano';
  }
}

// ============================================================
// CHAT
// ============================================================

class _CuidadorChatTab extends StatefulWidget {
  const _CuidadorChatTab();

  @override
  State<_CuidadorChatTab> createState() => _CuidadorChatTabState();
}

class _CuidadorChatTabState extends State<_CuidadorChatTab> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  bool _enviando = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _horaAgora() {
    final t = TimeOfDay.now();

    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _enviar() async {
    final texto = _input.text.trim();

    if (texto.isEmpty || _enviando) {
      return;
    }

    final state = context.read<AppState>();

    setState(() {
      _enviando = true;
    });

    try {
      await state.addMensagem(
        'cuidador',
        Mensagem(
          id: 'u${DateTime.now().millisecondsSinceEpoch}',
          texto: texto,
          recebido: false,
          hora: _horaAgora(),
        ),
      );

      _input.clear();

      _rolarParaFim();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível enviar a mensagem: $e',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _enviando = false;
      });
    }
  }

  void _rolarParaFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;

      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final paciente = state.paciente;
    final mensagens = state.mensagens('cuidador');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'Chat',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                16,
                24,
                16,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        AppTheme.primary.withValues(
                      alpha: 0.10,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          paciente.nome.isEmpty
                              ? 'Paciente'
                              : paciente.nome,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Paciente vinculado',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: mensagens.isEmpty
                  ? const _EmptyChat()
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(20),
                      itemCount: mensagens.length,
                      itemBuilder: (context, index) {
                        final mensagem = mensagens[index];

                        final minhaMensagem =
                            !mensagem.recebido;

                        return Align(
                          alignment: minhaMensagem
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints:
                                const BoxConstraints(
                              maxWidth: 300,
                            ),
                            margin:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: minhaMensagem
                                  ? AppTheme.primary
                                  : AppTheme.surface,
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: !minhaMensagem
                                  ? Border.all(
                                      color:
                                          Colors.grey.shade300,
                                    )
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                if (!minhaMensagem &&
                                    mensagem.remetente !=
                                        null)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(
                                      bottom: 2,
                                    ),
                                    child: Text(
                                      mensagem.remetente!,
                                      style:
                                          GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight.w600,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),

                                Text(
                                  mensagem.texto,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: minhaMensagem
                                        ? Colors.white
                                        : AppTheme.textPrimary,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  mensagem.hora,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: minhaMensagem
                                        ? Colors.white70
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      textCapitalization:
                          TextCapitalization.sentences,
                      onSubmitted: (_) => _enviar(),
                      enabled: !_enviando,
                      decoration: InputDecoration(
                        hintText:
                            'Digite uma mensagem...',
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        _enviando
                            ? AppTheme.textLight
                            : AppTheme.primary,
                    child: IconButton(
                      onPressed:
                          _enviando ? null : _enviar,
                      icon: _enviando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PERFIL
// ============================================================

class _CuidadorPerfilTab extends StatelessWidget {
  const _CuidadorPerfilTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final paciente = state.paciente;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'Perfil',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor:
                          AppTheme.primary.withValues(
                        alpha: 0.10,
                      ),
                      child: const Icon(
                        Icons.health_and_safety_outlined,
                        size: 40,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Cuidador',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Paciente vinculado',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      paciente.nome.isEmpty
                          ? 'Nenhum paciente'
                          : paciente.nome,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _PerfilInfoCard(
                titulo: 'Vínculo',
                icon: Icons.link,
                texto: paciente.nome.isEmpty
                    ? 'Nenhum paciente vinculado.'
                    : 'Você está vinculado a ${paciente.nome}.',
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context
                        .read<AppState>()
                        .logout();

                    if (!context.mounted) return;

                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair da conta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PACIENTE
// ============================================================

class _PacienteResumoCard extends StatelessWidget {
  final Paciente paciente;
  final VoidCallback onTap;

  const _PacienteResumoCard({
    required this.paciente,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.primary.withValues(
              alpha: 0.18,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paciente vinculado',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    paciente.nome.isEmpty
                        ? 'Paciente'
                        : paciente.nome,
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    paciente.condicaoSaude.isEmpty
                        ? 'Condição não informada'
                        : paciente.condicaoSaude,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// RESUMO
// ============================================================

class _ResumoCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;
  final String descricao;

  const _ResumoCard({
    required this.icon,
    required this.titulo,
    required this.valor,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.primary,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            descricao,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SAÚDE
// ============================================================

class _InformacoesSaudeCard extends StatelessWidget {
  final Paciente paciente;

  const _InformacoesSaudeCard({
    required this.paciente,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Informações importantes',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.bloodtype_outlined,
            label: 'Tipo sanguíneo',
            value: paciente.tipoSanguineo.isEmpty
                ? 'Não informado'
                : paciente.tipoSanguineo,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.warning_amber_outlined,
            label: 'Alergias',
            value: paciente.alergias.isEmpty
                ? 'Nenhuma informada'
                : paciente.alergias,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.medical_services_outlined,
            label: 'Dispositivos',
            value: paciente.dispositivos.isEmpty
                ? 'Nenhum informado'
                : paciente.dispositivos,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.notes_outlined,
            label: 'Observações',
            value: paciente.observacoes.isEmpty
                ? 'Nenhuma observação'
                : paciente.observacoes,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CARDS
// ============================================================

class _RemedioResumoCard extends StatelessWidget {
  final Remedio remedio;

  const _RemedioResumoCard({
    required this.remedio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  remedio.nome.isEmpty
                      ? 'Remédio'
                      : remedio.nome,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  remedio.tipo.isEmpty
                      ? 'Tipo não informado'
                      : remedio.tipo,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      remedio.horario.isEmpty
                          ? 'Horário não informado'
                          : remedio.horario,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            remedio.tomado
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: remedio.tomado
                ? Colors.green
                : AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _CompromissoResumoCard extends StatelessWidget {
  final Compromisso compromisso;

  const _CompromissoResumoCard({
    required this.compromisso,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  '${compromisso.dia}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  compromisso.mesAbrev,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  compromisso.titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  compromisso.local.isEmpty
                      ? 'Local não informado'
                      : compromisso.local,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      compromisso.horario,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SOS
// ============================================================

class _SosCard extends StatelessWidget {
  final bool ativado;

  const _SosCard({
    required this.ativado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ativado
              ? Colors.red.shade300
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: ativado
                  ? Colors.red.withValues(alpha: 0.10)
                  : AppTheme.primary.withValues(
                      alpha: 0.10,
                    ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sos,
              color: ativado
                  ? Colors.red
                  : AppTheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  ativado
                      ? 'SOS acionado'
                      : 'Nenhum SOS ativo',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ativado
                        ? Colors.red.shade700
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ativado
                      ? 'O paciente acionou uma emergência.'
                      : 'Não há emergência ativa no momento.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DADOS DO PACIENTE
// ============================================================

class _DadosPacienteSheet extends StatelessWidget {
  final Paciente paciente;

  const _DadosPacienteSheet({
    required this.paciente,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              24,
              12,
              24,
              32,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _Handle(),

                const SizedBox(height: 24),

                Text(
                  'Dados do paciente',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  paciente.nome,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                _SecaoDados(
                  titulo: 'Informações pessoais',
                  children: [
                    _CampoPaciente(
                      titulo: 'Nome',
                      valor: paciente.nome,
                    ),
                    _CampoPaciente(
                      titulo: 'Idade',
                      valor: '${paciente.idade} anos',
                    ),
                    _CampoPaciente(
                      titulo: 'Data de nascimento',
                      valor: paciente.dataNascimento,
                    ),
                    _CampoPaciente(
                      titulo: 'Sexo',
                      valor: paciente.sexo,
                    ),
                    _CampoPaciente(
                      titulo: 'Estado civil',
                      valor: paciente.estadoCivil,
                    ),
                    _CampoPaciente(
                      titulo: 'Telefone',
                      valor: paciente.telefone,
                    ),
                    _CampoPaciente(
                      titulo: 'Endereço',
                      valor: paciente.endereco,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _SecaoDados(
                  titulo: 'Informações de saúde',
                  children: [
                    _CampoPaciente(
                      titulo: 'Tipo sanguíneo',
                      valor: paciente.tipoSanguineo,
                    ),
                    _CampoPaciente(
                      titulo: 'Condição de saúde',
                      valor: paciente.condicaoSaude,
                    ),
                    _CampoPaciente(
                      titulo: 'Alergias',
                      valor: paciente.alergias,
                    ),
                    _CampoPaciente(
                      titulo: 'Dispositivos',
                      valor: paciente.dispositivos,
                    ),
                    _CampoPaciente(
                      titulo: 'Observações',
                      valor: paciente.observacoes,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _SecaoDados(
                  titulo: 'Informações do cuidador',
                  children: [
                    _CampoPaciente(
                      titulo: 'Cuidador',
                      valor: paciente.cuidadorNome,
                    ),
                    _CampoPaciente(
                      titulo: 'Turno',
                      valor: paciente.cuidadorTurno,
                    ),
                    _CampoPaciente(
                      titulo: 'Carga',
                      valor: paciente.cuidadorCarga,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _SecaoDados(
                  titulo: 'Documentos',
                  children: [
                    _CampoPaciente(
                      titulo: 'CPF',
                      valor: paciente.cpf,
                    ),
                    _CampoPaciente(
                      titulo: 'RG/CIN',
                      valor: paciente.rgCin,
                    ),
                    _CampoPaciente(
                      titulo: 'Órgão expedidor',
                      valor: paciente.orgaoExpedidor,
                    ),
                    _CampoPaciente(
                      titulo: 'Data de emissão',
                      valor: paciente.dataEmissaoDocumento,
                    ),
                    _CampoPaciente(
                      titulo: 'Cartão SUS',
                      valor: paciente.cartaoSus,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// AUXILIARES
// ============================================================

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _SecaoDados extends StatelessWidget {
  final String titulo;
  final List<Widget> children;

  const _SecaoDados({
    required this.titulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _CampoPaciente extends StatelessWidget {
  final String titulo;
  final String valor;

  const _CampoPaciente({
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final valorFinal =
        valor.trim().isEmpty
            ? 'Não informado'
            : valor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            valorFinal,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: AppTheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _EmptyCard({
    required this.icon,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 34,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 54,
              color: AppTheme.primary.withValues(
                alpha: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma mensagem ainda',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Comece uma conversa com o paciente.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerfilInfoCard extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final String texto;

  const _PerfilInfoCard({
    required this.titulo,
    required this.icon,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  texto,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}