import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço de localização está desativado.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permissão de localização negada.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização permanentemente negada.')),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        setState(() {
          _locationController.text = address;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endereço não encontrado.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização: $e')),
      );
    }
  }

  void _submitForm() {
  if (_formKey.currentState!.validate()) {
    final portfolioImages = _portfolioControllers
        .map((c) => c.text.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    // Aqui você pode obter o plano do usuário de onde estiver armazenado
    // Exemplo com Provider (se você tiver um SubscriptionService):
    // final subscriptionPlan = Provider.of<SubscriptionService>(context, listen: false).currentPlan;

    // Como você ainda não tem isso implementado, vamos simular:
    const subscriptionPlan = 'premium'; // <- Substitua isso com o valor real depois

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
      isFeatured: subscriptionPlan == 'premium', // <- Aqui aplicamos o destaque
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(_locationController, 'Localização'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      tooltip: 'Usar localização atual',
                      onPressed: _getCurrentLocation,
                    ),
                  ],
                ),
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
