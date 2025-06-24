import 'package:appservico/models/worker_model.dart';
import 'package:appservico/screens/profile/user_service.dart';
import 'package:appservico/screens/search/worker_filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/worker_service.dart';
import '../../widgets/worker_card.dart';
import 'worker_detail_screen.dart';

class WorkerListScreen extends StatefulWidget {
  const WorkerListScreen({super.key});

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  bool _isLoading = true;
  List<Worker>? _filteredWorkers;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    await Provider.of<WorkerService>(context, listen: false).fetchWorkers();
    await Provider.of<UserService>(context, listen: false).loadUserData();
    setState(() => _isLoading = false);
  }

  Future<void> _openFilter() async {
    final workers = Provider.of<WorkerService>(context, listen: false).workers;
    final filtered = await Navigator.push<List<Worker>>(
      context,
      MaterialPageRoute(
        builder: (_) => WorkerFilterScreen(workers: workers),
      ),
    );

    if (filtered != null) {
      setState(() {
        _filteredWorkers = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workerService = Provider.of<WorkerService>(context);
    final sortedWorkers = [...workerService.workers]
      ..sort((a, b) => b.isFeatured.toString().compareTo(a.isFeatured.toString()));

    final listToShow = _filteredWorkers ?? sortedWorkers;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trabalhadores',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Filtrar',
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilter,
          ),
          // Espaço para search se quiser depois
          // IconButton(
          //   tooltip: 'Buscar',
          //   icon: const Icon(Icons.search),
          //   onPressed: () {},
          // ),
        ],
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadWorkers,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Carregando trabalhadores...'),
                      ],
                    ),
                  )
                : listToShow.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            const Text(
                              'Nenhum trabalhador encontrado',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: listToShow.length,
                        itemBuilder: (context, index) {
                          final worker = listToShow[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: worker.isFeatured
                                  ? theme.colorScheme.primary.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              elevation: 2,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WorkerDetailScreen(worker: worker),
                                    ),
                                  );
                                },
                                child: WorkerCard(worker: worker),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}
