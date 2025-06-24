import 'package:flutter/material.dart';
import '../../models/worker_model.dart';
import '../home/worker_detail_screen.dart';  // Ajuste o caminho conforme sua estrutura

class WorkerFilterScreen extends StatefulWidget {
  final List<Worker> workers;

  const WorkerFilterScreen({super.key, required this.workers});

  @override
  State<WorkerFilterScreen> createState() => _WorkerFilterScreenState();
}

class _WorkerFilterScreenState extends State<WorkerFilterScreen> {
  String profession = '';
  int? minRating;
  String location = '';

  List<Worker> filteredWorkers = [];

  @override
  void initState() {
    super.initState();
    filteredWorkers = widget.workers;
  }

  void _applyFilter() {
    setState(() {
      filteredWorkers = widget.workers.where((worker) {
        final matchesProfession = profession.isEmpty ||
            worker.profession.toLowerCase().contains(profession.toLowerCase());
        final matchesRating = minRating == null || worker.rating >= minRating!;
        final matchesLocation = location.isEmpty ||
            worker.location.toLowerCase().contains(location.toLowerCase());

        return matchesProfession && matchesRating && matchesLocation;
      }).toList();
    });
  }

  void _submitFilter() {
    Navigator.pop(context, filteredWorkers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtrar Trabalhadores'),
        actions: [
          TextButton(
            onPressed: _submitFilter,
            child: const Text(
              'Aplicar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Profissão',
                prefixIcon: Icon(Icons.work),
              ),
              onChanged: (value) {
                profession = value;
                _applyFilter();
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Nota mínima',
                prefixIcon: Icon(Icons.star),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text('Qualquer nota')),
                ...List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1} estrela${index > 0 ? 's' : ''}'),
                  ),
                )
              ],
              onChanged: (value) {
                setState(() {
                  minRating = value;
                });
                _applyFilter();
              },
              value: minRating,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Localização',
                prefixIcon: Icon(Icons.location_on),
              ),
              onChanged: (value) {
                location = value;
                _applyFilter();
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: filteredWorkers.isEmpty
                  ? const Center(child: Text('Nenhum trabalhador encontrado'))
                  : ListView.builder(
                      itemCount: filteredWorkers.length,
                      itemBuilder: (context, index) {
                        final worker = filteredWorkers[index];
                        return ListTile(
                          title: Text(worker.name),
                          subtitle: Text('${worker.profession} • Nota: ${worker.rating.toStringAsFixed(1)}'),
                          trailing: Text(worker.location),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WorkerDetailScreen(worker: worker),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
