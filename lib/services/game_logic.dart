import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:credit_mania/models/card.dart';
import 'package:credit_mania/models/player.dart';
import 'package:credit_mania/models/game_state.dart';
import 'package:credit_mania/repositories/game_repository.dart';

class GameLogic extends ChangeNotifier {
  final GameRepository gameRepository;
  
  // Game state
  GameState _gameState = GameState.setup;
  List<Player> _players = [];
  int _currentPlayerIndex = 0;
  int _currentRound = 1;
  int _currentPhase = 0;
  
  // Card decks
  List<AssetCard> _assetDeck1Star = [];
  List<AssetCard> _assetDeck2Star = [];
  List<AssetCard> _assetDeck3Star = [];
  List<EventCard> _eventDeck = [];
  List<LifeCard> _lifeDeck = [];
  List<AvatarCard> _avatarDeck = [];
  
  // Market display
  List<AssetCard> _marketDisplay1Star = [];
  List<AssetCard> _marketDisplay2Star = [];
  List<AssetCard> _marketDisplay3Star = [];
  
  // Current event
  EventCard? _currentEvent;
  
  // Game session
  String? _gameSessionId;
  bool _isOnlineGame = false;
  
  // Random generator
  final Random _random = Random();
  
  // Getters
  GameState get gameState => _gameState;
  List<Player> get players => _players;
  Player get currentPlayer => _players[_currentPlayerIndex];
  int get currentRound => _currentRound;
  int get currentPhase => _currentPhase;
  List<AssetCard> get marketDisplay1Star => _marketDisplay1Star;
  List<AssetCard> get marketDisplay2Star => _marketDisplay2Star;
  List<AssetCard> get marketDisplay3Star => _marketDisplay3Star;
  EventCard? get currentEvent => _currentEvent;
  
  // Constructor
  GameLogic({required this.gameRepository});
  
  // Initialize game
  Future<void> initializeGame({
    required List<String> playerNames,
    bool isOnlineGame = false,
    String? gameSessionId,
  }) async {
    _isOnlineGame = isOnlineGame;
    _gameSessionId = gameSessionId;
    
    // Reset game state
    _gameState = GameState.setup;
    _players = [];
    _currentPlayerIndex = 0;
    _currentRound = 1;
    _currentPhase = 0;
    
    // Initialize card decks
    await _initializeCardDecks();
    
    // Create players
    _createPlayers(playerNames);
    
    // Initialize market display
    _initializeMarketDisplay();
    
    // Set game state to ready
    _gameState = GameState.ready;
    
    // Save game state if online
    if (_isOnlineGame && _gameSessionId != null) {
      await _saveGameState();
    }
    
    notifyListeners();
  }
  
  // Start game
  void startGame() {
    if (_gameState == GameState.ready) {
      _gameState = GameState.playing;
      _startRound();
      notifyListeners();
    }
  }
  
