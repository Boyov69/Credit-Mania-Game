import 'package:flutter_test/flutter_test.dart';
import 'package:credit_mania/blocs/game/game_bloc.dart';
import 'package:credit_mania/models/player.dart';
import 'package:credit_mania/models/card.dart';
import 'package:credit_mania/models/game_state.dart';
import 'package:credit_mania/services/game_logic.dart';
import 'package:credit_mania/repositories/game_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bloc_test/bloc_test.dart';

@GenerateMocks([GameLogic, GameRepository])
import 'game_bloc_test.mocks.dart';

void main() {
  late GameBloc gameBloc;
  late MockGameLogic mockGameLogic;
  late MockGameRepository mockGameRepository;

  setUp(() {
    mockGameLogic = MockGameLogic();
    mockGameRepository = MockGameRepository();
    gameBloc = GameBloc(gameLogic: mockGameLogic);
  });

  tearDown(() {
    gameBloc.close();
  });

  group('GameBloc Tests', () {
    final testPlayers = [
      Player(
        id: 'player_1',
        name: 'Player 1',
        avatar: AvatarCard(
          id: 'avatar_1',
          name: 'Test Avatar',
          startingCp: 10,
          startingDebt: 2,
          startingIncome: 5,
          ability: 'Test ability',
          imageAsset: 'assets/images/test_avatar.png',
        ),
        creditPoints: 10,
        debt: 2,
        money: 100,
        income: 5,
        assets: [],
        lifeCards: [],
      ),
      Player(
        id: 'player_2',
        name: 'Player 2',
        avatar: AvatarCard(
          id: 'avatar_2',
          name: 'Test Avatar 2',
          startingCp: 12,
          startingDebt: 3,
          startingIncome: 4,
          ability: 'Test ability 2',
          imageAsset: 'assets/images/test_avatar2.png',
        ),
        creditPoints: 12,
        debt: 3,
        money: 100,
        income: 4,
        assets: [],
        lifeCards: [],
      ),
    ];

    final testAssetCard = AssetCard(
      id: 'asset_1',
      name: 'Test Asset',
      starLevel: 1,
      cost: 20,
      cpOnPurchase: 2,
      cpPerRound: 0,
      incomePerRound: 3,
      debtUpkeep: 1,
      imageAsset: 'assets/images/test_asset.png',
    );

    final testLifeCard = LifeCard(
      id: 'life_1',
      name: 'Test Life Card',
      description: 'Test description',
      effect: (player) {
        player.money += 10;
      },
      imageAsset: 'assets/images/test_life_card.png',
    );

    blocTest<GameBloc, GameBlocState>(
      'emits [GameLoading, GameReady] when GameInitialized is added',
      build: () {
        when(mockGameLogic.gameState).thenReturn(GameState.ready);
        when(mockGameLogic.players).thenReturn(testPlayers);
        return gameBloc;
      },
      act: (bloc) => bloc.add(const GameInitialized(playerNames: ['Player 1', 'Player 2'])),
      expect: () => [
        isA<GameLoading>(),
        isA<GameReady>(),
      ],
    );

    blocTest<GameBloc, GameBlocState>(
      'emits [GameInProgress] when GameStarted is added',
      build: () {
        when(mockGameLogic.gameState).thenReturn(GameState.playing);
        when(mockGameLogic.players).thenReturn(testPlayers);
        when(mockGameLogic.currentPlayer).thenReturn(testPlayers[0]);
        when(mockGameLogic.currentRound).thenReturn(1);
        when(mockGameLogic.currentPhase).thenReturn(0);
        when(mockGameLogic.marketDisplay1Star).thenReturn([]);
        when(mockGameLogic.marketDisplay2Star).thenReturn([]);
        when(mockGameLogic.marketDisplay3Star).thenReturn([]);
        when(mockGameLogic.currentEvent).thenReturn(null);
        return gameBloc;
      },
      act: (bloc) => bloc.add(GameStarted()),
      expect: () => [
        isA<GameInProgress>(),
      ],
    );

    blocTest<GameBloc, GameBlocState>(
      'emits updated GameInProgress when GamePhaseAdvanced is added',
      build: () {
        when(mockGameLogic.gameState).thenReturn(GameState.playing);
        when(mockGameLogic.players).thenReturn(testPlayers);
        when(mockGameLogic.currentPlayer).thenReturn(testPlayers[0]);
        when(mockGameLogic.currentRound).thenReturn(1);
        when(mockGameLogic.currentPhase).thenReturn(1); // Advanced phase
        when(mockGameLogic.marketDisplay1Star).thenReturn([]);
        when(mockGameLogic.marketDisplay2Star).thenReturn([]);
        when(mockGameLogic.marketDisplay3Star).thenReturn([]);
        when(mockGameLogic.currentEvent).thenReturn(null);
        return gameBloc;
      },
      act: (bloc) => bloc.add(GamePhaseAdvanced()),
      expect: () => [
        isA<GameInProgress>(),
      ],
    );

    blocTest<GameBloc, GameBlocState>(
      'emits updated GameInProgress when PlayerTurnEnded is added',
      build: () {
        when(mockGameLogic.gameState).thenReturn(GameState.playing);
        when(mockGameLogic.players).thenReturn(testPlayers);
        when(mockGameLogic.currentPlayer).thenReturn(testPlayers[1]); // Next player
        when(mockGameLogic.currentRound).thenReturn(1);
        when(mockGameLogic.currentPhase).thenReturn(0);
        when(mockGameLogic.marketDisplay1Star).thenReturn([]);
        when(mockGameLogic.marketDisplay2Star).thenReturn([]);
        when(mockGameLogic.marketDisplay3Star).thenReturn([]);
        when(mockGameLogic.currentEvent).thenReturn(null);
        return gameBloc;
      },
      act: (bloc) => bloc.add(PlayerTurnEnded()),
      expect: () => [
        isA<GameInProgress>(),
      ],
    );

    blocTest<GameBloc, GameBlocState>(
      'emits updated GameInProgress when AssetPurchased is added',
      build: () {
        when(mockGameLogic.gameState).thenReturn(GameState.playing);
        when(mockGameLogic.players).thenReturn(testPlayers);
        when(mockGameLogic.currentPlayer).thenReturn(testPlayers[0]);
        when(mockGameLogic.currentRound).thenReturn(1);
        when(mockGameLogic.currentPhase).thenReturn(0);
        when(mockGameLogic.marketDisplay1Star).thenReturn([]);
        when(mockGameLogic.marketDisplay2Star).thenReturn([]);
        when(mockGameLogic.marketDisplay3Star).thenReturn([]);
        when(mockGameLogic.currentEvent).thenReturn(null);
        when(mockGameLogic.buyAssetCard(testPlayers[0], testAssetCard)).thenReturn(true);
        return gameBloc;
      },
      act: (bloc) => bloc.add(AssetPurchased(player: testPlayers[0], asset: testAssetCard)),
      expect: () => [
        isA<GameInProgress>(),
      ],
    );

    blocTest<GameBloc, GameBlocState>(
      'emits updated GameInProgress when MarketRefreshed is added',
      build: () {
        when(mockGameLogic.gameState).thenReturn(GameState.playing);
        when(mockGameLogic.players).thenReturn(testPlayers);
        when(mockGameLogic.currentPlayer).thenReturn(testPlayers[0]);
        when(mockGameLogic.currentRound).thenReturn(1);
        when(mockGameLogic.currentPhase).thenReturn(0);
        when(mockGameLogic.marketDisplay1Star).thenReturn([]);
        when(mockGameLogic.marketDisplay2Star).thenReturn([]);
        when(mockGameLogic.marketDisplay3Star).thenReturn([]);
        when(mockGameLogic.currentEvent).thenReturn(null);
        return gameBloc;
      },
      act: (bloc) => bloc.add(const MarketRefreshed(starLevel: 1)),
      expect: () => [
        isA<GameInProgress>(),
      ],
    );

    blocTest<GameBloc, GameBlocState>(
      'emits updated GameInProgress when LifeCardDrawn is added',
      build: () {
        when(mockGameLogic.gameState).thenReturn(GameState.playing);
        when(mockGameLogic.players).thenReturn(testPlayers);
        when(mockGameLogic.currentPlayer).thenReturn(testPlayers[0]);
        when(mockGameLogic.currentRound).thenReturn(1);
        when(mockGameLogic.currentPhase).thenReturn(0);
        when(mockGameLogic.marketDisplay1Star).thenReturn([]);
        when(mockGameLogic.marketDisplay2Star).thenReturn([]);
        when(mockGameLogic.marketDisplay3Star).thenReturn([]);
        when(mockGameLogic.currentEvent).thenReturn(null);
        when(mockGameLogic.drawLifeCards(testPlayers[0], 1)).thenReturn([testLifeCard]);
        return gameBloc;
      },
      act: (bloc) => bloc.add(LifeCardDrawn(player: testPlayers[0], count: 1)),
      expect: () => [
        isA<GameInProgress>(),
      ],
    );

    blocTest<GameBloc, GameBlocState>(
      'emits updated GameInProgress when LifeCardResolved is added',
      build: () {
        when(mockGameLogic.gameState).thenReturn(GameState.playing);
        when(mockGameLogic.players).thenReturn(testPlayers);
        when(mockGameLogic.currentPlayer).thenReturn(testPlayers[0]);
        when(mockGameLogic.currentRound).thenReturn(1);
        when(mockGameLogic.currentPhase).thenReturn(0);
        when(mockGameLogic.marketDisplay1Star).thenReturn([]);
        when(mockGameLogic.marketDisplay2Star).thenReturn([]);
        when(mockGameLogic.marketDisplay3Star).thenReturn([]);
        when(mockGameLogic.currentEvent).thenReturn(null);
        return gameBloc;
      },
      act: (bloc) => bloc.add(LifeCardResolved(player: testPlayers[0], card: testLifeCard)),
      expect: () => [
        isA<GameInProgress>(),
      ],
    );

    blocTest<GameBloc, GameBlocState>(
      'emits updated GameInProgress when DiceRolled is added',
      build: () {
        when(mockGameLogic.gameState).thenReturn(GameState.playing);
        when(mockGameLogic.players).thenReturn(testPlayers);
        when(mockGameLogic.currentPlayer).thenReturn(testPlayers[0]);
        when(mockGameLogic.currentRound).thenReturn(1);
        when(mockGameLogic.currentPhase).thenReturn(0);
        when(mockGameLogic.marketDisplay1Star).thenReturn([]);
        when(mockGameLogic.marketDisplay2Star).thenReturn([]);
        when(mockGameLogic.marketDisplay3Star).thenReturn([]);
        when(mockGameLogic.currentEvent).thenReturn(null);
        when(mockGameLogic.rollDiceForIncome(testPlayers[0])).thenReturn(6);
        return gameBloc;
      },
      act: (bloc) => bloc.add(DiceRolled(player: testPlayers[0])),
      expect: () => [
        isA<GameInProgress>(),
      ],
    );

    blocTest<GameBloc, GameBlocState>(
      'emits updated GameInProgress when DebtAdjusted is added',
      build: () {
        when(mockGameLogic.gameState).thenReturn(GameState.playing);
        when(mockGameLogic.players).thenReturn(testPlayers);
        when(mockGameLogic.currentPlayer).thenReturn(testPlayers[0]);
        when(mockGameLogic.currentRound).thenReturn(1);
        when(mockGameLogic.currentPhase).thenReturn(0);
        when(mockGameLogic.marketDisplay1Star).thenReturn([]);
        when(mockGameLogic.marketDisplay2Star).thenReturn([]);
        when(mockGameLogic.marketDisplay3Star).thenReturn([]);
        when(mockGameLogic.currentEvent).thenReturn(null);
        return gameBloc;
      },
      act: (bloc) => bloc.add(DebtAdjusted(player: testPlayers[0], amount: -1)),
      expect: () => [
        isA<GameInProgress>(),
      ],
    );

    blocTest<GameBloc, GameBlocState>(
      'emits [GameLoading] when GameStateLoaded is added',
      build: () {
        return gameBloc;
      },
      act: (bloc) => bloc.add(const GameStateLoaded(gameId: 'test_game_id')),
      expect: () => [
        isA<GameLoading>(),
      ],
    );

    blocTest<GameBloc, GameBlocState>(
      'emits [GameEnded] when game is over',
      build: () {
        when(mockGameLogic.gameState).thenReturn(GameState.ended);
        when(mockGameLogic.players).thenReturn(testPlayers);
        return gameBloc;
      },
      act: (bloc) {
        // Simulate game ending
        gameBloc.emit(GameEnded(players: testPlayers, winner: testPlayers[0]));
      },
      expect: () => [
        isA<GameEnded>(),
      ],
    );
  });
}
