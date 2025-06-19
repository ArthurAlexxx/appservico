import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _emailController = TextEditingController(text: 'teste@email.com');
    final _passwordController = TextEditingController(text: 'senha123');
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ServiçoJá',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Encontre os melhores profissionais',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
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
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Entrar',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final authService = Provider.of<AuthService>(context, listen: false);
                    await authService.signInWithEmailAndPassword(
                      _emailController.text,
                      _passwordController.text,
                    );
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text('Não tem conta? Registre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}