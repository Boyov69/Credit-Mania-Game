import 'package:flutter/material.dart';
import 'package:credit_mania/constants/app_colors.dart';
import 'package:credit_mania/utils/animation_helper.dart';

class AnimatedGameBoard extends StatefulWidget {
  final List<dynamic> players;
  final int currentPhase;
  final int currentRound;
  final bool animate;

  const AnimatedGameBoard({
    super.key,
    required this.players,
    required this.currentPhase,
    required this.currentRound,
    this.animate = true,
  });

  @override
  State<AnimatedGameBoard> createState() => _AnimatedGameBoardState();
}

class _AnimatedGameBoardState extends State<AnimatedGameBoard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
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
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primary,
                  width: 3.0,
                ),
              ),
              child: Column(
                children: [
                  // Board header
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Credit Mania',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Round ${widget.currentRound}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Board content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Credit Points Track
                          _buildCreditTrack(),
                          
                          const SizedBox(height: 16.0),
                          
                          // Income Track
                          _buildIncomeTrack(),
                          
                          const SizedBox(height: 16.0),
                          
                          // Debt Track
                          _buildDebtTrack(),
                          
                          const SizedBox(height: 16.0),
                          
                          // Phase Track
                          _buildPhaseTrack(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCreditTrack() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Credit Points Track',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 60.0,
          decoration: BoxDecoration(
            color: Colors.blue.shade200,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.blue.shade800),
          ),
          child: Stack(
            children: [
              // Track background
              Row(
                children: [
                  _buildTrackSection(0, 20, Colors.blue.shade300),
                  _buildTrackSection(20, 45, Colors.blue.shade400),
                  _buildTrackSection(45, 100, Colors.blue.shade500),
                ],
              ),
              
              // Player markers
              ...widget.players.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;
                final position = (player.creditPoints / 100) * MediaQuery.of(context).size.width * 0.6;
                
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  left: position.clamp(0.0, double.infinity),
                  top: 10.0,
                  child: AnimationHelper.pulseAnimation(
                    animate: true,
                    child: CircleAvatar(
                      backgroundColor: _getPlayerColor(index),
                      radius: 12.0,
                      child: Text(
                        player.name.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              
              // Checkpoint labels
              Positioned(
                left: 0,
                bottom: 0,
                child: _buildCheckpointLabel('0'),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.12,
                bottom: 0,
                child: _buildCheckpointLabel('20'),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.27,
                bottom: 0,
                child: _buildCheckpointLabel('45'),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: _buildCheckpointLabel('100'),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildIncomeTrack() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Income Track',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 40.0,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.green.shade800),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.players.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              
              return AnimationHelper.slideTransition(
                visible: true,
                beginOffset: Offset(0, index % 2 == 0 ? -0.5 : 0.5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(4.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${player.name}: ${player.income}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDebtTrack() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Debt Track',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 40.0,
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.red.shade800),
          ),
          child: Stack(
            children: [
              // Track background
              Row(
                children: [
                  _buildTrackSection(0, 5, Colors.red.shade200),
                  _buildTrackSection(5, 10, Colors.red.shade300),
                  _buildTrackSection(10, 15, Colors.red.shade400),
                  _buildTrackSection(15, 20, Colors.red.shade500),
                ],
              ),
              
              // Player markers
              ...widget.players.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;
                final position = (player.debt / 20) * MediaQuery.of(context).size.width * 0.6;
                
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  left: position.clamp(0.0, double.infinity),
                  top: 5.0,
                  child: CircleAvatar(
                    backgroundColor: _getPlayerColor(index),
                    radius: 10.0,
                    child: Text(
                      player.name.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.0,
                      ),
                    ),
                  ),
                );
              }).toList(),
              
              // Checkpoint labels
              Positioned(
                left: 0,
                bottom: 0,
                child: _buildCheckpointLabel('0'),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: _buildCheckpointLabel('20'),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPhaseTrack() {
    final phases = [
      'Event',
      'Income',
      'Life Cards',
      'Asset',
      'Scoring',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phase Track',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 50.0,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Row(
            children: List.generate(phases.length, (index) {
              final isActive = index == widget.currentPhase;
              
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: isActive ? AppColors.secondary : Colors.grey.shade400,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 5,
                              spreadRadius: 1,
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: AnimationHelper.pulseAnimation(
                      animate: isActive,
                      child: Text(
                        phases[index],
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.black,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTrackSection(int start, int end, Color color) {
    final width = ((end - start) / 100) * 100;
    return Container(
      width: MediaQuery.of(context).size.width * width * 0.006,
      color: color,
    );
  }
  
  Widget _buildCheckpointLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Color _getPlayerColor(int playerIndex) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];
    
    return colors[playerIndex % colors.length];
  }
}
