import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:credit_mania/constants/app_colors.dart';

class AnimationHelper {
  // Card animations
  static Widget cardFlipAnimation({
    required Widget front,
    required Widget back,
    required bool showFront,
    required VoidCallback onFlipComplete,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: showFront ? 0 : 180, end: showFront ? 180 : 0),
      duration: duration,
      builder: (context, double value, child) {
        final isShowingFront = value < 90;
        final rotationY = value * 3.1415926535897932 / 180;
        
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotationY),
          alignment: Alignment.center,
          child: isShowingFront
              ? front
              : Transform(
                  transform: Matrix4.identity()..rotateY(3.1415926535897932),
                  alignment: Alignment.center,
                  child: back,
                ),
        );
      },
      onEnd: onFlipComplete,
    );
  }
  
  // Dice roll animation
  static Widget diceRollAnimation({
    required int result,
    required VoidCallback onRollComplete,
  }) {
    return Lottie.asset(
      'assets/animations/dice_roll.json',
      width: 120,
      height: 120,
      fit: BoxFit.contain,
      animate: true,
      repeat: false,
      onLoaded: (composition) {
        Future.delayed(composition.duration, onRollComplete);
      },
    );
  }
  
  // Card deal animation
  static Widget cardDealAnimation({
    required Widget child,
    required int index,
    required VoidCallback onDealComplete,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, double value, _) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 200),
          child: Opacity(
            opacity: value,
            child: Transform.scale(
              scale: value,
              child: child,
            ),
          ),
        );
      },
      onEnd: onDealComplete,
    );
  }
  
  // Money change animation
  static Widget moneyChangeAnimation({
    required int oldValue,
    required int newValue,
    required TextStyle style,
  }) {
    return TweenAnimationBuilder(
      tween: IntTween(begin: oldValue, end: newValue),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, int value, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: style,
            ),
            const SizedBox(width: 4),
            Icon(
              newValue > oldValue ? Icons.arrow_upward : Icons.arrow_downward,
              color: newValue > oldValue ? AppColors.success : AppColors.error,
              size: 16,
            ),
          ],
        );
      },
    );
  }
  
  // Pulse animation for buttons
  static Widget pulseAnimation({
    required Widget child,
    bool animate = true,
  }) {
    if (!animate) return child;
    
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.95, end: 1.05),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, double value, _) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      onEnd: () {},
    );
  }
  
  // Confetti animation for winning
  static Widget confettiAnimation() {
    return Lottie.asset(
      'assets/animations/confetti.json',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      animate: true,
    );
  }
  
  // Shake animation for errors
  static Widget shakeAnimation({
    required Widget child,
    required bool animate,
    VoidCallback? onComplete,
  }) {
    if (!animate) return child;
    
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: -10, end: 10),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      builder: (context, double value, _) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: child,
        );
      },
      onEnd: onComplete,
    );
  }
  
  // Fade transition
  static Widget fadeTransition({
    required Widget child,
    required bool visible,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration,
      child: child,
    );
  }
  
  // Slide transition
  static Widget slideTransition({
    required Widget child,
    required bool visible,
    Duration duration = const Duration(milliseconds: 300),
    Offset beginOffset = const Offset(0, 0.2),
  }) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : beginOffset,
      duration: duration,
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: duration,
        child: child,
      ),
    );
  }
  
  // Progress indicator animation
  static Widget progressAnimation({
    required double progress,
    required Color color,
    double height = 10,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, double value, _) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            widthFactor: value,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
