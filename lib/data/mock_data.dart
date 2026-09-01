import '../models/models.dart';

class MockData {
  // ── Paciente logado ──────────────────────────────────────────────────────
  static const Paciente paciente = Paciente(
    nome: 'Gustavo G.',
    idade: 68,
    id: '#1234',
    dataNascimento: '21/01/1958',
    sexo: 'Masculino',
    estadoCivil: 'Casado',
    endereco: 'Rua 173, nº456, apart 789',
    telefone: '(11) 1234-5678',
    tipoSanguineo: 'A+',
    condicaoSaude: 'Tosse seca',
    alergias: 'Pelos de animais e poeira',
    dispositivos: 'Nenhum',
    observacoes: 'Nenhuma',
    cuidadorNome: 'Kaua G.',
    cuidadorTurno: 'Manhã',
    cuidadorCarga: '6h/dia',
  );

  // ── Remédios ─────────────────────────────────────────────────────────────
  static List<Remedio> remedios() => [
    Remedio(id: 'r1', nome: 'Vitamina D',  tipo: 'COMPRIMIDO', horario: '12:00', tomado: true),
    Remedio(id: 'r2', nome: 'Morfina',     tipo: 'COMPRIMIDO', horario: '20:00', tomado: false),
    Remedio(id: 'r3', nome: 'Fibra',       tipo: 'COMPRIMIDO', horario: '20:00', tomado: false),
    Remedio(id: 'r4', nome: 'Melatonina',  tipo: 'COMPRIMIDO', horario: '22:00', tomado: false),
  ];

  // ── Compromisso ──────────────────────────────────────────────────────────
  static const Compromisso compromisso = Compromisso(
    titulo: 'Consulta Cardiologista',
    horario: '15:00',
    local: 'Clínica Vida',
    dia: 15,
    mesAbrev: 'MAI',
    diaAbrev: 'SEX',
  );

  // ── Mensagens iniciais por canal ─────────────────────────────────────────
  static List<Mensagem> mensagensFamilia() => [
    Mensagem(id: 'm1', texto: 'Oi papai, tomou os remédios?', recebido: true,  hora: '09:10', remetente: 'Ana'),
    Mensagem(id: 'm2', texto: 'Ainda não, vou tomar agora.',  recebido: false, hora: '09:12'),
  ];

  static List<Mensagem> mensagensCuidador() => [
    Mensagem(id: 'm3', texto: 'Bom dia! Vou chegar às 8h.', recebido: true, hora: '07:30', remetente: 'Kaua'),
  ];

  static List<Mensagem> mensagensMilo() => [
    Mensagem(
      id: 'm4',
      texto: 'Olá, Gustavo! Sou o Milo, seu assistente de saúde. Como posso te ajudar hoje? 🐘',
      recebido: true,
      hora: '08:00',
      isMilo: true,
      remetente: 'Milo',
    ),
  ];

  // ── Respostas offline do Milo ─────────────────────────────────────────────
  static const List<String> respostasMilo = [
    'Entendido! Vou registrar isso no seu histórico. 🐘',
    'Certo, Gustavo! Seus cuidadores foram notificados.',
    'Anotado! Lembre-se de tomar seu próximo remédio às 20h. 💊',
    'Ok! O que mais você precisa?',
    'Registrei sua informação. Tudo bem com você hoje?',
    'Perfeito! Vou alertar a família sobre isso.',
  ];

  static const List<String> respostasFamilia = [
    'Ok, obrigado por avisar! ❤️',
    'Tá bom, pai! Qualquer coisa me chama.',
    'Ótimo! A gente passa aí mais tarde.',
  ];

  static const List<String> respostasCuidador = [
    'Certo! Anotei aqui.',
    'Ok, confirmo o recebimento.',
    'Entendido! Vou registrar no relatório.',
  ];
}
