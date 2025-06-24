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

  List<Worker> get workers => List.unmodifiable(_workers);

  /// Busca todos os trabalhadores no Firestore
  Future<void> fetchWorkers() async {
    try {
      final snapshot = await _firestore.collection('workers').get();

      _workers = snapshot.docs.map((doc) {
        final data = doc.data();
        return Worker.fromMap(data, doc.id);
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao buscar trabalhadores: $e');
      // Opcional: lançar exceção ou tratar de outra forma
    }
  }

  /// Adiciona novo trabalhador no Firestore e atualiza lista local
  Future<void> addWorker(Worker worker) async {
    try {
      await _firestore.collection('workers').doc(worker.id).set(worker.toMap());
      _workers.add(worker);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar trabalhador: $e');
      // Opcional: lançar exceção
    }
  }

  /// Verifica se um usuário já possui um trabalhador cadastrado
  Future<bool> userHasWorker(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('workers')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Erro ao verificar cadastro do usuário: $e');
      return false;
    }
  }

  /// Retorna avaliações locais carregadas para um trabalhador
  List<Review> getReviews(String workerId) {
    return List.unmodifiable(_workerReviews[workerId] ?? []);
  }

  /// Adiciona avaliação a um trabalhador no Firestore e localmente
  Future<void> addReview(String workerId, Review review) async {
    try {
      final collection = _firestore.collection('workers').doc(workerId).collection('reviews');
      await collection.add(review.toMap());

      _workerReviews.putIfAbsent(workerId, () => []);
      _workerReviews[workerId]!.add(review);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar avaliação: $e');
    }
  }

  /// Retorna a lista de trabalhadores favoritos de um usuário
  Future<List<Worker>> getFavoriteWorkers(UserService userService) async {
    try {
      final ids = userService.favoriteWorkerIds;
      // Caso _workers ainda não tenha sido carregado, carregar aqui
      if (_workers.isEmpty) {
        await fetchWorkers();
      }
      final workersList = _workers.where((w) => ids.contains(w.id)).toList();
      return workersList;
    } catch (e) {
      debugPrint('Erro ao buscar favoritos: $e');
      return [];
    }
  }

  /// Remove trabalhador do Firestore e da lista local
  Future<void> removeWorker(String id) async {
    try {
      await _firestore.collection('workers').doc(id).delete();
      _workers.removeWhere((w) => w.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao remover trabalhador: $e');
      throw Exception('Erro ao remover trabalhador');
    }
  }

  /// Alterna estado favorito do trabalhador para o usuário
  Future<void> toggleFavorite(String id, UserService userService) async {
    if (userService.favoriteWorkerIds.contains(id)) {
      await userService.removeFavoriteWorker(id);
    } else {
      await userService.addFavoriteWorker(id);
    }
    notifyListeners();
  }
}
