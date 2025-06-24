import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/subscription_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;

  Future<void> _selectPlan(
      BuildContext context, String userId, String plan) async {
    setState(() => _isLoading = true);

    try {
      final subscription = Provider.of<SubscriptionService>(context, listen: false);
      await subscription.updatePlan(userId, plan);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plano "$plan" selecionado com sucesso!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar plano: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? '';
    final subscription = Provider.of<SubscriptionService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planos de Assinatura'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildPlanCard(
                    context,
                    title: 'Grátis',
                    price: 'R\$ 0,00/mês',
                    features: [
                      'Acesso básico a profissionais',
                      'Visualização de avaliações',
                      'Limite de até 5 fotos no portfólio',
                      'Sem selo de verificação',
                      'Sem destaque nos resultados',
                    ],
                    selected: subscription.currentPlan == 'free',
                    onTap: () => _selectPlan(context, userId, 'free'),
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    context,
                    title: 'Profissional',
                    price: 'R\$ 19,90/mês',
                    features: [
                      'Acesso completo a profissionais',
                      'Visualização de avaliações',
                      'Limite de até 15 fotos no portfólio',
                      'Selo de verificação',
                      'Destaque nos resultados',
                    ],
                    selected: subscription.currentPlan == 'pro',
                    onTap: () => _selectPlan(context, userId, 'pro'),
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    context,
                    title: 'Premium',
                    price: 'R\$ 39,90/mês',
                    features: [
                      'Todos os benefícios do plano Profissional',
                      'Fotos ilimitadas no portfólio',
                      'Selo de verificação',
                      'Destaque garantido nos resultados',
                    ],
                    selected: subscription.currentPlan == 'premium',
                    onTap: () => _selectPlan(context, userId, 'premium'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required List<String> features,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: selected ? 6 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: selected ? theme.colorScheme.primary.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selected)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Selecionado',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(price, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...features.map((f) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, size: 18, color: Colors.green),
                    const SizedBox(width: 6),
                    Expanded(child: Text(f)),
                  ],
                )),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: selected ? null : onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Selecionar plano'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
