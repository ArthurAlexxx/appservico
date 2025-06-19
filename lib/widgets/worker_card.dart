import 'package:flutter/material.dart';
import '../../models/worker_model.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(worker.profession),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      worker.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: worker.isFavorite ? Colors.red : null,
                    ),
                    onPressed: onFavoritePressed,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(worker.description),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: worker.services
                    .map((service) => Chip(
                          label: Text(service),
                          backgroundColor: Colors.blue[50],
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  Text(' ${worker.rating}'),
                  const Spacer(),
                  const Icon(Icons.location_on, size: 20),
                  Text(' ${worker.location}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
