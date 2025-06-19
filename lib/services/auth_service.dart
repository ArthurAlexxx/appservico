import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    // Simulação de login
    await Future.delayed(const Duration(seconds: 1));
    _user = User(
      id: '1',
      name: 'Usuário Teste',
      email: email,
      phone: '(11) 99999-9999',
    );
    notifyListeners();
  }

  Future<void> registerWithEmailAndPassword(
    String name, String email, String password, String phone) async {
    // Simulação de registro
    await Future.delayed(const Duration(seconds: 1));
    _user = User(
      id: '2',
      name: name,
      email: email,
      phone: phone,
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    _user = null;
    notifyListeners();
  }
}