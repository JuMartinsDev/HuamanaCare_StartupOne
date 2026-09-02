import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // AUTENTICAÇÃO
  // ============================================================

  bool _logado = false;
  String _perfil = '';

  bool get logado => _logado;
  String get perfil => _perfil;

  // ============================================================
  // PACIENTE
  // ============================================================

  Paciente _paciente = const Paciente(
    nome: '',
    idade: 0,
    id: '',
    dataNascimento: '',
    sexo: '',
    estadoCivil: '',
    endereco: '',
    telefone: '',
    tipoSanguineo: '',
    condicaoSaude: '',
    alergias: '',
    dispositivos: '',
    observacoes: '',
    cuidadorNome: '',
    cuidadorTurno: '',
    cuidadorCarga: '',
    cpf: '',
    rgCin: '',
    orgaoExpedidor: '',
    dataEmissaoDocumento: '',
    cartaoSus: '',
  );

  Paciente get paciente => _paciente;

  // ============================================================
  // REMÉDIOS
  // ============================================================

  List<Remedio> _remedios = [];

  List<Remedio> get remedios =>
      List.unmodifiable(_remedios);

  // ============================================================
  // COMPROMISSOS
  // ============================================================

  List<Compromisso> _compromissos = [];

  List<Compromisso> get compromissos =>
      List.unmodifiable(_compromissos);

  // ============================================================
  // HISTÓRICO
  // ============================================================

  List<Historico> _historico = [];

  List<Historico> get historico =>
      List.unmodifiable(_historico);

  // ============================================================
  // MENSAGENS
  // ============================================================

  final Map<String, List<Mensagem>> _msgs = {
    'familia': [],
    'cuidador': [],
    'milo': [],
  };

  List<Mensagem> mensagens(String canal) {
    return List.unmodifiable(
      _msgs[canal] ?? [],
    );
  }

  // ============================================================
  // INICIALIZAÇÃO DA SESSÃO
  // ============================================================

  Future<void> inicializar() async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    try {
      _logado = true;

      await _carregarDadosFirestore();

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Erro ao restaurar sessão: $e',
      );

      _logado = false;
      _perfil = '';
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login(
    String email,
    String senha,
  ) async {
    try {
      final credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );

      if (credential.user == null) {
        throw Exception(
          'Usuário não encontrado.',
        );
      }

      await _carregarDadosFirestore();

      _logado = true;

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _mensagemErroFirebase(e),
      );
    }
  }

  // ============================================================
  // CARREGAR DADOS DO FIRESTORE
  // ============================================================

  Future<void> _carregarDadosFirestore() async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final pacienteRef =
        _firestore.collection('pacientes').doc(user.uid);

    // ----------------------------------------------------------
    // PACIENTE
    // ----------------------------------------------------------

    final pacienteDoc =
        await pacienteRef.get();

    if (pacienteDoc.exists &&
        pacienteDoc.data() != null) {
      final dados = pacienteDoc.data()!;

      _paciente = Paciente.fromMap(dados);

      _perfil =
          dados['perfil'] as String? ?? '';
    } else {
      await pacienteRef.set(
        {
          'uid': user.uid,
          'id': user.uid,
          'nome': user.displayName ?? '',
          'email': user.email ?? '',
          'perfil': '',
        },
        SetOptions(merge: true),
      );

      _paciente = Paciente(
        nome: user.displayName ?? '',
        idade: 0,
        id: user.uid,
        dataNascimento: '',
        sexo: '',
        estadoCivil: '',
        endereco: '',
        telefone: '',
        tipoSanguineo: '',
        condicaoSaude: '',
        alergias: '',
        dispositivos: '',
        observacoes: '',
        cuidadorNome: '',
        cuidadorTurno: '',
        cuidadorCarga: '',
        cpf: '',
        rgCin: '',
        orgaoExpedidor: '',
        dataEmissaoDocumento: '',
        cartaoSus: '',
      );

      _perfil = '';
    }

    // ----------------------------------------------------------
    // REMÉDIOS
    // ----------------------------------------------------------

    final remediosSnapshot =
        await pacienteRef
            .collection('remedios')
            .get();

    _remedios = remediosSnapshot.docs
        .map(
          (doc) => Remedio.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();

    // ----------------------------------------------------------
    // COMPROMISSOS
    // ----------------------------------------------------------

    final compromissosSnapshot =
        await pacienteRef
            .collection('compromissos')
            .get();

    _compromissos = compromissosSnapshot.docs
        .map(
          (doc) => Compromisso.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();

    // ----------------------------------------------------------
    // HISTÓRICO
    // ----------------------------------------------------------

    final historicoSnapshot =
        await pacienteRef
            .collection('historico')
            .get();

    _historico = historicoSnapshot.docs
        .map(
          (doc) => Historico.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();

    // Mais recente primeiro.
    _historico.sort(
      (a, b) => b.data.compareTo(a.data),
    );

    // ----------------------------------------------------------
    // MENSAGENS
    // ----------------------------------------------------------

    await _carregarMensagensFirestore();
  }

  // ============================================================
  // REMÉDIOS
  // ============================================================

  Future<void> toggleRemedio(
    String id,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final index =
        _remedios.indexWhere(
      (remedio) => remedio.id == id,
    );

    if (index == -1) {
      return;
    }

    final remedio = _remedios[index];

    remedio.tomado = !remedio.tomado;

    await _firestore
        .collection('pacientes')
        .doc(user.uid)
        .collection('remedios')
        .doc(remedio.id)
        .update({
      'tomado': remedio.tomado,
    });

    notifyListeners();
  }

  Future<void> updateRemedio(
  Remedio remedio,
) async {
  final user = _auth.currentUser;

  if (user == null) {
    throw Exception('Usuário não autenticado.');
  }

  await _firestore
      .collection('pacientes')
      .doc(user.uid)
      .collection('remedios')
      .doc(remedio.id)
      .set(
        remedio.toMap(),
      );

  final index = _remedios.indexWhere(
    (item) => item.id == remedio.id,
  );

  if (index != -1) {
    _remedios[index] = remedio;
  }

  notifyListeners();
}

  Future<void> addRemedio(
  Remedio remedio,
) async {
  final user = _auth.currentUser;

  if (user == null) {
    return;
  }

  final docRef = await _firestore
      .collection('pacientes')
      .doc(user.uid)
      .collection('remedios')
      .add(
        remedio.toMap(),
      );

  final novoRemedio = Remedio(
    id: docRef.id,
    nome: remedio.nome,
    tipo: remedio.tipo,
    horario: remedio.horario,
    tomado: remedio.tomado,
    dataInicio: remedio.dataInicio,
    dataFim: remedio.dataFim,
  );

  _remedios.add(novoRemedio);

  notifyListeners();
}

  Future<void> removeRemedio(
    String id,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await _firestore
        .collection('pacientes')
        .doc(user.uid)
        .collection('remedios')
        .doc(id)
        .delete();

    _remedios.removeWhere(
      (remedio) => remedio.id == id,
    );

    notifyListeners();
  }

  // ============================================================
  // COMPROMISSOS
  // ============================================================

  Future<void> addCompromisso(
    Compromisso compromisso,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final docRef =
        await _firestore
            .collection('pacientes')
            .doc(user.uid)
            .collection('compromissos')
            .add(
              compromisso.toMap(),
            );

    final novoCompromisso = Compromisso(
      id: docRef.id,
      titulo: compromisso.titulo,
      horario: compromisso.horario,
      local: compromisso.local,
      dia: compromisso.dia,
      mesAbrev: compromisso.mesAbrev,
      diaAbrev: compromisso.diaAbrev,
      data: compromisso.data,
    );

    _compromissos.add(novoCompromisso);

    // Registra automaticamente no histórico.
    await _registrarHistorico(
      tipo: 'compromisso',
      titulo: 'Compromisso criado',
      descricao: compromisso.titulo,
    );

    notifyListeners();
  }

  Future<void> removeCompromisso(
    String id,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final index =
        _compromissos.indexWhere(
      (compromisso) => compromisso.id == id,
    );

    if (index == -1) {
      return;
    }

    final compromisso =
        _compromissos[index];

    await _firestore
        .collection('pacientes')
        .doc(user.uid)
        .collection('compromissos')
        .doc(id)
        .delete();

    _compromissos.removeAt(index);

    // Registra automaticamente no histórico.
    await _registrarHistorico(
      tipo: 'compromisso',
      titulo: 'Compromisso removido',
      descricao: compromisso.titulo,
    );

    notifyListeners();
  }

  Future<void> updateCompromisso(
    Compromisso compromisso,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await _firestore
        .collection('pacientes')
        .doc(user.uid)
        .collection('compromissos')
        .doc(compromisso.id)
        .update(
          compromisso.toMap(),
        );

    final index =
        _compromissos.indexWhere(
      (item) => item.id == compromisso.id,
    );

    if (index != -1) {
      _compromissos[index] = compromisso;
    }

    // Registra automaticamente no histórico.
    await _registrarHistorico(
      tipo: 'compromisso',
      titulo: 'Compromisso atualizado',
      descricao: compromisso.titulo,
    );

    notifyListeners();
  }

  // ============================================================
  // HISTÓRICO
  // ============================================================

  Future<void> _registrarHistorico({
    required String tipo,
    required String titulo,
    required String descricao,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final historico = Historico(
      tipo: tipo,
      titulo: titulo,
      descricao: descricao,
      data: DateTime.now(),
    );

    final docRef =
        await _firestore
            .collection('pacientes')
            .doc(user.uid)
            .collection('historico')
            .add(
              historico.toMap(),
            );

    final novoHistorico = Historico(
      id: docRef.id,
      tipo: historico.tipo,
      titulo: historico.titulo,
      descricao: historico.descricao,
      data: historico.data,
    );

    _historico.add(novoHistorico);

    _historico.sort(
      (a, b) => b.data.compareTo(a.data),
    );
  }

  Future<void> addHistorico(
    Historico historico,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final docRef =
        await _firestore
            .collection('pacientes')
            .doc(user.uid)
            .collection('historico')
            .add(
              historico.toMap(),
            );

    final novoHistorico = Historico(
      id: docRef.id,
      tipo: historico.tipo,
      titulo: historico.titulo,
      descricao: historico.descricao,
      data: historico.data,
    );

    _historico.add(novoHistorico);

    _historico.sort(
      (a, b) => b.data.compareTo(a.data),
    );

    notifyListeners();
  }

  Future<void> removeHistorico(
    String id,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await _firestore
        .collection('pacientes')
        .doc(user.uid)
        .collection('historico')
        .doc(id)
        .delete();

    _historico.removeWhere(
      (historico) => historico.id == id,
    );

    notifyListeners();
  }

  // ============================================================
  // MENSAGENS
  // ============================================================

  Future<void> _carregarMensagensFirestore() async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    const canais = [
      'familia',
      'cuidador',
      'milo',
    ];

    for (final canal in canais) {
      final snapshot =
          await _firestore
              .collection('pacientes')
              .doc(user.uid)
              .collection('canais')
              .doc(canal)
              .collection('mensagens')
              .orderBy('hora')
              .get();

      _msgs[canal] = snapshot.docs
          .map(
            (doc) => Mensagem.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();
    }
  }

  Future<void> addMensagem(
    String canal,
    Mensagem mensagem,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final docRef =
        await _firestore
            .collection('pacientes')
            .doc(user.uid)
            .collection('canais')
            .doc(canal)
            .collection('mensagens')
            .add(
              mensagem.toMap(),
            );

    final novaMensagem = Mensagem(
      id: docRef.id,
      texto: mensagem.texto,
      recebido: mensagem.recebido,
      hora: mensagem.hora,
      isMilo: mensagem.isMilo,
      remetente: mensagem.remetente,
    );

    _msgs.putIfAbsent(
      canal,
      () => [],
    );

    _msgs[canal]!.add(
      novaMensagem,
    );

    notifyListeners();
  }

  // ============================================================
  // SOS
  // ============================================================

  bool _sosAtivado = false;

  bool get sosAtivado => _sosAtivado;

  Future<void> acionarSos() async {
    _sosAtivado = true;

    notifyListeners();

    final user = _auth.currentUser;

    if (user != null) {
      await _firestore
          .collection('pacientes')
          .doc(user.uid)
          .collection('sos_eventos')
          .add({
        'dataHora':
            FieldValue.serverTimestamp(),
        'status': 'acionado',
        'tipo': 'sos',
      });
    }

    Future.delayed(
      const Duration(seconds: 5),
      () {
        _sosAtivado = false;
        notifyListeners();
      },
    );
  }

  // ============================================================
  // DEFINIR PERFIL
  // ============================================================

  Future<void> definirPerfil(
    String perfilSelecionado,
  ) async {
    _perfil = perfilSelecionado;

    // O usuário já está autenticado nesse momento.
    _logado = true;

    final user = _auth.currentUser;

    if (user != null) {
      await _firestore
          .collection('pacientes')
          .doc(user.uid)
          .set(
        {
          'perfil': perfilSelecionado,
        },
        SetOptions(merge: true),
      );
    }

    notifyListeners();
  }

  // ============================================================
  // USUÁRIO CRIADO
  // ============================================================

  Future<void> usuarioCriado({
    required String nome,
    required String email,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final paciente = Paciente(
      nome: nome,
      idade: 0,
      id: user.uid,
      dataNascimento: '',
      sexo: '',
      estadoCivil: '',
      endereco: '',
      telefone: '',
      tipoSanguineo: '',
      condicaoSaude: '',
      alergias: '',
      dispositivos: '',
      observacoes: '',
      cuidadorNome: '',
      cuidadorTurno: '',
      cuidadorCarga: '',
      cpf: '',
      rgCin: '',
      orgaoExpedidor: '',
      dataEmissaoDocumento: '',
      cartaoSus: '',
    );

    await _firestore
        .collection('pacientes')
        .doc(user.uid)
        .set(
      {
        ...paciente.toMap(),
        'uid': user.uid,
        'email': email,
        'perfil': '',
      },
      SetOptions(merge: true),
    );

    _paciente = paciente;

    // createUserWithEmailAndPassword
    // já autentica o usuário.
    _logado = true;
    _perfil = '';

    notifyListeners();
  }

  // ============================================================
  // ATUALIZAR PACIENTE
  // ============================================================

  Future<void> atualizarPaciente({
    required String dataNascimento,
    required String sexo,
    required String estadoCivil,
    required String endereco,
    required String telefone,
    required String tipoSanguineo,
    required String condicaoSaude,
    required String alergias,
    required String dispositivos,
    required String observacoes,
    required String cuidadorNome,
    required String cuidadorTurno,
    required String cuidadorCarga,

    // Documentos são opcionais.
    // Se não forem enviados, os valores atuais são preservados.
    String? cpf,
    String? rgCin,
    String? orgaoExpedidor,
    String? dataEmissaoDocumento,
    String? cartaoSus,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'Usuário não autenticado.',
      );
    }

    // ----------------------------------------------------------
    // CALCULAR IDADE
    // ----------------------------------------------------------

    int idade = 0;

    if (dataNascimento.isNotEmpty) {
      try {
        final partes =
            dataNascimento.split('/');

        if (partes.length == 3) {
          final nascimento = DateTime(
            int.parse(partes[2]),
            int.parse(partes[1]),
            int.parse(partes[0]),
          );

          final hoje = DateTime.now();

          idade =
              hoje.year - nascimento.year;

          if (hoje.month < nascimento.month ||
              (hoje.month ==
                      nascimento.month &&
                  hoje.day <
                      nascimento.day)) {
            idade--;
          }
        }
      } catch (_) {
        idade = _paciente.idade;
      }
    }

    // ----------------------------------------------------------
    // PRESERVAR DOCUMENTOS EXISTENTES
    // ----------------------------------------------------------

    final cpfAtual =
        cpf ?? _paciente.cpf;

    final rgCinAtual =
        rgCin ?? _paciente.rgCin;

    final orgaoExpedidorAtual =
        orgaoExpedidor ??
            _paciente.orgaoExpedidor;

    final dataEmissaoAtual =
        dataEmissaoDocumento ??
            _paciente.dataEmissaoDocumento;

    final cartaoSusAtual =
        cartaoSus ?? _paciente.cartaoSus;

    // ----------------------------------------------------------
    // ATUALIZAR FIRESTORE
    // ----------------------------------------------------------

    final dadosAtualizados = {
      'dataNascimento': dataNascimento,
      'idade': idade,
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
      'cpf': cpfAtual,
      'rgCin': rgCinAtual,
      'orgaoExpedidor': orgaoExpedidorAtual,
      'dataEmissaoDocumento':
          dataEmissaoAtual,
      'cartaoSus': cartaoSusAtual,
    };

    await _firestore
        .collection('pacientes')
        .doc(user.uid)
        .set(
      dadosAtualizados,
      SetOptions(merge: true),
    );

    // ----------------------------------------------------------
    // ATUALIZAR ESTADO LOCAL
    // ----------------------------------------------------------

    _paciente = Paciente(
      nome: _paciente.nome,
      idade: idade,
      id: _paciente.id,
      dataNascimento: dataNascimento,
      sexo: sexo,
      estadoCivil: estadoCivil,
      endereco: endereco,
      telefone: telefone,
      tipoSanguineo: tipoSanguineo,
      condicaoSaude: condicaoSaude,
      alergias: alergias,
      dispositivos: dispositivos,
      observacoes: observacoes,
      cuidadorNome: cuidadorNome,
      cuidadorTurno: cuidadorTurno,
      cuidadorCarga: cuidadorCarga,

      // Documentos preservados
      cpf: cpfAtual,
      rgCin: rgCinAtual,
      orgaoExpedidor:
          orgaoExpedidorAtual,
      dataEmissaoDocumento:
          dataEmissaoAtual,
      cartaoSus: cartaoSusAtual,
    );

    // ----------------------------------------------------------
    // REGISTRAR NO HISTÓRICO
    // ----------------------------------------------------------

    await _registrarHistorico(
      tipo: 'perfil',
      titulo: 'Perfil atualizado',
      descricao:
          'Os dados do perfil foram atualizados.',
    );

    notifyListeners();
  }

  // ============================================================
  // ATUALIZAR DOCUMENTOS
  // ============================================================

  Future<void> atualizarDocumentos({
    required String cpf,
    required String rgCin,
    required String orgaoExpedidor,
    required String dataEmissaoDocumento,
    required String cartaoSus,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'Usuário não autenticado.',
      );
    }

    // ----------------------------------------------------------
    // LIMPAR ESPAÇOS
    // ----------------------------------------------------------

    final cpfAtual = cpf.trim();
    final rgCinAtual = rgCin.trim();
    final orgaoAtual =
        orgaoExpedidor.trim();
    final dataEmissaoAtual =
        dataEmissaoDocumento.trim();
    final cartaoSusAtual =
        cartaoSus.trim();

    // ----------------------------------------------------------
    // ATUALIZAR FIRESTORE
    // ----------------------------------------------------------

    await _firestore
        .collection('pacientes')
        .doc(user.uid)
        .set(
      {
        'cpf': cpfAtual,
        'rgCin': rgCinAtual,
        'orgaoExpedidor': orgaoAtual,
        'dataEmissaoDocumento':
            dataEmissaoAtual,
        'cartaoSus': cartaoSusAtual,
      },
      SetOptions(merge: true),
    );

    // ----------------------------------------------------------
    // ATUALIZAR ESTADO LOCAL
    // ----------------------------------------------------------

    _paciente = Paciente(
      nome: _paciente.nome,
      idade: _paciente.idade,
      id: _paciente.id,
      dataNascimento:
          _paciente.dataNascimento,
      sexo: _paciente.sexo,
      estadoCivil: _paciente.estadoCivil,
      endereco: _paciente.endereco,
      telefone: _paciente.telefone,
      tipoSanguineo:
          _paciente.tipoSanguineo,
      condicaoSaude:
          _paciente.condicaoSaude,
      alergias: _paciente.alergias,
      dispositivos:
          _paciente.dispositivos,
      observacoes:
          _paciente.observacoes,
      cuidadorNome:
          _paciente.cuidadorNome,
      cuidadorTurno:
          _paciente.cuidadorTurno,
      cuidadorCarga:
          _paciente.cuidadorCarga,

      // Documentos
      cpf: cpfAtual,
      rgCin: rgCinAtual,
      orgaoExpedidor: orgaoAtual,
      dataEmissaoDocumento:
          dataEmissaoAtual,
      cartaoSus: cartaoSusAtual,
    );

    // ----------------------------------------------------------
    // REGISTRAR NO HISTÓRICO
    // ----------------------------------------------------------

    await _registrarHistorico(
      tipo: 'documentos',
      titulo: 'Documentos atualizados',
      descricao:
          'Os dados documentais foram atualizados.',
    );

    notifyListeners();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _auth.signOut();

    _logado = false;
    _perfil = '';

    _paciente = const Paciente(
      nome: '',
      idade: 0,
      id: '',
      dataNascimento: '',
      sexo: '',
      estadoCivil: '',
      endereco: '',
      telefone: '',
      tipoSanguineo: '',
      condicaoSaude: '',
      alergias: '',
      dispositivos: '',
      observacoes: '',
      cuidadorNome: '',
      cuidadorTurno: '',
      cuidadorCarga: '',
      cpf: '',
      rgCin: '',
      orgaoExpedidor: '',
      dataEmissaoDocumento: '',
      cartaoSus: '',
    );

    _remedios = [];
    _compromissos = [];
    _historico = [];

    _msgs['familia'] = [];
    _msgs['cuidador'] = [];
    _msgs['milo'] = [];

    notifyListeners();
  }

  // ============================================================
  // MENSAGENS DE ERRO DO FIREBASE
  // ============================================================

  String _mensagemErroFirebase(
    FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'invalid-credential':
        return 'Email ou senha incorretos.';

      case 'user-not-found':
        return 'Usuário não encontrado.';

      case 'wrong-password':
        return 'Senha incorreta.';

      case 'invalid-email':
        return 'Digite um email válido.';

      case 'user-disabled':
        return 'Esta conta está desativada.';

      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';

      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';

      default:
        return 'Não foi possível fazer login. Tente novamente.';
    }
  }
}