import 'package:cloud_firestore/cloud_firestore.dart';

class Remedio {
  final String id;
  final String nome;
  final String tipo;
  final String horario;
  bool tomado;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  DateTime? dataTomado;

  Remedio({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.horario,
    this.tomado = false,
    this.dataInicio,
    this.dataFim,
    this.dataTomado,
  });

  factory Remedio.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    DateTime? converterData(dynamic valor) {
      if (valor == null) return null;

      if (valor is Timestamp) {
        return valor.toDate();
      }

      if (valor is String && valor.isNotEmpty) {
        return DateTime.tryParse(valor);
      }

      return null;
    }

    final dataTomado = converterData(map['dataTomado']);
    final agora = DateTime.now();

    final tomadoHoje = dataTomado != null &&
        dataTomado.year == agora.year &&
        dataTomado.month == agora.month &&
        dataTomado.day == agora.day;

    return Remedio(
      id: id,
      nome: map['nome'] ?? '',
      tipo: map['tipo'] ?? '',
      horario: map['horario'] ?? '',
      tomado: map['tomado'] == true && tomadoHoje,
      dataInicio: converterData(map['dataInicio']),
      dataFim: converterData(map['dataFim']),
      dataTomado: dataTomado,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'tipo': tipo,
      'horario': horario,
      'tomado': tomado,
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'dataTomado': dataTomado?.toIso8601String(),
    };
  }
}

class Compromisso {
  final String id;
  final String titulo;
  final String horario;
  final String local;
  final int dia;
  final String mesAbrev;
  final String diaAbrev;
  final DateTime? data;
  final String status;

  const Compromisso({
    this.id = '',
    required this.titulo,
    required this.horario,
    required this.local,
    required this.dia,
    required this.mesAbrev,
    required this.diaAbrev,
    this.data,
    this.status = 'pendente',
  });

  factory Compromisso.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    DateTime? data;

    final valorData = map['data'];

    if (valorData is String && valorData.isNotEmpty) {
      data = DateTime.tryParse(valorData);
    }

    return Compromisso(
      id: id,
      titulo: map['titulo'] ?? '',
      horario: map['horario'] ?? '',
      local: map['local'] ?? '',
      dia: map['dia'] ?? 0,
      mesAbrev: map['mesAbrev'] ?? '',
      diaAbrev: map['diaAbrev'] ?? '',
      data: data,
      status: map['status'] ?? 'pendente',
    );
  }

Compromisso copyWith({
  String? id,
  String? titulo,
  String? horario,
  String? local,
  int? dia,
  String? mesAbrev,
  String? diaAbrev,
  DateTime? data,
  String? status,
}) {
  return Compromisso(
    id: id ?? this.id,
    titulo: titulo ?? this.titulo,
    horario: horario ?? this.horario,
    local: local ?? this.local,
    dia: dia ?? this.dia,
    mesAbrev: mesAbrev ?? this.mesAbrev,
    diaAbrev: diaAbrev ?? this.diaAbrev,
    data: data ?? this.data,
    status: status ?? this.status,
  );
}

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'horario': horario,
      'local': local,
      'dia': dia,
      'mesAbrev': mesAbrev,
      'diaAbrev': diaAbrev,
      'data': data?.toIso8601String(),
      'status': status,
    };
  }
}

class Mensagem {
  final String id;
  final String texto;
  final bool recebido;
  final String hora;
  final bool isMilo;
  final String? remetente;
  final String? remetenteUid;
  final DateTime criadaEm;

  Mensagem({
    required this.id,
    required this.texto,
    required this.recebido,
    required this.hora,
    this.isMilo = false,
    this.remetente,
    this.remetenteUid,
    DateTime? criadaEm,
  }) : criadaEm = criadaEm ?? DateTime.now();

  factory Mensagem.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final valorData = map['criadaEm'];

    DateTime dataCriacao;

    if (valorData is String) {
      dataCriacao =
          DateTime.tryParse(valorData) ?? DateTime.now();
    } else if (valorData is DateTime) {
      dataCriacao = valorData;
    } else {
      // Compatibilidade com mensagens antigas.
      final idNumerico = RegExp(r'^[ua](\d+)$')
          .firstMatch(id)
          ?.group(1);

      dataCriacao = idNumerico != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.parse(idNumerico),
            )
          : DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Mensagem(
      id: id,
      texto: map['texto'] ?? '',
      recebido: map['recebido'] ?? false,
      hora: map['hora'] ?? '',
      isMilo: map['isMilo'] ?? false,
      remetente: map['remetente'],
      remetenteUid: map['remetenteUid'],
      criadaEm: dataCriacao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'texto': texto,
      'recebido': recebido,
      'hora': hora,
      'isMilo': isMilo,
      'remetente': remetente,
      'remetenteUid': remetenteUid,
      'criadaEm': criadaEm.toIso8601String(),
    };
  }
}

