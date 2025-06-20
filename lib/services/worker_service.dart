import 'package:flutter/material.dart';
import '../models/worker_model.dart';
import '../models/review_model.dart';

class WorkerService with ChangeNotifier {
  List<Worker> _workers = [
    Worker(
      id: '1',
      name: 'João Silva',
      profession: 'Encanador',
      description: 'Serviços de encanamento residencial e comercial com 10 anos de experiência',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1580894732444-8ecded7900cd?w=500',
      services: ['Encanamento', 'Conserto de vazamentos', 'Instalação hidráulica'],
      location: 'São Paulo - SP',
      whatsappNumber: '5511987654321',
      reviews: [],
      portfolioImages: [
        'https://images.unsplash.com/photo-1580894732444-8ecded7900cd?w=500',
        'https://images.unsplash.com/photo-1580894732444-8ecded7900cd?w=500',
      ],
    ),
    Worker(
      id: '2',
      name: 'Maria Souza',
      profession: 'Eletricista',
      description: 'Instalações elétricas residenciais e pequenos reparos',
      rating: 4.5,
      imageUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=500',
      services: ['Instalação elétrica', 'Manutenção', 'Troca de disjuntores'],
      location: 'Rio de Janeiro - RJ',
      whatsappNumber: '5521998765432',
      reviews: [],
      portfolioImages: [
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=500',
        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=500',
      ],
    ),
    Worker(
      id: '3',
      name: 'Carlos Mendes',
      profession: 'Pintor',
      description: 'Pintura residencial e comercial com materiais de qualidade',
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=500',
      services: ['Pintura interna', 'Pintura externa', 'Texturização'],
      location: 'Belo Horizonte - MG',
      whatsappNumber: '5531991234567',
      reviews: [],
      portfolioImages: [
        'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=500',
        'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=500',
      ],
    ),
  ];

  List<Worker> get workers => _workers;

  void addWorker(Worker worker) {
    _workers.add(worker);
    notifyListeners();
  }

  void toggleFavorite(String workerId) {
    _workers = _workers.map((worker) {
      if (worker.id == workerId) {
        return Worker(
          id: worker.id,
          name: worker.name,
          profession: worker.profession,
          description: worker.description,
          rating: worker.rating,
          imageUrl: worker.imageUrl,
          services: worker.services,
          location: worker.location,
          whatsappNumber: worker.whatsappNumber,
          isFavorite: !worker.isFavorite,
          reviews: worker.reviews,
          portfolioImages: worker.portfolioImages,
        );
      }
      return worker;
    }).toList();
    notifyListeners();
  }

  List<Worker> getFavoriteWorkers() {
    return _workers.where((worker) => worker.isFavorite).toList();
  }

  void removeWorker(String id) {
    _workers.removeWhere((worker) => worker.id == id);
    notifyListeners();
  }

  void addReview(String workerId, Review review) {
    final index = _workers.indexWhere((w) => w.id == workerId);
    if (index != -1) {
      final worker = _workers[index];
      final updatedReviews = [...worker.reviews, review];
      final newRating = updatedReviews.map((r) => r.rating).reduce((a, b) => a + b) / updatedReviews.length;

      _workers[index] = Worker(
        id: worker.id,
        name: worker.name,
        profession: worker.profession,
        description: worker.description,
        rating: newRating,
        imageUrl: worker.imageUrl,
        services: worker.services,
        location: worker.location,
        whatsappNumber: worker.whatsappNumber,
        isFavorite: worker.isFavorite,
        reviews: updatedReviews,
        portfolioImages: worker.portfolioImages,
      );
      notifyListeners();
    }
  }
}
