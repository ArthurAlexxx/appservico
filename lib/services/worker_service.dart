import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/worker_model.dart';
import '../models/review_model.dart';
import '../screens/profile/user_service.dart';
import 'package:flutter/material.dart';

class WorkerService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Worker> _workers = [];
  final Map<String, List<Review>> _workerReviews = {};

  List<Worker> get workers => _workers;

  Future<void> fetchWorkers() async {
    try {
      final snapshot = await _firestore.collection('workers').get();

      _workers = snapshot.docs.map((doc) {
        final data = doc.data();
        return Worker.fromMap(data, doc.id);
      }).toList();

      // Opcional: já carregar avaliações aqui se quiser
      notifyListeners();
    } catch (e) {
      print('Erro ao buscar trabalhadores: $e');
    }
  }

  Future<void> addWorker(Worker worker) async {
    try {
      await _firestore.collection('workers').doc(worker.id).set(worker.toMap());
      _workers.add(worker);
      notifyListeners();
    } catch (e) {
      print('Erro ao adicionar trabalhador: $e');
    }
  }

  Future<bool> userHasWorker(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('workers')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar cadastro do usuário: $e');
      return false;
    }
  }

  // Retorna as avaliações do trabalhador, do cache ou do Firestore
  List<Review> getReviews(String workerId) {
    return _workerReviews[workerId] ?? [];
  }

  // Adiciona uma avaliação para o trabalhador no Firestore e atualiza o cache local
  Future<void> addReview(String workerId, Review review) async {
    try {
      final collection = _firestore.collection('workers').doc(workerId).collection('reviews');
      await collection.add(review.toMap());

      // Atualiza cache local
      if (_workerReviews[workerId] == null) {
        _workerReviews[workerId] = [];
      }
      _workerReviews[workerId]!.add(review);
      notifyListeners();
    } catch (e) {
      print('Erro ao adicionar avaliação: $e');
    }
  }

  // Outros métodos que você pode implementar depois...
  Future<List<Worker>> getFavoriteWorkers(UserService userService) async {
    try {
      final ids = userService.favoriteWorkerIds;
      final workersList = _workers.where((w) => ids.contains(w.id)).toList();
      return workersList;
    } catch (e) {
      print('Erro ao buscar favoritos: $e');
      return [];
    }
  }

  void removeWorker(String id) {
    _workers.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id, UserService userService) async {
    if (userService.favoriteWorkerIds.contains(id)) {
      await userService.removeFavoriteWorker(id);
    } else {
      await userService.addFavoriteWorker(id);
    }
    notifyListeners();
  }
}
