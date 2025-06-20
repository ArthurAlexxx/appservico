import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/worker_model.dart';
import '../../services/worker_service.dart';

class WorkerCard extends StatelessWidget {
  final Worker worker;
  final VoidCallback onFavoritePressed;
  final VoidCallback? onTap;

  const WorkerCard({
    super.key,
    required this.worker,
    required this.onFavoritePressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(worker.imageUrl),
                    radius: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          worker.profession,
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      worker.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: worker.isFavorite ? Colors.red : theme.iconTheme.color,
                    ),
                    onPressed: onFavoritePressed,
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Provider.of<WorkerService>(context, listen: false).removeWorker(worker.id);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Remover',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
