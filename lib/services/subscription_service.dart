import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _currentPlan = 'free'; // 'free', 'pro', 'premium'

  String get currentPlan => _currentPlan;

  bool get isFree => _currentPlan == 'free';
  bool get isPro => _currentPlan == 'pro';
  bool get isPremium => _currentPlan == 'premium';

  /// Atualiza o plano do usuário no Firestore e localmente
  Future<void> updatePlan(String userId, String plan) async {
    if (plan == _currentPlan) return; // evita notificar sem necessidade

    try {
      _currentPlan = plan;
      notifyListeners();

      await _firestore.collection('subscriptions').doc(userId).set({
        'plan': plan,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Erro ao atualizar plano: $e');
      rethrow;
    }
  }

  /// Carrega o plano do usuário no login ou atualização
  Future<void> loadUserPlan(String userId) async {
    try {
      final doc = await _firestore.collection('subscriptions').doc(userId).get();

      final fetchedPlan = doc.data()?['plan'] as String?;
      if (fetchedPlan == 'free' || fetchedPlan == 'pro' || fetchedPlan == 'premium') {
        if (_currentPlan != fetchedPlan) {
          _currentPlan = fetchedPlan!;
          notifyListeners();
        }
      } else {
        _currentPlan = 'free';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar plano: $e');
      _currentPlan = 'free';
      notifyListeners();
    }
  }
}
