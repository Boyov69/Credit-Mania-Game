import 'package:flutter/foundation.dart';
import 'package:credit_mania/models/player.dart';
import 'package:credit_mania/models/card.dart';
import 'package:credit_mania/models/game_state.dart';

class GameService extends ChangeNotifier {
  late GameState _gameState;
  List<Player> _players = [];
  int _currentPlayerIndex = 0;
  int _currentPhase = 0;
  
  // Game phases
  static const int EVENT_PHASE = 0;
  static const int INCOME_PHASE = 1;
  static const int LIFE_CARDS_PHASE = 2;
  static const int ASSET_PHASE = 3;
  static const int SCORING_PHASE = 4;
  
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
  
  GameService() {
    _initializeGame();
  }
  
  // Getters
  GameState get gameState => _gameState;
  List<Player> get players => _players;
  Player get currentPlayer => _players[_currentPlayerIndex];
  int get currentPhase => _currentPhase;
  List<AssetCard> get marketDisplay1Star => _marketDisplay1Star;
  List<AssetCard> get marketDisplay2Star => _marketDisplay2Star;
  List<AssetCard> get marketDisplay3Star => _marketDisplay3Star;
  EventCard? get currentEvent => _currentEvent;
  
  // Initialize game
  void _initializeGame() {
    _gameState = GameState.setup;
    _initializeDecks();
    notifyListeners();
  }
  
  // Initialize card decks
  void _initializeDecks() {
    // Initialize asset decks
    _assetDeck1Star = _createAssetDeck1Star();
    _assetDeck2Star = _createAssetDeck2Star();
    _assetDeck3Star = _createAssetDeck3Star();
    
    // Initialize event deck
    _eventDeck = _createEventDeck();
    
    // Initialize life deck
    _lifeDeck = _createLifeDeck();
    
    // Initialize avatar deck
    _avatarDeck = _createAvatarDeck();
    
    // Shuffle all decks
    _shuffleDecks();
  }
  
  // Create asset decks
  List<AssetCard> _createAssetDeck1Star() {
    // In a real implementation, this would load card data from a JSON file or database
    return [
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
      // Add more 1-star asset cards here
    ];
  }
  
  List<AssetCard> _createAssetDeck2Star() {
    return [
      AssetCard(
        id: 'asset_2_1',
        name: 'Luxury Condo',
        starLevel: 2,
        cost: 50,
        cpOnPurchase: 2,
        cpPerRound: 1,
        incomePerRound: 5,
        debtUpkeep: 1,
        imageAsset: 'assets/images/luxury_condo.png',
      ),
      // Add more 2-star asset cards here
    ];
  }
  
  List<AssetCard> _createAssetDeck3Star() {
    return [
      AssetCard(
        id: 'asset_3_1',
        name: 'Sport Center',
        starLevel: 3,
        cost: 100,
        cpOnPurchase: 5,
        cpPerRound: 2,
        incomePerRound: 10,
        debtUpkeep: 2,
        imageAsset: 'assets/images/sport_center.png',
      ),
      // Add more 3-star asset cards here
    ];
  }
  
  // Create event deck
  List<EventCard> _createEventDeck() {
    return [
      EventCard(
        id: 'event_1',
        name: 'Market Crash',
        description: 'All players lose 10 coins',
        phase: INCOME_PHASE,
        effect: (List<Player> players) {
          for (var player in players) {
            player.money = player.money > 10 ? player.money - 10 : 0;
          }
        },
        imageAsset: 'assets/images/market_crash.png',
      ),
      // Add more event cards here
    ];
  }
  
  // Create life deck
  List<LifeCard> _createLifeDeck() {
    return [
      LifeCard(
        id: 'life_1',
        name: 'Promotion',
        description: 'Gain 2 CP and 20 coins',
        effect: (Player player) {
          player.creditPoints += 2;
          player.money += 20;
        },
        imageAsset: 'assets/images/promotion.png',
      ),
      // Add more life cards here
    ];
  }
  
  // Create avatar deck
  List<AvatarCard> _createAvatarDeck() {
    return [
      AvatarCard(
        id: 'avatar_1',
        name: 'Business Dog',
        startingCp: 10,
        startingDebt: 2,
        startingIncome: 5,
        ability: 'Roll one extra die for income',
        imageAsset: 'assets/images/business_dog.png',
      ),
      // Add more avatar cards here
    ];
  }
  
