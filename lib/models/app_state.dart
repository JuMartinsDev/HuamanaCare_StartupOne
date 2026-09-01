import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

class AppState extends ChangeNotifier {
  // ─────────────────────────────────────────────────────────────
  // Firebase Authentication
  // ─────────────────────────────────────────────────────────────

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _logado = false;
  String _perfil = '';

  bool get logado => _logado;
  String get perfil => _perfil;

  String _nomeUsuario = '';

String get nomeUsuario => _nomeUsuario;

Future<void> definirPerfil(String perfil) async {
  final user = _auth.currentUser;

  if (user == null) return;

  await _firestore.collection('usuarios').doc(user.uid).update({
    'perfil': perfil,
  });

  _perfil = perfil;
  _logado = true;

  notifyListeners();
}

void setNomeUsuario(String nome) {
  _nomeUsuario = nome;
  notifyListeners();
}

  // ─────────────────────────────────────────────────────────────
  // Dados do paciente
  // Por enquanto continuam usando MockData.
  // Depois vamos migrar para o Firestore.
  // ─────────────────────────────────────────────────────────────

  final Paciente paciente = MockData.paciente;

  // ─────────────────────────────────────────────────────────────
  // Remédios
  // ─────────────────────────────────────────────────────────────

  late List<Remedio> _remedios = MockData.remedios();

  List<Remedio> get remedios => _remedios;

  void toggleRemedio(String id) {
    final i = _remedios.indexWhere((r) => r.id == id);

    if (i >= 0) {
      _remedios[i].tomado = !_remedios[i].tomado;
      notifyListeners();
    }
  }

  void addRemedio(Remedio r) {
    _remedios.add(r);
    notifyListeners();
  }

  void removeRemedio(String id) {
    _remedios.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // Mensagens
  // Por enquanto continuam em memória.
  // Depois vamos migrar para Firestore.
  // ─────────────────────────────────────────────────────────────

  final Map<String, List<Mensagem>> _msgs = {
    'familia': MockData.mensagensFamilia(),
    'cuidador': MockData.mensagensCuidador(),
    'milo': MockData.mensagensMilo(),
  };

  List<Mensagem> mensagens(String canal) {
    return List.unmodifiable(_msgs[canal] ?? []);
  }

  void addMensagem(String canal, Mensagem msg) {
    _msgs[canal] ??= [];
    _msgs[canal]!.add(msg);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // SOS
  // ─────────────────────────────────────────────────────────────

  bool _sosAtivado = false;

  bool get sosAtivado => _sosAtivado;

  void acionarSos() {
    _sosAtivado = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 5), () {
      _sosAtivado = false;
      notifyListeners();
    });
  }

  // ─────────────────────────────────────────────────────────────
  // LOGIN COM FIREBASE
  // ─────────────────────────────────────────────────────────────

  Future<bool> loginFirebase(
    String email,
    String senha,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );

      _logado = true;

      // Como o login atual é da tela de paciente,
      // mantemos o perfil como paciente por enquanto.
      _perfil = 'paciente';

      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erro Firebase Auth: ${e.code}');

      _logado = false;
      _perfil = '';

      notifyListeners();

      return false;
    } catch (e) {
      debugPrint('Erro inesperado no login: $e');

      _logado = false;
      _perfil = '';

      notifyListeners();

      return false;
    }
  }

  void login(String perfil) {
  _logado = true;
  _perfil = perfil;

  notifyListeners();
}

  // ─────────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _auth.signOut();

    _logado = false;
    _perfil = '';

    notifyListeners();
  }

  Future<void> usuarioCriado({
  required String nome,
  required String email,
}) async {
  final user = _auth.currentUser;

  if (user == null) return;

  await _firestore.collection('usuarios').doc(user.uid).set({
    'nome': nome,
    'email': email,
    'criadoEm': FieldValue.serverTimestamp(),
  });

  _logado = true;
  notifyListeners();
}



  // ─────────────────────────────────────────────────────────────
  // Usuário atualmente autenticado
  // ─────────────────────────────────────────────────────────────

  User? get usuarioAtual => _auth.currentUser;
}

