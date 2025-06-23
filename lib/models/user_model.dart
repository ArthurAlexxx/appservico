class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String subscriptionPlan;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.subscriptionPlan = 'free',
  });

  bool get isPremium => subscriptionPlan == 'premium';
  bool get isPro => subscriptionPlan == 'pro';

  // 🔹 Converte para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'subscriptionPlan': subscriptionPlan,
    };
  }

  // 🔹 Cria a partir de Map (para ler do Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      subscriptionPlan: map['subscriptionPlan'] ?? 'free',
    );
  }
}
