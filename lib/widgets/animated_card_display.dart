import 'package:flutter/material.dart';
import 'package:credit_mania/models/card.dart';
import 'package:credit_mania/utils/animation_helper.dart';
import 'package:credit_mania/constants/app_colors.dart';

class AnimatedCardDisplay extends StatefulWidget {
  final Card card;
  final VoidCallback onTap;
  final bool animate;
  final int index;

  const AnimatedCardDisplay({
    super.key,
    required this.card,
    required this.onTap,
    this.animate = true,
    this.index = 0,
  });

  @override
  State<AnimatedCardDisplay> createState() => _AnimatedCardDisplayState();
}

class _AnimatedCardDisplayState extends State<AnimatedCardDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isFlipped = false;
  bool _isDealt = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.animate) {
      Future.delayed(Duration(milliseconds: 100 * widget.index), () {
        _controller.forward();
        setState(() {
          _isDealt = true;
        });
      });
    } else {
      _controller.value = 1.0;
      _isDealt = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getCardColor() {
    if (widget.card is AssetCard) {
      final assetCard = widget.card as AssetCard;
      switch (assetCard.starLevel) {
        case 1:
          return AppColors.assetCard1Star;
        case 2:
          return AppColors.assetCard2Star;
        case 3:
          return AppColors.assetCard3Star;
        default:
          return AppColors.assetCard1Star;
      }
    } else if (widget.card is EventCard) {
      return AppColors.eventCard;
    } else if (widget.card is LifeCard) {
      return AppColors.lifeCard;
    } else if (widget.card is AvatarCard) {
      return AppColors.avatarCard;
    }
    
    return Colors.grey.shade100;
  }
  
  Color _getHeaderColor() {
    if (widget.card is AssetCard) {
      final assetCard = widget.card as AssetCard;
      switch (assetCard.starLevel) {
        case 1:
          return AppColors.assetCard1Star.withOpacity(0.8);
        case 2:
          return AppColors.assetCard2Star.withOpacity(0.8);
        case 3:
          return AppColors.assetCard3Star.withOpacity(0.8);
        default:
          return AppColors.assetCard1Star.withOpacity(0.8);
      }
    } else if (widget.card is EventCard) {
      return AppColors.eventCard.withOpacity(0.8);
    } else if (widget.card is LifeCard) {
      return AppColors.lifeCard.withOpacity(0.8);
    } else if (widget.card is AvatarCard) {
      return AppColors.avatarCard.withOpacity(0.8);
    }
    
    return Colors.grey.shade700;
  }

  Widget _buildCardFront() {
    return Container(
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
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
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: Text(
              widget.card.name,
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
              child: Hero(
                tag: 'card_${widget.card.id}',
                child: Image.asset(
                  widget.card.imageAsset,
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
          ),
          
          // Card details
          Container(
            padding: const EdgeInsets.all(8.0),
            child: _buildCardDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCardColor().withOpacity(0.7),
            _getCardColor(),
          ],
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCardIcon(),
              size: 48,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 8),
            Text(
              _getCardTypeName(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCardIcon() {
    if (widget.card is AssetCard) {
      return Icons.business;
    } else if (widget.card is EventCard) {
      return Icons.event;
    } else if (widget.card is LifeCard) {
      return Icons.favorite;
    } else if (widget.card is AvatarCard) {
      return Icons.person;
    }
    return Icons.credit_card;
  }

  String _getCardTypeName() {
    if (widget.card is AssetCard) {
      return 'Asset Card';
    } else if (widget.card is EventCard) {
      return 'Event Card';
    } else if (widget.card is LifeCard) {
      return 'Life Card';
    } else if (widget.card is AvatarCard) {
      return 'Avatar Card';
    }
    return 'Card';
  }

  Widget _buildCardDetails() {
    if (widget.card is AssetCard) {
      final assetCard = widget.card as AssetCard;
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
    } else if (widget.card is EventCard) {
      final eventCard = widget.card as EventCard;
      return Text(
        eventCard.description,
        style: const TextStyle(fontSize: 12),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    } else if (widget.card is LifeCard) {
      final lifeCard = widget.card as LifeCard;
      return Text(
        lifeCard.description,
        style: const TextStyle(fontSize: 12),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    } else if (widget.card is AvatarCard) {
      final avatarCard = widget.card as AvatarCard;
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

  @override
  Widget build(BuildContext context) {
    if (!_isDealt && widget.animate) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isFlipped = !_isFlipped;
        });
        
        // Only trigger the onTap callback when the card is face up
        if (!_isFlipped) {
          widget.onTap();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: AnimationHelper.cardFlipAnimation(
                front: _buildCardFront(),
                back: _buildCardBack(),
                showFront: !_isFlipped,
                onFlipComplete: () {},
                duration: const Duration(milliseconds: 400),
              ),
            ),
          );
        },
      ),
    );
  }
}
