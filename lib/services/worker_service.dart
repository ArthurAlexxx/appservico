import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/worker_model.dart';
import '../models/review_model.dart';

class WorkerService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Worker> _workers = [];
  List<Worker> get workers => _workers;

  // Buscar todos os workers do Firestore
  Future<void> fetchWorkers() async {
    final snapshot = await _firestore.collection('workers').get();
    _workers = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Worker.fromMap(data);
    }).toList();
    notifyListeners();
  }

  Future<void> addWorker(Worker worker) async {
  final docRef = await _firestore.collection('workers').add(worker.toMap());
  final newWorker = worker.copyWith(id: docRef.id);
  _workers.add(newWorker);
  notifyListeners();
}

  // Alternar favorito localmente
  void toggleFavorite(String workerId) {
    final index = _workers.indexWhere((w) => w.id == workerId);
    if (index != -1) {
      _workers[index] = _workers[index].copyWith(
        isFavorite: !_workers[index].isFavorite,
      );
      notifyListeners();
    }
  }

  List<Worker> getFavoriteWorkers() {
    return _workers.where((w) => w.isFavorite).toList();
  }

  // Adicionar avaliação
  Future<void> addReview(String workerId, Review review) async {
    final index = _workers.indexWhere((w) => w.id == workerId);
    if (index != -1) {
      final worker = _workers[index];
      final updatedReviews = [...worker.reviews, review];
      final newRating = updatedReviews.map((r) => r.rating).reduce((a, b) => a + b) / updatedReviews.length;

      final updatedWorker = worker.copyWith(
        reviews: updatedReviews,
        rating: newRating,
      );

      await _firestore.collection('workers').doc(workerId).update(updatedWorker.toMap());
      _workers[index] = updatedWorker;
      notifyListeners();
    }
  }
  Future<void> removeWorker(String id) async {
  try {
    await _firestore.collection('workers').doc(id).delete();
    _workers.removeWhere((worker) => worker.id == id);
    notifyListeners();
  } catch (e) {
    debugPrint('Erro ao remover worker: $e');
  }
}
}
