import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String accountType = 'user';

  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _register(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.registerWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
        nameController.text.trim(),
        phoneController.text.trim(),
        accountType,
      );
      // Limpar campos após sucesso
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      phoneController.clear();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      final errorMsg = _parseError(e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao registrar. Tente novamente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email já cadastrado.';
      case 'weak-password':
        return 'Senha fraca. Use no mínimo 6 caracteres.';
      case 'invalid-email':
        return 'Email inválido.';
      default:
        return 'Erro ao registrar. Tente novamente.';
    }
  }

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
                                value == null || value.isEmpty ? 'Insira seu nome' : null, suffixIcon: null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: emailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Insira seu email';
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value)) return 'Email inválido';
                              return null;
                            }, suffixIcon: null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: passwordController,
                            label: 'Senha',
                            obscureText: !_showPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword ? Icons.visibility_off : Icons.visibility,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                            validator: (value) => value == null || value.length < 6
                                ? 'Senha deve ter no mínimo 6 caracteres'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: phoneController,
                            label: 'Telefone',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Insira o telefone';
                              // Validação simples de telefone: só números e 10-11 dígitos
                              final phoneRegex = RegExp(r'^\d{10,11}$');
                              if (!phoneRegex.hasMatch(value)) return 'Telefone inválido';
                              return null;
                            }, suffixIcon: null,
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
                          _isLoading
                              ? const CircularProgressIndicator()
                              : CustomButton(
                                  text: 'Registrar',
                                  onPressed: () => _register(context),
                                ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _isLoading ? null : () => Navigator.pop(context),
                            child: Text(
                              'Já tem conta? Faça login',
                              style: TextStyle(color: theme.colorScheme.primary),
                            ),
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
