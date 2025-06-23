import 'package:appservico/screens/home/worker_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/worker_service.dart';
import '../../widgets/worker_card.dart';

class WorkerListScreen extends StatefulWidget {
  const WorkerListScreen({super.key});

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    await Provider.of<WorkerService>(context, listen: false).fetchWorkers();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final workerService = Provider.of<WorkerService>(context);
    final sortedWorkers = [...workerService.workers]
      ..sort((a, b) => b.isFeatured.toString().compareTo(a.isFeatured.toString()));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: sortedWorkers.length,
                itemBuilder: (context, index) {
                  final worker = sortedWorkers[index];
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
