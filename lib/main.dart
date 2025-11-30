import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

// Data
import 'data/datasources/game_local_datasource.dart';
import 'data/repositories/game_repository_impl.dart';

// Domain
import 'domain/usecases/start_game.dart';
import 'domain/usecases/make_bid.dart';
import 'domain/usecases/play_card.dart';
import 'domain/usecases/get_bot_move.dart';
import 'domain/usecases/clear_trick.dart';

// Core
import 'core/theme/theme_provider.dart';
import 'core/audio/audio_service.dart';

// Presentation
import 'presentation/bloc/game_bloc.dart';
import 'presentation/pages/home_page.dart';

// Point d'entrée principal de l'application
void main() async {
  // S'assurer que Flutter est initialisé avant les opérations asynchrones
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser le service audio pour la musique de fond et les effets sonores
  await AudioService().init();

  // Couche de données: source locale pour la persistance du jeu
  final localDataSource = GameLocalDataSource();

  // Couche repository: implémentation du dépôt de jeu
  final gameRepository = GameRepositoryImpl(localDataSource);

  // Use cases: cas d'utilisation métier de l'application
  final startGame = StartGame(gameRepository); // Démarrer une nouvelle partie
  final makeBid = MakeBid(gameRepository); // Placer une mise
  final playCard = PlayCard(gameRepository); // Jouer une carte
  final getBotMove = GetBotMove(gameRepository); // Calculer le coup du bot
  final clearTrick = ClearTrick(gameRepository); // Nettoyer le pli terminé

  runApp(
    // Configuration des providers globaux de l'application
    MultiProvider(
      providers: [
        // Provider pour la gestion du thème clair/sombre
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // BLoC pour la gestion de l'état du jeu
        BlocProvider(
          create: (_) => GameBloc(
            startGame: startGame,
            makeBid: makeBid,
            playCard: playCard,
            getBotMove: getBotMove,
            clearTrick: clearTrick,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

// Widget racine de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consommer le ThemeProvider pour réagir aux changements de thème
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Tarot Africain',
          theme: themeProvider.currentTheme, // Thème dynamique (clair/sombre)
          home: SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// Écran de chargement affiché au démarrage de l'application
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // Navigation automatique vers la page d'accueil après 2 secondes
  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));

    // Vérifier que le widget est toujours monté avant de naviguer
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[800]!, Colors.green[600]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou image
              Container(
                width: 120,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/cards/excuse.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white,
                        child: const Icon(
                          Icons.style,
                          size: 80,
                          color: Colors.green,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Tarot Africain',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Chargement...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
