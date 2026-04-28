import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/service_locator.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/champions_provider.dart';
import 'screens/champion_form_screen.dart';
import 'screens/champion_detail_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  // Inicializar Service Locator e inyección de dependencias
  await ServiceLocator.setupServiceLocator();
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChampionProvider()),
      ],
      child: MaterialApp(
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
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Widget que envuelve la autenticación
/// Cumple con SRP: solo decide qué screen mostrar según estado de auth
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.state == AuthState.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.isAuthenticated) {
          return const ChampionsListScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class ChampionsListScreen extends StatefulWidget {
  const ChampionsListScreen({super.key});

  @override
  State<ChampionsListScreen> createState() => _ChampionsListScreenState();
}

class _ChampionsListScreenState extends State<ChampionsListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar campeones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChampionProvider>().loadChampions();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
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
      body: Consumer<ChampionProvider>(
        builder: (context, championProvider, _) {
          if (championProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (championProvider.state == ChampionLoadState.error) {
            return Center(
              child: Text(
                'Error: ${championProvider.errorMessage}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (championProvider.isEmpty) {
            return const Center(child: Text('No hay registros disponibles.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: championProvider.count,
            itemBuilder: (context, index) {
              final champion = championProvider.champions[index];
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

                    if (result == true && context.mounted) {
                      await context.read<ChampionProvider>().loadChampions();
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

          if (result == true && context.mounted) {
            await context.read<ChampionProvider>().loadChampions();
          }
        },
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }
}