  // Shuffle all decks
  void _shuffleDecks() {
    _assetDeck1Star.shuffle();
    _assetDeck2Star.shuffle();
    _assetDeck3Star.shuffle();
    _eventDeck.shuffle();
    _lifeDeck.shuffle();
    _avatarDeck.shuffle();
  }
  
  // Setup game with players
  void setupGame(int numberOfPlayers) {
    _players = [];
    
    // Create players with random avatars
    for (int i = 0; i < numberOfPlayers; i++) {
      if (_avatarDeck.isEmpty) {
        // If we run out of avatars, reshuffle the deck
        _avatarDeck = _createAvatarDeck();
        _avatarDeck.shuffle();
      }
      
      AvatarCard avatar = _avatarDeck.removeAt(0);
      
      _players.add(Player(
        id: 'player_$i',
        name: 'Player ${i + 1}',
        avatar: avatar,
        creditPoints: avatar.startingCp,
        debt: avatar.startingDebt,
        money: 100, // Starting money
        income: avatar.startingIncome,
        assets: [],
        lifeCards: [],
      ));
    }
    
    // Setup initial market display
    _setupMarketDisplay();
    
    // Set game state to ready
    _gameState = GameState.ready;
    notifyListeners();
  }
  
  // Setup market display
  void _setupMarketDisplay() {
    _marketDisplay1Star = [];
    _marketDisplay2Star = [];
    _marketDisplay3Star = [];
    
    // Add cards to market display
    for (int i = 0; i < 4; i++) {
      if (_assetDeck1Star.isNotEmpty) {
        _marketDisplay1Star.add(_assetDeck1Star.removeAt(0));
      }
    }
    
    for (int i = 0; i < 3; i++) {
      if (_assetDeck2Star.isNotEmpty) {
        _marketDisplay2Star.add(_assetDeck2Star.removeAt(0));
      }
    }
    
    for (int i = 0; i < 2; i++) {
      if (_assetDeck3Star.isNotEmpty) {
        _marketDisplay3Star.add(_assetDeck3Star.removeAt(0));
      }
    }
  }
  
  // Start game
  void startGame() {
    if (_gameState == GameState.ready) {
      _gameState = GameState.playing;
      _currentPlayerIndex = 0;
      _currentPhase = EVENT_PHASE;
      _startRound();
      notifyListeners();
    }
  }
  
  // Start a new round
  void _startRound() {
    // Draw event card
    if (_eventDeck.isNotEmpty) {
      _currentEvent = _eventDeck.removeAt(0);
    }
    
    notifyListeners();
  }
  
  // Move to next phase
  void nextPhase() {
    _currentPhase = (_currentPhase + 1) % 5;
    
    if (_currentPhase == EVENT_PHASE) {
      // If we're back to the event phase, it's a new round
      _startRound();
    }
    
    notifyListeners();
  }
  
  // Move to next player
  void nextPlayer() {
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    
    // If we've gone through all players, move to next phase
    if (_currentPlayerIndex == 0) {
      nextPhase();
    }
    
    notifyListeners();
  }
  
  // Roll dice for income
  int rollDiceForIncome(Player player) {
    // Determine number of dice based on player's credit points
    int numberOfDice = 1;
    
    if (player.creditPoints >= 45) {
      numberOfDice = 3;
    } else if (player.creditPoints >= 20) {
      numberOfDice = 2;
    }
    
    // Roll dice and calculate income
    int total = 0;
    for (int i = 0; i < numberOfDice; i++) {
      total += (DateTime.now().millisecondsSinceEpoch % 6) + 1; // Simple random dice roll
    }
    
    return total * 2; // Income is 2x the dice roll
  }
  
