import 'package:appservico/models/worker_model.dart';
import 'package:appservico/services/worker_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'filters_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  String? _selectedLocation;
  String? _selectedProfession;

  List<Worker> _filterAndSearch(List<Worker> workers) {
    return workers.where((worker) {
      final matchesQuery = _searchQuery.isEmpty ||
          worker.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          worker.profession.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesLocation = _selectedLocation == null || worker.location == _selectedLocation;
      final matchesProfession = _selectedProfession == null || worker.profession == _selectedProfession;

      return matchesQuery && matchesLocation && matchesProfession;
    }).toList();
  }

  void _openFilters() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FiltersScreen(
          selectedLocation: _selectedLocation,
          selectedProfession: _selectedProfession,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result['location'];
        _selectedProfession = result['profession'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workers = Provider.of<WorkerService>(context).workers;
    final filteredWorkers = _filterAndSearch(workers);

    return Scaffold(
          appBar: AppBar(
      title: const Text('Buscar Profissionais'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _openFilters,
        ),
      ],   
    ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por nome ou profissão',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.colorScheme.surface.withOpacity(0.05),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredWorkers.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum profissional encontrado.',
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredWorkers.length,
                    itemBuilder: (context, index) {
                      final worker = filteredWorkers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(worker.imageUrl),
                          ),
                          title: Text(worker.name, style: theme.textTheme.titleMedium),
                          subtitle: Text('${worker.profession} • ${worker.location}'),
                          trailing: Icon(
                            worker.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: worker.isFavorite ? Colors.red : theme.iconTheme.color,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