  // Initialize card decks
  Future<void> _initializeCardDecks() async {
    // In a real implementation, these would be loaded from a database or asset files
    // For now, we'll create some sample cards
    
    // Asset cards - 1 Star
    _assetDeck1Star = [
      AssetCard(
        id: 'asset_1_1',
        name: 'Bank Stocks',
        starLevel: 1,
        cost: 20,
        cpOnPurchase: 1,
        cpPerRound: 0,
        incomePerRound: 2,
        debtUpkeep: 0,
        imageAsset: 'assets/images/bank_stocks.png',
      ),
      AssetCard(
        id: 'asset_1_2',
        name: 'Small Business',
        starLevel: 1,
        cost: 15,
        cpOnPurchase: 2,
        cpPerRound: 0,
        incomePerRound: 1,
        debtUpkeep: 0,
        imageAsset: 'assets/images/small_business.png',
      ),
      AssetCard(
        id: 'asset_1_3',
        name: 'Rental Property',
        starLevel: 1,
        cost: 25,
        cpOnPurchase: 3,
        cpPerRound: 0,
        incomePerRound: 3,
        debtUpkeep: 1,
        imageAsset: 'assets/images/rental_property.png',
      ),
      AssetCard(
        id: 'asset_1_4',
        name: 'Tech Startup',
        starLevel: 1,
        cost: 30,
        cpOnPurchase: 4,
        cpPerRound: 0,
        incomePerRound: 2,
        debtUpkeep: 0,
        imageAsset: 'assets/images/tech_startup.png',
      ),
      AssetCard(
        id: 'asset_1_5',
        name: 'Food Truck',
        starLevel: 1,
        cost: 10,
        cpOnPurchase: 1,
        cpPerRound: 0,
        incomePerRound: 1,
        debtUpkeep: 0,
        imageAsset: 'assets/images/food_truck.png',
      ),
    ];
    
    // Asset cards - 2 Star
    _assetDeck2Star = [
      AssetCard(
        id: 'asset_2_1',
        name: 'Luxury Condo',
        starLevel: 2,
        cost: 50,
        cpOnPurchase: 5,
        cpPerRound: 1,
        incomePerRound: 4,
        debtUpkeep: 1,
        imageAsset: 'assets/images/luxury_condo.png',
      ),
      AssetCard(
        id: 'asset_2_2',
        name: 'Sport Center',
        starLevel: 2,
        cost: 60,
        cpOnPurchase: 6,
        cpPerRound: 1,
        incomePerRound: 5,
        debtUpkeep: 2,
        imageAsset: 'assets/images/sport_center.png',
      ),
      AssetCard(
        id: 'asset_2_3',
        name: 'Gold',
        starLevel: 2,
        cost: 45,
        cpOnPurchase: 4,
        cpPerRound: 1,
        incomePerRound: 3,
        debtUpkeep: 0,
        imageAsset: 'assets/images/gold.png',
      ),
    ];
    
    // Asset cards - 3 Star
    _assetDeck3Star = [
      AssetCard(
        id: 'asset_3_1',
        name: 'Villa',
        starLevel: 3,
        cost: 100,
        cpOnPurchase: 10,
        cpPerRound: 2,
        incomePerRound: 8,
        debtUpkeep: 3,
        imageAsset: 'assets/images/villa.png',
      ),
      AssetCard(
        id: 'asset_3_2',
        name: 'Art Gallery',
        starLevel: 3,
        cost: 90,
        cpOnPurchase: 9,
        cpPerRound: 2,
        incomePerRound: 7,
        debtUpkeep: 2,
        imageAsset: 'assets/images/art_gallery.png',
      ),
    ];
    
    // Event cards
    _eventDeck = [
      EventCard(
        id: 'event_1',
        name: 'Market Crash',
        description: 'All players lose 5 CP',
        phase: 0,
        effect: (players) {
          for (var player in players) {
            player.creditPoints = max(0, player.creditPoints - 5);
          }
        },
        imageAsset: 'assets/images/market_crash.png',
      ),
      EventCard(
        id: 'event_2',
        name: 'Economic Boom',
        description: 'All players gain 3 CP',
        phase: 0,
        effect: (players) {
          for (var player in players) {
            player.creditPoints += 3;
          }
        },
        imageAsset: 'assets/images/economic_boom.png',
      ),
      EventCard(
        id: 'event_3',
        name: 'Tax Audit',
        description: 'Players with more than 50 CP lose 10% of their CP',
        phase: 0,
        effect: (players) {
          for (var player in players) {
            if (player.creditPoints > 50) {
              player.creditPoints -= (player.creditPoints * 0.1).round();
            }
          }
        },
        imageAsset: 'assets/images/tax_audit.png',
      ),
    ];
    
    // Life cards
    _lifeDeck = [
      LifeCard(
        id: 'life_1',
        name: 'Lottery Win',
        description: 'Gain 20 coins',
        effect: (player) {
          player.money += 20;
        },
        imageAsset: 'assets/images/lottery_win.png',
      ),
      LifeCard(
        id: 'life_2',
        name: 'Medical Emergency',
        description: 'Lose 15 coins',
        effect: (player) {
          player.money = max(0, player.money - 15);
        },
        imageAsset: 'assets/images/medical_emergency.png',
      ),
      LifeCard(
        id: 'life_3',
        name: 'Credit Score Boost',
        description: 'Gain 5 CP',
        effect: (player) {
          player.creditPoints += 5;
        },
        imageAsset: 'assets/images/credit_score_boost.png',
      ),
      LifeCard(
        id: 'life_4',
        name: 'Debt Consolidation',
        description: 'Reduce debt by 2',
        effect: (player) {
          player.debt = max(0, player.debt - 2);
        },
        imageAsset: 'assets/images/debt_consolidation.png',
      ),
    ];
    
    // Avatar cards
    _avatarDeck = [
      AvatarCard(
        id: 'avatar_1',
        name: 'Business Dog',
        startingCp: 10,
        startingDebt: 2,
        startingIncome: 5,
        ability: 'Roll one extra die for income',
        imageAsset: 'assets/images/business_dog.png',
      ),
      AvatarCard(
        id: 'avatar_2',
        name: 'Finance Cat',
        startingCp: 12,
        startingDebt: 3,
        startingIncome: 4,
        ability: 'Pay 1 less when reducing debt',
        imageAsset: 'assets/images/finance_cat.png',
      ),
      AvatarCard(
        id: 'avatar_3',
        name: 'Investor Rabbit',
        startingCp: 8,
        startingDebt: 1,
        startingIncome: 6,
        ability: 'Get 1 extra CP when buying assets',
        imageAsset: 'assets/images/investor_rabbit.png',
      ),
    ];
    
    // Shuffle decks
    _assetDeck1Star.shuffle(_random);
    _assetDeck2Star.shuffle(_random);
    _assetDeck3Star.shuffle(_random);
    _eventDeck.shuffle(_random);
    _lifeDeck.shuffle(_random);
    _avatarDeck.shuffle(_random);
  }
  
