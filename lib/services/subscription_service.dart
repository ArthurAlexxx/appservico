import 'package:flutter/material.dart';

class SubscriptionService with ChangeNotifier {
  String _currentPlan = 'free'; // Pode ser: 'free', 'pro', 'premium'

  String get currentPlan => _currentPlan;

  void updatePlan(String plan) {
    _currentPlan = plan;
    notifyListeners();
  }

  bool get isFree => _currentPlan == 'free';
  bool get isPro => _currentPlan == 'pro';
  bool get isPremium => _currentPlan == 'premium';
}
