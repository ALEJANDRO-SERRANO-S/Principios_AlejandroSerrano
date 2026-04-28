import 'package:flutter/material.dart';
import '../models/champion.dart';
import '../services/champion_service.dart';
import 'image_view_screen.dart';

class ChampionDetailScreen extends StatelessWidget {
  final Champion champion;
  final ChampionService _service = ChampionService();

  ChampionDetailScreen({super.key, required this.champion});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Está seguro de que desea eliminar a ${champion.name}? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Cierra el diálogo
                try {
                  await _service.deleteChampion(champion.id!);
                  if (context.mounted) {
                    Navigator.pop(context, true); // Regresa a la lista indicando éxito
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageTag = 'image_${champion.id}';

    return Scaffold(
      appBar: AppBar(
        title: Text(champion.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context),
            tooltip: 'Eliminar registro',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageViewScreen(imageUrl: champion.imageUrl, tag: imageTag),
                  ),
                );
              },
              child: Hero(
                tag: imageTag,
                child: Image.network(
                  champion.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300,
                    color: Colors.grey.shade900,
                    child: const Icon(Icons.image_not_supported, size: 100),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    champion.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Período de reinado: ${champion.period}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Divider(height: 32),
                  _buildInfoRow(Icons.flag, 'País de origen', champion.birthCountry),
                  _buildInfoRow(Icons.public, 'País representado', champion.representedCountry),
                  _buildInfoRow(Icons.cake, 'Edad al primer título', '${champion.ageAtFirstWin} años'),
                  const SizedBox(height: 24),
                  const Text(
                    'Biografía completa',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    champion.bio,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
