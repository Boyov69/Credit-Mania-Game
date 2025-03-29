import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:credit_mania/services/game_logic.dart';
import 'package:credit_mania/models/player.dart';
import 'package:credit_mania/models/card.dart';
import 'package:credit_mania/models/game_state.dart';

// Events
abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class GameInitialized extends GameEvent {
  final List<String> playerNames;
  final bool isOnlineGame;
  final String? gameSessionId;

  const GameInitialized({
    required this.playerNames,
    this.isOnlineGame = false,
    this.gameSessionId,
  });

  @override
  List<Object?> get props => [playerNames, isOnlineGame, gameSessionId];
}

class GameStarted extends GameEvent {}

class GamePhaseAdvanced extends GameEvent {}

class PlayerTurnEnded extends GameEvent {}

class AssetPurchased extends GameEvent {
  final Player player;
  final AssetCard asset;

  const AssetPurchased({
    required this.player,
    required this.asset,
  });

  @override
  List<Object> get props => [player, asset];
}

class MarketRefreshed extends GameEvent {
  final int starLevel;

  const MarketRefreshed({required this.starLevel});

  @override
  List<Object> get props => [starLevel];
}

class LifeCardDrawn extends GameEvent {
  final Player player;
  final int count;

  const LifeCardDrawn({
    required this.player,
    required this.count,
  });

  @override
  List<Object> get props => [player, count];
}

class LifeCardResolved extends GameEvent {
  final Player player;
  final LifeCard card;

  const LifeCardResolved({
    required this.player,
    required this.card,
  });

  @override
  List<Object> get props => [player, card];
}

class DiceRolled extends GameEvent {
  final Player player;

  const DiceRolled({required this.player});

  @override
  List<Object> get props => [player];
}

class DebtAdjusted extends GameEvent {
  final Player player;
  final int amount;

  const DebtAdjusted({
    required this.player,
    required this.amount,
  });

  @override
  List<Object> get props => [player, amount];
}

class GameStateLoaded extends GameEvent {
  final String gameId;

