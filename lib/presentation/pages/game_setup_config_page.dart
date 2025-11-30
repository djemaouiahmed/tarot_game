import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../core/constants/game_config.dart';
import '../../core/theme/theme_provider.dart';
import '../../domain/entities/bot_difficulty.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import 'game_page.dart';

class GameSetupConfigPage extends StatefulWidget {
  final int numberOfPlayers;

  const GameSetupConfigPage({super.key, required this.numberOfPlayers});

  @override
  State<GameSetupConfigPage> createState() => _GameSetupConfigPageState();
}

class _GameSetupConfigPageState extends State<GameSetupConfigPage> {
  late GameConfig _config;
  BotDifficulty _difficulty = BotDifficulty.easy;

  @override
  void initState() {
    super.initState();
    _config = GameConfig(
      numberOfPlayers: widget.numberOfPlayers,
      teamAssignments: List.filled(widget.numberOfPlayers, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: themeProvider.backgroundGradient,
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Configuration options
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nombre de vies
                      _buildLivesSection(),
                      const SizedBox(height: 24),

                      // Nombre de cartes initiales
                      _buildInitialCardsSection(),
                      const SizedBox(height: 24),

                      // Mode équipes (seulement pour 4 joueurs)
                      if (widget.numberOfPlayers == 4) ...[
                        _buildTeamsSection(),
                        const SizedBox(height: 24),
                      ],

                      // Difficulté
                      _buildDifficultySection(),
                      const SizedBox(height: 24),

                      // Mode sombre
                      _buildDarkModeSection(),
                      const SizedBox(height: 24),

                      // Effets sonores
                      _buildSoundSection(),
                      const SizedBox(height: 40),

                      // Bouton Démarrer
                      _buildStartButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade800.withOpacity(0.9),
            Colors.deepPurple.shade900.withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configuration',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${widget.numberOfPlayers} Joueurs',
                  style: TextStyle(fontSize: 16, color: Colors.amber.shade300),
                ),
              ],
            ),
          ),
          Icon(Icons.settings, color: Colors.amber.shade300, size: 32),
        ],
      ),
    );
  }

  Widget _buildLivesSection() {
    return _buildConfigCard(
      title: '❤️ Nombre de vies',
      subtitle: 'Définir le point de départ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: GameConfig.lifeOptions.map((lives) {
              final isSelected = _config.startingLives == lives;
              return ChoiceChip(
                label: Text(
                  GameConfig.getLifeLabel(lives),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _config = _config.copyWith(startingLives: lives);
                    });
                  }
                },
                selectedColor: Colors.amber.shade700,
                backgroundColor: Colors.deepPurple.shade700.withOpacity(0.5),
                side: BorderSide(
                  color: isSelected
                      ? Colors.amber.shade400
                      : Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialCardsSection() {
    return _buildConfigCard(
      title: '🃏 Cartes par Tour',
      subtitle: 'Nombre de cartes au premier tour',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: GameConfig.initialCardsOptions.map((cards) {
              final isSelected = _config.initialCards == cards;
              return ChoiceChip(
                label: Text(
                  GameConfig.getInitialCardsLabel(cards),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _config = _config.copyWith(initialCards: cards);
                    });
                  }
                },
                selectedColor: Colors.amber.shade700,
                backgroundColor: Colors.deepPurple.shade700.withOpacity(0.5),
                side: BorderSide(
                  color: isSelected
                      ? Colors.amber.shade400
                      : Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsSection() {
    return _buildConfigCard(
      title: '👥 Mode Équipes',
      subtitle: 'Jouer en équipe de 2 vs 2',
      child: Column(
        children: [
          SwitchListTile(
            value: _config.teamsEnabled,
            onChanged: (value) {
              setState(() {
                if (value) {
                  // Équipe 1: joueurs 0 et 2, Équipe 2: joueurs 1 et 3
                  _config = _config.copyWith(
                    teamsEnabled: true,
                    teamAssignments: [1, 2, 1, 2],
                  );
                } else {
                  _config = _config.copyWith(
                    teamsEnabled: false,
                    teamAssignments: [0, 0, 0, 0],
                  );
                }
              });
            },
            title: Text(
              _config.teamsEnabled ? 'Activé' : 'Désactivé',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: _config.teamsEnabled
                ? const Text(
                    'Vous + Bot 2 VS Bot 1 + Bot 3',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  )
                : null,
            activeColor: Colors.amber,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySection() {
    return _buildConfigCard(
      title: '🎯 Difficulté des Bots',
      subtitle: 'Niveau de l\'intelligence artificielle',
      child: Column(
        children: [
          const SizedBox(height: 12),
          RadioListTile<BotDifficulty>(
            value: BotDifficulty.easy,
            groupValue: _difficulty,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _difficulty = value;
                });
              }
            },
            title: Text(
              'Facile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: _difficulty == BotDifficulty.easy
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            subtitle: const Text(
              'Pour les débutants',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            activeColor: Colors.amber,
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<BotDifficulty>(
            value: BotDifficulty.hard,
            groupValue: _difficulty,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _difficulty = value;
                });
              }
            },
            title: Text(
              'Difficile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: _difficulty == BotDifficulty.hard
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            subtitle: const Text(
              'Pour les experts',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            activeColor: Colors.amber,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeSection() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return _buildConfigCard(
      title: '🌙 Mode Sombre',
      subtitle: 'Apparence de l\'application',
      child: SwitchListTile(
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme();
          setState(() {
            _config = _config.copyWith(darkMode: value);
          });
        },
        title: Text(
          themeProvider.isDarkMode ? 'Activé' : 'Désactivé',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        activeColor: Colors.amber,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSoundSection() {
    return _buildConfigCard(
      title: '🔊 Effets Sonores',
      subtitle: 'Sons du jeu',
      child: SwitchListTile(
        value: _config.soundEnabled,
        onChanged: (value) {
          setState(() {
            _config = _config.copyWith(soundEnabled: value);
          });
        },
        title: Text(
          _config.soundEnabled ? 'Activé' : 'Désactivé',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        activeColor: Colors.amber,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildConfigCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade800.withOpacity(0.7),
            Colors.deepPurple.shade900.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade700.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _startGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 70),
            alignment: Alignment.center,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded, size: 36, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'DÉMARRER LA PARTIE',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startGame() {
    final gameBloc = context.read<GameBloc>();

    // Passer la configuration au GameBloc
    gameBloc.add(
      StartGameEvent(
        widget.numberOfPlayers,
        difficulty: _difficulty,
        initialCards: _config.initialCards,
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BlocProvider<GameBloc>.value(
          value: gameBloc,
          child: const GamePage(),
        ),
      ),
    );
  }
}