  // Create players
  void _createPlayers(List<String> playerNames) {
    _players = [];
    
    for (int i = 0; i < playerNames.length; i++) {
      // Get a random avatar card
      final avatarIndex = i % _avatarDeck.length;
      final avatar = _avatarDeck[avatarIndex];
      
      // Create player
      final player = Player(
        id: 'player_$i',
        name: playerNames[i],
        avatar: avatar,
        creditPoints: avatar.startingCp,
        debt: avatar.startingDebt,
        money: 100, // Starting money
        income: avatar.startingIncome,
        assets: [],
        lifeCards: [],
      );
      
      _players.add(player);
    }
  }
  
  // Initialize market display
  void _initializeMarketDisplay() {
    _marketDisplay1Star = _drawCards(_assetDeck1Star, 3);
    _marketDisplay2Star = _drawCards(_assetDeck2Star, 2);
    _marketDisplay3Star = _drawCards(_assetDeck3Star, 1);
  }
  
  // Draw cards from a deck
  List<T> _drawCards<T>(List<T> deck, int count) {
    final drawnCards = <T>[];
    
    for (int i = 0; i < count && deck.isNotEmpty; i++) {
      drawnCards.add(deck.removeAt(0));
    }
    
    return drawnCards;
  }
  
  // Start a new round
  void _startRound() {
    _currentRound++;
    _currentPhase = 0;
    _startPhase();
  }
  
  // Start a phase
  void _startPhase() {
    switch (_currentPhase) {
      case 0: // Event phase
        _startEventPhase();
        break;
      case 1: // Income phase
        _startIncomePhase();
        break;
      case 2: // Life cards phase
        _startLifeCardsPhase();
        break;
      case 3: // Asset phase
        _startAssetPhase();
        break;
      case 4: // Scoring phase
        _startScoringPhase();
        break;
    }
    
    notifyListeners();
  }
  
  // Start event phase
  void _startEventPhase() {
    if (_eventDeck.isNotEmpty) {
      _currentEvent = _eventDeck.removeAt(0);
      _currentEvent!.effect(_players);
    }
  }
  
  // Start income phase
  void _startIncomePhase() {
    for (var player in _players) {
      // Add income
      player.money += player.totalIncome;
      
      // Pay debt upkeep
      final debtUpkeep = player.totalDebtUpkeep;
      if (debtUpkeep > 0) {
        player.money = max(0, player.money - debtUpkeep * 10);
      }
    }
  }
  
  // Start life cards phase
  void _startLifeCardsPhase() {
    // Each player can draw life cards in their turn
    // This is handled by the UI
  }
  
  // Start asset phase
  void _startAssetPhase() {
    // Players can buy assets in their turn
    // This is handled by the UI
  }
  
  // Start scoring phase
  void _startScoringPhase() {
    for (var player in _players) {
      // Add CP from assets
      player.creditPoints += player.totalCpPerRound;
    }
    
    // Check for game end
    if (_checkGameEnd()) {
      _endGame();
    } else {
      // Move to next round
      _startRound();
    }
  }
  
  // Check if game should end
  bool _checkGameEnd() {
    // Game ends when a player reaches 100 CP
    for (var player in _players) {
      if (player.creditPoints >= 100) {
        return true;
      }
    }
    
    // Or after 10 rounds
    return _currentRound >= 10;
  }
  
  // End the game
  void _endGame() {
    _gameState = GameState.ended;
    
    // Sort players by CP
    _players.sort((a, b) => b.creditPoints.compareTo(a.creditPoints));
    
    notifyListeners();
  }
  
  // Move to next phase
  void nextPhase() {
    if (_gameState == GameState.playing) {
      _currentPhase = (_currentPhase + 1) % 5;
      _startPhase();
    }
  }
  
  // End current player's turn
  void endTurn() {
    if (_gameState == GameState.playing) {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
      
      // If we've gone through all players, move to next phase
      if (_currentPlayerIndex == 0) {
        nextPhase();
      }
      
      notifyListeners();
    }
  }
  
