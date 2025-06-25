import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final _servicesController = TextEditingController();
  final _locationController = TextEditingController();
  final _whatsappController = TextEditingController();

  File? _selectedImage;
  String? _uploadedImageUrl;

  List<File> _portfolioImages = [];
  List<String> _uploadedPortfolioUrls = [];

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
    _updatePhotoLimit(_subscriptionService.currentPlan);
    _subscriptionService.addListener(_subscriptionListener);
  }

  void _subscriptionListener() {
    _updatePhotoLimit(_subscriptionService.currentPlan);
  }

  void _updatePhotoLimit(String plan) {
    int newLimit = plan == 'pro' ? 15 : plan == 'premium' ? 999 : 5;
    if (_photoLimit != newLimit) {
      setState(() => _photoLimit = newLimit);
    }
  }

  @override
  void dispose() {
    _subscriptionService.removeListener(_subscriptionListener);
    _nameController.dispose();
    _professionController.dispose();
    _descriptionController.dispose();
    _servicesController.dispose();
    _locationController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _selectedImage = File(pickedFile.path));

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child('workers/$fileName');

    try {
      await ref.putFile(_selectedImage!);
      final url = await ref.getDownloadURL();
      setState(() => _uploadedImageUrl = url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagem enviada com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar imagem: $e')),
      );
    }
  }

  Future<void> _pickPortfolioImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isEmpty) return;

    if ((_portfolioImages.length + pickedFiles.length) > _photoLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você pode enviar até $_photoLimit imagens.')),
      );
      return;
    }

    setState(() {
      _portfolioImages.addAll(pickedFiles.map((e) => File(e.path)));
    });
  }

  Future<void> _uploadPortfolioImages() async {
    _uploadedPortfolioUrls.clear();

    for (var image in _portfolioImages) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
      final ref = FirebaseStorage.instance.ref().child('portfolio/$fileName');

      try {
        await ref.putFile(image);
        final url = await ref.getDownloadURL();
        _uploadedPortfolioUrls.add(url);
      } catch (e) {
        throw Exception('Erro ao enviar imagem do portfólio: $e');
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, envie uma imagem de perfil.')),
      );
      return;
    }

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

    try {
      await _uploadPortfolioImages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
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
      imageUrl: _uploadedImageUrl!,
      services: _servicesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      location: _locationController.text.trim(),
      whatsappNumber: userService.phone,
      portfolioImages: _uploadedPortfolioUrls,
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

                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Imagem de perfil',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                _selectedImage != null
                    ? Image.file(_selectedImage!, height: 120)
                    : const Text('Nenhuma imagem selecionada.'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _pickAndUploadImage,
                  icon: const Icon(Icons.upload),
                  label: const Text('Selecionar imagem'),
                ),

                _buildTextField(_servicesController, 'Serviços (separados por vírgula)'),
                _buildTextField(_locationController, 'Localização (cidade)'),
                _buildTextField(
                  _whatsappController,
                  'Número do WhatsApp (ex: 11999999999)',
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Preencha o número';
                    if (!RegExp(r'^\d{10,11}$').hasMatch(value)) {
                      return 'Número inválido. Use o DDD + número';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                Text(
                  'Imagens do Portfólio (máximo $_photoLimit)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _portfolioImages
                      .map((img) => Image.file(img, height: 100, width: 100, fit: BoxFit.cover))
                      .toList(),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _portfolioImages.length >= _photoLimit
                      ? null
                      : _pickPortfolioImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(_portfolioImages.length >= _photoLimit
                      ? 'Limite atingido'
                      : 'Selecionar imagens'),
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
