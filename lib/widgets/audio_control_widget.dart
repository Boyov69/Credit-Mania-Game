import 'package:flutter/material.dart';
import 'package:credit_mania/services/audio_manager.dart';

class AudioControlWidget extends StatefulWidget {
  const AudioControlWidget({super.key});

  @override
  State<AudioControlWidget> createState() => _AudioControlWidgetState();
}

class _AudioControlWidgetState extends State<AudioControlWidget> {
  final AudioManager _audioManager = AudioManager();
  bool _showVolumeControls = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _showVolumeControls ? 300 : 120,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Music toggle
                IconButton(
                  icon: Icon(
                    _audioManager.isMusicEnabled
                        ? Icons.music_note
                        : Icons.music_off,
                    color: _audioManager.isMusicEnabled
                        ? Colors.green
                        : Colors.red,
                  ),
                  onPressed: () {
                    _audioManager.toggleMusic();
                    _audioManager.playSfx('button_click');
                    setState(() {});
                  },
                  tooltip: 'Toggle Music',
                ),
                
                // Sound effects toggle
                IconButton(
                  icon: Icon(
                    _audioManager.isSfxEnabled
                        ? Icons.volume_up
                        : Icons.volume_off,
                    color: _audioManager.isSfxEnabled
                        ? Colors.green
                        : Colors.red,
                  ),
                  onPressed: () {
                    _audioManager.toggleSfx();
                    setState(() {});
                  },
                  tooltip: 'Toggle Sound Effects',
                ),
                
                // Expand/collapse button
                IconButton(
                  icon: Icon(
                    _showVolumeControls
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onPressed: () {
                    setState(() {
                      _showVolumeControls = !_showVolumeControls;
                    });
                    _audioManager.playSfx('button_click');
                  },
                  tooltip: 'Volume Controls',
                ),
              ],
            ),
            
            // Volume sliders
            if (_showVolumeControls) ...[
              const Divider(),
              
              // Music volume
              Row(
                children: [
                  const Icon(Icons.music_note, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _audioManager.musicVolume,
                      onChanged: (value) {
                        _audioManager.setMusicVolume(value);
                        setState(() {});
                      },
                      activeColor: Colors.green,
                    ),
                  ),
                ],
              ),
              
              // Sound effects volume
              Row(
                children: [
                  const Icon(Icons.volume_up, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _audioManager.sfxVolume,
                      onChanged: (value) {
                        _audioManager.setSfxVolume(value);
                        setState(() {});
                        _audioManager.playSfx('button_click');
                      },
                      activeColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
