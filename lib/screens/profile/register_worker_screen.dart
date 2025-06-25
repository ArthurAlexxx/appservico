import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  int _photoLimit = 5; 

  late final SubscriptionService _subscriptionService;

  @override
  void initState() {
    super.initState();

    final userService = Provider.of<UserService>(context, listen: false);
    _nameController.text = userService.name;
    _whatsappController.text = userService.phone;

    _subscriptionService = Provider.of<SubscriptionService>(context, listen: false);

    // Inicializa o limite conforme plano atual
    _updatePhotoLimit(_subscriptionService.currentPlan);

    // Escuta mudanças do plano para atualizar limite
    _subscriptionService.addListener(_subscriptionListener);
  }

  void _subscriptionListener() {
    _updatePhotoLimit(_subscriptionService.currentPlan);
  }

  void _updatePhotoLimit(String plan) {
    int newLimit = 5;
    if (plan == 'free') {
      newLimit = 5;
    } else if (plan == 'pro') {
      newLimit = 15;
    } else if (plan == 'premium') {
      newLimit = 999;
    }

    if (_photoLimit != newLimit) {
      setState(() {
        _photoLimit = newLimit;
      });
    }
  }

  @override
  void dispose() {
    _subscriptionService.removeListener(_subscriptionListener);

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
        validator: validator ?? (value) {
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
                _buildTextField(_locationController, 'Localização (cidade)'),
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
                    : ElevatedButton.icon(
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
}
