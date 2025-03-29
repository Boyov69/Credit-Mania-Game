import 'package:equatable/equatable.dart';
import 'package:credit_mania/models/card.dart';
import 'package:credit_mania/models/player.dart';

class GameSession extends Equatable {
  final String id;
  final String hostId;
  final String name;
  final List<String> players;
  final int maxPlayers;
  final bool isPublic;
  final String state;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? gameState;

  const GameSession({
    required this.id,
    required this.hostId,
    required this.name,
    required this.players,
    required this.maxPlayers,
    required this.isPublic,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
    this.gameState,
  });

  @override
  List<Object?> get props => [
        id,
        hostId,
        name,
        players,
        maxPlayers,
        isPublic,
        state,
        createdAt,
        updatedAt,
        gameState,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hostId': hostId,
      'name': name,
      'players': players,
      'maxPlayers': maxPlayers,
      'isPublic': isPublic,
      'state': state,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'gameState': gameState,
    };
  }

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      id: map['id'] as String,
      hostId: map['hostId'] as String,
      name: map['name'] as String,
      players: List<String>.from(map['players'] as List),
      maxPlayers: map['maxPlayers'] as int,
      isPublic: map['isPublic'] as bool,
      state: map['state'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      gameState: map['gameState'] as Map<String, dynamic>?,
    );
  }

  GameSession copyWith({
    String? id,
    String? hostId,
    String? name,
    List<String>? players,
    int? maxPlayers,
    bool? isPublic,
    String? state,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? gameState,
  }) {
    return GameSession(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      name: name ?? this.name,
      players: players ?? this.players,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      isPublic: isPublic ?? this.isPublic,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gameState: gameState ?? this.gameState,
    );
  }
}
