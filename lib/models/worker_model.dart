class Worker {
  final String id;
  final String userId;
  final String name;
  final String profession;
  final String description;
  final String imageUrl;
  final List<String> services;
  final String location;
  final String whatsappNumber;
  final List<String> portfolioImages;
  final bool isVerified;
  final bool isFeatured;
  final double rating;

  Worker({
    required this.id,
    required this.userId,
    required this.name,
    required this.profession,
    required this.description,
    required this.imageUrl,
    required this.services,
    required this.location,
    required this.whatsappNumber,
    required this.portfolioImages,
    this.isVerified = false,
    this.isFeatured = false,
    this.rating = 0.0,
  });

  factory Worker.fromMap(Map<String, dynamic> map, String docId) {
    return Worker(
      id: docId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      profession: map['profession'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      services: List<String>.from(map['services'] ?? []),
      location: map['location'] ?? '',
      whatsappNumber: map['whatsappNumber'] ?? '',
      portfolioImages: List<String>.from(map['portfolioImages'] ?? []),
      isVerified: map['isVerified'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
      rating: (map['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'profession': profession,
      'description': description,
      'imageUrl': imageUrl,
      'services': services,
      'location': location,
      'whatsappNumber': whatsappNumber,
      'portfolioImages': portfolioImages,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
      'rating': rating,
    };
  }
}
