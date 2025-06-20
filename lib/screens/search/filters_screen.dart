import 'package:flutter/material.dart';

class FiltersScreen extends StatefulWidget {
  final String? selectedLocation;
  final String? selectedProfession;

  const FiltersScreen({
    super.key,
    this.selectedLocation,
    this.selectedProfession,
  });

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  String? _location;
  String? _profession;

  final List<String> _locations = [
    'São Paulo - SP',
    'Rio de Janeiro - RJ',
    'Belo Horizonte - MG',
  ];

  final List<String> _professions = [
    'Encanador',
    'Eletricista',
    'Pintor',
  ];

  @override
  void initState() {
    super.initState();
    _location = widget.selectedLocation;
    _profession = widget.selectedProfession;
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'location': _location,
      'profession': _profession,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _location,
              items: _locations.map((loc) {
                return DropdownMenuItem(value: loc, child: Text(loc));
              }).toList(),
              onChanged: (value) => setState(() => _location = value),
              decoration: InputDecoration(
                labelText: 'Localização',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.colorScheme.surface.withOpacity(0.05),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _profession,
              items: _professions.map((prof) {
                return DropdownMenuItem(value: prof, child: Text(prof));
              }).toList(),
              onChanged: (value) => setState(() => _profession = value),
              decoration: InputDecoration(
                labelText: 'Profissão',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.colorScheme.surface.withOpacity(0.05),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.check),
                label: const Text('Aplicar Filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
