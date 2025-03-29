import 'package:flutter/material.dart';
import 'package:credit_mania/models/card.dart';
import 'package:credit_mania/utils/animation_helper.dart';
import 'dart:math' as math;

class AnimatedDiceRoll extends StatefulWidget {
  final int diceCount;
  final Function(int) onRollComplete;
  final bool autoRoll;

  const AnimatedDiceRoll({
    super.key,
    required this.diceCount,
    required this.onRollComplete,
    this.autoRoll = false,
  });

  @override
  State<AnimatedDiceRoll> createState() => _AnimatedDiceRollState();
}

class _AnimatedDiceRollState extends State<AnimatedDiceRoll> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _rotationAnimations;
  late List<int> _diceValues;
  bool _isRolling = false;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    if (widget.autoRoll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startRoll();
      });
    }
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.diceCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800 + (index * 200)),
      ),
    );

    _rotationAnimations = List.generate(
      widget.diceCount,
      (index) => Tween<double>(begin: 0, end: 10 * math.pi).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _diceValues = List.generate(widget.diceCount, (index) => 1);
  }

  void _startRoll() {
    if (_isRolling) return;
    
    setState(() {
      _isRolling = true;
    });

    // Reset controllers
    for (var controller in _controllers) {
      controller.reset();
    }

    // Start animations with slight delay between each dice
    for (int i = 0; i < widget.diceCount; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        _controllers[i].forward();
      });
    }

    // Wait for all animations to complete
    Future.delayed(Duration(milliseconds: 800 + (widget.diceCount * 200)), () {
      // Generate random values for each dice
      final newValues = List.generate(
        widget.diceCount,
        (index) => _random.nextInt(6) + 1,
      );
      
      setState(() {
        _diceValues = newValues;
        _isRolling = false;
      });
      
      // Calculate total
      final total = _diceValues.fold(0, (sum, value) => sum + value);
      widget.onRollComplete(total);
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.diceCount,
            (index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedBuilder(
                animation: _controllers[index],
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimations[index].value,
                    child: Transform.scale(
                      scale: 1.0 + (0.2 * _controllers[index].value),
                      child: _buildDice(_diceValues[index]),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!widget.autoRoll)
          ElevatedButton.icon(
            onPressed: _isRolling ? null : _startRoll,
            icon: const Icon(Icons.casino),
            label: Text(_isRolling ? 'Rolling...' : 'Roll Dice'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
      ],
    );
  }

  Widget _buildDice(int value) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: _buildDiceFace(value),
      ),
    );
  }

  Widget _buildDiceFace(int value) {
    switch (value) {
      case 1:
        return _buildDot(const Offset(0.5, 0.5));
      case 2:
        return Stack(
          children: [
            _buildDot(const Offset(0.25, 0.25)),
            _buildDot(const Offset(0.75, 0.75)),
          ],
        );
      case 3:
        return Stack(
          children: [
            _buildDot(const Offset(0.25, 0.25)),
            _buildDot(const Offset(0.5, 0.5)),
            _buildDot(const Offset(0.75, 0.75)),
          ],
        );
      case 4:
        return Stack(
          children: [
            _buildDot(const Offset(0.25, 0.25)),
            _buildDot(const Offset(0.75, 0.25)),
            _buildDot(const Offset(0.25, 0.75)),
            _buildDot(const Offset(0.75, 0.75)),
          ],
        );
      case 5:
        return Stack(
          children: [
            _buildDot(const Offset(0.25, 0.25)),
            _buildDot(const Offset(0.75, 0.25)),
            _buildDot(const Offset(0.5, 0.5)),
            _buildDot(const Offset(0.25, 0.75)),
            _buildDot(const Offset(0.75, 0.75)),
          ],
        );
      case 6:
        return Stack(
          children: [
            _buildDot(const Offset(0.25, 0.25)),
            _buildDot(const Offset(0.75, 0.25)),
            _buildDot(const Offset(0.25, 0.5)),
            _buildDot(const Offset(0.75, 0.5)),
            _buildDot(const Offset(0.25, 0.75)),
            _buildDot(const Offset(0.75, 0.75)),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildDot(Offset position) {
    return Positioned(
      left: position.dx * 60 - 5,
      top: position.dy * 60 - 5,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
