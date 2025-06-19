import 'package:flutter/material.dart';

class UserService with ChangeNotifier {
  String name = 'Usuário Teste';
  String email = 'teste@email.com';
  String phone = '(11) 99999-9999';

  void updateProfile({required String newName, required String newEmail, required String newPhone}) {
    name = newName;
    email = newEmail;
    phone = newPhone;
    notifyListeners();
  }
}
