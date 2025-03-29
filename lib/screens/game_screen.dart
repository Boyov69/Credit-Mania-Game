import 'package:flutter/material.dart';
import 'package:credit_mania/models/card.dart';
import 'package:credit_mania/models/player.dart';
import 'package:credit_mania/services/game_service.dart';
import 'package:credit_mania/widgets/game_board.dart';
import 'package:credit_mania/widgets/card_display.dart';
import 'package:credit_mania/widgets/player_dashboard.dart';
import 'package:credit_mania/widgets/action_buttons.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Start the game when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameService = Provider.of<GameService>(context, listen: false);
      gameService.startGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameService>(
        builder: (context, gameService, child) {
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_wood.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                // Top bar with player stats
                PlayerDashboard(player: gameService.currentPlayer),
                
                // Main game area
                Expanded(
                  child: Row(
                    children: [
                      // Left side - Game board
                      Expanded(
                        flex: 3,
                        child: GameBoard(
                          players: gameService.players,
                          currentPhase: gameService.currentPhase,
                        ),
                      ),
                      
                      // Right side - Cards
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            // Event card
                            if (gameService.currentEvent != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CardDisplay(
                                  card: gameService.currentEvent!,
                                  onTap: () {
                                    // Show event details
                                  },
                                ),
                              ),
                            
                            // Asset market
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.all(8.0),
                                children: [
                                  const Text(
                                    'Asset Market',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  // 1-star assets
                                  if (gameService.marketDisplay1Star.isNotEmpty)
                                    _buildAssetSection(
                                      context,
                                      '1-Star Assets',
                                      gameService.marketDisplay1Star,
                                      gameService,
                                    ),
                                  
                                  // 2-star assets
                                  if (gameService.marketDisplay2Star.isNotEmpty)
                                    _buildAssetSection(
                                      context,
                                      '2-Star Assets',
                                      gameService.marketDisplay2Star,
                                      gameService,
                                    ),
                                  
                                  // 3-star assets
                                  if (gameService.marketDisplay3Star.isNotEmpty)
                                    _buildAssetSection(
                                      context,
                                      '3-Star Assets',
                                      gameService.marketDisplay3Star,
                                      gameService,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bottom action buttons
                ActionButtons(
                  onBuyAsset: () {
                    // Show asset buying dialog
                  },
                  onPayDebt: () {
                    _showPayDebtDialog(context, gameService);
                  },
                  onEndTurn: () {
                    gameService.endTurn();
                  },
                  onEventCards: () {
                    // Show event cards dialog
                  },
                  onLifeCard: () {
                    _showLifeCardsDialog(context, gameService);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAssetSection(
    BuildContext context,
    String title,
    List<AssetCard> assets,
    GameService gameService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: assets.length,
          itemBuilder: (context, index) {
            return CardDisplay(
              card: assets[index],
              onTap: () {
                _showAssetBuyDialog(context, gameService, assets[index]);
              },
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                gameService.refreshMarketDisplay(
                  title.startsWith('1') ? 1 : title.startsWith('2') ? 2 : 3,
                );
              },
              child: const Text('Refresh (10 coins)'),
            ),
          ],
        ),
        const Divider(color: Colors.white54),
      ],
    );
  }
  
  void _showAssetBuyDialog(
    BuildContext context,
    GameService gameService,
    AssetCard asset,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(asset.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cost: ${asset.cost} coins'),
              Text('CP on purchase: ${asset.cpOnPurchase}'),
              Text('CP per round: ${asset.cpPerRound}'),
              Text('Income per round: ${asset.incomePerRound}'),
              Text('Debt upkeep: ${asset.debtUpkeep}'),
              const SizedBox(height: 16),
              Text(
                'Your money: ${gameService.currentPlayer.money} coins',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final success = gameService.buyAssetCard(
                  gameService.currentPlayer,
                  asset,
                );
                
                Navigator.of(context).pop();
                
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Not enough money or credit points!'),
                    ),
                  );
                }
              },
              child: const Text('Buy'),
            ),
          ],
        );
      },
    );
  }
  
  void _showPayDebtDialog(BuildContext context, GameService gameService) {
    int debtToPay = 0;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pay Debt'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Current debt: ${gameService.currentPlayer.debt}'),
                  Text('Your money: ${gameService.currentPlayer.money} coins'),
                  const SizedBox(height: 16),
                  const Text('How much debt to pay?'),
                  Slider(
                    value: debtToPay.toDouble(),
                    min: 0,
                    max: gameService.currentPlayer.debt.toDouble(),
                    divisions: gameService.currentPlayer.debt,
                    label: debtToPay.toString(),
                    onChanged: (double value) {
                      setState(() {
                        debtToPay = value.toInt();
                      });
                    },
                  ),
                  Text(
                    'Pay $debtToPay debt for ${debtToPay * 10} coins',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (gameService.currentPlayer.money >= debtToPay * 10) {
                      gameService.adjustDebt(gameService.currentPlayer, -debtToPay);
                      gameService.currentPlayer.money -= debtToPay * 10;
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Not enough money!'),
                        ),
                      );
                    }
                  },
                  child: const Text('Pay'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showLifeCardsDialog(BuildContext context, GameService gameService) {
    // Draw 2 life cards if player doesn't have any
    if (gameService.currentPlayer.lifeCards.isEmpty) {
      gameService.currentPlayer.lifeCards = gameService.drawLifeCards(gameService.currentPlayer, 2);
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Life Cards'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: gameService.currentPlayer.lifeCards.length,
              itemBuilder: (context, index) {
                final card = gameService.currentPlayer.lifeCards[index];
                return ListTile(
                  title: Text(card.name),
                  subtitle: Text(card.description),
                  trailing: ElevatedButton(
                    onPressed: () {
                      gameService.resolveLifeCard(gameService.currentPlayer, card);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Resolve'),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
