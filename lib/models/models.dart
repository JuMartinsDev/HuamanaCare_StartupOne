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
}

class Compromisso {
  final String titulo;
  final String horario;
  final String local;
  final int dia;
  final String mesAbrev;
  final String diaAbrev;

  const Compromisso({
    required this.titulo,
    required this.horario,
    required this.local,
    required this.dia,
    required this.mesAbrev,
    required this.diaAbrev,
  });
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
}
