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

    return ListView.builder(
      itemCount: workerService.workers.length,
      itemBuilder: (context, index) {
        final worker = workerService.workers[index];
        return WorkerCard(
          worker: worker,
          onFavoritePressed: () {
            workerService.toggleFavorite(worker.id);
          },
          onTap: () {
        print('Clicou em: ${worker.name}');
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
