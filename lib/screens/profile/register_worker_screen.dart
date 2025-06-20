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
  final _whatsappController = TextEditingController();
  final List<TextEditingController> _portfolioControllers = [TextEditingController()];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final portfolioImages = _portfolioControllers
          .map((c) => c.text.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      final newWorker = Worker(
        id: DateTime.now().toString(),
        name: _nameController.text,
        profession: _professionController.text,
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text,
        services: _servicesController.text.split(',').map((s) => s.trim()).toList(),
        location: _locationController.text,
        whatsappNumber: _whatsappController.text,
        portfolioImages: portfolioImages,
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
                _buildTextField(
                  _whatsappController,
                  'Número do WhatsApp (ex: 5511999999999)',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, preencha este campo';
                    }
                    final regex = RegExp(r'^55\d{10,11}$');
                    if (!regex.hasMatch(value)) {
                      return 'Número inválido. Use o formato 55 + DDD + número (ex: 5511999999999)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Links do Portfólio', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._portfolioControllers.map((controller) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: TextFormField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'https://exemplo.com/imagem.jpg',
                          labelText: 'Imagem do Portfólio',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty && !Uri.parse(value).isAbsolute) {
                            return 'Insira uma URL válida';
                          }
                          return null;
                        },
                      ),
                    )),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _portfolioControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar imagem'),
                ),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
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
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, preencha este campo';
              }
              return null;
            },
      ),
    );
  }
}
