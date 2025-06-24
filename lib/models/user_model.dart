class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String subscriptionPlan;
  final List<String> favoriteWorkerIds;
  final String type; // novo campo para tipo de usuário

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.subscriptionPlan = 'free',
    this.favoriteWorkerIds = const [],
    required this.type,
  });

  bool get isPremium => subscriptionPlan == 'premium';
  bool get isPro => subscriptionPlan == 'pro';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'subscriptionPlan': subscriptionPlan,
      'favoriteWorkerIds': favoriteWorkerIds,
      'type': type,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      subscriptionPlan: map['subscriptionPlan'] ?? 'free',
      favoriteWorkerIds: List<String>.from(map['favoriteWorkerIds'] ?? []),
      type: map['type'] ?? 'user',
    );
  }
}
