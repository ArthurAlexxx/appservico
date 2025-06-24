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
  List<String> favoriteWorkerIds = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  Future<void> loadUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final doc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        name = data['name'] ?? '';
        email = data['email'] ?? currentUser.email ?? '';
        phone = data['phone'] ?? '';
        photoUrl = data['photoUrl'] ?? '';
        favoriteWorkerIds = List<String>.from(data['favoriteWorkerIds'] ?? []);
        notifyListeners();
      }
    }
  }

  Future<void> updateProfile({
    required String newName,
    required String newEmail,
    required String newPhone,
  }) async {
    final uid = _auth.currentUser!.uid;

    name = newName;
    email = newEmail;
    phone = newPhone;

    await _firestore.collection('users').doc(uid).update({
      'name': newName,
      'email': newEmail,
      'phone': newPhone,
    });

    notifyListeners();
  }

  Future<void> uploadProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final uid = _auth.currentUser!.uid;
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
    final uid = _auth.currentUser!.uid;
    final ref = _storage.ref().child('profile_photos/$uid.jpg');

    UploadTask uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    final url = await snapshot.ref.getDownloadURL();

    await _firestore.collection('users').doc(uid).update({'photoUrl': url});
    photoUrl = url;
    notifyListeners();
  }

  Future<void> addFavoriteWorker(String workerId) async {
    final uid = _auth.currentUser!.uid;
    final userRef = _firestore.collection('users').doc(uid);

    await userRef.update({
      'favoriteWorkerIds': FieldValue.arrayUnion([workerId]),
    });

    favoriteWorkerIds.add(workerId);
    notifyListeners();
  }

  Future<void> removeFavoriteWorker(String workerId) async {
    final uid = _auth.currentUser!.uid;
    final userRef = _firestore.collection('users').doc(uid);

    await userRef.update({
      'favoriteWorkerIds': FieldValue.arrayRemove([workerId]),
    });

    favoriteWorkerIds.remove(workerId);
    notifyListeners();
  }

  Future<List<String>> getFavoriteWorkerIds() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      return List<String>.from(data['favoriteWorkerIds'] ?? []);
    }

    return [];
  }
}
