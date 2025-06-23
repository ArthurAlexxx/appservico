import 'review_model.dart';

class Worker {
  final String id;
  final String name;
  final String profession;
  final String description;
  final double rating;
  final String imageUrl;
  final List<String> services;
  final String location;
  final bool isFavorite;
  final List<Review> reviews;
  final String whatsappNumber;
  final List<String> portfolioImages;
  final bool isVerified;
  final bool isFeatured;

  Worker({
    required this.id,
    required this.name,
    required this.profession,
    required this.description,
    this.rating = 0.0,
    required this.imageUrl,
    required this.services,
    required this.location,
    required this.whatsappNumber,
    this.isFavorite = false,
    this.reviews = const [],
    this.portfolioImages = const [],
    this.isVerified = false,
    this.isFeatured = false,
  });

  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      profession: map['profession'] ?? '',
      description: map['description'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      services: List<String>.from(map['services'] ?? []),
      location: map['location'] ?? '',
      whatsappNumber: map['whatsappNumber'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
      reviews: map['reviews'] != null
          ? List<Review>.from(map['reviews'].map((r) => Review.fromMap(r)))
          : [],
      portfolioImages: List<String>.from(map['portfolioImages'] ?? []),
      isVerified: map['isVerified'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profession': profession,
      'description': description,
      'rating': rating,
      'imageUrl': imageUrl,
      'services': services,
      'location': location,
      'whatsappNumber': whatsappNumber,
      'isFavorite': isFavorite,
      'reviews': reviews.map((r) => r.toMap()).toList(),
      'portfolioImages': portfolioImages,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
    };
  }

  Worker copyWith({
    String? id,
    String? name,
    String? profession,
    String? description,
    double? rating,
    String? imageUrl,
    List<String>? services,
    String? location,
    String? whatsappNumber,
    bool? isFavorite,
    List<Review>? reviews,
    List<String>? portfolioImages,
    bool? isVerified,
    bool? isFeatured,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      profession: profession ?? this.profession,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      services: services ?? this.services,
      location: location ?? this.location,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      isFavorite: isFavorite ?? this.isFavorite,
      reviews: reviews ?? this.reviews,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
