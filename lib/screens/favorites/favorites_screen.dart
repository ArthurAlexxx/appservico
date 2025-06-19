import 'package:appservico/screens/home/worker_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/worker_service.dart';
import '../../widgets/worker_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workerService = Provider.of<WorkerService>(context);
    final favoriteWorkers = workerService.getFavoriteWorkers();

    if (favoriteWorkers.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum profissional favorito ainda.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: favoriteWorkers.length,
      itemBuilder: (context, index) {
        final worker = favoriteWorkers[index];
        return WorkerCard(
          worker: worker,
          onFavoritePressed: () {
            workerService.toggleFavorite(worker.id);
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkerDetailScreen(worker: worker),
              ),
            );
          },
        );
      },
    );
  }
}
