import 'package:appservico/screens/profile/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/subscription_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _currentPlan;
  late final SubscriptionService _subscriptionService;

  @override
  void initState() {
    super.initState();

    _subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
    _currentPlan = _subscriptionService.currentPlan;

    // Escuta mudanças do plano para atualizar a UI
    _subscriptionService.addListener(_subscriptionListener);
  }

  void _subscriptionListener() {
    if (mounted) {
      setState(() {
        _currentPlan = _subscriptionService.currentPlan;
      });
    }
  }

  @override
  void dispose() {
    _subscriptionService.removeListener(_subscriptionListener);
    super.dispose();
  }

  Future<void> _selectPlan(BuildContext context, String plan) async {
    final userService = Provider.of<UserService>(context, listen: false);
    final userId = userService.currentUserId;

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
      return;
    }

    try {
      await _subscriptionService.updatePlan(userId, plan);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plano "$plan" selecionado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar plano: $e')),
      );
    }
  }

  Widget _buildPlanCard(BuildContext context,
      {required String title,
      required String price,
      required String description,
      required Color color}) {
    final theme = Theme.of(context);
    final isSelected = _currentPlan == title.toLowerCase();

    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Text(price,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Text(description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSelected
                    ? null
                    : () {
                        _selectPlan(context, title.toLowerCase());
                      },
                // Sem alteração na cor do botão para manter o estilo padrão do Flutter
                child: Text(isSelected ? 'Selecionado' : 'Selecionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planos de Assinatura'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Escolha o plano ideal para você:',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              _buildPlanCard(
                context,
                title: 'Free',
                price: 'R\$ 0,00',
                description: 'Até 5 imagens no portfólio.',
                color: Colors.grey[300]!,
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                context,
                title: 'Pro',
                price: 'R\$ 29,90/mês',
                description: 'Até 15 imagens no portfólio.\nDestaque nos resultados.',
                color: Colors.blue[100]!,
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                context,
                title: 'Premium',
                price: 'R\$ 59,90/mês',
                description: 'Portfólio ilimitado.\nPrioridade máxima.',
                color: Colors.amber[100]!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
