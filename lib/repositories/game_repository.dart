import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credit_mania/models/game_session.dart';
import 'package:credit_mania/models/player.dart';
import 'package:credit_mania/models/card.dart';
import 'package:flutter/foundation.dart';

class GameRepository {
  final FirebaseFirestore _firestore;
  
  GameRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference get _gameSessions => _firestore.collection('game_sessions');
  
  // Create a new game session
  Future<GameSession> createGameSession({
    required String hostId,
    required String gameName,
    required int maxPlayers,
    required bool isPublic,
  }) async {
    try {
      final gameId = 'game_${DateTime.now().millisecondsSinceEpoch}';
      
      final gameSession = GameSession(
        id: gameId,
        hostId: hostId,
        name: gameName,
        players: [hostId],
        maxPlayers: maxPlayers,
        isPublic: isPublic,
        state: 'waiting',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _gameSessions.doc(gameId).set(gameSession.toMap());
      
      return gameSession;
    } catch (e) {
      debugPrint('Error creating game session: $e');
      throw Exception('Failed to create game session: $e');
    }
  }
  
  // Get all public game sessions
  Future<List<GameSession>> getPublicGameSessions() async {
    try {
      final snapshot = await _gameSessions
          .where('isPublic', isEqualTo: true)
          .where('state', isEqualTo: 'waiting')
          .get();
      
      return snapshot.docs
          .map((doc) => GameSession.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting public game sessions: $e');
      throw Exception('Failed to get public game sessions: $e');
    }
  }
  
  // Join a game session
  Future<void> joinGameSession({
    required String gameId,
    required String playerId,
  }) async {
    try {
      final gameDoc = await _gameSessions.doc(gameId).get();
      
      if (!gameDoc.exists) {
        throw Exception('Game session not found');
      }
      
      final gameData = gameDoc.data() as Map<String, dynamic>;
      final players = List<String>.from(gameData['players'] as List);
      
      if (players.contains(playerId)) {
        throw Exception('Player already in game');
      }
      
      if (players.length >= gameData['maxPlayers']) {
        throw Exception('Game is full');
      }
      
      if (gameData['state'] != 'waiting') {
        throw Exception('Game has already started');
      }
      
      players.add(playerId);
      
      await _gameSessions.doc(gameId).update({
        'players': players,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error joining game session: $e');
      throw Exception('Failed to join game session: $e');
    }
  }
  
  // Leave a game session
  Future<void> leaveGameSession({
    required String gameId,
    required String playerId,
  }) async {
    try {
      final gameDoc = await _gameSessions.doc(gameId).get();
      
      if (!gameDoc.exists) {
        throw Exception('Game session not found');
      }
      
      final gameData = gameDoc.data() as Map<String, dynamic>;
      final players = List<String>.from(gameData['players'] as List);
      
      if (!players.contains(playerId)) {
        throw Exception('Player not in game');
      }
      
      if (gameData['state'] != 'waiting') {
        throw Exception('Game has already started');
      }
      
      players.remove(playerId);
      
      // If the host leaves, assign a new host or delete the game
      if (playerId == gameData['hostId']) {
        if (players.isEmpty) {
          // Delete the game if no players left
          await _gameSessions.doc(gameId).delete();
          return;
        } else {
          // Assign a new host
          await _gameSessions.doc(gameId).update({
            'players': players,
            'hostId': players.first,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      } else {
        // Just update players list
        await _gameSessions.doc(gameId).update({
          'players': players,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error leaving game session: $e');
      throw Exception('Failed to leave game session: $e');
    }
  }
  
  // Start a game session
  Future<void> startGameSession({
    required String gameId,
  }) async {
    try {
      final gameDoc = await _gameSessions.doc(gameId).get();
      
      if (!gameDoc.exists) {
        throw Exception('Game session not found');
      }
      
      final gameData = gameDoc.data() as Map<String, dynamic>;
      
      if (gameData['state'] != 'waiting') {
        throw Exception('Game has already started');
      }
      
      final players = List<String>.from(gameData['players'] as List);
      
      if (players.length < 2) {
        throw Exception('Need at least 2 players to start');
      }
      
      await _gameSessions.doc(gameId).update({
        'state': 'playing',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error starting game session: $e');
      throw Exception('Failed to start game session: $e');
    }
  }
  
  // Get a stream of updates for a game session
  Stream<GameSession> gameSessionStream({required String gameId}) {
    return _gameSessions.doc(gameId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('Game session not found');
      }
      
      return GameSession.fromMap(snapshot.data() as Map<String, dynamic>);
    });
  }
  
  // Save game state to Firestore
  Future<void> saveGameState({
    required String gameId,
    required List<Player> players,
    required int currentPhase,
    required int currentPlayerIndex,
    required List<AssetCard> marketDisplay1Star,
    required List<AssetCard> marketDisplay2Star,
    required List<AssetCard> marketDisplay3Star,
  }) async {
    try {
      final gameState = {
        'players': players.map((player) => player.toMap()).toList(),
        'currentPhase': currentPhase,
        'currentPlayerIndex': currentPlayerIndex,
        'marketDisplay1Star': marketDisplay1Star.map((card) => card.toMap()).toList(),
        'marketDisplay2Star': marketDisplay2Star.map((card) => card.toMap()).toList(),
        'marketDisplay3Star': marketDisplay3Star.map((card) => card.toMap()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      await _gameSessions.doc(gameId).update({
        'gameState': gameState,
      });
    } catch (e) {
      debugPrint('Error saving game state: $e');
      throw Exception('Failed to save game state: $e');
    }
  }
  
  // For offline testing - save game state locally
  Future<void> saveLocalGameState({
    required String gameId,
    required List<Player> players,
    required int currentPhase,
    required int currentPlayerIndex,
    required List<AssetCard> marketDisplay1Star,
    required List<AssetCard> marketDisplay2Star,
    required List<AssetCard> marketDisplay3Star,
  }) async {
    // In a real implementation, this would save to local storage
    debugPrint('Saving local game state for game: $gameId');
  }
  
  // For offline testing - load game state locally
  Future<Map<String, dynamic>> loadLocalGameState({required String gameId}) async {
    // In a real implementation, this would load from local storage
    debugPrint('Loading local game state for game: $gameId');
    return {};
  }
  
  // End a game session
  Future<void> endGameSession({
    required String gameId,
    required String winnerId,
  }) async {
    try {
      await _gameSessions.doc(gameId).update({
        'state': 'ended',
        'winnerId': winnerId,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error ending game session: $e');
      throw Exception('Failed to end game session: $e');
    }
  }
}