  // Refresh market display
  void refreshMarketDisplay(int starLevel) {
    if (_gameState == GameState.playing) {
      // Check if player has enough money
      if (currentPlayer.money >= 10) {
        currentPlayer.money -= 10;
        
        switch (starLevel) {
          case 1:
            // Return current cards to deck
            _assetDeck1Star.addAll(_marketDisplay1Star);
            _assetDeck1Star.shuffle(_random);
            
            // Draw new cards
            _marketDisplay1Star = _drawCards(_assetDeck1Star, 3);
            break;
          case 2:
            // Return current cards to deck
            _assetDeck2Star.addAll(_marketDisplay2Star);
            _assetDeck2Star.shuffle(_random);
            
            // Draw new cards
            _marketDisplay2Star = _drawCards(_assetDeck2Star, 2);
            break;
          case 3:
            // Return current cards to deck
            _assetDeck3Star.addAll(_marketDisplay3Star);
            _assetDeck3Star.shuffle(_random);
            
            // Draw new cards
            _marketDisplay3Star = _drawCards(_assetDeck3Star, 1);
            break;
        }
        
        notifyListeners();
      }
    }
  }
  
  // Buy asset card
  bool buyAssetCard(Player player, AssetCard asset) {
    if (_gameState == GameState.playing) {
      // Check if player can afford the asset
      if (player.money >= asset.cost) {
        // Check if player has enough CP for the star level
        if (player.canBuyStarLevel(asset.starLevel)) {
          // Remove asset from market display
          switch (asset.starLevel) {
            case 1:
              _marketDisplay1Star.remove(asset);
              // Draw a new card if available
              if (_assetDeck1Star.isNotEmpty) {
                _marketDisplay1Star.add(_assetDeck1Star.removeAt(0));
              }
              break;
            case 2:
              _marketDisplay2Star.remove(asset);
              // Draw a new card if available
              if (_assetDeck2Star.isNotEmpty) {
                _marketDisplay2Star.add(_assetDeck2Star.removeAt(0));
              }
              break;
            case 3:
              _marketDisplay3Star.remove(asset);
              // Draw a new card if available
              if (_assetDeck3Star.isNotEmpty) {
                _marketDisplay3Star.add(_assetDeck3Star.removeAt(0));
              }
              break;
          }
          
          // Pay for asset
          player.money -= asset.cost;
          
          // Add asset to player's assets
          player.assets.add(asset);
          
          // Add CP from asset
          player.creditPoints += asset.cpOnPurchase;
          
          // Add income from asset
          player.income += asset.incomePerRound;
          
          // Add debt from asset
          player.debt += asset.debtUpkeep;
          
          notifyListeners();
          return true;
        }
      }
    }
    
    return false;
  }
  
  // Draw life cards
  List<LifeCard> drawLifeCards(Player player, int count) {
    final drawnCards = <LifeCard>[];
    
    if (_gameState == GameState.playing) {
      drawnCards.addAll(_drawCards(_lifeDeck, count));
      
      // If we've drawn all cards, reshuffle the deck
      if (_lifeDeck.isEmpty) {
        _lifeDeck.shuffle(_random);
      }
    }
    
    return drawnCards;
  }
  
  // Resolve life card
  void resolveLifeCard(Player player, LifeCard card) {
    if (_gameState == GameState.playing) {
      // Apply card effect
      card.effect(player);
      
      // Remove card from player's hand
      player.lifeCards.remove(card);
      
      // Add card back to deck
      _lifeDeck.add(card);
      
      notifyListeners();
    }
  }
  
  // Roll dice for income
  int rollDiceForIncome(Player player) {
    if (_gameState == GameState.playing) {
      // Get number of dice based on CP
      int diceCount = player.getDiceCount();
      
      // Roll dice
      int total = 0;
      for (int i = 0; i < diceCount; i++) {
        total += _random.nextInt(6) + 1; // 1-6
      }
      
      // Add income
      player.money += total;
      
      notifyListeners();
      return total;
    }
    
    return 0;
  }
  
  // Adjust debt
  void adjustDebt(Player player, int amount) {
    if (_gameState == GameState.playing) {
      player.debt = max(0, player.debt + amount);
      notifyListeners();
    }
  }
  
  // Save game state
  Future<void> _saveGameState() async {
    if (_isOnlineGame && _gameSessionId != null) {
      try {
        await gameRepository.saveLocalGameState(
          gameId: _gameSessionId!,
          players: _players,
          currentPhase: _currentPhase,
          currentPlayerIndex: _currentPlayerIndex,
          marketDisplay1Star: _marketDisplay1Star,
          marketDisplay2Star: _marketDisplay2Star,
          marketDisplay3Star: _marketDisplay3Star,
        );
      } catch (e) {
        debugPrint('Failed to save game state: $e');
      }
    }
  }
  
  // Load game state
  Future<void> loadGameState(String gameId) async {
    try {
      final gameState = await gameRepository.loadLocalGameState(gameId: gameId);
      
      // TODO: Implement loading game state
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load game state: $e');
    }
  }
}
