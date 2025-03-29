import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:credit_mania/models/card.dart';

class Player extends Equatable {
  final String id;
  String name;
  final AvatarCard avatar;
  int creditPoints;
  int debt;
  int money;
  int income;
  List<AssetCard> assets;
  List<LifeCard> lifeCards;

  Player({
    required this.id,
    required this.name,
    required this.avatar,
    required this.creditPoints,
    required this.debt,
    required this.money,
    required this.income,
    required this.assets,
    required this.lifeCards,
  });

  // Calculate total income per round (avatar + assets)
  int get totalIncome {
    int total = income;
    for (var asset in assets) {
      total += asset.incomePerRound;
    }
    return total;
  }

  // Calculate total CP per round from assets
  int get totalCpPerRound {
    int total = 0;
    for (var asset in assets) {
      total += asset.cpPerRound;
    }
    return total;
  }

  // Calculate total debt upkeep from assets
  int get totalDebtUpkeep {
    int total = 0;
    for (var asset in assets) {
      total += asset.debtUpkeep;
    }
    return total;
  }

  // Check if player can buy a specific star level asset
  bool canBuyStarLevel(int starLevel) {
    if (starLevel == 1) {
      return true; // All players can buy 1-star assets
    } else if (starLevel == 2) {
      return creditPoints >= 20; // Need 20+ CP for 2-star assets
    } else if (starLevel == 3) {
      return creditPoints >= 45; // Need 45+ CP for 3-star assets
    }
    return false;
  }

  // Get number of dice to roll based on credit points
  int getDiceCount() {
    if (creditPoints >= 45) {
      return 3;
    } else if (creditPoints >= 20) {
      return 2;
    }
    return 1;
  }
  
  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar.toMap(),
      'creditPoints': creditPoints,
      'debt': debt,
      'money': money,
      'income': income,
      'assets': assets.map((asset) => asset.toMap()).toList(),
      'lifeCards': lifeCards.map((card) => card.toMap()).toList(),
    };
  }
  
  // Create from map
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      name: map['name'] as String,
      avatar: AvatarCard.fromMap(map['avatar'] as Map<String, dynamic>),
      creditPoints: map['creditPoints'] as int,
      debt: map['debt'] as int,
      money: map['money'] as int,
      income: map['income'] as int,
      assets: (map['assets'] as List)
          .map((asset) => AssetCard.fromMap(asset as Map<String, dynamic>))
          .toList(),
      lifeCards: (map['lifeCards'] as List)
          .map((card) => LifeCard.fromMap(card as Map<String, dynamic>))
          .toList(),
    );
  }
  
  // Copy with new values
  Player copyWith({
    String? id,
    String? name,
    AvatarCard? avatar,
    int? creditPoints,
    int? debt,
    int? money,
    int? income,
    List<AssetCard>? assets,
    List<LifeCard>? lifeCards,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      creditPoints: creditPoints ?? this.creditPoints,
      debt: debt ?? this.debt,
      money: money ?? this.money,
      income: income ?? this.income,
      assets: assets ?? this.assets,
      lifeCards: lifeCards ?? this.lifeCards,
    );
  }

  @override
  List<Object> get props => [
        id,
        name,
        avatar,
        creditPoints,
        debt,
        money,
        income,
        assets,
        lifeCards,
      ];
}
