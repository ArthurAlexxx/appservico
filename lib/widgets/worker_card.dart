import 'package:appservico/screens/profile/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/worker_model.dart';
import '../../services/worker_service.dart';

class WorkerCard extends StatelessWidget {
  final Worker worker;
  final VoidCallback? onTap;
  final bool showVerificationBadge;

  const WorkerCard({
    super.key,
    required this.worker,
    this.onTap,
    this.showVerificationBadge = true, // default true, pode ajustar se quiser
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userService = Provider.of<UserService>(context, listen: false);
    final currentUserId = userService.currentUserId;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: worker.isFeatured ? 4 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(worker.imageUrl),
                        radius: 30,
                      ),
                      if (worker.isFeatured)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                worker.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Só mostra o selo de verificado se for verdade e o worker.isVerified for true
                            if (showVerificationBadge && worker.isVerified)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(Icons.verified, color: Colors.blue, size: 18),
                              ),
                          ],
                        ),
                        Text(
                          worker.profession,
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  Consumer<UserService>(
                    builder: (context, userService, _) {
                      final isFavorite = userService.favoriteWorkerIds.contains(worker.id);

                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : theme.iconTheme.color,
                        ),
                        onPressed: () async {
                          await Provider.of<WorkerService>(context, listen: false)
                              .toggleFavorite(worker.id, userService);
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                worker.description,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: worker.services
                    .map((service) => Chip(
                          label: Text(service),
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          labelStyle: TextStyle(color: theme.colorScheme.primary),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  Text(' ${worker.rating}', style: theme.textTheme.bodyMedium),
                  const Spacer(),
                  const Icon(Icons.location_on, size: 20, color: Colors.grey),
                  Text(' ${worker.location}', style: theme.textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 12),
              if (worker.userId == currentUserId) // Só exibe se for dono do anúncio
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      try {
                        await Provider.of<WorkerService>(context, listen: false).removeWorker(worker.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profissional removido com sucesso.')),
                        );
                      } catch (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Erro ao remover profissional.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Remover', style: TextStyle(color: Colors.red)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
