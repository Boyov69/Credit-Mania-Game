import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  // Singleton instance
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Audio players
  late AudioPlayer _musicPlayer;
  late AudioPlayer _sfxPlayer;
  
  // Audio settings
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  double _musicVolume = 0.5;
  double _sfxVolume = 0.7;
  
  // Audio files
  final Map<String, String> _musicTracks = {
    'menu': 'assets/audio/music/menu_music.mp3',
    'gameplay': 'assets/audio/music/gameplay_music.mp3',
    'victory': 'assets/audio/music/victory_music.mp3',
  };
  
  final Map<String, String> _soundEffects = {
    'card_flip': 'assets/audio/sfx/card_flip.mp3',
    'card_deal': 'assets/audio/sfx/card_deal.mp3',
    'dice_roll': 'assets/audio/sfx/dice_roll.mp3',
    'money_gain': 'assets/audio/sfx/money_gain.mp3',
    'money_loss': 'assets/audio/sfx/money_loss.mp3',
    'button_click': 'assets/audio/sfx/button_click.mp3',
    'error': 'assets/audio/sfx/error.mp3',
    'success': 'assets/audio/sfx/success.mp3',
    'game_start': 'assets/audio/sfx/game_start.mp3',
    'game_end': 'assets/audio/sfx/game_end.mp3',
    'player_turn': 'assets/audio/sfx/player_turn.mp3',
  };
  
  // Initialize audio manager
  Future<void> initialize() async {
    try {
      _musicPlayer = AudioPlayer();
      _sfxPlayer = AudioPlayer();
      
      // Load settings from shared preferences
      await _loadSettings();
      
      // Pre-load sound effects for faster playback
      await _preloadSoundEffects();
      
      debugPrint('Audio Manager initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Audio Manager: $e');
    }
  }
  
  // Load audio settings from shared preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _musicEnabled = prefs.getBool('musicEnabled') ?? true;
      _sfxEnabled = prefs.getBool('sfxEnabled') ?? true;
      _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
      _sfxVolume = prefs.getDouble('sfxVolume') ?? 0.7;
      
      // Apply volume settings
      await _musicPlayer.setVolume(_musicEnabled ? _musicVolume : 0);
      await _sfxPlayer.setVolume(_sfxEnabled ? _sfxVolume : 0);
    } catch (e) {
      debugPrint('Error loading audio settings: $e');
    }
  }
  
  // Save audio settings to shared preferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('musicEnabled', _musicEnabled);
      await prefs.setBool('sfxEnabled', _sfxEnabled);
      await prefs.setDouble('musicVolume', _musicVolume);
      await prefs.setDouble('sfxVolume', _sfxVolume);
    } catch (e) {
      debugPrint('Error saving audio settings: $e');
    }
  }
  
  // Pre-load sound effects
  Future<void> _preloadSoundEffects() async {
    try {
      for (final sfx in _soundEffects.values) {
        await _sfxPlayer.setAsset(sfx);
      }
    } catch (e) {
      debugPrint('Error preloading sound effects: $e');
    }
  }
  
  // Play background music
  Future<void> playMusic(String track) async {
    try {
      if (!_musicEnabled) return;
      
      final trackPath = _musicTracks[track];
      if (trackPath == null) {
        debugPrint('Music track not found: $track');
        return;
      }
      
      // Stop current music if playing
      await _musicPlayer.stop();
      
      // Load and play new track
      await _musicPlayer.setAsset(trackPath);
      await _musicPlayer.setLoopMode(LoopMode.all);
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.play();
    } catch (e) {
      debugPrint('Error playing music: $e');
    }
  }
  
  // Stop background music
  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }
  
  // Play sound effect
  Future<void> playSfx(String effect) async {
    try {
      if (!_sfxEnabled) return;
      
      final effectPath = _soundEffects[effect];
      if (effectPath == null) {
        debugPrint('Sound effect not found: $effect');
        return;
      }
      
      // Create a new player for each sound effect to allow overlapping
      final player = AudioPlayer();
      await player.setAsset(effectPath);
      await player.setVolume(_sfxVolume);
      await player.play();
      
      // Dispose player after playback
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          player.dispose();
        }
      });
    } catch (e) {
      debugPrint('Error playing sound effect: $e');
    }
  }
  
  // Toggle music on/off
  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    
    if (_musicEnabled) {
      await _musicPlayer.setVolume(_musicVolume);
    } else {
      await _musicPlayer.setVolume(0);
    }
    
    await _saveSettings();
  }
  
  // Toggle sound effects on/off
  Future<void> toggleSfx() async {
    _sfxEnabled = !_sfxEnabled;
    await _saveSettings();
  }
  
  // Set music volume
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    
    if (_musicEnabled) {
      await _musicPlayer.setVolume(_musicVolume);
    }
    
    await _saveSettings();
  }
  
  // Set sound effects volume
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _saveSettings();
  }
  
  // Get music enabled status
  bool get isMusicEnabled => _musicEnabled;
  
  // Get sound effects enabled status
  bool get isSfxEnabled => _sfxEnabled;
  
  // Get music volume
  double get musicVolume => _musicVolume;
  
  // Get sound effects volume
  double get sfxVolume => _sfxVolume;
  
  // Dispose audio players
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