  const GameStateLoaded({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

// States
abstract class GameBlocState extends Equatable {
  const GameBlocState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameBlocState {}

class GameLoading extends GameBlocState {}

class GameReady extends GameBlocState {
  final List<Player> players;

  const GameReady({required this.players});

  @override
  List<Object> get props => [players];
}

class GameInProgress extends GameBlocState {
  final GameState gameState;
  final List<Player> players;
  final Player currentPlayer;
  final int currentRound;
  final int currentPhase;
  final List<AssetCard> marketDisplay1Star;
  final List<AssetCard> marketDisplay2Star;
  final List<AssetCard> marketDisplay3Star;
  final EventCard? currentEvent;
  final int lastDiceRoll;

  const GameInProgress({
    required this.gameState,
    required this.players,
    required this.currentPlayer,
    required this.currentRound,
    required this.currentPhase,
    required this.marketDisplay1Star,
    required this.marketDisplay2Star,
    required this.marketDisplay3Star,
    this.currentEvent,
    this.lastDiceRoll = 0,
  });

  @override
  List<Object?> get props => [
        gameState,
        players,
        currentPlayer,
        currentRound,
        currentPhase,
        marketDisplay1Star,
        marketDisplay2Star,
        marketDisplay3Star,
        currentEvent,
        lastDiceRoll,
      ];

  GameInProgress copyWith({
    GameState? gameState,
    List<Player>? players,
    Player? currentPlayer,
    int? currentRound,
    int? currentPhase,
    List<AssetCard>? marketDisplay1Star,
    List<AssetCard>? marketDisplay2Star,
    List<AssetCard>? marketDisplay3Star,
    EventCard? currentEvent,
    int? lastDiceRoll,
  }) {
    return GameInProgress(
      gameState: gameState ?? this.gameState,
      players: players ?? this.players,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      currentRound: currentRound ?? this.currentRound,
      currentPhase: currentPhase ?? this.currentPhase,
      marketDisplay1Star: marketDisplay1Star ?? this.marketDisplay1Star,
      marketDisplay2Star: marketDisplay2Star ?? this.marketDisplay2Star,
      marketDisplay3Star: marketDisplay3Star ?? this.marketDisplay3Star,
      currentEvent: currentEvent ?? this.currentEvent,
      lastDiceRoll: lastDiceRoll ?? this.lastDiceRoll,
    );
  }
}

class GameEnded extends GameBlocState {
  final List<Player> players;
  final Player winner;

  const GameEnded({
    required this.players,
    required this.winner,
  });

  @override
  List<Object> get props => [players, winner];
}

class GameError extends GameBlocState {
  final String message;

  const GameError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class GameBloc extends Bloc<GameEvent, GameBlocState> {
  final GameLogic gameLogic;

  GameBloc({required this.gameLogic}) : super(GameInitial()) {
    on<GameInitialized>(_onGameInitialized);
    on<GameStarted>(_onGameStarted);
    on<GamePhaseAdvanced>(_onGamePhaseAdvanced);
    on<PlayerTurnEnded>(_onPlayerTurnEnded);
    on<AssetPurchased>(_onAssetPurchased);
    on<MarketRefreshed>(_onMarketRefreshed);
    on<LifeCardDrawn>(_onLifeCardDrawn);
    on<LifeCardResolved>(_onLifeCardResolved);
    on<DiceRolled>(_onDiceRolled);
    on<DebtAdjusted>(_onDebtAdjusted);
    on<GameStateLoaded>(_onGameStateLoaded);

    // Listen to changes in game logic
    gameLogic.addListener(_onGameLogicChanged);
  }

  void _onGameLogicChanged() {
    if (gameLogic.gameState == GameState.ready) {
      emit(GameReady(players: gameLogic.players));
    } else if (gameLogic.gameState == GameState.playing) {
      emit(GameInProgress(
        gameState: gameLogic.gameState,
        players: gameLogic.players,
        currentPlayer: gameLogic.currentPlayer,
        currentRound: gameLogic.currentRound,
        currentPhase: gameLogic.currentPhase,
        marketDisplay1Star: gameLogic.marketDisplay1Star,
        marketDisplay2Star: gameLogic.marketDisplay2Star,
        marketDisplay3Star: gameLogic.marketDisplay3Star,
        currentEvent: gameLogic.currentEvent,
      ));
    } else if (gameLogic.gameState == GameState.ended) {
      emit(GameEnded(
        players: gameLogic.players,
        winner: gameLogic.players.first, // Assuming players are sorted by CP
      ));
    }
  }

  Future<void> _onGameInitialized(
    GameInitialized event,
    Emitter<GameBlocState> emit,
  ) async {
    emit(GameLoading());
    try {
      await gameLogic.initializeGame(
        playerNames: event.playerNames,
        isOnlineGame: event.isOnlineGame,
        gameSessionId: event.gameSessionId,
      );
    } catch (e) {
      emit(GameError(message: e.toString()));
    }
  }

  void _onGameStarted(
    GameStarted event,
    Emitter<GameBlocState> emit,
  ) {
    gameLogic.startGame();
  }

  void _onGamePhaseAdvanced(
    GamePhaseAdvanced event,
    Emitter<GameBlocState> emit,
  ) {
    gameLogic.nextPhase();
  }

  void _onPlayerTurnEnded(
    PlayerTurnEnded event,
    Emitter<GameBlocState> emit,
  ) {
    gameLogic.endTurn();
  }

  void _onAssetPurchased(
    AssetPurchased event,
    Emitter<GameBlocState> emit,
  ) {
    gameLogic.buyAssetCard(event.player, event.asset);
  }

  void _onMarketRefreshed(
    MarketRefreshed event,
    Emitter<GameBlocState> emit,
  ) {
    gameLogic.refreshMarketDisplay(event.starLevel);
  }

  void _onLifeCardDrawn(
    LifeCardDrawn event,
    Emitter<GameBlocState> emit,
  ) {
    final lifeCards = gameLogic.drawLifeCards(event.player, event.count);
    event.player.lifeCards.addAll(lifeCards);
    
    if (state is GameInProgress) {
      emit((state as GameInProgress).copyWith(
        players: List.from(gameLogic.players),
        currentPlayer: gameLogic.currentPlayer,
      ));
    }
  }

  void _onLifeCardResolved(
    LifeCardResolved event,
    Emitter<GameBlocState> emit,
  ) {
    gameLogic.resolveLifeCard(event.player, event.card);
  }

  void _onDiceRolled(
    DiceRolled event,
    Emitter<GameBlocState> emit,
  ) {
    final result = gameLogic.rollDiceForIncome(event.player);
    
    if (state is GameInProgress) {
      emit((state as GameInProgress).copyWith(
        players: List.from(gameLogic.players),
        currentPlayer: gameLogic.currentPlayer,
        lastDiceRoll: result,
      ));
    }
  }

  void _onDebtAdjusted(
    DebtAdjusted event,
    Emitter<GameBlocState> emit,
  ) {
    gameLogic.adjustDebt(event.player, event.amount);
  }

  Future<void> _onGameStateLoaded(
    GameStateLoaded event,
    Emitter<GameBlocState> emit,
  ) async {
    emit(GameLoading());
    try {
      await gameLogic.loadGameState(event.gameId);
    } catch (e) {
      emit(GameError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    gameLogic.removeListener(_onGameLogicChanged);
    return super.close();
  }
}
