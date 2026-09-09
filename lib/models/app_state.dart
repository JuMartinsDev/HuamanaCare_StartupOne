import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class AppState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _pacienteListener;

  // ============================================================
  // AUTH / PERFIL
  // ============================================================

  bool _logado = false;
  String _perfil = '';

  bool get logado => _logado;
  String get perfil => _perfil;

  String? _pacienteVinculadoId;
  String? _codigoVinculo;
  String? _nomeConta;

  String? _cuidadorUid;
  String? _cuidadorNome;

  String? get pacienteVinculadoId => _pacienteVinculadoId;

  String? get codigoVinculo => _codigoVinculo;

  String? get usuarioAtualId => _auth.currentUser?.uid;

  String? get usuarioAtualEmail => _auth.currentUser?.email;

  String get usuarioAtualNome {
    if (_nomeConta != null && _nomeConta!.trim().isNotEmpty) {
      return _nomeConta!;
    }

    return _auth.currentUser?.displayName ?? '';
  }

  String? get cuidadorUid => _cuidadorUid;

  String? get cuidadorNome {
    if (_cuidadorNome != null && _cuidadorNome!.trim().isNotEmpty) {
      return _cuidadorNome;
    }

    if (_paciente.cuidadorNome.trim().isNotEmpty) {
      return _paciente.cuidadorNome;
    }

    return null;
  }

  bool get temCuidador {
    return cuidadorUid != null && cuidadorUid!.isNotEmpty;
  }

  String? get pacienteIdDados {
    if (_perfil == 'paciente') {
      return _auth.currentUser?.uid;
    }

    if (_perfil == 'familiar' || _perfil == 'cuidador') {
      return _pacienteVinculadoId;
    }

    return null;
  }

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
  // SOS
  // ============================================================

  bool _sosAtivado = false;

  bool get sosAtivado => _sosAtivado;

  // ============================================================
  // INICIALIZAÇÃO
  // ============================================================

  Future<void> inicializar() async {
    final user = _auth.currentUser;

    if (user == null) {
      _limparEstadoLocal();
      return;
    }

    try {
      await _carregarDadosFirestore();
    } catch (e) {
      debugPrint(
        'Erro ao inicializar AppState: $e',
      );

      _limparEstadoLocal();
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
          'Não foi possível entrar na conta.',
        );
      }

      _logado = true;

      await _carregarDadosFirestore();

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _mensagemErroFirebase(e),
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Não foi possível realizar o login.',
      );
    }
  }

  // ============================================================
  // CARREGAR DADOS DO FIRESTORE
  // ============================================================

  Future<void> _carregarDadosFirestore() async {
    final user = _auth.currentUser;

    if (user == null) {
      _limparEstadoLocal();
      return;
    }

    _logado = true;

    final minhaContaRef = _firestore
        .collection('pacientes')
        .doc(user.uid);

    var minhaContaSnap =
        await minhaContaRef.get();

    // Cria documento base caso ainda não exista.
    if (!minhaContaSnap.exists) {
      await minhaContaRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'nome': user.displayName ?? '',
        'perfil': '',
        'criadoEm': FieldValue.serverTimestamp(),
      });
    }

    minhaContaSnap =
        await minhaContaRef.get();

    final dados =
        minhaContaSnap.data() ??
            <String, dynamic>{};

    _perfil =
        dados['perfil']?.toString() ?? '';

    _nomeConta =
        dados['nome']?.toString() ?? '';

    _pacienteVinculadoId =
        dados['pacienteVinculadoId']?.toString();

    _codigoVinculo =
        dados['codigoVinculo']?.toString();

    // ==========================================================
    // PACIENTE SEM CÓDIGO
    // ==========================================================

    if (_perfil == 'paciente' &&
        (_codigoVinculo == null ||
            _codigoVinculo!.isEmpty)) {
      final codigo =
          _gerarCodigoVinculo();

      _codigoVinculo = codigo;

      await minhaContaRef.set(
        {
          'codigoVinculo': codigo,
        },
        SetOptions(merge: true),
      );
    }

    // ==========================================================
    // PACIENTE
    // ==========================================================

    if (_perfil == 'paciente') {
      await _carregarDadosPacientePorId(
        user.uid,
      );

      _atualizarDadosCuidadorDoPaciente();

      await _carregarMensagensFirestore();

      // IMPORTANTE:
      // Mantém o paciente sincronizado em tempo real.
      _iniciarListenerPaciente(user.uid);
    }

    // ==========================================================
    // FAMILIAR / CUIDADOR
    // ==========================================================

    if (_perfil == 'familiar' ||
        _perfil == 'cuidador') {
      final pacienteId =
          _pacienteVinculadoId;

      if (pacienteId != null &&
          pacienteId.isNotEmpty) {
        await _carregarDadosPacientePorId(
          pacienteId,
        );

        _atualizarDadosCuidadorDoPaciente();

        await _carregarMensagensFirestore();

        // Também acompanha alterações do paciente.
        _iniciarListenerPaciente(pacienteId);
      } else {
        _limparDadosPaciente();

        await _carregarMensagensFirestore();
      }
    }

    notifyListeners();
  }

  // ============================================================
  // LISTENER EM TEMPO REAL DO PACIENTE
  // ============================================================

  void _iniciarListenerPaciente(
    String pacienteId,
  ) {
    _pacienteListener?.cancel();

    final pacienteRef = _firestore
        .collection('pacientes')
        .doc(pacienteId);

    _pacienteListener =
        pacienteRef.snapshots().listen(
      (snapshot) async {
        if (!snapshot.exists) {
          return;
        }

        final dados =
            snapshot.data() ??
                <String, dynamic>{};

        try {
          final idadeCalculada =
              _calcularIdade(
            dados['dataNascimento']
                    ?.toString() ??
                '',
          );

          final mapaPaciente =
              <String, dynamic>{
            ...dados,
            'id': pacienteId,
          };

          if (idadeCalculada != null) {
            mapaPaciente['idade'] =
                idadeCalculada;
          }

          _paciente =
              Paciente.fromMap(
            mapaPaciente,
          );

          // ======================================================
          // AQUI ESTÁ A CORREÇÃO DO CUIDADOR
          // ======================================================

          _cuidadorUid =
              dados['cuidadorUid']?.toString();

          _cuidadorNome =
              dados['cuidadorNome']?.toString();

          // Se não existir cuidador, limpa o estado.
          if (_cuidadorUid == null ||
              _cuidadorUid!.isEmpty) {
            _cuidadorUid = null;
          }

          if (_cuidadorNome == null ||
              _cuidadorNome!.trim().isEmpty) {
            _cuidadorNome = null;
          }

          notifyListeners();
        } catch (e) {
          debugPrint(
            'Erro no listener do paciente: $e',
          );
        }
      },
    );
  }

  // ============================================================
  // CARREGAR DADOS DE UM PACIENTE
  // ============================================================

  Future<void> _carregarDadosPacientePorId(
    String pacienteId,
  ) async {
    final pacienteRef = _firestore
        .collection('pacientes')
        .doc(pacienteId);

    final pacienteSnap =
        await pacienteRef.get();

    if (!pacienteSnap.exists) {
      debugPrint(
        'Paciente não encontrado: $pacienteId',
      );
      return;
    }

    final dados =
        pacienteSnap.data() ??
            <String, dynamic>{};

    try {
      final idadeCalculada =
          _calcularIdade(
        dados['dataNascimento']
                ?.toString() ??
            '',
      );

      if (idadeCalculada != null &&
          dados['idade'] != idadeCalculada) {
        await pacienteRef.set(
          {
            'idade': idadeCalculada,
          },
          SetOptions(merge: true),
        );

        dados['idade'] =
            idadeCalculada;
      }

      _paciente =
          Paciente.fromMap({
        ...dados,
        'id': pacienteId,
      });

      // ==========================================================
      // CARREGA CUIDADOR DIRETAMENTE DO FIRESTORE
      // ==========================================================

      _cuidadorUid =
          dados['cuidadorUid']?.toString();

      _cuidadorNome =
          dados['cuidadorNome']?.toString();

      // Compatibilidade com dados antigos.
      if ((_cuidadorNome == null ||
              _cuidadorNome!.isEmpty) &&
          _paciente.cuidadorNome.isNotEmpty) {
        _cuidadorNome =
            _paciente.cuidadorNome;
      }

      if (_cuidadorUid == null ||
          _cuidadorUid!.isEmpty) {
        _cuidadorUid = null;
      }

      if (_cuidadorNome == null ||
          _cuidadorNome!.trim().isEmpty) {
        _cuidadorNome = null;
      }
    } catch (e) {
      debugPrint(
        'Erro ao converter paciente: $e',
      );
    }

    await _carregarRemedios(
      pacienteId,
    );

    await _carregarCompromissos(
      pacienteId,
    );

    await _carregarHistorico(
      pacienteId,
    );
  }

  // ============================================================
  // CALCULAR IDADE
  // ============================================================

  int? _calcularIdade(
    String dataNascimento,
  ) {
    if (dataNascimento.trim().isEmpty) {
      return null;
    }

    DateTime? data;

    // Formato ISO:
    // 2000-08-15
    data = DateTime.tryParse(
      dataNascimento.trim(),
    );

    // Formato brasileiro:
    // 15/08/2000
    if (data == null &&
        dataNascimento.contains('/')) {
      final partes =
          dataNascimento.split('/');

      if (partes.length == 3) {
        final dia =
            int.tryParse(partes[0]);

        final mes =
            int.tryParse(partes[1]);

        final ano =
            int.tryParse(partes[2]);

        if (dia != null &&
            mes != null &&
            ano != null) {
          try {
            final candidata =
                DateTime(
              ano,
              mes,
              dia,
            );

            // Evita datas inválidas como
            // 31/02/2000.
            if (candidata.year == ano &&
                candidata.month == mes &&
                candidata.day == dia) {
              data = candidata;
            }
          } catch (_) {
            data = null;
          }
        }
      }
    }

    if (data == null) {
      return null;
    }

    final hoje = DateTime.now();

    int idade =
        hoje.year - data.year;

    final aniversarioAindaNaoChegou =
        hoje.month < data.month ||
        (hoje.month == data.month &&
            hoje.day < data.day);

    if (aniversarioAindaNaoChegou) {
      idade--;
    }

    if (idade < 0) {
      return null;
    }

    return idade;
  }

  // ============================================================
  // ATUALIZAR DADOS DO CUIDADOR NO ESTADO
  // ============================================================

  void _atualizarDadosCuidadorDoPaciente() {
    if (_paciente.cuidadorNome.isNotEmpty &&
        (_cuidadorNome == null ||
            _cuidadorNome!.isEmpty)) {
      _cuidadorNome =
          _paciente.cuidadorNome;
    }
  }

  // ============================================================
  // CÓDIGO DE VÍNCULO
  // ============================================================

  String _gerarCodigoVinculo() {
    const caracteres =
        'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

    final random = Random();

    final codigo = List.generate(
      6,
      (_) => caracteres[
          random.nextInt(
            caracteres.length,
          )
        ],
    ).join();

    return 'HC-$codigo';
  }

  Future<String> gerarCodigoVinculo() async {
    final user =
        _auth.currentUser;

    if (user == null) {
      throw Exception(
        'Usuário não autenticado.',
      );
    }

    final codigo =
        _gerarCodigoVinculo();

    _codigoVinculo = codigo;

    await _firestore
        .collection('pacientes')
        .doc(user.uid)
        .set(
      {
        'codigoVinculo': codigo,
      },
      SetOptions(merge: true),
    );

    notifyListeners();

    return codigo;
  }

  // ============================================================
  // VINCULAR PACIENTE POR CÓDIGO
  // ============================================================

  Future<void> vincularPacientePorCodigo(
    String codigo,
  ) async {
    final user =
        _auth.currentUser;

    if (user == null) {
      throw Exception(
        'Usuário não autenticado.',
      );
    }

    final codigoLimpo =
        codigo.trim().toUpperCase();

    if (codigoLimpo.isEmpty) {
      throw Exception(
        'Digite o código de vínculo.',
      );
    }

    if (_perfil != 'cuidador' &&
        _perfil != 'familiar') {
      throw Exception(
        'Apenas cuidador ou familiar podem realizar um vínculo.',
      );
    }

    final resultado =
        await _firestore
            .collection('pacientes')
            .where(
              'codigoVinculo',
              isEqualTo: codigoLimpo,
            )
            .limit(1)
            .get();

    if (resultado.docs.isEmpty) {
      throw Exception(
        'Nenhum paciente encontrado com esse código.',
      );
    }

    final pacienteDoc =
        resultado.docs.first;

    final pacienteId =
        pacienteDoc.id;

    if (pacienteId == user.uid) {
      throw Exception(
        'Você não pode vincular sua própria conta.',
      );
    }

    final pacienteDados =
        pacienteDoc.data();

    // ==========================================================
    // VÍNCULO DO CUIDADOR
    // ==========================================================

    if (_perfil == 'cuidador') {
      final cuidadorAtualUid =
          pacienteDados['cuidadorUid']
              ?.toString();

      if (cuidadorAtualUid != null &&
          cuidadorAtualUid.isNotEmpty &&
          cuidadorAtualUid != user.uid) {
        throw Exception(
          'Este paciente já possui um cuidador vinculado.',
        );
      }

      final nomeCuidador =
          (_nomeConta != null &&
                  _nomeConta!.trim().isNotEmpty)
              ? _nomeConta!.trim()
              : (user.displayName ?? '').trim();

      // Salva o cuidador no documento do paciente.
      await _firestore
          .collection('pacientes')
          .doc(pacienteId)
          .set(
        {
          'cuidadorUid': user.uid,
          'cuidadorNome': nomeCuidador,
        },
        SetOptions(merge: true),
      );

      // Atualiza imediatamente o estado local.
      _cuidadorUid =
          user.uid;

      _cuidadorNome =
          nomeCuidador.isEmpty
              ? null
              : nomeCuidador;

      // Registra no histórico.
      await _registrarHistoricoPaciente(
        pacienteId: pacienteId,
        tipo: 'cuidador',
        titulo: 'Cuidador vinculado',
        descricao:
            nomeCuidador.isNotEmpty
                ? '$nomeCuidador foi vinculado como cuidador.'
                : 'Um novo cuidador foi vinculado ao paciente.',
      );
    }

    // ==========================================================
    // VÍNCULO DO FAMILIAR / CUIDADOR
    // ==========================================================

    _pacienteVinculadoId =
        pacienteId;

    await _firestore
        .collection('pacientes')
        .doc(user.uid)
        .set(
      {
        'pacienteVinculadoId':
            pacienteId,
      },
      SetOptions(merge: true),
    );

    await _carregarDadosPacientePorId(
      pacienteId,
    );

    await _carregarMensagensFirestore();

    // Mantém acompanhamento em tempo real.
    _iniciarListenerPaciente(
      pacienteId,
    );

    notifyListeners();
  }

  // ============================================================
  // DESVINCULAR CUIDADOR
  // ============================================================

  Future<void> desvincularCuidador() async {
    final pacienteId =
        pacienteIdDados;

    if (pacienteId == null ||
        pacienteId.isEmpty) {
      throw Exception(
        'Nenhum paciente disponível.',
      );
    }

    final pacienteRef =
        _firestore
            .collection('pacientes')
            .doc(pacienteId);

    // Só permite que o próprio cuidador
    // remova o vínculo dele.
    if (_perfil == 'cuidador') {
      final user =
          _auth.currentUser;

      if (user == null) {
        throw Exception(
          'Usuário não autenticado.',
        );
      }

      final pacienteSnap =
          await pacienteRef.get();

      final dados =
          pacienteSnap.data() ??
              <String, dynamic>{};

      final cuidadorAtualUid =
          dados['cuidadorUid']
              ?.toString();

      if (cuidadorAtualUid != null &&
          cuidadorAtualUid.isNotEmpty &&
          cuidadorAtualUid != user.uid) {
        throw Exception(
          'Este cuidador não está vinculado a esta conta.',
        );
      }
    }

    final nomeCuidadorAnterior =
        (_cuidadorNome != null &&
                _cuidadorNome!.trim().isNotEmpty)
            ? _cuidadorNome!.trim()
            : _paciente.cuidadorNome.trim();

    // Remove cuidador do paciente.
    await pacienteRef.set(
      {
        'cuidadorUid':
            FieldValue.delete(),
        'cuidadorNome':
            FieldValue.delete(),
      },
      SetOptions(merge: true),
    );

    // Remove vínculo da conta do cuidador.
    if (_perfil == 'cuidador') {
      final user =
          _auth.currentUser;

      if (user != null) {
        await _firestore
            .collection('pacientes')
            .doc(user.uid)
            .set(
          {
            'pacienteVinculadoId':
                FieldValue.delete(),
          },
          SetOptions(merge: true),
        );
      }

      _pacienteVinculadoId =
          null;
    }

    await _registrarHistoricoPaciente(
      pacienteId: pacienteId,
      tipo: 'cuidador',
      titulo: 'Cuidador desvinculado',
      descricao:
          nomeCuidadorAnterior.isNotEmpty
              ? '$nomeCuidadorAnterior foi desvinculado do paciente.'
              : 'O cuidador foi desvinculado do paciente.',
    );

    // Atualiza imediatamente o estado.
    _cuidadorUid = null;
    _cuidadorNome = null;

    if (_perfil == 'paciente') {
      await _carregarDadosPacientePorId(
        pacienteId,
      );

      _iniciarListenerPaciente(
        pacienteId,
      );
    } else {
      _limparDadosPaciente();
    }

    notifyListeners();
  }

  // ============================================================
  // REMÉDIOS
  // ============================================================

  Future<void> _carregarRemedios(
    String pacienteId,
  ) async {
    final snapshot =
        await _firestore
            .collection('pacientes')
            .doc(pacienteId)
            .collection('remedios')
            .get();

    _remedios = snapshot.docs
        .map(
          (doc) => Remedio.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  Future<void> toggleRemedio(
    String id,
  ) async {
    final pacienteId =
        pacienteIdDados;

    if (pacienteId == null) {
      return;
    }

    final index =
        _remedios.indexWhere(
      (remedio) =>
          remedio.id == id,
    );

    if (index == -1) {
      return;
    }

    final remedio =
        _remedios[index];

    remedio.tomado =
        !remedio.tomado;

    notifyListeners();

    await _firestore
        .collection('pacientes')
        .doc(pacienteId)
        .collection('remedios')
        .doc(id)
        .set(
      remedio.toMap(),
      SetOptions(merge: true),
    );
  }

  Future<void> addRemedio(
    Remedio remedio,
  ) async {
    final pacienteId =
        pacienteIdDados;

    if (pacienteId == null) {
      throw Exception(
        'Nenhum paciente vinculado.',
      );
    }

    final colecao =
        _firestore
            .collection('pacientes')
            .doc(pacienteId)
            .collection('remedios');

    late DocumentReference<
        Map<String, dynamic>> docRef;

    if (remedio.id.isEmpty) {
      docRef = colecao.doc();

      await docRef.set(
        remedio.toMap(),
      );
    } else {
      docRef =
          colecao.doc(remedio.id);

      await docRef.set(
        remedio.toMap(),
      );
    }

    final remedioSalvo =
        Remedio(
      id: docRef.id,
      nome: remedio.nome,
      tipo: remedio.tipo,
      horario: remedio.horario,
      tomado: remedio.tomado,
      dataInicio: remedio.dataInicio,
      dataFim: remedio.dataFim,
    );

    _remedios.add(
      remedioSalvo,
    );

    notifyListeners();
  }

  Future<void> updateRemedio(
    Remedio remedio,
  ) async {
    final pacienteId =
        pacienteIdDados;

    if (pacienteId == null) {
      throw Exception(
        'Nenhum paciente vinculado.',
      );
    }

    if (remedio.id.isEmpty) {
      throw Exception(
        'Não foi possível atualizar o remédio sem ID.',
      );
    }

    await _firestore
        .collection('pacientes')
        .doc(pacienteId)
        .collection('remedios')
        .doc(remedio.id)
        .set(
      remedio.toMap(),
      SetOptions(merge: true),
    );

    final index =
        _remedios.indexWhere(
      (item) =>
          item.id == remedio.id,
    );

    if (index != -1) {
      _remedios[index] =
          remedio;
    }

    notifyListeners();
  }

  Future<void> removeRemedio(
    String id,
  ) async {
    final pacienteId =
        pacienteIdDados;

    if (pacienteId == null) {
      return;
    }

    await _firestore
        .collection('pacientes')
        .doc(pacienteId)
        .collection('remedios')
        .doc(id)
        .delete();

    _remedios.removeWhere(
      (remedio) =>
          remedio.id == id,
    );

    notifyListeners();
  }

  // ============================================================
  // COMPROMISSOS
  // ============================================================

  Future<void> _carregarCompromissos(
    String pacienteId,
  ) async {
    final snapshot =
        await _firestore
            .collection('pacientes')
            .doc(pacienteId)
            .collection('compromissos')
            .get();

    _compromissos = snapshot.docs
        .map(
          (doc) => Compromisso.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  Future<void> addCompromisso(
    Compromisso compromisso,
  ) async {
    final pacienteId =
        pacienteIdDados;

    if (pacienteId == null) {
      throw Exception(
        'Nenhum paciente vinculado.',
      );
    }

    final colecao =
        _firestore
            .collection('pacientes')
            .doc(pacienteId)
            .collection('compromissos');

    late DocumentReference<
        Map<String, dynamic>> docRef;

    if (compromisso.id.isEmpty) {
      docRef = colecao.doc();

      await docRef.set(
        compromisso.toMap(),
      );
    } else {
      docRef =
          colecao.doc(compromisso.id);

      await docRef.set(
        compromisso.toMap(),
      );
    }

    final compromissoSalvo =
        Compromisso(
      id: docRef.id,
      titulo: compromisso.titulo,
      horario: compromisso.horario,
      local: compromisso.local,
      dia: compromisso.dia,
      mesAbrev: compromisso.mesAbrev,
      diaAbrev: compromisso.diaAbrev,
      data: compromisso.data,
    );

    _compromissos.add(
      compromissoSalvo,
    );

    notifyListeners();
  }

  Future<void> updateCompromisso(
    Compromisso compromisso,
  ) async {
    final pacienteId =
        pacienteIdDados;

    if (pacienteId == null) {
      throw Exception(
        'Nenhum paciente vinculado.',
      );
    }

    if (compromisso.id.isEmpty) {
      throw Exception(
        'Não foi possível atualizar o compromisso sem ID.',
      );
    }

    await _firestore
        .collection('pacientes')
        .doc(pacienteId)
        .collection('compromissos')
        .doc(compromisso.id)
        .set(
      compromisso.toMap(),
      SetOptions(merge: true),
    );

    final index =
        _compromissos.indexWhere(
      (item) =>
          item.id == compromisso.id,
    );

    if (index != -1) {
      _compromissos[index] =
          compromisso;
    }

    notifyListeners();
  }

  Future<void> removeCompromisso(
    String id,
  ) async {
    final pacienteId =
        pacienteIdDados;

    if (pacienteId == null) {
      return;
    }

    await _firestore
        .collection('pacientes')
        .doc(pacienteId)
        .collection('compromissos')
        .doc(id)
        .delete();

    _compromissos.removeWhere(
      (compromisso) =>
          compromisso.id == id,
    );

    notifyListeners();
  }

  // ============================================================
  // HISTÓRICO
  // ============================================================

  Future<void> _carregarHistorico(
    String pacienteId,
  ) async {
    final snapshot =
        await _firestore
            .collection('pacientes')
            .doc(pacienteId)
            .collection('historico')
            .get();

    _historico = snapshot.docs
        .map(
          (doc) => Historico.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();

    _historico.sort(
      (a, b) =>
          b.data.compareTo(a.data),
    );
  }

  Future<void> addHistorico(
    Historico item,
  ) async {
    final pacienteId =
        pacienteIdDados;

    if (pacienteId == null) {
      throw Exception(
        'Nenhum paciente vinculado.',
      );
    }

    await _registrarHistoricoPaciente(
      pacienteId: pacienteId,
      tipo: item.tipo,
      titulo: item.titulo,
      descricao: item.descricao,
      data: item.data,
    );

    notifyListeners();
  }

  Future<void> _registrarHistoricoPaciente({
    required String pacienteId,
    required String tipo,
    required String titulo,
    required String descricao,
    DateTime? data,
  }) async {
    final colecao =
        _firestore
            .collection('pacientes')
            .doc(pacienteId)
            .collection('historico');

    final historico =
        Historico(
      tipo: tipo,
      titulo: titulo,
      descricao: descricao,
      data: data ?? DateTime.now(),
    );

    final docRef =
        colecao.doc();

    await docRef.set(
      historico.toMap(),
    );

    // Atualiza o estado local somente
    // se estivermos vendo o mesmo paciente.
    if (pacienteId ==
        pacienteIdDados) {
      final historicoSalvo =
          Historico(
        id: docRef.id,
        tipo: historico.tipo,
        titulo: historico.titulo,
        descricao: historico.descricao,
        data: historico.data,
      );

      _historico.insert(
        0,
        historicoSalvo,
      );
    }
  }

  // ============================================================
  // MENSAGENS
  // ============================================================

  Future<void>
      _carregarMensagensFirestore() async {
    final pacienteId =
        pacienteIdDados;

    if (pacienteId == null ||
        pacienteId.isEmpty) {
      _msgs['familia'] = [];
      _msgs['cuidador'] = [];
      _msgs['milo'] = [];
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
              .doc(pacienteId)
              .collection('canais')
              .doc(canal)
              .collection('mensagens')
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
    final pacienteId =
        pacienteIdDados;

    if (pacienteId == null) {
      throw Exception(
        'Nenhum paciente vinculado.',
      );
    }

    const canaisValidos = [
      'familia',
      'cuidador',
      'milo',
    ];

    if (!canaisValidos.contains(
      canal,
    )) {
      throw Exception(
        'Canal de mensagem inválido.',
      );
    }

    final colecao =
        _firestore
            .collection('pacientes')
            .doc(pacienteId)
            .collection('canais')
            .doc(canal)
            .collection('mensagens');

    final docRef =
        mensagem.id.isEmpty
            ? colecao.doc()
            : colecao.doc(mensagem.id);

    await docRef.set(
      mensagem.toMap(),
    );

    final mensagemSalva =
        Mensagem(
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
      mensagemSalva,
    );

    notifyListeners();
  }

  // ============================================================
  // SOS
  // ============================================================

  Future<void> acionarSos() async {
    _sosAtivado = true;

    notifyListeners();
  }

  Future<void> desativarSos() async {
    _sosAtivado = false;

    notifyListeners();
  }

  // ============================================================
  // DEFINIR PERFIL
  // ============================================================

  Future<void> definirPerfil(
    String perfilSelecionado,
  ) async {
    final user =
        _auth.currentUser;

    if (user == null) {
      throw Exception(
        'Usuário não autenticado.',
      );
    }

    const perfisValidos = [
      'paciente',
      'familiar',
      'cuidador',
    ];

    if (!perfisValidos.contains(
      perfilSelecionado,
    )) {
      throw Exception(
        'Perfil inválido.',
      );
    }

    final perfilAnterior =
        _perfil;

    _perfil =
        perfilSelecionado;

    _logado = true;

    final dados =
        <String, dynamic>{
      'perfil': perfilSelecionado,
    };

    // ==========================================================
    // PERFIL PACIENTE
    // ==========================================================

    if (perfilSelecionado ==
        'paciente') {
      final codigo =
          _codigoVinculo ??
              _gerarCodigoVinculo();

      _codigoVinculo =
          codigo;

      dados['codigoVinculo'] =
          codigo;

      _pacienteVinculadoId =
          null;

      dados['pacienteVinculadoId'] =
          FieldValue.delete();
    }

    // ==========================================================
    // PERFIL FAMILIAR / CUIDADOR
    // ==========================================================

    if (perfilSelecionado ==
            'familiar' ||
        perfilSelecionado ==
            'cuidador') {
      final mesmoPerfil =
          perfilAnterior ==
              perfilSelecionado;

      final possuiVinculo =
          _pacienteVinculadoId !=
                  null &&
              _pacienteVinculadoId!
                  .isNotEmpty;

      if (mesmoPerfil &&
          possuiVinculo) {
        dados[
                'pacienteVinculadoId'] =
            _pacienteVinculadoId;
      } else {
        _pacienteVinculadoId =
            null;

        dados[
                'pacienteVinculadoId'] =
            FieldValue.delete();
      }

      _codigoVinculo =
          null;

      dados['codigoVinculo'] =
          FieldValue.delete();
    }

    // ==========================================================
    // SALVAR PERFIL
    // ==========================================================

    await _firestore
        .collection('pacientes')
        .doc(user.uid)
        .set(
      dados,
      SetOptions(merge: true),
    );

    // ==========================================================
    // RECARREGAR DADOS
    // ==========================================================

    if (perfilSelecionado ==
        'paciente') {
      await _carregarDadosPacientePorId(
        user.uid,
      );

      _atualizarDadosCuidadorDoPaciente();

      await _carregarMensagensFirestore();

      _iniciarListenerPaciente(
        user.uid,
      );
    }

    if (perfilSelecionado ==
            'familiar' ||
        perfilSelecionado ==
            'cuidador') {
      final pacienteId =
          _pacienteVinculadoId;

      if (pacienteId != null &&
          pacienteId.isNotEmpty) {
        await _carregarDadosPacientePorId(
          pacienteId,
        );

        _atualizarDadosCuidadorDoPaciente();

        await _carregarMensagensFirestore();

        _iniciarListenerPaciente(
          pacienteId,
        );
      } else {
        _limparDadosPaciente();

        await _carregarMensagensFirestore();
      }
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
    final user =
        _auth.currentUser;

    if (user == null) {
      return;
    }

    _logado = true;

    _nomeConta = nome;

    await _firestore
        .collection('pacientes')
        .doc(user.uid)
        .set(
      {
        'uid': user.uid,
        'nome': nome,
        'email': email,
        'perfil': '',
        'criadoEm':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    _perfil = '';

    notifyListeners();
  }

  // ============================================================
  // ATUALIZAR DADOS DO PACIENTE
  // ============================================================

  Future<void> atualizarPaciente({
    String? dataNascimento,
    String? sexo,
    String? estadoCivil,
    String? endereco,
    String? telefone,
    String? tipoSanguineo,
    String? condicaoSaude,
    String? alergias,
    String? dispositivos,
    String? observacoes,
    String? cuidadorNome,
    String? cuidadorTurno,
    String? cuidadorCarga,
  }) async {
    final pacienteId =
        pacienteIdDados;

    if (pacienteId == null) {
      throw Exception(
        'Nenhum paciente disponível.',
      );
    }

    // Guarda o paciente ANTERIOR antes
    // de modificar o estado.
    final pacienteAnterior =
        _paciente;

    final novaDataNascimento =
        dataNascimento ??
            pacienteAnterior
                .dataNascimento;

    final idadeCalculada =
        _calcularIdade(
      novaDataNascimento,
    );

    final pacienteAtualizado =
        Paciente(
      nome: pacienteAnterior.nome,
      idade: idadeCalculada ??
          pacienteAnterior.idade,
      id: pacienteAnterior.id,
      dataNascimento:
          novaDataNascimento,
      sexo: sexo ??
          pacienteAnterior.sexo,
      estadoCivil:
          estadoCivil ??
              pacienteAnterior.estadoCivil,
      endereco:
          endereco ??
              pacienteAnterior.endereco,
      telefone:
          telefone ??
              pacienteAnterior.telefone,
      tipoSanguineo:
          tipoSanguineo ??
              pacienteAnterior.tipoSanguineo,
      condicaoSaude:
          condicaoSaude ??
              pacienteAnterior.condicaoSaude,
      alergias:
          alergias ??
              pacienteAnterior.alergias,
      dispositivos:
          dispositivos ??
              pacienteAnterior.dispositivos,
      observacoes:
          observacoes ??
              pacienteAnterior.observacoes,
      cuidadorNome:
          cuidadorNome ??
              pacienteAnterior.cuidadorNome,
      cuidadorTurno:
          cuidadorTurno ??
              pacienteAnterior.cuidadorTurno,
      cuidadorCarga:
          cuidadorCarga ??
              pacienteAnterior.cuidadorCarga,
      cpf: pacienteAnterior.cpf,
      rgCin: pacienteAnterior.rgCin,
      orgaoExpedidor:
          pacienteAnterior.orgaoExpedidor,
      dataEmissaoDocumento:
          pacienteAnterior
              .dataEmissaoDocumento,
      cartaoSus:
          pacienteAnterior.cartaoSus,
    );

    await _firestore
        .collection('pacientes')
        .doc(pacienteId)
        .set(
      pacienteAtualizado.toMap(),
      SetOptions(merge: true),
    );

    // Atualiza estado local.
    _paciente =
        pacienteAtualizado;

    if (cuidadorNome != null) {
      _cuidadorNome =
          cuidadorNome.trim().isEmpty
              ? null
              : cuidadorNome.trim();
    }

    // ==========================================================
    // HISTÓRICO DO PERFIL
    // ==========================================================

    final alteracoes =
        <String>[];

    if (dataNascimento != null &&
        dataNascimento !=
            pacienteAnterior
                .dataNascimento) {
      alteracoes.add(
        'data de nascimento',
      );
    }

    if (sexo != null &&
        sexo !=
            pacienteAnterior.sexo) {
      alteracoes.add(
        'sexo',
      );
    }

    if (estadoCivil != null &&
        estadoCivil !=
            pacienteAnterior.estadoCivil) {
      alteracoes.add(
        'estado civil',
      );
    }

    if (endereco != null &&
        endereco !=
            pacienteAnterior.endereco) {
      alteracoes.add(
        'endereço',
      );
    }

    if (telefone != null &&
        telefone !=
            pacienteAnterior.telefone) {
      alteracoes.add(
        'telefone',
      );
    }

    if (tipoSanguineo != null &&
        tipoSanguineo !=
            pacienteAnterior.tipoSanguineo) {
      alteracoes.add(
        'tipo sanguíneo',
      );
    }

    if (condicaoSaude != null &&
        condicaoSaude !=
            pacienteAnterior
                .condicaoSaude) {
      alteracoes.add(
        'condição de saúde',
      );
    }

    if (alergias != null &&
        alergias !=
            pacienteAnterior.alergias) {
      alteracoes.add(
        'alergias',
      );
    }

    if (dispositivos != null &&
        dispositivos !=
            pacienteAnterior
                .dispositivos) {
      alteracoes.add(
        'dispositivos',
      );
    }

    if (observacoes != null &&
        observacoes !=
            pacienteAnterior
                .observacoes) {
      alteracoes.add(
        'observações',
      );
    }

    if (cuidadorNome != null &&
        cuidadorNome !=
            pacienteAnterior
                .cuidadorNome) {
      alteracoes.add(
        'dados do cuidador',
      );
    }

    if (cuidadorTurno != null &&
        cuidadorTurno !=
            pacienteAnterior
                .cuidadorTurno) {
      alteracoes.add(
        'turno do cuidador',
      );
    }

    if (cuidadorCarga != null &&
        cuidadorCarga !=
            pacienteAnterior
                .cuidadorCarga) {
      alteracoes.add(
        'carga horária do cuidador',
      );
    }

    if (idadeCalculada != null &&
        idadeCalculada !=
            pacienteAnterior.idade) {
      alteracoes.add(
        'idade',
      );
    }

    if (alteracoes.isNotEmpty) {
      await _registrarHistoricoPaciente(
        pacienteId: pacienteId,
        tipo: 'perfil',
        titulo: 'Perfil atualizado',
        descricao:
            'Foram atualizados: ${alteracoes.join(', ')}.',
      );
    }

    notifyListeners();
  }

  // ============================================================
  // ATUALIZAR DOCUMENTOS
  // ============================================================

  Future<void> atualizarDocumentos({
    String? cpf,
    String? rgCin,
    String? orgaoExpedidor,
    String? dataEmissaoDocumento,
    String? cartaoSus,
  }) async {
    final pacienteId =
        pacienteIdDados;

    if (pacienteId == null) {
      throw Exception(
        'Nenhum paciente disponível.',
      );
    }

    final pacienteAnterior =
        _paciente;

    final documentos =
        <String, dynamic>{};

    final alteracoes =
        <String>[];

    if (cpf != null &&
        cpf != pacienteAnterior.cpf) {
      documentos['cpf'] =
          cpf;

      alteracoes.add(
        'CPF',
      );
    }

    if (rgCin != null &&
        rgCin != pacienteAnterior.rgCin) {
      documentos['rgCin'] =
          rgCin;

      alteracoes.add(
        'RG/CIN',
      );
    }

    if (orgaoExpedidor != null &&
        orgaoExpedidor !=
            pacienteAnterior
                .orgaoExpedidor) {
      documentos[
              'orgaoExpedidor'] =
          orgaoExpedidor;

      alteracoes.add(
        'órgão expedidor',
      );
    }

    if (dataEmissaoDocumento !=
            null &&
        dataEmissaoDocumento !=
            pacienteAnterior
                .dataEmissaoDocumento) {
      documentos[
              'dataEmissaoDocumento'] =
          dataEmissaoDocumento;

      alteracoes.add(
        'data de emissão',
      );
    }

    if (cartaoSus != null &&
        cartaoSus !=
            pacienteAnterior.cartaoSus) {
      documentos['cartaoSus'] =
          cartaoSus;

      alteracoes.add(
        'Cartão SUS',
      );
    }

    if (documentos.isEmpty) {
      return;
    }

    await _firestore
        .collection('pacientes')
        .doc(pacienteId)
        .set(
      documentos,
      SetOptions(merge: true),
    );

    _paciente =
        Paciente(
      nome: pacienteAnterior.nome,
      idade: pacienteAnterior.idade,
      id: pacienteAnterior.id,
      dataNascimento:
          pacienteAnterior.dataNascimento,
      sexo: pacienteAnterior.sexo,
      estadoCivil:
          pacienteAnterior.estadoCivil,
      endereco:
          pacienteAnterior.endereco,
      telefone:
          pacienteAnterior.telefone,
      tipoSanguineo:
          pacienteAnterior.tipoSanguineo,
      condicaoSaude:
          pacienteAnterior.condicaoSaude,
      alergias:
          pacienteAnterior.alergias,
      dispositivos:
          pacienteAnterior.dispositivos,
      observacoes:
          pacienteAnterior.observacoes,
      cuidadorNome:
          pacienteAnterior.cuidadorNome,
      cuidadorTurno:
          pacienteAnterior.cuidadorTurno,
      cuidadorCarga:
          pacienteAnterior.cuidadorCarga,
      cpf: cpf ??
          pacienteAnterior.cpf,
      rgCin: rgCin ??
          pacienteAnterior.rgCin,
      orgaoExpedidor:
          orgaoExpedidor ??
              pacienteAnterior
                  .orgaoExpedidor,
      dataEmissaoDocumento:
          dataEmissaoDocumento ??
              pacienteAnterior
                  .dataEmissaoDocumento,
      cartaoSus:
          cartaoSus ??
              pacienteAnterior.cartaoSus,
    );

    if (alteracoes.isNotEmpty) {
      await _registrarHistoricoPaciente(
        pacienteId: pacienteId,
        tipo: 'documento',
        titulo: 'Documentos atualizados',
        descricao:
            'Foram atualizados: ${alteracoes.join(', ')}.',
      );
    }

    notifyListeners();
  }

  // ============================================================
  // LIMPAR DADOS DO PACIENTE
  // ============================================================

  void _limparDadosPaciente() {
    _paciente =
        const Paciente(
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

    _cuidadorUid = null;
    _cuidadorNome = null;

    _remedios = [];
    _compromissos = [];
    _historico = [];

    _msgs['familia'] = [];
    _msgs['cuidador'] = [];
    _msgs['milo'] = [];
  }

  // ============================================================
  // LIMPAR ESTADO LOCAL
  // ============================================================

  void _limparEstadoLocal() {
    _pacienteListener?.cancel();
    _pacienteListener = null;

    _logado = false;
    _perfil = '';

    _pacienteVinculadoId = null;
    _codigoVinculo = null;
    _nomeConta = null;

    _cuidadorUid = null;
    _cuidadorNome = null;

    _limparDadosPaciente();

    _sosAtivado = false;

    notifyListeners();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _pacienteListener?.cancel();

    _pacienteListener = null;

    await _auth.signOut();

    _limparEstadoLocal();
  }

  // ============================================================
  // ERROS DO FIREBASE AUTH
  // ============================================================

  String _mensagemErroFirebase(
    FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'invalid-email':
        return 'O email informado é inválido.';

      case 'user-not-found':
        return 'Não encontramos uma conta com esse email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou senha incorretos.';

      case 'user-disabled':
        return 'Esta conta foi desativada.';

      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';

      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';

      case 'email-already-in-use':
        return 'Este email já está cadastrado.';

      case 'weak-password':
        return 'A senha é muito fraca.';

      case 'operation-not-allowed':
        return 'Este método de autenticação não está habilitado.';

      default:
        return 'Não foi possível realizar a operação. Tente novamente.';
    }
  }
}