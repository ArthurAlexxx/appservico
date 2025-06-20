import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/worker_model.dart';
import '../../services/worker_service.dart';

class RegisterWorkerScreen extends StatefulWidget {
  const RegisterWorkerScreen({super.key});

  @override
  State<RegisterWorkerScreen> createState() => _RegisterWorkerScreenState();
}

class _RegisterWorkerScreenState extends State<RegisterWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _professionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _servicesController = TextEditingController();
  final _locationController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newWorker = Worker(
        id: DateTime.now().toString(),
        name: _nameController.text,
        profession: _professionController.text,
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text,
        services: _servicesController.text.split(',').map((s) => s.trim()).toList(),
        location: _locationController.text,
      );

      Provider.of<WorkerService>(context, listen: false).addWorker(newWorker);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Profissional'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(_nameController, 'Nome'),
                _buildTextField(_professionController, 'Profissão'),
                _buildTextField(_descriptionController, 'Descrição', maxLines: 3),
                _buildTextField(_imageUrlController, 'URL da Imagem'),
                _buildTextField(_servicesController, 'Serviços (separados por vírgula)'),
                _buildTextField(_locationController, 'Localização'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: theme.colorScheme.surface.withOpacity(0.05),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, preencha este campo';
          }
          return null;
        },
      ),
    );
  }
}
