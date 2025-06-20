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
  });
}
