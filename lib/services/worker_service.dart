import 'package:flutter/material.dart';
import '../models/worker_model.dart';

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
          isFavorite: !worker.isFavorite,
        );
      }
      return worker;
    }).toList();
    notifyListeners();
  }

  List<Worker> getFavoriteWorkers() {
    return _workers.where((worker) => worker.isFavorite).toList();
  }
}