import 'package:flutter/material.dart';
import 'package:credit_mania/models/player.dart';
import 'package:credit_mania/constants/app_colors.dart';
import 'package:credit_mania/utils/animation_helper.dart';

class AnimatedPlayerDashboard extends StatefulWidget {
  final Player player;
  final bool isCurrentPlayer;
  final Map<String, int> previousValues;

  const AnimatedPlayerDashboard({
    super.key,
    required this.player,
    this.isCurrentPlayer = false,
    required this.previousValues,
  });

  @override
  State<AnimatedPlayerDashboard> createState() => _AnimatedPlayerDashboardState();
}

class _AnimatedPlayerDashboardState extends State<AnimatedPlayerDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: widget.isCurrentPlayer
                    ? Colors.black.withOpacity(0.8)
                    : Colors.black.withOpacity(0.6),
                border: Border(
                  bottom: BorderSide(
                    color: widget.isCurrentPlayer
                        ? AppColors.primary
                        : Colors.grey.shade700,
                    width: 2.0,
                  ),
                ),
                boxShadow: widget.isCurrentPlayer
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Credit Points
                  _buildAnimatedStatItem(
                    icon: Icons.star,
                    value: widget.player.creditPoints,
                    previousValue: widget.previousValues['creditPoints'] ?? widget.player.creditPoints,
                    label: 'CP',
                    color: AppColors.primary,
                  ),
                  
                  // Income
                  _buildAnimatedStatItem(
                    icon: Icons.trending_up,
                    value: widget.player.income,
                    previousValue: widget.previousValues['income'] ?? widget.player.income,
                    label: 'Income',
                    color: AppColors.incomeTrack,
                  ),
                  
                  // Debt
                  _buildAnimatedStatItem(
                    icon: Icons.warning,
                    value: widget.player.debt,
                    previousValue: widget.previousValues['debt'] ?? widget.player.debt,
                    label: 'Debt',
                    color: AppColors.debtTrack,
                  ),
                  
                  // Money
                  _buildAnimatedStatItem(
                    icon: Icons.attach_money,
                    value: widget.player.money,
                    previousValue: widget.previousValues['money'] ?? widget.player.money,
                    label: 'Money',
                    color: AppColors.success,
                  ),
                  
                  // Player info
                  _buildPlayerInfo(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAnimatedStatItem({
    required IconData icon,
    required int value,
    required int previousValue,
    required String label,
    required Color color,
  }) {
    final hasChanged = value != previousValue;
    
    return AnimationHelper.pulseAnimation(
      animate: hasChanged && widget.isCurrentPlayer,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8.0),
          border: widget.isCurrentPlayer
              ? Border.all(color: color.withOpacity(0.5), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 24.0,
            ),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimationHelper.moneyChangeAnimation(
                  oldValue: previousValue,
                  newValue: value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: hasChanged ? 20.0 : 18.0,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlayerInfo() {
    return AnimationHelper.pulseAnimation(
      animate: widget.isCurrentPlayer,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: widget.isCurrentPlayer ? AppColors.primary : Colors.blue.shade700,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: widget.isCurrentPlayer
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'player_avatar_${widget.player.id}',
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16.0,
                child: Text(
                  widget.player.name.substring(0, 1),
                  style: TextStyle(
                    color: widget.isCurrentPlayer ? AppColors.primary : Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                if (widget.isCurrentPlayer)
                  const Text(
                    'Your Turn',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