class Paciente {
  final String nome;
  final int idade;
  final String id;
  final String dataNascimento;
  final String sexo;
  final String estadoCivil;
  final String endereco;
  final String telefone;
  final String tipoSanguineo;
  final String condicaoSaude;
  final String alergias;
  final String dispositivos;
  final String observacoes;
  final String cuidadorNome;
  final String cuidadorTurno;
  final String cuidadorCarga;

  // Documentos - opcionais
  final String cpf;
  final String rgCin;
  final String orgaoExpedidor;
  final String dataEmissaoDocumento;
  final String cartaoSus;

  const Paciente({
    required this.nome,
    required this.idade,
    required this.id,
    required this.dataNascimento,
    required this.sexo,
    required this.estadoCivil,
    required this.endereco,
    required this.telefone,
    required this.tipoSanguineo,
    required this.condicaoSaude,
    required this.alergias,
    required this.dispositivos,
    required this.observacoes,
    required this.cuidadorNome,
    required this.cuidadorTurno,
    required this.cuidadorCarga,

    // Documentos
    this.cpf = '',
    this.rgCin = '',
    this.orgaoExpedidor = '',
    this.dataEmissaoDocumento = '',
    this.cartaoSus = '',
  });

  factory Paciente.fromMap(
    Map<String, dynamic> map,
  ) {
    return Paciente(
      nome: map['nome'] ?? '',
      idade: map['idade'] ?? 0,
      id: map['id'] ?? '',
      dataNascimento: map['dataNascimento'] ?? '',
      sexo: map['sexo'] ?? '',
      estadoCivil: map['estadoCivil'] ?? '',
      endereco: map['endereco'] ?? '',
      telefone: map['telefone'] ?? '',
      tipoSanguineo: map['tipoSanguineo'] ?? '',
      condicaoSaude: map['condicaoSaude'] ?? '',
      alergias: map['alergias'] ?? '',
      dispositivos: map['dispositivos'] ?? '',
      observacoes: map['observacoes'] ?? '',
      cuidadorNome: map['cuidadorNome'] ?? '',
      cuidadorTurno: map['cuidadorTurno'] ?? '',
      cuidadorCarga: map['cuidadorCarga'] ?? '',

      // Documentos
      cpf: map['cpf'] ?? '',
      rgCin: map['rgCin'] ?? '',
      orgaoExpedidor: map['orgaoExpedidor'] ?? '',
      dataEmissaoDocumento: map['dataEmissaoDocumento'] ?? '',
      cartaoSus: map['cartaoSus'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'idade': idade,
      'id': id,
      'dataNascimento': dataNascimento,
      'sexo': sexo,
      'estadoCivil': estadoCivil,
      'endereco': endereco,
      'telefone': telefone,
      'tipoSanguineo': tipoSanguineo,
      'condicaoSaude': condicaoSaude,
      'alergias': alergias,
      'dispositivos': dispositivos,
      'observacoes': observacoes,
      'cuidadorNome': cuidadorNome,
      'cuidadorTurno': cuidadorTurno,
      'cuidadorCarga': cuidadorCarga,

      // Documentos
      'cpf': cpf,
      'rgCin': rgCin,
      'orgaoExpedidor': orgaoExpedidor,
      'dataEmissaoDocumento': dataEmissaoDocumento,
      'cartaoSus': cartaoSus,
    };
  }
}

class Cuidado {
  final String id;
  final String tipo;
  final String horario;
  final String observacao;
  final String frequencia;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final bool ativo;
final Map<String, bool> conclusoesPorData;

  const Cuidado({
    this.id = '',
    required this.tipo,
    required this.horario,
    this.observacao = '',
    this.frequencia = 'diaria',
    this.dataInicio,
    this.dataFim,
    this.ativo = true,
  this.conclusoesPorData = const {},
  });

  factory Cuidado.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Cuidado(
      id: id,
      tipo: map['tipo'] ?? '',
      horario: map['horario'] ?? '',
      observacao: map['observacao'] ?? '',
      frequencia: map['frequencia'] ?? 'diaria',
      dataInicio: _dataFromMap(map['dataInicio']),
      dataFim: _dataFromMap(map['dataFim']),
      ativo: map['ativo'] == true,
conclusoesPorData: Map<String, bool>.from(
  map['conclusoesPorData'] ?? {},
),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'horario': horario,
      'observacao': observacao,
      'frequencia': frequencia,
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'ativo': ativo,
'conclusoesPorData': conclusoesPorData,
    };
  }

