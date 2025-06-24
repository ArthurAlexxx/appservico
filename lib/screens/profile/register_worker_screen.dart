import 'package:appservico/utils/brazil_cities.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../models/worker_model.dart';
import '../../services/worker_service.dart';
import '../profile/user_service.dart';
import '../../services/subscription_service.dart';

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

  bool _isLoading = false;
  int _photoLimit = 5; // padrão free

  @override
  void initState() {
    super.initState();
    final userService = Provider.of<UserService>(context, listen: false);
    _nameController.text = userService.name;
    _whatsappController.text = userService.phone;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plan = Provider.of<SubscriptionService>(context, listen: false).currentPlan;
      setState(() {
        if (plan == 'free') {
          _photoLimit = 5;
        } else if (plan == 'pro') {
          _photoLimit = 15;
        } else if (plan == 'premium') {
          _photoLimit = 999; // ilimitado
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _professionController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _servicesController.dispose();
    _locationController.dispose();
    _whatsappController.dispose();
    for (var c in _portfolioControllers) {
      c.dispose();
    }
    super.dispose();
  }

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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userService = Provider.of<UserService>(context, listen: false);
    final userId = userService.currentUserId;

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final portfolioImages = _portfolioControllers
        .map((c) => c.text.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    if (portfolioImages.length > _photoLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você ultrapassou o limite de $_photoLimit imagens no portfólio.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final newWorker = Worker(
      id: DateTime.now().toString(),
      userId: userId,
      name: userService.name,
      profession: _professionController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      services: _servicesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      location: _locationController.text.trim(),
      whatsappNumber: userService.phone,
      portfolioImages: portfolioImages,
      isFeatured: false,
    );

    try {
      await Provider.of<WorkerService>(context, listen: false).addWorker(newWorker);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar profissional: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // === NOVO: Popular exemplos rápidos direto no Firebase ===
  Future<void> _populateExampleWorkers() async {
    setState(() => _isLoading = true);
    final userService = Provider.of<UserService>(context, listen: false);
    final workerService = Provider.of<WorkerService>(context, listen: false);
    final userId = userService.currentUserId;

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final examples = [
      Worker(
        id: (timestamp + 1).toString(),
        userId: userId,
        name: "Ana Maria",
        profession: "Eletricista",
        description: "Especialista em instalações elétricas residenciais.",
        imageUrl: "https://randomuser.me/api/portraits/women/21.jpg",
        services: ["Instalação elétrica", "Reparo de tomadas", "Iluminação"],
        location: "São Paulo",
        whatsappNumber: userService.phone,
        portfolioImages: [
          "https://picsum.photos/id/1011/400/300",
          "https://picsum.photos/id/1012/400/300",
        ],
        isFeatured: true,
        rating: 4.8,
      ),
      Worker(
        id: (timestamp + 2).toString(),
        userId: userId,
        name: "João Pedro",
        profession: "Pedreiro",
        description: "Construção civil e reformas com qualidade.",
        imageUrl: "https://randomuser.me/api/portraits/men/32.jpg",
        services: ["Reformas", "Alvenaria", "Pintura"],
        location: "Rio de Janeiro",
        whatsappNumber: userService.phone,
        portfolioImages: [
          "https://picsum.photos/id/1015/400/300",
          "https://picsum.photos/id/1016/400/300",
        ],
        rating: 4.5,
      ),
      Worker(
        id: (timestamp + 3).toString(),
        userId: userId,
        name: "Carla Souza",
        profession: "Faxineira",
        description: "Serviços de limpeza residencial e comercial.",
        imageUrl: "https://randomuser.me/api/portraits/women/44.jpg",
        services: ["Limpeza residencial", "Limpeza pós-obra", "Organização"],
        location: "Belo Horizonte",
        whatsappNumber: userService.phone,
        portfolioImages: [
          "https://picsum.photos/id/1021/400/300",
          "https://picsum.photos/id/1022/400/300",
        ],
        rating: 4.7,
      ),
      // Adicione mais exemplos aqui se quiser...
    ];

    try {
      for (var worker in examples) {
        await workerService.addWorker(worker);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exemplos adicionados com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar exemplos: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        enabled: enabled,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentCount = _portfolioControllers.length;

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
                _buildTextField(_nameController, 'Nome', enabled: false),
                _buildTextField(_professionController, 'Profissão'),
                _buildTextField(_descriptionController, 'Descrição', maxLines: 3),
                _buildTextField(
                  _imageUrlController,
                  'URL da Imagem (opcional)',
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !Uri.parse(value).isAbsolute) {
                      return 'Insira uma URL válida';
                    }
                    return null;
                  },
                ),
                _buildTextField(_servicesController, 'Serviços (separados por vírgula)'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TypeAheadFormField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Localização (cidade)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: theme.colorScheme.surface.withOpacity(0.05),
                      ),
                    ),
                    suggestionsCallback: (pattern) {
                      if (pattern.isEmpty) return const [];
                      return brazilCities.where((city) =>
                          city.toLowerCase().startsWith(pattern.toLowerCase()));
                    },
                    itemBuilder: (context, String suggestion) {
                      return ListTile(title: Text(suggestion));
                    },
                    onSuggestionSelected: (String suggestion) {
                      _locationController.text = suggestion;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, preencha a cidade';
                      }
                      if (!brazilCities.contains(value)) {
                        return 'Cidade inválida';
                      }
                      return null;
                    },
                  ),
                ),
                _buildTextField(
                  _whatsappController,
                  'Número do WhatsApp (ex: 11999999999)',
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, preencha este campo';
                    }
                    final regex = RegExp(r'^\d{10,11}$');
                    if (!regex.hasMatch(value)) {
                      return 'Número inválido. Use o DDD + número (ex: 11999999999)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text(
                  'Links do Portfólio (máximo $_photoLimit imagens)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: currentCount >= _photoLimit
                      ? null
                      : () {
                          setState(() {
                            _portfolioControllers.add(TextEditingController());
                          });
                        },
                  icon: const Icon(Icons.add),
                  label: Text(currentCount >= _photoLimit
                      ? 'Limite de imagens atingido'
                      : 'Adicionar imagem'),
                ),
                const SizedBox(height: 24),

                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
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
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _populateExampleWorkers,
                            icon: const Icon(Icons.cloud_download),
                            label: const Text('Adicionar exemplos automáticos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
