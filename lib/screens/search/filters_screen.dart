import 'package:flutter/material.dart';

class FiltersScreen extends StatefulWidget {
  final String? selectedLocation;
  final String? selectedProfession;

  const FiltersScreen({
    Key? key,
    this.selectedLocation,
    this.selectedProfession,
  }) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(title: const Text('Filtros')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _location,
              items: _locations.map((loc) {
                return DropdownMenuItem(value: loc, child: Text(loc));
              }).toList(),
              onChanged: (value) => setState(() => _location = value),
              decoration: const InputDecoration(labelText: 'Localização'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _profession,
              items: _professions.map((prof) {
                return DropdownMenuItem(value: prof, child: Text(prof));
              }).toList(),
              onChanged: (value) => setState(() => _profession = value),
              decoration: const InputDecoration(labelText: 'Profissão'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Aplicar Filtros'),
            ),
          ],
        ),
      ),
    );
  }
}
