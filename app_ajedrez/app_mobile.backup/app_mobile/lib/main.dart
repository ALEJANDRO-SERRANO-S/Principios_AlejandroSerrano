import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- NUEVO: Para leer el token

import 'services/champion_service.dart';
import 'services/auth_service.dart'; // <-- NUEVO: Para poder cerrar sesión
import 'models/champion.dart';

import 'screens/champion_form_screen.dart';
import 'screens/champion_detail_screen.dart';
import 'screens/login_screen.dart'; // <-- NUEVO: Pantalla de inicio de sesión

void main() {
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  // --- NUEVO: Método que revisa si el usuario ya inició sesión ---
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return token != null; // Devuelve true si el token existe
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leyendas del Ajedrez',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
          primary: Colors.amber.shade300,
          secondary: Colors.amber.shade700,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      // --- NUEVO: FutureBuilder para proteger la entrada ---
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          // Mientras busca en la memoria, mostramos la ruedita de carga con tu fondo oscuro
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Si encontró el token, lo deja pasar a la lista. Si no, lo manda a Login.
          if (snapshot.data == true) {
            return const ChampionsListScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

class ChampionsListScreen extends StatefulWidget {
  const ChampionsListScreen({super.key});

  @override
  State<ChampionsListScreen> createState() => _ChampionsListScreenState();
}

class _ChampionsListScreenState extends State<ChampionsListScreen> {
  final ChampionService _service = ChampionService();
  late Future<List<Champion>> _futureChampions;

  @override
  void initState() {
    super.initState();
    _loadChampions();
  }

  void _loadChampions() {
    setState(() {
      _futureChampions = _service.getChampions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Maestros del Tablero',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        // --- NUEVO: Botón para Cerrar Sesión ---
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              // 1. Borramos el token usando nuestro AuthService
              await AuthService().logout();

              // 2. Lo regresamos al Login y borramos el historial para que no pueda volver con el botón Atrás
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Champion>>(
        future: _futureChampions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar datos:\n${snapshot.error}', textAlign: TextAlign.center),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay registros disponibles.'));
          }

          final champions = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: champions.length,
            itemBuilder: (context, index) {
              final champion = champions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChampionDetailScreen(champion: champion),
                      ),
                    );

                    // Si se eliminó el registro (result == true), recargamos la lista
                    if (result == true) {
                      _loadChampions();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            champion.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(width: 80, height: 80, color: Colors.grey, child: const Icon(Icons.person)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                champion.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'País: ${champion.representedCountry} | Período: ${champion.period}',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                champion.bio,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChampionFormScreen()),
          );

          if (result == true) {
            _loadChampions();
          }
        },
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }
}