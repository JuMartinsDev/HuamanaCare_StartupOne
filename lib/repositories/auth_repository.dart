import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authState => _auth.authStateChanges();

  Future<Map<String, dynamic>?> login(
    String email,
    String senha,
  ) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );

    final doc = await _db
        .collection('usuarios')
        .doc(cred.user!.uid)
        .get();

    return doc.data();
  }

  Future<void> registrar({
    required String nome,
    required String email,
    required String senha,
    required String role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );

    await _db.collection('usuarios').doc(cred.user!.uid).set({
      'nome': nome,
      'email': email,
      'role': role,
      'pacienteId': null,
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}