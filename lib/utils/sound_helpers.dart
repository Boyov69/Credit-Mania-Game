import 'package:flutter/material.dart';
import 'package:credit_mania/services/audio_manager.dart';

class SoundEffectMixin {
  final AudioManager _audioManager = AudioManager();
  
  // Card sounds
  void playCardFlipSound() {
    _audioManager.playSfx('card_flip');
  }
  
  void playCardDealSound() {
    _audioManager.playSfx('card_deal');
  }
  
  // Dice sounds
  void playDiceRollSound() {
    _audioManager.playSfx('dice_roll');
  }
  
  // Money sounds
  void playMoneyGainSound() {
    _audioManager.playSfx('money_gain');
  }
  
  void playMoneyLossSound() {
    _audioManager.playSfx('money_loss');
  }
  
  // UI sounds
  void playButtonClickSound() {
    _audioManager.playSfx('button_click');
  }
  
  void playErrorSound() {
    _audioManager.playSfx('error');
  }
  
  void playSuccessSound() {
    _audioManager.playSfx('success');
  }
  
  // Game state sounds
  void playGameStartSound() {
    _audioManager.playSfx('game_start');
  }
  
  void playGameEndSound() {
    _audioManager.playSfx('game_end');
  }
  
  void playPlayerTurnSound() {
    _audioManager.playSfx('player_turn');
  }
}

class SoundButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String soundEffect;
  
  const SoundButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.soundEffect = 'button_click',
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        AudioManager().playSfx(soundEffect);
        onPressed();
      },
      child: child,
    );
  }
}

class SoundIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String soundEffect;
  final Color? color;
  final double? size;
  final String? tooltip;
  
  const SoundIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.soundEffect = 'button_click',
    this.color,
    this.size,
    this.tooltip,
  });
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        AudioManager().playSfx(soundEffect);
        onPressed();
      },
      icon: Icon(icon),
      color: color,
      iconSize: size,
      tooltip: tooltip,
    );
  }
}

class BackgroundMusicWidget extends StatefulWidget {
  final String musicTrack;
  final Widget child;
  
  const BackgroundMusicWidget({
    super.key,
    required this.musicTrack,
    required this.child,
  });
  
  @override
  State<BackgroundMusicWidget> createState() => _BackgroundMusicWidgetState();
}

class _BackgroundMusicWidgetState extends State<BackgroundMusicWidget> {
  final AudioManager _audioManager = AudioManager();
  
  @override
  void initState() {
    super.initState();
    _playMusic();
  }
  
  @override
  void didUpdateWidget(BackgroundMusicWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.musicTrack != widget.musicTrack) {
      _playMusic();
    }
  }
  
  @override
  void dispose() {
    _audioManager.stopMusic();
    super.dispose();
  }
  
  void _playMusic() {
    _audioManager.playMusic(widget.musicTrack);
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
