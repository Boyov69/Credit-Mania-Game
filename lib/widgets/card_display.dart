import 'package:flutter/material.dart';
import 'package:credit_mania/models/card.dart';

class CardDisplay extends StatelessWidget {
  final Card card;
  final VoidCallback onTap;

  const CardDisplay({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card header
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: _getHeaderColor(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: Text(
                card.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Card image
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  card.imageAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Card details
            Container(
              padding: const EdgeInsets.all(8.0),
              child: _buildCardDetails(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCardDetails() {
    if (card is AssetCard) {
      final assetCard = card as AssetCard;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Cost', '${assetCard.cost}', Icons.attach_money),
          _buildDetailRow('CP', '+${assetCard.cpOnPurchase}', Icons.star),
          _buildDetailRow('Income', '+${assetCard.incomePerRound}/round', Icons.trending_up),
          if (assetCard.debtUpkeep > 0)
            _buildDetailRow('Debt', '+${assetCard.debtUpkeep}/round', Icons.warning),
        ],
      );
    } else if (card is EventCard) {
      final eventCard = card as EventCard;
      return Text(
        eventCard.description,
        style: const TextStyle(fontSize: 12),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    } else if (card is LifeCard) {
      final lifeCard = card as LifeCard;
      return Text(
        lifeCard.description,
        style: const TextStyle(fontSize: 12),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    } else if (card is AvatarCard) {
      final avatarCard = card as AvatarCard;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('CP', '${avatarCard.startingCp}', Icons.star),
          _buildDetailRow('Debt', '${avatarCard.startingDebt}', Icons.warning),
          _buildDetailRow('Income', '${avatarCard.startingIncome}/round', Icons.trending_up),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }
  
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 12),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
  
  Color _getCardColor() {
    if (card is AssetCard) {
      final assetCard = card as AssetCard;
      switch (assetCard.starLevel) {
        case 1:
          return Colors.blue.shade100;
        case 2:
          return Colors.blue.shade200;
        case 3:
          return Colors.blue.shade300;
        default:
          return Colors.blue.shade100;
      }
    } else if (card is EventCard) {
      return Colors.orange.shade100;
    } else if (card is LifeCard) {
      return Colors.green.shade100;
    } else if (card is AvatarCard) {
      return Colors.purple.shade100;
    }
    
    return Colors.grey.shade100;
  }
  
  Color _getHeaderColor() {
    if (card is AssetCard) {
      final assetCard = card as AssetCard;
      switch (assetCard.starLevel) {
        case 1:
          return Colors.blue.shade700;
        case 2:
          return Colors.blue.shade800;
        case 3:
          return Colors.blue.shade900;
        default:
          return Colors.blue.shade700;
      }
    } else if (card is EventCard) {
      return Colors.orange.shade700;
    } else if (card is LifeCard) {
      return Colors.green.shade700;
    } else if (card is AvatarCard) {
      return Colors.purple.shade700;
    }
    
    return Colors.grey.shade700;
  }
}
