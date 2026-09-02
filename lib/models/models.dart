class Remedio {
  final String id;
  final String nome;
  final String tipo;
  final String horario;
  bool tomado;

  Remedio({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.horario,
    this.tomado = false,
  });

  // Firestore -> Flutter
  factory Remedio.fromMap(String id, Map<String, dynamic> map) {
    return Remedio(
      id: id,
      nome: map['nome'] ?? '',
      tipo: map['tipo'] ?? '',
      horario: map['horario'] ?? '',
      tomado: map['tomado'] ?? false,
    );
  }

  // Flutter -> Firestore
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'tipo': tipo,
      'horario': horario,
      'tomado': tomado,
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

  const Compromisso({
    this.id = '',
    required this.titulo,
    required this.horario,
    required this.local,
    required this.dia,
    required this.mesAbrev,
    required this.diaAbrev,
    this.data,
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

  Mensagem({
    required this.id,
    required this.texto,
    required this.recebido,
    required this.hora,
    this.isMilo = false,
    this.remetente,
  });

  factory Mensagem.fromMap(String id, Map<String, dynamic> map) {
    return Mensagem(
      id: id,
      texto: map['texto'] ?? '',
      recebido: map['recebido'] ?? false,
      hora: map['hora'] ?? '',
      isMilo: map['isMilo'] ?? false,
      remetente: map['remetente'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'texto': texto,
      'recebido': recebido,
      'hora': hora,
      'isMilo': isMilo,
      'remetente': remetente,
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
  });

  factory Paciente.fromMap(Map<String, dynamic> map) {
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
    };
  }
}
