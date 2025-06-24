import 'dart:io';
import 'package:appservico/screens/profile/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _email;
  late String _phone;

  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserService>(context, listen: false);
    _name = user.name;
    _email = user.email;
    _phone = user.phone;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userService = Provider.of<UserService>(context, listen: false);

      try {
        // Se selecionou uma nova foto, faz o upload
        if (_profileImageFile != null) {
          // Faz o upload da foto no Firebase Storage e atualiza a URL no Firestore e UserService
          await userService.uploadProfilePhotoFromFile(_profileImageFile!);
        }

        // Atualiza os outros dados
        await userService.updateProfile(
          newName: _name,
          newEmail: _email,
          newPhone: _phone,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImageFile != null
                        ? FileImage(_profileImageFile!)
                        : (userService.photoUrl.isNotEmpty
                            ? NetworkImage(userService.photoUrl)
                            : const AssetImage('assets/images/default_avatar.png'))
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      onSaved: (value) => _name = value ?? '',
                      validator: (value) => value!.isEmpty ? 'Informe seu nome' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _email,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      onSaved: (value) => _email = value ?? '',
                      validator: (value) => value!.contains('@') ? null : 'E-mail inválido',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _phone,
                      decoration: const InputDecoration(labelText: 'Telefone'),
                      onSaved: (value) => _phone = value ?? '',
                      validator: (value) => value!.length < 10 ? 'Telefone inválido' : null,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