  // Buy asset card
  bool buyAssetCard(Player player, AssetCard card) {
    // Check if player can afford the card
    if (player.money < card.cost) {
      return false;
    }
    
    // Check if player has enough credit points for the card's star level
    if (card.starLevel == 2 && player.creditPoints < 20) {
      return false;
    }
    
    if (card.starLevel == 3 && player.creditPoints < 45) {
      return false;
    }
    
    // Buy the card
    player.money -= card.cost;
    player.assets.add(card);
    player.creditPoints += card.cpOnPurchase;
    player.income += card.incomePerRound;
    
    // Remove card from market display and replace it
    if (card.starLevel == 1) {
      _marketDisplay1Star.remove(card);
      if (_assetDeck1Star.isNotEmpty) {
        _marketDisplay1Star.add(_assetDeck1Star.removeAt(0));
      }
    } else if (card.starLevel == 2) {
      _marketDisplay2Star.remove(card);
      if (_assetDeck2Star.isNotEmpty) {
        _marketDisplay2Star.add(_assetDeck2Star.removeAt(0));
      }
    } else if (card.starLevel == 3) {
      _marketDisplay3Star.remove(card);
      if (_assetDeck3Star.isNotEmpty) {
        _marketDisplay3Star.add(_assetDeck3Star.removeAt(0));
      }
    }
    
    notifyListeners();
    return true;
  }
  
  // Refresh market display for a specific star level
  void refreshMarketDisplay(int starLevel) {
    if (currentPlayer.money < 10) {
      return; // Not enough money to refresh
    }
    
    currentPlayer.money -= 10;
    
    if (starLevel == 1) {
      _marketDisplay1Star.clear();
      for (int i = 0; i < 4; i++) {
        if (_assetDeck1Star.isNotEmpty) {
          _marketDisplay1Star.add(_assetDeck1Star.removeAt(0));
        }
      }
    } else if (starLevel == 2) {
      _marketDisplay2Star.clear();
      for (int i = 0; i < 3; i++) {
        if (_assetDeck2Star.isNotEmpty) {
          _marketDisplay2Star.add(_assetDeck2Star.removeAt(0));
        }
      }
    } else if (starLevel == 3) {
      _marketDisplay3Star.clear();
      for (int i = 0; i < 2; i++) {
        if (_assetDeck3Star.isNotEmpty) {
          _marketDisplay3Star.add(_assetDeck3Star.removeAt(0));
        }
      }
    }
    
    notifyListeners();
  }
  
  // Draw life cards for a player
  List<LifeCard> drawLifeCards(Player player, int count) {
    List<LifeCard> drawnCards = [];
    
    for (int i = 0; i < count; i++) {
      if (_lifeDeck.isEmpty) {
        // Reshuffle discard pile if deck is empty
        _lifeDeck = _createLifeDeck();
        _lifeDeck.shuffle();
      }
      
      if (_lifeDeck.isNotEmpty) {
        drawnCards.add(_lifeDeck.removeAt(0));
      }
    }
    
    notifyListeners();
    return drawnCards;
  }
  
  // Resolve life card
  void resolveLifeCard(Player player, LifeCard card) {
    // Apply card effect
    card.effect(player);
    
    // Remove card from player's hand
    player.lifeCards.remove(card);
    
    notifyListeners();
  }
  
  // Get or pay debt
  void adjustDebt(Player player, int amount) {
    player.debt += amount;
    
    if (amount > 0) {
      // Getting debt (loan)
      player.money += amount * 20; // 20 coins per debt
    }
    
    // Check for bankruptcy
    if (player.debt > 20) { // Assuming 20 is the max debt
      _handleBankruptcy(player);
    }
    
    notifyListeners();
  }
  
  // Handle player bankruptcy
  void _handleBankruptcy(Player player) {
    // In a real implementation, this would handle the bankruptcy rules
    player.debt = 20; // Cap at max
    player.money = 0;
    player.creditPoints = player.creditPoints > 5 ? player.creditPoints - 5 : 0;
    
    notifyListeners();
  }
  
  // Score CP from assets
  void scoreAssetsCP(Player player) {
    int cpGained = 0;
    int debtGained = 0;
    
    for (var asset in player.assets) {
      cpGained += asset.cpPerRound;
      debtGained += asset.debtUpkeep;
    }
    
    player.creditPoints += cpGained;
    player.debt += debtGained;
    
    // Check for game end
    if (player.creditPoints >= 100) {
      _gameState = GameState.ended;
    }
    
    // Check for bankruptcy
    if (player.debt > 20) {
      _handleBankruptcy(player);
    }
    
    notifyListeners();
  }
  
  // End turn
  void endTurn() {
    nextPlayer();
  }
  
  // Reset game
  void resetGame() {
    _initializeGame();
  }
}
