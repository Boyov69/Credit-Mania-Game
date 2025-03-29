import 'package:flutter/material.dart';
import 'package:credit_mania/models/player.dart';

class PlayerDashboard extends StatelessWidget {
  final Player player;

  const PlayerDashboard({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border(
          bottom: BorderSide(
            color: Colors.amber.shade700,
            width: 2.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Credit Points
          _buildStatItem(
            icon: Icons.star,
            value: player.creditPoints.toString(),
            label: 'CP',
            color: Colors.amber,
          ),
          
          // Income
          _buildStatItem(
            icon: Icons.trending_up,
            value: player.income.toString(),
            label: 'Income',
            color: Colors.blue,
          ),
          
          // Debt
          _buildStatItem(
            icon: Icons.warning,
            value: player.debt.toString(),
            label: 'Debt',
            color: Colors.red,
          ),
          
          // Money
          _buildStatItem(
            icon: Icons.attach_money,
            value: player.money.toString(),
            label: 'Money',
            color: Colors.green,
          ),
          
          // Player info
          _buildPlayerInfo(),
        ],
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8.0),
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
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
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
    );
  }
  
  Widget _buildPlayerInfo() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 16.0,
            child: Text(
              player.name.substring(0, 1),
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            player.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
