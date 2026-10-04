import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';

import '../../../models/app_state.dart';

import '../../../models/models.dart';

import '../paciente_home.dart';

import '../alertas_screen.dart';

import '../criar_compromisso_screen.dart';

class InicioTab extends StatefulWidget {
  const InicioTab({super.key});

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<InicioTab> {
  Offset _miloOffset = Offset.zero;
  int _filtroTimeline = 0;

  static const List<String> _meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final p = state.paciente;

    final agora = DateTime.now();

    final hoje = DateTime(agora.year, agora.month, agora.day);

    final remediosDoDia = state.remedios.where((r) {
      final inicio = r.dataInicio;
      final fim = r.dataFim;

      final inicioValido = inicio == null ||
          !DateTime(inicio.year, inicio.month, inicio.day)
              .isAfter(hoje);

      final fimValido = fim == null ||
          !DateTime(fim.year, fim.month, fim.day)
              .isBefore(hoje);

      return inicioValido && fimValido;
    }).toList();

    final pendentes =
    remediosDoDia.where((r) => !r.tomado).length;

final agoraMinutos = agora.hour * 60 + agora.minute;

int converterHorarioEmMinutos(String horario) {
  final partes = horario.split(':');

  if (partes.length < 2) {
    return 9999;
  }

  final hora = int.tryParse(partes[0]);
  final minuto = int.tryParse(partes[1]);

  if (hora == null || minuto == null) {
    return 9999;
  }

  return hora * 60 + minuto;
}

// =========================
// ALERTAS DE MEDICAMENTOS
// =========================
final medicamentosEmAlerta = remediosDoDia.where((remedio) {
  if (remedio.tomado) {
    return false;
  }

  final minutos = converterHorarioEmMinutos(
    remedio.horario,
  );

  return minutos != 9999 && minutos < agoraMinutos;
}).length;

// =========================
// ALERTAS DE COMPROMISSOS
// =========================
final compromissosEmAlerta =
    state.compromissos.where((compromisso) {
  final data = compromisso.data;

  if (data == null) {
    return false;
  }

  final dataCompromisso = DateTime(
    data.year,
    data.month,
    data.day,
  );

  if (!dataCompromisso.isAtSameMomentAs(hoje)) {
    return false;
  }

  return compromisso.status == 'pendente';
}).length;

final totalAlertas =
    medicamentosEmAlerta + compromissosEmAlerta;

final remediosTomadosHoje =
    remediosDoDia.where((r) => r.tomado).length;

final progressoMedicamentos = remediosDoDia.isEmpty
    ? 0.0
    : remediosTomadosHoje / remediosDoDia.length;

    final proximoCompromisso =
        _encontrarProximoCompromisso(
      state.compromissos,
      agora,
    );

   // =========================
// LINHA DO TEMPO
// =========================

final atividadesDoDia = <Map<String, dynamic>>[];
final atividadesDaSemana = <Map<String, dynamic>>[];

// =========================
// HOJE - MEDICAMENTOS
// =========================
for (final remedio in remediosDoDia) {
  final minutosRemedio =
      converterHorarioEmMinutos(remedio.horario);

  final remedioAtrasado =
      minutosRemedio != 9999 &&
      minutosRemedio < agoraMinutos &&
      !remedio.tomado;

  atividadesDoDia.add({
    'tipo': 'medicamento',
    'titulo': remedio.nome,
    'horario': remedio.horario,
    'minutos': minutosRemedio,
    'concluido': remedio.tomado,
    'detalhe': remedio.tomado
        ? 'Tomado'
        : remedioAtrasado
            ? 'Não registrado'
            : 'Pendente',
    'data': hoje,
    'naoRegistrado': remedioAtrasado,
  });
}

// =========================
// HOJE - COMPROMISSOS
// =========================

for (final compromisso in state.compromissos) {
  final data = compromisso.data;

  if (data == null) continue;

  final dataDoCompromisso = DateTime(
    data.year,
    data.month,
    data.day,
  );

  if (!dataDoCompromisso.isAtSameMomentAs(hoje)) {
    continue;
  }

  if (compromisso.status == 'cancelado') {
    continue;
  }

  final local = compromisso.local.trim();

  atividadesDoDia.add({
    'tipo': 'compromisso',
    'titulo': compromisso.titulo,
    'horario': compromisso.horario,
    'minutos': converterHorarioEmMinutos(compromisso.horario),
    'concluido': compromisso.status == 'concluido',
    'detalhe': compromisso.status == 'concluido'
        ? 'Concluído'
        : (local.isEmpty
            ? 'Compromisso agendado'
            : local),
    'data': dataDoCompromisso,
  });
}

// =========================
// SEMANA - COMPROMISSOS
// =========================

final inicioSemana = hoje.subtract(
  Duration(days: hoje.weekday - 1),
);

final fimSemana = inicioSemana.add(
  const Duration(days: 7),
);

for (final compromisso in state.compromissos) {
  final data = compromisso.data;

  if (data == null) continue;

  final dataDoCompromisso = DateTime(
    data.year,
    data.month,
    data.day,
  );

  if (dataDoCompromisso.isBefore(inicioSemana) ||
      !dataDoCompromisso.isBefore(fimSemana)) {
    continue;
  }

  if (compromisso.status == 'cancelado') {
    continue;
  }

  final local = compromisso.local.trim();

  atividadesDaSemana.add({
    'tipo': 'compromisso',
    'titulo': compromisso.titulo,
    'horario': compromisso.horario,
    'minutos': converterHorarioEmMinutos(compromisso.horario),
    'concluido': compromisso.status == 'concluido',
    'detalhe': compromisso.status == 'concluido'
        ? 'Concluído'
        : (local.isEmpty
            ? 'Compromisso agendado'
            : local),
    'data': dataDoCompromisso,
  });
}

  // =========================
  // SEMANA - MEDICAMENTOS
  // =========================

for (int i = 0; i < 7; i++) {
  final diaDaSemana = inicioSemana.add(
    Duration(days: i),
  );

  for (final remedio in state.remedios) {
    final inicio = remedio.dataInicio;
    final fim = remedio.dataFim;

    final inicioValido = inicio == null ||
        !DateTime(
          inicio.year,
          inicio.month,
          inicio.day,
        ).isAfter(diaDaSemana);

    final fimValido = fim == null ||
        !DateTime(
          fim.year,
          fim.month,
          fim.day,
        ).isBefore(diaDaSemana);

    if (!inicioValido || !fimValido) {
      continue;
    }

    final tomadoNoDia =
        diaDaSemana.year == hoje.year &&
        diaDaSemana.month == hoje.month &&
        diaDaSemana.day == hoje.day
            ? remedio.tomado
            : false;

    final diaJaPassou = diaDaSemana.isBefore(hoje);

    final concluido = tomadoNoDia;

    final detalhe = diaJaPassou
        ? 'Não registrado'
        : (tomadoNoDia ? 'Tomado' : 'Programado');

    atividadesDaSemana.add({
      'tipo': 'medicamento',
      'titulo': remedio.nome,
      'horario': remedio.horario,
      'minutos': converterHorarioEmMinutos(
        remedio.horario,
      ),
      'concluido': concluido,
      'detalhe': detalhe,
      'data': diaDaSemana,
      'naoRegistrado': diaJaPassou && !tomadoNoDia,
    });
  }
}

  // =========================
  // ORDENA HOJE
  // =========================

  atividadesDoDia.sort(
    (a, b) => (a['minutos'] as int).compareTo(
      b['minutos'] as int,
    ),
  );

  // =========================
  // ORDENA SEMANA
  // =========================

  atividadesDaSemana.sort((a, b) {
    final dataA = a['data'] as DateTime;
    final dataB = b['data'] as DateTime;

    final comparacaoData = dataA.compareTo(dataB);

    if (comparacaoData != 0) {
      return comparacaoData;
    }

    return (a['minutos'] as int).compareTo(
      b['minutos'] as int,
    );
  });

  final atividadesExibidas = _filtroTimeline == 0
    ? atividadesDoDia
    : atividadesDaSemana;

// =========================
// CONTEXTO DA DICA DE HOJE
// =========================

Map<String, dynamic>? proximaAtividade;

for (final atividade in atividadesDoDia) {
  final minutos = atividade['minutos'] as int;

  if (minutos >= agoraMinutos) {
    proximaAtividade = atividade;
    break;
  }
}

final temMedicamentoPendente = remediosDoDia.any(
  (remedio) => !remedio.tomado,
);

final temCompromissoHoje = atividadesDoDia.any(
  (atividade) => atividade['tipo'] == 'compromisso',
);

final compromissosHoje = atividadesDoDia
    .where(
      (atividade) => atividade['tipo'] == 'compromisso',
    )
    .toList();

final compromissosPendentes = compromissosHoje.any(
  (atividade) => atividade['concluido'] == false,
);

final todosCompromissosConcluidos =
    compromissosHoje.isNotEmpty &&
    !compromissosPendentes;

final todosMedicamentosConcluidos =
    remediosDoDia.isNotEmpty &&
    remediosDoDia.every(
      (remedio) => remedio.tomado,
    );

String tituloDica;
String mensagemDica;

final medicamentoAtrasado = atividadesDoDia.cast<Map<String, dynamic>?>().firstWhere(
  (atividade) =>
      atividade != null &&
      atividade['tipo'] == 'medicamento' &&
      atividade['naoRegistrado'] == true,
  orElse: () => null,
);

if (medicamentoAtrasado != null) {
  final horario =
      medicamentoAtrasado['horario'] as String? ?? '';
  final titulo =
      medicamentoAtrasado['titulo'] as String;

  tituloDica = 'Dose pendente';

  mensagemDica = horario.isEmpty
      ? 'O medicamento "$titulo" ainda não foi registrado. Confira sua rotina.'
      : 'O medicamento "$titulo", das $horario, ainda não foi registrado. Confira sua rotina.';
} else if (proximaAtividade != null &&
    proximaAtividade['tipo'] == 'medicamento' &&
    proximaAtividade['concluido'] == false) {
  final horario =
      proximaAtividade['horario'] as String? ?? '';

  tituloDica = 'Hora de cuidar dos seus medicamentos';

  mensagemDica = horario.isEmpty
      ? 'Você tem um medicamento pendente. Não esqueça de registrar quando concluir.'
      : 'Seu próximo medicamento está programado para $horario. Não esqueça de registrar após tomar.';
} else if (proximaAtividade != null &&
    proximaAtividade['tipo'] == 'compromisso' &&
    proximaAtividade['concluido'] == false) {
  final horario =
      proximaAtividade['horario'] as String? ?? '';

  final titulo =
      proximaAtividade['titulo'] as String;

  tituloDica = 'Atenção à sua agenda';

  mensagemDica = horario.isEmpty
      ? 'Você tem o compromisso "$titulo" programado para hoje. Confira sua linha do tempo.'
      : 'Seu próximo compromisso é "$titulo", às $horario. Confira sua linha do tempo para acompanhar o horário.';
} else if (todosCompromissosConcluidos &&
    todosMedicamentosConcluidos) {
  tituloDica = 'Tudo em dia';

  mensagemDica =
      'Você concluiu seus compromissos e está com os medicamentos em dia. Continue cuidando da sua rotina e aproveite para se hidratar.';
} else if (todosCompromissosConcluidos) {
  tituloDica = 'Compromissos concluídos';

  mensagemDica =
      'Você já concluiu todos os compromissos de hoje. Continue acompanhando sua linha do tempo e sua rotina de medicamentos.';
} else if (temMedicamentoPendente) {
  tituloDica = 'Cuide dos seus medicamentos';

  mensagemDica =
      'Você ainda tem medicamentos programados para hoje. Não esqueça de tomar e registrar cada dose.';
} else if (temCompromissoHoje) {
  tituloDica = 'Acompanhe sua agenda';

  mensagemDica =
      'Você tem compromissos programados para hoje. Confira a linha do tempo para acompanhar seus horários.';
} else if (atividadesDoDia.isNotEmpty) {
  tituloDica = 'Tudo em dia';

  mensagemDica =
      'Sua rotina de hoje está registrada. Continue acompanhando suas atividades ao longo do dia.';
} else {
  tituloDica = 'Um dia tranquilo';

  mensagemDica =
      'Não há atividades programadas para hoje. Aproveite para cuidar de você e organizar sua rotina.';
}

    final diasComCompromisso = state.compromissos
        .where((c) => c.data != null)
        .where(
          (c) =>
              c.data!.year == agora.year &&
              c.data!.month == agora.month,
        )
        .map((c) => c.data!.day)
        .toSet();
return SafeArea(
  child: Stack(
    children: [
      Positioned.fill(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE7F4F2),
                Color(0xFFF7FBFA),
                Color(0xFFF9FBFA),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),

      SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // =========================
            // CABEÇALHO
            // =========================

            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    56,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7CC4B6),
                        Color(0xFF4EA596),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${p.nome.trim().isEmpty ? 'Paciente' : p.nome.trim().split(' ').first}!',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hoje é dia ${agora.day} de '
                        '${_meses[agora.month - 1]} de '
                        '${agora.year}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
           
                // =========================
                // CARD DO PACIENTE
                // =========================

                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -34,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const PacienteHome(
                            abaInicial: 4,
                          ),
                        ),
                      );
                    },
                    borderRadius:
                        BorderRadius.circular(16),
                    child: Container(
                      padding:
                          const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius:
                            BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset:
                                const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _avatar(p, 56),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.nome,
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w700,
                                    color:
                                        AppTheme
                                            .textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.idade} anos  .  ID: ${p.id}',
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 12,
                                    color:
                                        AppTheme
                                            .textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color:
                                AppTheme.textLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =========================
                  // RESUMO DO DIA
                  // =========================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Resumo do dia',
                        style:
                            GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${atividadesDoDia.length} '
                        '${atividadesDoDia.length == 1 ? 'item hoje' : 'itens hoje'}',
                        style:
                            GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // =========================
                  // MEDICAMENTOS
                  // =========================

                  _ResumoRow(
                    icone:
                        Icons.medication_outlined,
                    titulo: 'Medicamentos',
                    sub: '$pendentes pendentes',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const PacienteHome(
                            abaInicial: 3,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // =========================
                  // ALERTAS
                  // =========================

                  _ResumoRow(
                    icone:
                        Icons.notifications_none_rounded,
                    titulo: 'Alertas',
                    sub: totalAlertas == 0
                        ? 'Nenhuma situação exige atenção'
                        : totalAlertas == 1
                            ? '1 situação precisa de atenção'
                            : '$totalAlertas situações precisam de atenção',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const AlertasScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // =========================
                  // PRÓXIMO COMPROMISSO
                  // =========================

                  _ResumoRow(
                    icone: Icons.event_outlined,
                    titulo: 'Próximo compromisso',
                    sub: proximoCompromisso == null
                        ? 'Nenhum compromisso futuro'
                        : '${proximoCompromisso.titulo} • '
                            '${proximoCompromisso.dia} ${proximoCompromisso.mesAbrev}'
                            '${proximoCompromisso.horario.trim().isEmpty ? '' : ' • ${proximoCompromisso.horario}'}',
                  ),

                  const SizedBox(height: 12),

                  // =========================
                  // ROTINA DE MEDICAMENTOS
                  // =========================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.divider,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: AppTheme.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Rotina de medicamentos',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '${(progressoMedicamentos * 100).round()}%',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progressoMedicamentos,
                            minHeight: 8,
                            backgroundColor: AppTheme.divider,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                              AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          remediosDoDia.isEmpty
                              ? 'Nenhum medicamento programado para hoje.'
                              : '$remediosTomadosHoje de '
                                  '${remediosDoDia.length} medicamentos '
                                  'concluídos hoje.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =========================
                  // ATIVIDADES DE HOJE
                  // =========================

                  _AtividadesHojeCard(
                    coposAgua: state.coposAguaHoje,
                    passos: state.passosHoje,
                    atividadesConcluidas:
                        state.atividadesConcluidasHoje,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const PacienteHome(
                            abaInicial: 1,
                          ),
                        ),
                      );
                    },
                  ),

                      const SizedBox(height: 12),

                    // =========================
                    // LINHA DO TEMPO DO DIA
                    // =========================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.divider,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: AppTheme.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _filtroTimeline == 0
                                    ? 'Linha do tempo de hoje'
                                    : 'Linha do tempo da semana',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _filtroTimeline = 0;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _filtroTimeline == 0
                                        ? AppTheme.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Hoje',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _filtroTimeline == 0
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _filtroTimeline = 1;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _filtroTimeline == 1
                                        ? AppTheme.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Esta semana',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _filtroTimeline == 1
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                          const SizedBox(height: 16),

              if (atividadesExibidas.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Center(
                    child: Text(
                      _filtroTimeline == 0
                          ? 'Nenhuma atividade programada para hoje.'
                          : 'Nenhuma atividade programada para esta semana.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(
                  atividadesExibidas.length,
                  (index) {
                    final atividade = atividadesExibidas[index];

                    final ehMedicamento =
                        atividade['tipo'] == 'medicamento';

                    final concluido =
                        atividade['concluido'] as bool;

                    final horario =
                        (atividade['horario'] as String?) ?? '';

                    final titulo =
                        atividade['titulo'] as String;

                    final detalhe =
                        atividade['detalhe'] as String;

                    final data =
                        atividade['data'] as DateTime;

                    final naoRegistrado =
                        atividade['naoRegistrado'] as bool? ?? false;

                    final cor = concluido
                        ? Colors.green
                        : naoRegistrado
                            ? Colors.orange
                            : (ehMedicamento
                                ? AppTheme.primary
                                : Colors.blueGrey);

                    final mostrarCabecalhoDoDia =
                        _filtroTimeline == 1 &&
                        (index == 0 ||
                            !(atividadesExibidas[index - 1]['data']
                                    as DateTime)
                                .isAtSameMomentAs(data));

                    final nomeDia = [
                      'SEGUNDA',
                      'TERÇA',
                      'QUARTA',
                      'QUINTA',
                      'SEXTA',
                      'SÁBADO',
                      'DOMINGO',
                    ][data.weekday - 1];

                    final nomeMes = _meses[data.month - 1];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mostrarCabecalhoDoDia)
                          Padding(
                            padding: EdgeInsets.only(
                              top: index == 0 ? 0 : 18,
                              bottom: 10,
                            ),
                            child: Text(
                              '$nomeDia, ${data.day} DE ${nomeMes.toUpperCase()}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 48,
                              child: Column(
                                children: [
                                  Text(
                                    horario.isEmpty
                                        ? '--:--'
                                        : horario,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: cor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (index < atividadesExibidas.length - 1 &&
                                    (atividadesExibidas[index + 1]['data'] as DateTime)
                                        .isAtSameMomentAs(data))
                                  Container(
                                    width: 2,
                                    height: 48,
                                    color: AppTheme.divider,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.background,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            titulo,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.w600,
                                              color:
                                                  AppTheme.textPrimary,
                                              decoration: concluido
                                                  ? TextDecoration
                                                      .lineThrough
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            ehMedicamento
                                                ? 'Medicamento'
                                                : 'Compromisso',
                                            style: GoogleFonts.poppins(
                                              fontSize: 9,
                                              fontWeight:
                                                  FontWeight.w600,
                                              color: cor,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: cor.withValues(
                                                alpha: 0.10,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              detalhe,
                                              style: GoogleFonts.poppins(
                                                fontSize: 9,
                                                fontWeight:
                                                    FontWeight.w600,
                                                color: cor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (concluido)
                                      const Icon(
                                        Icons.check_circle,
                                        size: 18,
                                        color: Colors.green,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                        ],
                      ),
                ),

                const SizedBox(height: 12),

                  // =========================
                // DICA DE HOJE
                // =========================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.divider,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Milo recomenda',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              tituloDica,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mensagemDica,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // =========================
                // PRÓXIMO COMPROMISSO
                // =========================
                Text(
                    'Próximo compromisso',
                    style:
                        GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =========================
                  // CALENDÁRIO
                  // =========================

                  _MiniCalendar(
                    mes: agora.month,
                    ano: agora.year,
                    diaDestaque: agora.day,
                    diasComCompromisso:
                        diasComCompromisso,
                  ),

                  const SizedBox(height: 12),

                  // =========================
                  // MEUS COMPROMISSOS
                  // =========================
                  const SizedBox(height: 22),

                  const _MeusCompromissosSection(),

                  const SizedBox(height: 22),

                  // =========================
                  // BOTÃO NOVO COMPROMISSO
                  // =========================

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const CriarCompromissoScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 20,
                      ),
                      label: Text(
                        'Novo compromisso',
                        style:
                            GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.primary,
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),

      // =========================
      // BOTÃO FLUTUANTE MILO
      // =========================
      Positioned(
        right: 18,
        bottom: 18,
        child: Transform.translate(
          offset: _miloOffset,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PacienteHome(
                    abaInicial: 0,
                    canalChatInicial: 'milo',
                  ),
                ),
              );
            },
            onPanUpdate: (details) {
              setState(() {
                _miloOffset += details.delta;
              });
            },
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
}

  // =========================
  // CONFIRMAR EXCLUSÃO
  // =========================

  Future<void> _confirmarExclusao(
    BuildContext context,
    Compromisso compromisso,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Excluir compromisso?',
          ),
          content: Text(
            'Deseja realmente excluir '
            '"${compromisso.titulo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

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
        const SnackBar(
          content: Text(
            'Não foi possível excluir o compromisso.',
          ),
        ),
      );
    }
  }

  // =========================
  // ENCONTRAR PRÓXIMO COMPROMISSO
  // =========================

  static Compromisso? _encontrarProximoCompromisso(
    List<Compromisso> compromissos,
    DateTime agora,
  ) {
    final futuros = compromissos
        .where((c) => c.data != null)
        .where((c) => !c.data!.isBefore(agora))
        .toList();

    if (futuros.isEmpty) {
      return null;
    }

    futuros.sort(
      (a, b) =>
          a.data!.compareTo(b.data!),
    );

    return futuros.first;
  }

  // =========================
  // AVATAR
  // =========================

  static Widget _avatar(
    Paciente paciente,
    double s,
  ) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primary,
        image: paciente.fotoPerfilUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(
                  paciente.fotoPerfilUrl,
                ),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: paciente.fotoPerfilUrl.isEmpty
          ? const Icon(
              Icons.person,
              color: Colors.white,
              size: 26,
            )
          : null,
    );
  }
}


// =====================================================
// ATIVIDADES DE HOJE
// =====================================================

class _AtividadesHojeCard extends StatelessWidget {
  final int coposAgua;
  final int passos;
  final int atividadesConcluidas;
  final VoidCallback onTap;

  const _AtividadesHojeCard({
    required this.coposAgua,
    required this.passos,
    required this.atividadesConcluidas,
    required this.onTap,
  });

  static const int _metaAgua = 6;
  static const int _metaPassos = 5000;
  static const int _metaAtividades = 3;

  double _progresso(
    int valor,
    int meta,
  ) {
    if (meta <= 0) {
      return 0;
    }

    return (valor / meta).clamp(
      0.0,
      1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.grid_view_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Atividades de hoje',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppTheme.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: onTap,
                child: Text(
                  'Ver atividades',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _AtividadeProgressoItem(
            icon: Icons.water_drop_outlined,
            titulo: 'Água',
            detalhe:
                '$coposAgua de $_metaAgua copos',
            valor: _progresso(
              coposAgua,
              _metaAgua,
            ),
          ),

          const SizedBox(height: 14),

          _AtividadeProgressoItem(
            icon: Icons.directions_walk_outlined,
            titulo: 'Passos',
            detalhe:
                '$passos de $_metaPassos passos',
            valor: _progresso(
              passos,
              _metaPassos,
            ),
          ),

          const SizedBox(height: 14),

          _AtividadeProgressoItem(
            icon: Icons.psychology_outlined,
            titulo: 'Atividades cognitivas',
            detalhe:
                '$atividadesConcluidas de $_metaAtividades concluídas',
            valor: _progresso(
              atividadesConcluidas,
              _metaAtividades,
            ),
          ),
        ],
      ),
    );
  }
}

class _AtividadeProgressoItem
    extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String detalhe;
  final double valor;

  const _AtividadeProgressoItem({
    required this.icon,
    required this.titulo,
    required this.detalhe,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final percentual =
        (valor * 100).round();

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 19,
            color: AppTheme.primary,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      titulo,
                      style:
                          GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                        color: AppTheme
                            .textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '$percentual%',
                    style:
                        GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          AppTheme.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 3),

              Text(
                detalhe,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color:
                      AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 7),

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(20),
                child:
                    LinearProgressIndicator(
                  value: valor,
                  minHeight: 6,
                  backgroundColor:
                      AppTheme.divider,
                  valueColor:
                      const AlwaysStoppedAnimation<
                          Color>(
                    AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =====================================================
// RESUMO ROW
// =====================================================

class _ResumoRow extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String sub;
  final VoidCallback? onTap;

  const _ResumoRow({
    required this.icone,
    required this.titulo,
    required this.sub,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icone,
              size: 20,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 12,
                      color:
                          AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppTheme.textLight,
              ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// CARD DO COMPROMISSO
// =====================================================

class _CompromissoCard
    extends StatelessWidget {
  final Compromisso c;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _CompromissoCard({
    required this.c,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            padding:
                const EdgeInsets.symmetric(
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFE0F4F1),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  c.mesAbrev,
                  style:
                      GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppTheme.primary,
                  ),
                ),
                Text(
                  '${c.dia}',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    height: 1,
                    color:
                        AppTheme.primary,
                  ),
                ),
                Text(
                  c.diaAbrev,
                  style:
                      GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  c.titulo,
                  style:
                      GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppTheme.textPrimary,
                  ),
                ),
                Text(
                  c.local,
                  style:
                      GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                        AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Text(
            c.horario,
            style:
                GoogleFonts.poppins(
              fontSize: 14,
              fontWeight:
                  FontWeight.w700,
              color:
                  AppTheme.primary,
            ),
          ),

          // ÚNICA ADIÇÃO VISUAL:
          // menu de opções do compromisso.
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.more_vert,
              size: 20,
              color: AppTheme.textLight,
            ),
            onSelected: (opcao) {
              if (opcao == 'editar') {
                onEditar();
              } else if (opcao == 'excluir') {
                onExcluir();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 19,
                    ),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'excluir',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 19,
                    ),
                    SizedBox(width: 8),
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

// =====================================================
// MINI CALENDÁRIO
// =====================================================

class _MiniCalendar
    extends StatelessWidget {
  final int mes;
  final int ano;
  final int diaDestaque;
  final Set<int> diasComCompromisso;

  const _MiniCalendar({
    required this.mes,
    required this.ano,
    required this.diaDestaque,
    required this.diasComCompromisso,
  });

  static const List<String> _meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  Widget build(BuildContext context) {
    final primeiro = DateTime(
      ano,
      mes,
      1,
    );

    final diasNoMes =
        DateTime(ano, mes + 1, 0).day;

    final offset =
        primeiro.weekday - 1;

    final mesAntDias =
        DateTime(ano, mes, 0).day;

    const labels = [
      'Mo',
      'Tu',
      'We',
      'Th',
      'Fr',
      'Sa',
      'Su',
    ];

    final flat = <Map<String, int>>[];

    for (
      int i = 0;
      i < offset;
      i++
    ) {
      flat.add({
        'd': mesAntDias -
            offset +
            1 +
            i,
        'cur': 0,
      });
    }

    for (
      int d = 1;
      d <= diasNoMes;
      d++
    ) {
      flat.add({
        'd': d,
        'cur': 1,
      });
    }

    int prox = 1;

    while (flat.length < 42) {
      flat.add({
        'd': prox++,
        'cur': 0,
      });
    }

    return Container(
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment:
                Alignment.centerLeft,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFFFDF6E3),
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Text(
                _meses[mes - 1],
                style:
                    GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      AppTheme.accent,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: labels
                .map(
                  (l) => Expanded(
                    child: Center(
                      child: Text(
                        l,
                        style:
                            GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w700,
                          color: AppTheme
                              .textLight,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 4),

          for (
            int w = 0;
            w < 6;
            w++
          )
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 3,
              ),
              child: Row(
                children: [
                  for (
                    int dow = 0;
                    dow < 7;
                    dow++
                  )
                    _celula(
                      flat[w * 7 + dow],
                      dow,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _celula(
    Map<String, int> info,
    int dow,
  ) {
    final d = info['d']!;
    final cur = info['cur'] == 1;

    final destaque =
        cur && d == diaDestaque;

    final temCompromisso =
        cur &&
        diasComCompromisso.contains(d);

    final fimDeSemana =
        dow >= 5;

    Color cor;

    if (!cur) {
      cor =
          const Color(0xFFC4D3CE);
    } else if (destaque) {
      cor = Colors.white;
    } else if (fimDeSemana) {
      cor = AppTheme.primary;
    } else {
      cor = AppTheme.textPrimary;
    }

    return Expanded(
      child: Center(
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: destaque
              ? const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary,
                )
              : temCompromisso
                  ? BoxDecoration(
                      shape:
                          BoxShape.circle,
                      border: Border.all(
                        color:
                            AppTheme.primary,
                        width: 1.5,
                      ),
                    )
                  : null,
          child: Text(
            '$d',
            style:
                GoogleFonts.poppins(
              fontSize: 11,
              fontWeight:
                  destaque ||
                          temCompromisso
                      ? FontWeight.w700
                      : FontWeight.w500,
              color: cor,
            ),
          ),
        ),
      ),
    );
  }
}

class _MeusCompromissosSection extends StatefulWidget {
  const _MeusCompromissosSection();

  @override
  State<_MeusCompromissosSection> createState() =>
      _MeusCompromissosSectionState();
}

class _MeusCompromissosSectionState
    extends State<_MeusCompromissosSection> {
  int _filtroSelecionado = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final agora = DateTime.now();

    final compromissos = state.compromissos.where((c) {
      if (c.data == null) {
        return _filtroSelecionado == 2;
      }

      final data = c.data!;

      if (_filtroSelecionado == 0) {
        return data.year == agora.year &&
            data.month == agora.month &&
            data.day == agora.day;
      }

      if (_filtroSelecionado == 1) {
        final inicioSemana = DateTime(
          agora.year,
          agora.month,
          agora.day,
        ).subtract(
          Duration(days: agora.weekday - 1),
        );

        final fimSemana = inicioSemana.add(
          const Duration(days: 7),
        );

        return !data.isBefore(inicioSemana) &&
            data.isBefore(fimSemana);
      }

      return true;
    }).toList();

    compromissos.sort((a, b) {
      if (a.data == null) return 1;
      if (b.data == null) return -1;
      return a.data!.compareTo(b.data!);
    });

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          12,
          0,
          12,
          12,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide.none,
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide.none,
        ),

        leading: Icon(
          Icons.event_note_outlined,
          color: AppTheme.primary,
          size: 22,
        ),
        title: Text(
          'Meus compromissos',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          '${state.compromissos.length} compromissos cadastrados',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
        children: [
          Row(
            children: [
              _FiltroCompromisso(
                texto: 'Hoje',
                selecionado: _filtroSelecionado == 0,
                onTap: () {
                  setState(() {
                    _filtroSelecionado = 0;
                  });
                },
              ),
              const SizedBox(width: 6),
              _FiltroCompromisso(
                texto: 'Esta semana',
                selecionado: _filtroSelecionado == 1,
                onTap: () {
                  setState(() {
                    _filtroSelecionado = 1;
                  });
                },
              ),
              const SizedBox(width: 6),
              _FiltroCompromisso(
                texto: 'Todos',
                selecionado: _filtroSelecionado == 2,
                onTap: () {
                  setState(() {
                    _filtroSelecionado = 2;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (compromissos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 18,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    size: 30,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhum compromisso neste período.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...compromissos.map(
              (compromisso) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                ),
                child: _MeuCompromissoCard(
                  compromisso: compromisso,
                  onConcluir: () async {
                    await _marcarComoConcluido(
                      context,
                      compromisso,
                    );
                  },
                  onCancelar: () async {
                    await _cancelarCompromisso(
                      context,
                      compromisso,
                    );
                  },
                  onRemarcar: () async {
                    await _remarcarCompromisso(
                      context,
                      compromisso,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _marcarComoConcluido(
    BuildContext context,
    Compromisso compromisso,
  ) async {
    try {
      await context.read<AppState>().updateCompromisso(
        compromisso.copyWith(
          status: 'concluido',
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compromisso marcado como concluído.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível atualizar o compromisso: $e',
          ),
        ),
      );
    }
  }

  Future<void> _cancelarCompromisso(
    BuildContext context,
    Compromisso compromisso,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Cancelar compromisso?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'O compromisso será mantido no histórico como cancelado.',
            style: GoogleFonts.poppins(
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Voltar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Cancelar compromisso'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await context.read<AppState>().updateCompromisso(
        compromisso.copyWith(
          status: 'cancelado',
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compromisso cancelado.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível cancelar o compromisso: $e',
          ),
        ),
      );
    }
  }

  Future<void> _remarcarCompromisso(
    BuildContext context,
    Compromisso compromisso,
  ) async {
    final dataAtual =
        compromisso.data ?? DateTime.now();

    final novaData = await showDatePicker(
      context: context,
      initialDate: dataAtual,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (novaData == null) return;

    final horarioAtual =
        compromisso.horario.split(':');

    final horario = TimeOfDay(
      hour: horarioAtual.isNotEmpty
          ? int.tryParse(horarioAtual[0]) ?? 0
          : 0,
      minute: horarioAtual.length > 1
          ? int.tryParse(horarioAtual[1]) ?? 0
          : 0,
    );

    final novoHorario = await showTimePicker(
      context: context,
      initialTime: horario,
    );

    if (novoHorario == null) return;

    final dataCompleta = DateTime(
      novaData.year,
      novaData.month,
      novaData.day,
      novoHorario.hour,
      novoHorario.minute,
    );

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

    const dias = [
      'SEG',
      'TER',
      'QUA',
      'QUI',
      'SEX',
      'SÁB',
      'DOM',
    ];

    final atualizado = compromisso.copyWith(
      horario:
          '${novoHorario.hour.toString().padLeft(2, '0')}:'
          '${novoHorario.minute.toString().padLeft(2, '0')}',
      dia: novaData.day,
      mesAbrev: meses[novaData.month - 1],
      diaAbrev: dias[novaData.weekday - 1],
      data: dataCompleta,
      status: 'pendente',
    );

    try {
      await context.read<AppState>().updateCompromisso(
        atualizado,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compromisso remarcado.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível remarcar o compromisso: $e',
          ),
        ),
      );
    }
  }
}

class _FiltroCompromisso extends StatelessWidget {
  final String texto;
  final bool selecionado;
  final VoidCallback onTap;

  const _FiltroCompromisso({
    required this.texto,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: selecionado
                ? AppTheme.primary
                : AppTheme.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: selecionado
                  ? Colors.white
                  : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _MeuCompromissoCard extends StatelessWidget {
  final Compromisso compromisso;
  final VoidCallback onConcluir;
  final VoidCallback onRemarcar;
  final VoidCallback onCancelar;

  const _MeuCompromissoCard({
    required this.compromisso,
    required this.onConcluir,
    required this.onRemarcar,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final concluido =
        compromisso.status == 'concluido';
    final cancelado =
        compromisso.status == 'cancelado';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cancelado
            ? AppTheme.background
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            padding: const EdgeInsets.symmetric(
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: cancelado
                  ? AppTheme.divider
                  : const Color(0xFFE0F4F1),
              borderRadius:
                  BorderRadius.circular(9),
            ),
            child: Column(
              children: [
                Text(
                  compromisso.mesAbrev,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: cancelado
                        ? AppTheme.textSecondary
                        : AppTheme.primary,
                  ),
                ),
                Text(
                  '${compromisso.dia}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: cancelado
                        ? AppTheme.textSecondary
                        : AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  compromisso.titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cancelado
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary,
                    decoration: cancelado || concluido
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${compromisso.horario} • '
                  '${compromisso.local}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cancelado
                      ? 'Cancelado'
                      : concluido
                          ? 'Concluído'
                          : 'Pendente',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: cancelado
                        ? AppTheme.textSecondary
                        : concluido
                            ? AppTheme.primary
                            : AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),
          if (!cancelado && !concluido)
            IconButton(
              tooltip: 'Marcar como feito',
              onPressed: onConcluir,
              icon: Icon(
                Icons.check_circle_outline,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
          PopupMenuButton<String>(
            tooltip: 'Ações',
            onSelected: (valor) {
              if (valor == 'concluir') {
                onConcluir();
              } else if (valor == 'remarcar') {
                onRemarcar();
              } else if (valor == 'cancelar') {
                onCancelar();
              }
            },
            itemBuilder: (context) => [
              if (!concluido && !cancelado)
                const PopupMenuItem(
                  value: 'concluir',
                  child: Text('Marcar como feito'),
                ),
              if (!cancelado)
                const PopupMenuItem(
                  value: 'remarcar',
                  child: Text('Remarcar'),
                ),
              if (!cancelado)
                const PopupMenuItem(
                  value: 'cancelar',
                  child: Text('Cancelar'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}