  static DateTime? _dataFromMap(dynamic valor) {
    if (valor is String && valor.isNotEmpty) {
      return DateTime.tryParse(valor);
    }
    return null;
  }

  bool concluidoEm(DateTime data) {
  final chave =
      '${data.year.toString().padLeft(4, '0')}-'
      '${data.month.toString().padLeft(2, '0')}-'
      '${data.day.toString().padLeft(2, '0')}';

  return conclusoesPorData[chave] == true;
}

Cuidado marcarConcluidoEm(DateTime data) {
  final chave =
      '${data.year.toString().padLeft(4, '0')}-'
      '${data.month.toString().padLeft(2, '0')}-'
      '${data.day.toString().padLeft(2, '0')}';

  return copyWith(
    conclusoesPorData: {
      ...conclusoesPorData,
      chave: true,
    },
  );
}

  Cuidado copyWith({
    String? id,
    String? tipo,
    String? horario,
    String? observacao,
    String? frequencia,
    DateTime? dataInicio,
    DateTime? dataFim,
    bool? ativo,
Map<String, bool>? conclusoesPorData,
  }) {
    return Cuidado(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      horario: horario ?? this.horario,
      observacao: observacao ?? this.observacao,
      frequencia: frequencia ?? this.frequencia,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      ativo: ativo ?? this.ativo,
conclusoesPorData:
    conclusoesPorData ?? this.conclusoesPorData,
    );
  }
}

class Historico {
  final String id;
  final String tipo;
  final String titulo;
  final String descricao;
  final DateTime data;

  final DateTime? dataPrevista;
  final DateTime? dataRealizada;
  final String resultado;
  final String atividadeId;

  const Historico({
    this.id = '',
    required this.tipo,
    required this.titulo,
    required this.descricao,
    required this.data,
    this.dataPrevista,
    this.dataRealizada,
    this.resultado = '',
    this.atividadeId = '',
  });

  factory Historico.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    DateTime? converterData(dynamic valor) {
      if (valor == null) return null;

      if (valor is Timestamp) {
        return valor.toDate();
      }

      if (valor is String && valor.isNotEmpty) {
        return DateTime.tryParse(valor);
      }

      return null;
    }

    final data = converterData(map['data']) ?? DateTime.now();

    return Historico(
      id: id,
      tipo: map['tipo'] ?? '',
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      data: data,
      dataPrevista: converterData(
        map['dataPrevista'],
      ),
      dataRealizada: converterData(
        map['dataRealizada'],
      ),
      resultado: map['resultado'] ?? '',
      atividadeId: map['atividadeId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'titulo': titulo,
      'descricao': descricao,
      'data': data.toIso8601String(),
      'dataPrevista': dataPrevista?.toIso8601String(),
      'dataRealizada': dataRealizada?.toIso8601String(),
      'resultado': resultado,
      'atividadeId': atividadeId,
    };
  }
}


class AtividadeCognitivaResultado {
  final String id;
  final String tipo;
  final String titulo;
  final DateTime data;
  final int pontuacao;
  final int acertos;
  final int erros;
  final int tempoSegundos;
  final Map<String, dynamic> detalhes;

  const AtividadeCognitivaResultado({
    this.id = '',
    required this.tipo,
    required this.titulo,
    required this.data,
    this.pontuacao = 0,
    this.acertos = 0,
    this.erros = 0,
    this.tempoSegundos = 0,
    this.detalhes = const {},
  });

  factory AtividadeCognitivaResultado.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    DateTime converterData(dynamic valor) {
      if (valor is Timestamp) {
        return valor.toDate();
      }

      if (valor is String && valor.isNotEmpty) {
        return DateTime.tryParse(valor) ?? DateTime.now();
      }

      return DateTime.now();
    }

    return AtividadeCognitivaResultado(
      id: id,
      tipo: map['tipo'] ?? '',
      titulo: map['titulo'] ?? '',
      data: converterData(map['data']),
      pontuacao: (map['pontuacao'] as num?)?.toInt() ?? 0,
      acertos: (map['acertos'] as num?)?.toInt() ?? 0,
      erros: (map['erros'] as num?)?.toInt() ?? 0,
      tempoSegundos:
          (map['tempoSegundos'] as num?)?.toInt() ?? 0,
      detalhes: Map<String, dynamic>.from(
        map['detalhes'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'titulo': titulo,
      'data': data.toIso8601String(),
      'pontuacao': pontuacao,
      'acertos': acertos,
      'erros': erros,
      'tempoSegundos': tempoSegundos,
      'detalhes': detalhes,
    };
  }
}