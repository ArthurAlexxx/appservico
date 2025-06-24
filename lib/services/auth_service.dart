import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  UserModel? get user => _user;

  // 🔐 Login
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final doc = await _firestore.collection('users').doc(result.user!.uid).get();

      if (!doc.exists) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Usuário não encontrado no banco.',
        );
      }

      final data = doc.data()!..addAll({'id': result.user!.uid});
      _user = UserModel.fromMap(data);
      notifyListeners();

      return result;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // 📝 Registro
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String phone,
    String type,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = result.user!.uid;

      final newUser = UserModel(
        id: uid,
        name: name,
        email: email,
        phone: phone,
        type: type,
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());

      _user = newUser;
      notifyListeners();

      return result;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // 🚪 Logout
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    final user = await _auth.authStateChanges().first;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!..addAll({'id': user.uid});
        _user = UserModel.fromMap(data);
        notifyListeners();
      }
    } else {
      _user = null;
      notifyListeners();
    }
  }

  // 🔑 Reset de senha via email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }
}
