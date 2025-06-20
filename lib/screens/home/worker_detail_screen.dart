import 'package:appservico/screens/profile/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/worker_model.dart';
import '../../models/review_model.dart';
import '../../services/worker_service.dart';

class WorkerDetailScreen extends StatelessWidget {
  final Worker worker;

  const WorkerDetailScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(worker.name),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(worker.imageUrl),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                worker.profession,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(worker.rating.toStringAsFixed(1), style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              context,
              title: 'Descrição',
              child: Text(worker.description, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context,
              title: 'Serviços oferecidos',
              child: Column(
                children: worker.services
                    .map((s) => ListTile(
                          leading: const Icon(Icons.check_circle_outline),
                          title: Text(s),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 4),
                Text(worker.location, style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(),
            Text('Avaliações', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...worker.reviews.map((review) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(review.author),
                    subtitle: Text(review.comment),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        review.rating,
                        (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 20),
            Text('Deixe sua avaliação', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _ReviewForm(workerId: worker.id),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required Widget child}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _ReviewForm extends StatefulWidget {
  final String workerId;

  const _ReviewForm({required this.workerId});

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserService>(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            value: _rating,
            decoration: const InputDecoration(labelText: 'Nota'),
            items: List.generate(5, (index) => index + 1)
                .map((value) => DropdownMenuItem(value: value, child: Text('$value estrela${value > 1 ? 's' : ''}')))
                .toList(),
            onChanged: (value) {
              setState(() {
                _rating = value ?? 5;
              });
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: 'Comentário'),
            maxLines: 2,
            validator: (value) => value == null || value.isEmpty ? 'Digite um comentário' : null,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final review = Review(
                  author: user.name,
                  comment: _commentController.text,
                  rating: _rating,
                  date: DateTime.now(),
                );
                Provider.of<WorkerService>(context, listen: false).addReview(widget.workerId, review);
                _commentController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Avaliação enviada com sucesso!')),
                );
              }
            },
            child: const Text('Enviar Avaliação'),
          ),
        ],
      ),
    );
  }
}
