import 'package:flutter/material.dart';
import '../../models/worker_model.dart';

class WorkerDetailScreen extends StatelessWidget {
  final Worker worker;

  const WorkerDetailScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(worker.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(worker.imageUrl),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              worker.profession,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text(worker.rating.toString(), style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Descrição', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(worker.description),
            const SizedBox(height: 20),
            const Text('Serviços oferecidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...worker.services.map((s) => ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(s),
                )),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 4),
                Text(worker.location),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
