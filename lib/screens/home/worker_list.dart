import 'package:appservico/screens/home/worker_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/worker_service.dart';
import '../../widgets/worker_card.dart';

class WorkerListScreen extends StatelessWidget {
  const WorkerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workerService = Provider.of<WorkerService>(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView.builder(
          itemCount: workerService.workers.length,
          itemBuilder: (context, index) {
            final worker = workerService.workers[index];
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
      ),
    );
  }
}
