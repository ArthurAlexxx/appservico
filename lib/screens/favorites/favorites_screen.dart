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
    final theme = Theme.of(context);

    if (favoriteWorkers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Nenhum profissional favorito ainda.',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        itemCount: favoriteWorkers.length,
        itemBuilder: (context, index) {
          final worker = favoriteWorkers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WorkerCard(
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
            ),
          );
        },
      ),
    );
  }
}
