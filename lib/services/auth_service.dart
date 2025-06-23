import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  UserModel? get user => _user;

  // Login
  Future<void> signInWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _firestore.collection('users').doc(result.user!.uid).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception('Usuário não encontrado no banco de dados.');
    }

    final data = doc.data()!;
    data['id'] = result.user!.uid;

    _user = UserModel.fromMap(data);
    notifyListeners();
  } on FirebaseAuthException catch (e) {
    throw _handleAuthError(e);
  } catch (e) {
    throw 'Erro inesperado ao fazer login: $e';
  }
}

  // Registro
  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = result.user!.uid;

      final newUser = UserModel(
        id: uid,
        name: name,
        email: email,
        phone: phone,
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());

      _user = newUser;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  // Tratamento de erros
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este email já está em uso.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      default:
        return 'Erro: ${e.message}';
    }
  }
}
