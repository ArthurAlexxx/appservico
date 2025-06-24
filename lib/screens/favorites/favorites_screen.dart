import 'package:appservico/models/worker_model.dart';
import 'package:appservico/screens/profile/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/worker_service.dart';
import '../../widgets/worker_card.dart';
import '../home/worker_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workerService = Provider.of<WorkerService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);
    final theme = Theme.of(context);

    return FutureBuilder<List<Worker>>(
      future: workerService.getFavoriteWorkers(userService),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Erro ao carregar favoritos: ${snapshot.error}',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final favoriteWorkers = snapshot.data ?? [];

        if (favoriteWorkers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
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

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: favoriteWorkers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final worker = favoriteWorkers[index];
            return WorkerCard(
              worker: worker,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkerDetailScreen(worker: worker),
                  ),
                );
              },
              showVerificationBadge: worker.isVerified,
            );
          },
        );
      },
    );
  }
}
