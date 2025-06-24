import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserService with ChangeNotifier {
  String name = '';
  String email = '';
  String phone = '';
  String photoUrl = '';
  String profileType = '';
  List<String> favoriteWorkerIds = [];

  // Plano de assinatura: 'free', 'pro' ou 'premium'
  String subscriptionPlan = 'free';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não está logado');
    return user.uid;
  }

  Future<void> loadUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final doc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      name = data['name'] ?? '';
      email = data['email'] ?? currentUser.email ?? '';
      phone = data['phone'] ?? '';
      photoUrl = data['photoUrl'] ?? '';
      profileType = data['type'] ?? '';
      favoriteWorkerIds = List<String>.from(data['favoriteWorkerIds'] ?? []);

      // Carrega o plano de assinatura da collection 'subscriptions'
      final subscriptionDoc = await _firestore.collection('subscriptions').doc(currentUser.uid).get();
      if (subscriptionDoc.exists) {
        subscriptionPlan = subscriptionDoc.data()?['plan'] ?? 'free';
      } else {
        subscriptionPlan = 'free';
      }

      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String newName,
    required String newEmail,
    required String newPhone,
  }) async {
    if (_auth.currentUser == null) return;
    final uid = currentUserId;

    name = newName;
    email = newEmail;
    phone = newPhone;

    await _firestore.collection('users').doc(uid).update({
      if (newName.isNotEmpty) 'name': newName,
      if (newEmail.isNotEmpty) 'email': newEmail,
      if (newPhone.isNotEmpty) 'phone': newPhone,
    });

    notifyListeners();
  }

  Future<void> uploadProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && _auth.currentUser != null) {
      final uid = currentUserId;
      final ref = _storage.ref().child('profile_photos/$uid.jpg');

      UploadTask uploadTask;

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        uploadTask = ref.putData(bytes);
      } else {
        final file = io.File(pickedFile.path);
        uploadTask = ref.putFile(file);
      }

      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      await _firestore.collection('users').doc(uid).update({'photoUrl': url});
      photoUrl = url;
      notifyListeners();
    }
  }

  Future<void> uploadProfilePhotoFromFile(io.File file) async {
    if (_auth.currentUser == null) return;
    final uid = currentUserId;
    final ref = _storage.ref().child('profile_photos/$uid.jpg');

    final snapshot = await ref.putFile(file);
    final url = await snapshot.ref.getDownloadURL();

    await _firestore.collection('users').doc(uid).update({'photoUrl': url});
    photoUrl = url;
    notifyListeners();
  }

  Future<void> addFavoriteWorker(String workerId) async {
    if (_auth.currentUser == null) return;
    final uid = currentUserId;
    final userRef = _firestore.collection('users').doc(uid);

    await userRef.update({
      'favoriteWorkerIds': FieldValue.arrayUnion([workerId]),
    });

    if (!favoriteWorkerIds.contains(workerId)) {
      favoriteWorkerIds.add(workerId);
      notifyListeners();
    }
  }

  Future<void> removeFavoriteWorker(String workerId) async {
    if (_auth.currentUser == null) return;
    final uid = currentUserId;
    final userRef = _firestore.collection('users').doc(uid);

    await userRef.update({
      'favoriteWorkerIds': FieldValue.arrayRemove([workerId]),
    });

    favoriteWorkerIds.remove(workerId);
    notifyListeners();
  }

  Future<List<String>> getFavoriteWorkerIds() async {
    if (_auth.currentUser == null) return [];

    final doc = await _firestore.collection('users').doc(currentUserId).get();
    if (doc.exists) {
      final data = doc.data()!;
      return List<String>.from(data['favoriteWorkerIds'] ?? []);
    }
    return [];
  }

  /// Retorna a URL da foto de perfil ou uma imagem padrão
  String getUserPhoto() {
    return photoUrl.isNotEmpty
        ? photoUrl
        : 'https://www.gravatar.com/avatar/placeholder';
  }

  /// Atualiza o plano localmente e notifica
  void setSubscriptionPlan(String plan) {
    subscriptionPlan = plan;
    notifyListeners();
  }
}
