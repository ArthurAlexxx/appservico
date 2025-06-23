import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/subscription_service.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscription = Provider.of<SubscriptionService>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planos de Assinatura'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPlanCard(
              context,
              title: 'Grátis',
              price: 'R\$ 0,00/mês',
              features: [
                'Acesso limitado a profissionais',
                'Visualização de avaliações',
              ],
              selected: subscription.currentPlan == 'free',
              onTap: () {
                subscription.updatePlan('free');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              context,
              title: 'Profissional',
              price: 'R\$ 19,90/mês',
              features: [
                'Acesso completo a profissionais',
                'Contato direto via WhatsApp',
                'Suporte prioritário',
              ],
              selected: subscription.currentPlan == 'pro',
              onTap: () {
                subscription.updatePlan('pro');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              context,
              title: 'Premium',
              price: 'R\$ 39,90/mês',
              features: [
                'Todos os benefícios do plano Profissional',
                'Destaque nos resultados',
                'Selo de verificado automático',
              ],
              selected: subscription.currentPlan == 'premium',
              onTap: () {
                subscription.updatePlan('premium');
                Navigator.pop(context);
              },
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
                  children: [
                    const Icon(Icons.check, size: 18, color: Colors.green),
                    const SizedBox(width: 6),
                    Expanded(child: Text(f)),
                  ],
                )),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: onTap,
                child: const Text('Selecionar plano'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
