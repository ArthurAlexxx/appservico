import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  String accountType = 'user'; // padrão

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Text(
                  'ServiçoJá',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crie sua conta para começar',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: nameController,
                            label: 'Nome Completo',
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Insira seu nome' : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: emailController,
                            label: 'Email',
                            validator: (value) => value == null || value.isEmpty
                                ? 'Insira seu email'
                                : (!value.contains('@') ? 'Email inválido' : null),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: passwordController,
                            label: 'Senha',
                            obscureText: true,
                            validator: (value) =>
                                value == null || value.length < 6
                                    ? 'Senha deve ter no mínimo 6 caracteres'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: phoneController,
                            label: 'Telefone',
                            keyboardType: TextInputType.phone,
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Insira o telefone' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: accountType,
                            items: const [
                              DropdownMenuItem(value: 'user', child: Text('Usuário Comum')),
                              DropdownMenuItem(value: 'worker', child: Text('Profissional')),
                            ],
                            onChanged: (value) => setState(() => accountType = value!),
                            decoration: const InputDecoration(
                              labelText: 'Tipo de Conta',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Registrar',
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final authService =
                                    Provider.of<AuthService>(context, listen: false);
                                try {
                                  await authService.registerWithEmailAndPassword(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                    nameController.text.trim(),
                                    phoneController.text.trim(),
                                    accountType,
                                  );
                                  Navigator.pushReplacementNamed(context, '/home');
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Já tem conta? Faça login',
                                style: TextStyle(color: theme.colorScheme.primary)),
                          ),
                        ],
                      ),
                    ),
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
