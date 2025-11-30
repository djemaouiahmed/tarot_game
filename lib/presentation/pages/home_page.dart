import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/bot_difficulty.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/audio/audio_service.dart';
import '../../core/utils/responsive_utils.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import 'game_page.dart';
import 'game_setup_config_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Start background music (désactivé car fichier MP3 manquant)
    AudioService().playBackgroundMusic();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ui/background.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Dark overlay with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeProvider.backgroundGradient
                      .map((c) => c.withOpacity(0.7))
                      .toList(),
                ),
              ),
            ),

            // Floating particles (heavily optimized)
            ...List.generate(3, (index) {
              final radius = 0.4 + (index % 3) * 0.1;
              return Positioned(
                left:
                    MediaQuery.of(context).size.width *
                    (0.5 + radius * (index % 2 == 0 ? 1 : -1) * (index / 3)),
                top:
                    MediaQuery.of(context).size.height *
                    (0.2 +
                        radius * (index % 3 == 0 ? 1 : -1) * ((3 - index) / 3)),
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity:
                            0.12 *
                            _glowAnimation.value *
                            ((index % 2 == 0) ? 1 : 0.7),
                        child: Container(
                          width: 70 + (index % 3) * 20,
                          height: 70 + (index % 3) * 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                index % 3 == 0
                                    ? Colors.amber.withOpacity(0.6)
                                    : (index % 3 == 1
                                          ? Colors.cyanAccent.withOpacity(0.5)
                                          : Colors.deepPurple.withOpacity(0.5)),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),

            // Main content
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo avec effet de brillance (responsive)
                          Container(
                            width: ResponsiveUtils.responsiveSize(context, 140),
                            height: ResponsiveUtils.responsiveSize(
                              context,
                              220,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.5),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/cards/excuse.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.white,
                                    child: Icon(
                                      Icons.style,
                                      size: ResponsiveUtils.getIconSize(
                                        context,
                                        80,
                                      ),
                                      color: Colors.deepPurple,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                                ResponsiveUtils.getVerticalSpacing(context) * 4,
                          ),

                          // Titre avec effet de gradient (responsive)
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.amber.shade300,
                                Colors.orange.shade400,
                                Colors.amber.shade300,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'Tarot Africain',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getFontSize(
                                  context,
                                  52,
                                ),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: const [
                                  Shadow(
                                    blurRadius: 20,
                                    color: Colors.black87,
                                    offset: Offset(3, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.getVerticalSpacing(context),
                          ),

                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  ResponsiveUtils.getHorizontalSpacing(
                                    context,
                                  ) *
                                  3,
                              vertical: ResponsiveUtils.getVerticalSpacing(
                                context,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '✨ Jeu de plis stratégique ✨',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getFontSize(
                                  context,
                                  16,
                                ),
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                                ResponsiveUtils.getVerticalSpacing(context) * 6,
                          ),

                          // Section nombre de joueurs (responsive)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  ResponsiveUtils.getHorizontalSpacing(
                                    context,
                                  ) *
                                  2,
                              vertical: ResponsiveUtils.getVerticalSpacing(
                                context,
                              ),
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurple.shade700,
                                  Colors.deepPurple.shade900,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '👥 NOMBRE DE JOUEURS',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getFontSize(
                                  context,
                                  18,
                                ),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Boutons de jeu
                          _buildGameButton(
                            context,
                            icon: Icons.people,
                            label: '3 Joueurs',
                            players: 3,
                            gradient: [
                              Colors.blue.shade600,
                              Colors.blue.shade800,
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildGameButton(
                            context,
                            icon: Icons.groups,
                            label: '4 Joueurs',
                            players: 4,
                            gradient: [
                              Colors.purple.shade600,
                              Colors.purple.shade800,
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Bouton Règles
                          _buildRulesButton(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Dark mode toggle button (bottom-right, responsive)
            Positioned(
              bottom: ResponsiveUtils.getVerticalSpacing(context) * 2.5,
              right: ResponsiveUtils.getHorizontalSpacing(context) * 2.5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: themeProvider.isDarkMode
                          ? Colors.amber.withOpacity(0.5)
                          : Colors.deepPurple.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      themeProvider.toggleTheme();
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.getVerticalSpacing(context) * 1.5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeProvider.isDarkMode
                              ? [Colors.amber.shade600, Colors.orange.shade700]
                              : [
                                  Colors.deepPurple.shade700,
                                  Colors.deepPurple.shade900,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: Colors.white,
                        size: ResponsiveUtils.getIconSize(context, 32),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int players,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[1].withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _startGame(context, players),
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
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Container(
            constraints: BoxConstraints(
              minWidth: ResponsiveUtils.responsiveSize(context, 240),
              minHeight: ResponsiveUtils.responsiveSize(context, 70),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: ResponsiveUtils.getIconSize(context, 32),
                  color: Colors.white,
                ),
                SizedBox(
                  width: ResponsiveUtils.getHorizontalSpacing(context) * 1.5,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 22),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRulesButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showRules(context),
      icon: Icon(
        Icons.menu_book,
        color: Colors.amber,
        size: ResponsiveUtils.getIconSize(context, 24),
      ),
      label: Text(
        'Règles du jeu',
        style: TextStyle(
          fontSize: ResponsiveUtils.getFontSize(context, 18),
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalSpacing(context) * 4,
          vertical: ResponsiveUtils.getVerticalSpacing(context) * 2,
        ),
        side: BorderSide(color: Colors.amber.withOpacity(0.8), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.black.withOpacity(0.3),
      ),
    );
  }

  void _showRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.menu_book, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Règles du Tarot Africain',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRuleSection(
                '🎯 But du jeu',
                'Survivre 5 tours en respectant vos paris. Chaque écart vous coûte des vies.',
              ),
              _buildRuleSection(
                '🃏 Les cartes',
                '• 14 cartes ordinaires (7♣, 7♠, 7♦, 7♥)\n• 22 atouts (1-21 + Excuse)\n• Seuls les atouts gagnent les plis',
              ),
              _buildRuleSection(
                '💰 Paris',
                'Pariez le nombre de plis que vous pensez gagner. Le dernier joueur ne peut pas faire un total égal au nombre de cartes.',
              ),
              _buildRuleSection(
                '🎴 L\'Excuse',
                'Vaut 0 par défaut, mais vous pouvez choisir 22 pour gagner certains plis.',
              ),
              _buildRuleSection(
                '❤️ Vies',
                'Vous perdez 1 vie par point d\'écart entre votre pari et vos plis gagnés.',
              ),
              _buildRuleSection(
                '🏆 Victoire',
                'Le joueur avec le plus de vies après 5 tours gagne !',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade600, Colors.orange.shade700],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Compris !',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _startGame(BuildContext context, int numberOfPlayers) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<GameBloc>.value(
          value: context.read<GameBloc>(),
          child: GameSetupConfigPage(numberOfPlayers: numberOfPlayers),
        ),
      ),
    );
  }
}
