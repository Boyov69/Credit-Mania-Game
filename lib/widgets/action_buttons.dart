import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onBuyAsset;
  final VoidCallback onPayDebt;
  final VoidCallback onEndTurn;
  final VoidCallback onEventCards;
  final VoidCallback onLifeCard;

  const ActionButtons({
    super.key,
    required this.onBuyAsset,
    required this.onPayDebt,
    required this.onEndTurn,
    required this.onEventCards,
    required this.onLifeCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border(
          top: BorderSide(
            color: Colors.amber.shade700,
            width: 2.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            label: 'Buy Assets',
            icon: Icons.shopping_cart,
            color: Colors.blue.shade700,
            onPressed: onBuyAsset,
          ),
          _buildActionButton(
            label: 'Pay Debt',
            icon: Icons.money_off,
            color: Colors.red.shade700,
            onPressed: onPayDebt,
          ),
          _buildActionButton(
            label: 'End Turn',
            icon: Icons.skip_next,
            color: Colors.amber.shade700,
            onPressed: onEndTurn,
          ),
          _buildActionButton(
            label: 'Event Cards',
            icon: Icons.event_note,
            color: Colors.orange.shade700,
            onPressed: onEventCards,
          ),
          _buildActionButton(
            label: 'Life Card',
            icon: Icons.favorite,
            color: Colors.green.shade700,
            onPressed: onLifeCard,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}
