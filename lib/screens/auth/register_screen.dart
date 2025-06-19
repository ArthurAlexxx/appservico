import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _phoneController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'Nome Completo',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha';
                    }
                    if (value.length < 6) {
                      return 'Senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Telefone',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu telefone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Registrar',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final authService = Provider.of<AuthService>(context, listen: false);
                      await authService.registerWithEmailAndPassword(
                        _nameController.text,
                        _emailController.text,
                        _passwordController.text,
                        _phoneController.text,
                      );
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}