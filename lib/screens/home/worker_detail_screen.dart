import 'package:appservico/screens/profile/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/worker_model.dart';
import '../../models/review_model.dart';
import '../../services/worker_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WorkerDetailScreen extends StatelessWidget {
  final Worker worker;

  const WorkerDetailScreen({super.key, required this.worker});

  void abrirWhatsApp(String numero) async {
    final url = 'https://wa.me/$numero?text=Olá,%20vim%20pelo%20app%20ServiçoJá!';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  static BuildContext? _scaffoldContext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _scaffoldContext = context;

    return Scaffold(
      appBar: AppBar(
        title: Text(worker.name),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(worker.imageUrl),
                onBackgroundImageError: (_, __) => const Icon(Icons.person, size: 70),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                worker.profession,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 6),
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
            const SizedBox(height: 24),

            // Descrição
            _buildSectionCard(
              context,
              title: 'Descrição',
              child: Text(
                worker.description.isNotEmpty ? worker.description : 'Sem descrição.',
                style: theme.textTheme.bodyMedium,
              ),
            ),

            const SizedBox(height: 20),

            // Serviços
            _buildSectionCard(
              context,
              title: 'Serviços oferecidos',
              child: worker.services.isNotEmpty
                  ? Column(
                      children: worker.services
                          .map(
                            (service) => ListTile(
                              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                              title: Text(service),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          )
                          .toList(),
                    )
                  : Text('Nenhum serviço listado.', style: theme.textTheme.bodyMedium),
            ),

            const SizedBox(height: 20),

            // Portfólio com clique para tela cheia
            if (worker.portfolioImages.isNotEmpty)
              _buildSectionCard(
                context,
                title: 'Portfólio',
                child: SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: worker.portfolioImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final imgUrl = worker.portfolioImages[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar: AppBar(backgroundColor: Colors.black),
                              backgroundColor: Colors.black,
                              body: Center(
                                child: InteractiveViewer(
                                  child: Image.network(imgUrl, fit: BoxFit.contain),
                                ),
                              ),
                            ),
                          ));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imgUrl,
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              width: 140,
                              height: 140,
                              child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Localização
            _buildSectionCard(
              context,
              title: 'Localização',
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Flexible(child: Text(worker.location, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botão WhatsApp
            Center(
              child: ElevatedButton.icon(
                onPressed: () => abrirWhatsApp(worker.whatsappNumber),
                icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                label: const Text('Conversar no WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),

            const SizedBox(height: 36),

            const Divider(),

            Text('Avaliações', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Consumer<WorkerService>(
              builder: (context, workerService, _) {
                final reviews = workerService.getReviews(worker.id);

                if (reviews.isEmpty) {
                  return const Text('Nenhuma avaliação ainda.', style: TextStyle(color: Colors.grey));
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(review.author, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(review.comment),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            review.rating,
                            (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            Text('Deixe sua avaliação', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _ReviewForm(workerId: worker.id),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required Widget child}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          child,
        ]),
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
  bool _sending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserService>(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int>(
            value: _rating,
            decoration: const InputDecoration(
              labelText: 'Nota',
              border: OutlineInputBorder(),
            ),
            items: List.generate(5, (i) => i + 1)
                .map(
                  (val) => DropdownMenuItem(
                    value: val,
                    child: Text('$val estrela${val > 1 ? 's' : ''}'),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => _rating = val ?? 5),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Comentário',
              border: OutlineInputBorder(),
            ),
            validator: (val) => (val == null || val.isEmpty) ? 'Digite um comentário' : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _sending
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _sending = true);
                      try {
                        if (widget.workerId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Erro: ID do trabalhador inválido.')),
                          );
                          return;
                        }

                        final review = Review(
                          author: user.name,
                          workerId: widget.workerId,
                          comment: _commentController.text.trim(),
                          rating: _rating,
                          date: DateTime.now(),
                        );

                        await Provider.of<WorkerService>(context, listen: false).addReview(widget.workerId, review);

                        _commentController.clear();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Avaliação enviada com sucesso!')),
                        );
                      } finally {
                        setState(() => _sending = false);
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _sending
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Enviar Avaliação'),
          ),
        ],
      ),
    );
  }
}
