import 'package:appservico/screens/profile/user_service.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserService>(context, listen: false);
    _name = user.name;
    _email = user.email;
    _phone = user.phone;
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Provider.of<UserService>(context, listen: false).updateProfile(
        newName: _name,
        newEmail: _email,
        newPhone: _phone,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
