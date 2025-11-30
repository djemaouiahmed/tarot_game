import 'package:flutter/material.dart';
import '../../core/audio/audio_service.dart';

class GameMenuDrawer extends StatefulWidget {
  final VoidCallback onQuit;
  final double volume;
  final ValueChanged<double>? onVolumeChanged;

  const GameMenuDrawer({
    super.key,
    required this.onQuit,
    this.volume = 0.5,
    this.onVolumeChanged,
  });

  @override
  State<GameMenuDrawer> createState() => _GameMenuDrawerState();
}

class _GameMenuDrawerState extends State<GameMenuDrawer> {
  late double _currentVolume;
  bool _isMusicEnabled = true;
  bool _areEffectsEnabled = true;

  @override
  void initState() {
    super.initState();
    _currentVolume = widget.volume;
    _isMusicEnabled = AudioService().isMusicEnabled;
    _areEffectsEnabled = AudioService().areEffectsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade800,
              Colors.deepPurple.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              const SizedBox(height: 20),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildVolumeControl(),
                    const SizedBox(height: 16),
                    _buildMusicToggle(),
                    const SizedBox(height: 12),
                    _buildEffectsToggle(),
                    const SizedBox(height: 16),
                    _buildMenuDivider(),
                    const SizedBox(height: 16),
                    _buildStatisticsButton(),
                    const SizedBox(height: 12),
                    _buildRulesButton(),
                    const SizedBox(height: 12),
                    _buildSettingsButton(),
                    const SizedBox(height: 24),
                    _buildMenuDivider(),
                    const SizedBox(height: 24),
                    _buildQuitButton(),
                  ],
                ),
              ),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.withOpacity(0.3), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.amber.shade700, Colors.amber.shade900],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.casino, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tarot Africain',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Menu de jeu',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeControl() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _currentVolume == 0
                    ? Icons.volume_off
                    : _currentVolume < 0.5
                    ? Icons.volume_down
                    : Icons.volume_up,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Volume',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(_currentVolume * 100).round()}%',
                style: TextStyle(
                  color: Colors.amber.shade300,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.amber.shade600,
              inactiveTrackColor: Colors.amber.shade900.withOpacity(0.3),
              thumbColor: Colors.amber.shade400,
              overlayColor: Colors.amber.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 4,
            ),
            child: Slider(
              value: _currentVolume,
              onChanged: (value) {
                setState(() {
                  _currentVolume = value;
                });
                widget.onVolumeChanged?.call(value);
              },
              min: 0.0,
              max: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            _isMusicEnabled ? Icons.music_note : Icons.music_off,
            color: Colors.amber,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Musique de fond',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: _isMusicEnabled,
            onChanged: (value) {
              setState(() {
                _isMusicEnabled = value;
              });
              AudioService().toggleMusic();
            },
            activeColor: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildEffectsToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            _areEffectsEnabled ? Icons.volume_up : Icons.volume_off,
            color: Colors.amber,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Effets sonores',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: _areEffectsEnabled,
            onChanged: (value) {
              setState(() {
                _areEffectsEnabled = value;
              });
              AudioService().toggleEffects();
            },
            activeColor: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsButton() {
    return _buildMenuItem(
      icon: Icons.bar_chart_rounded,
      title: 'Statistiques',
      subtitle: 'Voir vos performances',
      onTap: () {
        Navigator.pop(context);
        // TODO: Navigate to statistics page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statistiques - À venir'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Widget _buildRulesButton() {
    return _buildMenuItem(
      icon: Icons.help_outline_rounded,
      title: 'Règles du jeu',
      subtitle: 'Apprendre à jouer',
      onTap: () {
        Navigator.pop(context);
        // TODO: Navigate to rules page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Règles du jeu - À venir'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Widget _buildSettingsButton() {
    return _buildMenuItem(
      icon: Icons.settings_rounded,
      title: 'Paramètres',
      subtitle: 'Configuration du jeu',
      onTap: () {
        Navigator.pop(context);
        // TODO: Navigate to settings page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres - À venir'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Widget _buildQuitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          widget.onQuit();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade700, Colors.red.shade900],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.shade400.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quitter la partie',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Retour au menu principal',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white70,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.amber.shade300, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2024 Tarot Africain',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
