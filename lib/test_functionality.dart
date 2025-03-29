import 'package:flutter/material.dart';
import 'package:credit_mania/models/card.dart';
import 'package:credit_mania/models/player.dart';
import 'package:credit_mania/models/game_state.dart';
import 'package:credit_mania/utils/asset_images.dart';

// This is a test file to verify the functionality of the game mechanics
// In a real implementation, this would be a proper test suite

void main() {
  // Test creating players
  final avatarCard = AvatarCard(
    id: 'avatar_1',
    name: 'Business Dog',
    startingCp: 10,
    startingDebt: 2,
    startingIncome: 5,
    ability: 'Roll one extra die for income',
    imageAsset: AssetImages.logo, // Placeholder
  );
  
  final player = Player(
    id: 'player_1',
    name: 'Player 1',
    avatar: avatarCard,
    creditPoints: avatarCard.startingCp,
    debt: avatarCard.startingDebt,
    money: 100,
    income: avatarCard.startingIncome,
    assets: [],
    lifeCards: [],
  );
  
  // Test creating asset cards
  final assetCard = AssetCard(
    id: 'asset_1_1',
    name: 'Bank Stocks',
    starLevel: 1,
    cost: 20,
    cpOnPurchase: 1,
    cpPerRound: 0,
    incomePerRound: 2,
    debtUpkeep: 0,
    imageAsset: AssetImages.bankStocks,
  );
  
  // Test buying asset
  player.money -= assetCard.cost;
  player.assets.add(assetCard);
  player.creditPoints += assetCard.cpOnPurchase;
  player.income += assetCard.incomePerRound;
  
  // Test calculating total income
  final totalIncome = player.totalIncome;
  assert(totalIncome == player.income);
  
  // Test calculating total CP per round
  final totalCpPerRound = player.totalCpPerRound;
  assert(totalCpPerRound == 0); // This asset doesn't give CP per round
  
  // Test calculating total debt upkeep
  final totalDebtUpkeep = player.totalDebtUpkeep;
  assert(totalDebtUpkeep == 0); // This asset doesn't have debt upkeep
  
  // Test checking if player can buy specific star level assets
  assert(player.canBuyStarLevel(1) == true);
  assert(player.canBuyStarLevel(2) == false); // Player has only 11 CP, needs 20
  assert(player.canBuyStarLevel(3) == false); // Player has only 11 CP, needs 45
  
  // Test getting number of dice to roll
  assert(player.getDiceCount() == 1); // Player has only 11 CP
  
  // Test game state enum
  assert(GameState.setup != GameState.playing);
  
  print('All tests passed!');
}
