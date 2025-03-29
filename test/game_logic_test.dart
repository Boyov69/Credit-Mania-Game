import 'package:flutter_test/flutter_test.dart';
import 'package:credit_mania/models/player.dart';
import 'package:credit_mania/models/card.dart';
import 'package:credit_mania/services/game_logic.dart';
import 'package:credit_mania/repositories/game_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([GameRepository])
import 'game_logic_test.mocks.dart';

void main() {
  late GameLogic gameLogic;
  late MockGameRepository mockGameRepository;

  setUp(() {
    mockGameRepository = MockGameRepository();
    gameLogic = GameLogic(gameRepository: mockGameRepository);
  });

  group('GameLogic Initialization Tests', () {
    test('Should initialize game with correct number of players', () async {
      // Arrange
      final playerNames = ['Player 1', 'Player 2', 'Player 3'];
      
      // Act
      await gameLogic.initializeGame(playerNames: playerNames);
      
      // Assert
      expect(gameLogic.players.length, equals(3));
      expect(gameLogic.players[0].name, equals('Player 1'));
      expect(gameLogic.players[1].name, equals('Player 2'));
      expect(gameLogic.players[2].name, equals('Player 3'));
    });

    test('Should initialize game with correct game state', () async {
      // Arrange
      final playerNames = ['Player 1', 'Player 2'];
      
      // Act
      await gameLogic.initializeGame(playerNames: playerNames);
      
      // Assert
      expect(gameLogic.gameState, equals(GameState.ready));
      expect(gameLogic.currentRound, equals(1));
      expect(gameLogic.currentPhase, equals(0));
      expect(gameLogic.currentPlayerIndex, equals(0));
    });

    test('Should initialize market display with correct number of cards', () async {
      // Arrange
      final playerNames = ['Player 1', 'Player 2'];
      
      // Act
      await gameLogic.initializeGame(playerNames: playerNames);
      
      // Assert
      expect(gameLogic.marketDisplay1Star.length, equals(3));
      expect(gameLogic.marketDisplay2Star.length, equals(2));
      expect(gameLogic.marketDisplay3Star.length, equals(1));
    });
  });

  group('Game Mechanics Tests', () {
    test('Should start game and change state to playing', () async {
      // Arrange
      final playerNames = ['Player 1', 'Player 2'];
      await gameLogic.initializeGame(playerNames: playerNames);
      
      // Act
      gameLogic.startGame();
      
      // Assert
      expect(gameLogic.gameState, equals(GameState.playing));
    });

    test('Should advance to next phase correctly', () async {
      // Arrange
      final playerNames = ['Player 1', 'Player 2'];
      await gameLogic.initializeGame(playerNames: playerNames);
      gameLogic.startGame();
      final initialPhase = gameLogic.currentPhase;
      
      // Act
      gameLogic.nextPhase();
      
      // Assert
      expect(gameLogic.currentPhase, equals((initialPhase + 1) % 5));
    });

    test('Should end turn and move to next player', () async {
      // Arrange
      final playerNames = ['Player 1', 'Player 2', 'Player 3'];
      await gameLogic.initializeGame(playerNames: playerNames);
      gameLogic.startGame();
      final initialPlayerIndex = gameLogic.currentPlayerIndex;
      
      // Act
      gameLogic.endTurn();
      
      // Assert
      expect(gameLogic.currentPlayerIndex, equals((initialPlayerIndex + 1) % 3));
    });

    test('Should buy asset card successfully', () async {
      // Arrange
      final playerNames = ['Player 1', 'Player 2'];
      await gameLogic.initializeGame(playerNames: playerNames);
      gameLogic.startGame();
      
      final player = gameLogic.players[0];
      player.money = 100; // Ensure player has enough money
      player.creditPoints = 30; // Ensure player has enough CP for star level
      
      final assetCard = gameLogic.marketDisplay1Star[0];
      final initialMoney = player.money;
      final initialCp = player.creditPoints;
      final initialAssetCount = player.assets.length;
      
      // Act
      final result = gameLogic.buyAssetCard(player, assetCard);
      
      // Assert
      expect(result, isTrue);
      expect(player.money, equals(initialMoney - assetCard.cost));
      expect(player.creditPoints, equals(initialCp + assetCard.cpOnPurchase));
      expect(player.assets.length, equals(initialAssetCount + 1));
      expect(player.assets.last, equals(assetCard));
    });

    test('Should not buy asset card if player has insufficient money', () async {
      // Arrange
      final playerNames = ['Player 1', 'Player 2'];
      await gameLogic.initializeGame(playerNames: playerNames);
      gameLogic.startGame();
      
      final player = gameLogic.players[0];
      player.money = 5; // Ensure player has insufficient money
      player.creditPoints = 30; // Ensure player has enough CP for star level
      
      final assetCard = gameLogic.marketDisplay1Star[0];
      final initialMoney = player.money;
      final initialCp = player.creditPoints;
      final initialAssetCount = player.assets.length;
      
      // Act
      final result = gameLogic.buyAssetCard(player, assetCard);
      
      // Assert
      expect(result, isFalse);
      expect(player.money, equals(initialMoney));
      expect(player.creditPoints, equals(initialCp));
      expect(player.assets.length, equals(initialAssetCount));
    });

    test('Should roll dice for income correctly', () async {
      // Arrange
      final playerNames = ['Player 1', 'Player 2'];
      await gameLogic.initializeGame(playerNames: playerNames);
      gameLogic.startGame();
      
      final player = gameLogic.players[0];
      final initialMoney = player.money;
      
      // Act
      final diceResult = gameLogic.rollDiceForIncome(player);
      
      // Assert
      expect(diceResult, greaterThan(0));
      expect(player.money, equals(initialMoney + diceResult));
    });

    test('Should adjust debt correctly', () async {
      // Arrange
      final playerNames = ['Player 1', 'Player 2'];
      await gameLogic.initializeGame(playerNames: playerNames);
      gameLogic.startGame();
      
      final player = gameLogic.players[0];
      final initialDebt = player.debt;
      
      // Act
      gameLogic.adjustDebt(player, 3);
      
      // Assert
      expect(player.debt, equals(initialDebt + 3));
    });
  });

  group('Game State Management Tests', () {
    test('Should save game state for online game', () async {
      // Arrange
      final playerNames = ['Player 1', 'Player 2'];
      final gameSessionId = 'test_game_session';
      
      when(mockGameRepository.saveLocalGameState(
        gameId: anyNamed('gameId'),
        players: anyNamed('players'),
        currentPhase: anyNamed('currentPhase'),
        currentPlayerIndex: anyNamed('currentPlayerIndex'),
        marketDisplay1Star: anyNamed('marketDisplay1Star'),
        marketDisplay2Star: anyNamed('marketDisplay2Star'),
        marketDisplay3Star: anyNamed('marketDisplay3Star'),
      )).thenAnswer((_) async {});
      
      // Act
      await gameLogic.initializeGame(
        playerNames: playerNames,
        isOnlineGame: true,
        gameSessionId: gameSessionId,
      );
      
      // Assert
      verify(mockGameRepository.saveLocalGameState(
        gameId: gameSessionId,
        players: anyNamed('players'),
        currentPhase: anyNamed('currentPhase'),
        currentPlayerIndex: anyNamed('currentPlayerIndex'),
        marketDisplay1Star: anyNamed('marketDisplay1Star'),
        marketDisplay2Star: anyNamed('marketDisplay2Star'),
        marketDisplay3Star: anyNamed('marketDisplay3Star'),
      )).called(1);
    });
  });
}
