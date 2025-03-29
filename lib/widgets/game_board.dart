import 'package:flutter/material.dart';
import 'package:credit_mania/models/player.dart';

class GameBoard extends StatelessWidget {
  final List<Player> players;
  final int currentPhase;

  const GameBoard({
    super.key,
    required this.players,
    required this.currentPhase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          color: Colors.amber.shade700,
          width: 3.0,
        ),
      ),
      child: Column(
        children: [
          // Board header
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: const Center(
              child: Text(
                'Credit Mania',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
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
          child: Row(
            children: [
              // Checkpoints
              Expanded(
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
                    ...players.map((player) {
                      final position = (player.creditPoints / 100) * MediaQuery.of(context).size.width * 0.6;
                      return Positioned(
                        left: position.clamp(0.0, double.infinity),
                        top: 10.0,
                        child: CircleAvatar(
                          backgroundColor: _getPlayerColor(players.indexOf(player)),
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
            children: players.map((player) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  '${player.name}: ${player.income}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
              ...players.map((player) {
                final position = (player.debt / 20) * MediaQuery.of(context).size.width * 0.6;
                return Positioned(
                  left: position.clamp(0.0, double.infinity),
                  top: 5.0,
                  child: CircleAvatar(
                    backgroundColor: _getPlayerColor(players.indexOf(player)),
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
              final isActive = index == currentPhase;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.amber.shade600 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: isActive ? Colors.amber.shade800 : Colors.grey.shade400,
                    ),
                  ),
                  child: Center(
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
