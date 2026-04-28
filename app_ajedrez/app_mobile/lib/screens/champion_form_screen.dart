import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/entities/entities.dart';
import '../presentation/providers/champions_provider.dart';

class ChampionFormScreen extends StatefulWidget {
  const ChampionFormScreen({super.key});

  @override
  State<ChampionFormScreen> createState() => _ChampionFormScreenState();
}

class _ChampionFormScreenState extends State<ChampionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar el texto de los campos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthCountryController = TextEditingController();
  final TextEditingController _representedCountryController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _birthCountryController.dispose();
    _representedCountryController.dispose();
    _ageController.dispose();
    _periodController.dispose();
    _imageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveChampion(ChampionProvider championProvider) async {
    if (_formKey.currentState!.validate()) {
      final newChampion = ChampionEntity(
        name: _nameController.text,
        birthCountry: _birthCountryController.text,
        representedCountry: _representedCountryController.text,
        ageAtFirstWin: int.tryParse(_ageController.text) ?? 0,
        period: _periodController.text,
        imageUrl: _imageController.text,
        bio: _bioController.text,
      );

      bool success = await championProvider.addChampion(newChampion);

      if (success && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${championProvider.errorMessage}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChampionProvider>(
      builder: (context, championProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Nuevo Campeón'),
          ),
          body: championProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(_nameController, 'Nombre'),
                        _buildTextField(_birthCountryController, 'País de Nacimiento'),
                        _buildTextField(_representedCountryController, 'País Representado'),
                        _buildTextField(_ageController, 'Edad al ganar (número)', isNumber: true),
                        _buildTextField(_periodController, 'Período (ej. 1985-2000)'),
                        _buildTextField(_imageController, 'URL de la imagen (Cloudinary)'),
                        _buildTextField(_bioController, 'Biografía', maxLines: 3),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _saveChampion(championProvider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.black87,
                            ),
                            child: const Text('Guardar Registro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }
}
