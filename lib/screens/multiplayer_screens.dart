import 'package:flutter/material.dart';
import 'package:credit_mania/blocs/game/game_bloc.dart';
import 'package:credit_mania/models/game_session.dart';
import 'package:credit_mania/repositories/game_repository.dart';
import 'package:credit_mania/utils/animation_helper.dart';
import 'package:credit_mania/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  final TextEditingController _gameNameController = TextEditingController();
  final TextEditingController _playerNameController = TextEditingController();
  bool _isPublicGame = true;
  int _maxPlayers = 4;
  bool _isCreatingGame = false;
  bool _isJoiningGame = false;
  List<GameSession> _availableGames = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableGames();
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    _playerNameController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableGames() async {
    try {
      final gameRepository = RepositoryProvider.of<GameRepository>(context);
      final games = await gameRepository.getPublicGameSessions();
      setState(() {
        _availableGames = games;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading games: $e')),
      );
    }
  }

  Future<void> _createGame() async {
    if (_gameNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a game name')),
      );
      return;
    }

    setState(() {
      _isCreatingGame = true;
    });

    try {
      final gameRepository = RepositoryProvider.of<GameRepository>(context);
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}'; // In a real app, this would be the authenticated user's ID
      
      final gameSession = await gameRepository.createGameSession(
        hostId: userId,
        gameName: _gameNameController.text,
        maxPlayers: _maxPlayers,
        isPublic: _isPublicGame,
      );

      // Navigate to game lobby
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GameLobbyScreen(
              gameSession: gameSession,
              isHost: true,
              userId: userId,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating game: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingGame = false;
        });
      }
    }
  }

  Future<void> _joinGame(GameSession gameSession) async {
    if (_playerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() {
      _isJoiningGame = true;
    });

    try {
      final gameRepository = RepositoryProvider.of<GameRepository>(context);
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}'; // In a real app, this would be the authenticated user's ID
      
      await gameRepository.joinGameSession(
        gameId: gameSession.id,
        playerId: userId,
      );

      // Navigate to game lobby
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GameLobbyScreen(
              gameSession: gameSession,
              isHost: false,
              userId: userId,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining game: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isJoiningGame = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplayer Lobby'),
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_wood.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Create Game Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Create New Game',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _gameNameController,
                        decoration: const InputDecoration(
                          labelText: 'Game Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Max Players:'),
                          Expanded(
                            child: Slider(
                              value: _maxPlayers.toDouble(),
                              min: 2,
                              max: 5,
                              divisions: 3,
                              label: _maxPlayers.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _maxPlayers = value.toInt();
                                });
                              },
                            ),
                          ),
                          Text(_maxPlayers.toString()),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Public Game:'),
                          Switch(
                            value: _isPublicGame,
                            onChanged: (value) {
                              setState(() {
                                _isPublicGame = value;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AnimationHelper.pulseAnimation(
                        animate: !_isCreatingGame,
                        child: ElevatedButton(
                          onPressed: _isCreatingGame ? null : _createGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isCreatingGame
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Create Game'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Join Game Section
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Join Existing Game',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _loadAvailableGames,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _playerNameController,
                          decoration: const InputDecoration(
                            labelText: 'Your Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _availableGames.isEmpty
                              ? const Center(
                                  child: Text('No games available. Create one!'),
                                )
                              : ListView.builder(
                                  itemCount: _availableGames.length,
                                  itemBuilder: (context, index) {
                                    final game = _availableGames[index];
                                    return AnimationHelper.slideTransition(
                                      visible: true,
                                      beginOffset: Offset(0.2, 0),
                                      child: Card(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          title: Text(game.name),
                                          subtitle: Text(
                                              'Players: ${game.players.length}/${game.maxPlayers}'),
                                          trailing: ElevatedButton(
                                            onPressed: _isJoiningGame
                                                ? null
                                                : () => _joinGame(game),
                                            child: const Text('Join'),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameLobbyScreen extends StatefulWidget {
  final GameSession gameSession;
  final bool isHost;
  final String userId;

  const GameLobbyScreen({
    super.key,
    required this.gameSession,
    required this.isHost,
    required this.userId,
  });

  @override
  State<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends State<GameLobbyScreen> {
  late Stream<GameSession> _gameSessionStream;
  bool _isStartingGame = false;

  @override
  void initState() {
    super.initState();
    final gameRepository = RepositoryProvider.of<GameRepository>(context);
    _gameSessionStream = gameRepository.gameSessionStream(gameId: widget.gameSession.id);
  }

  Future<void> _startGame() async {
    setState(() {
      _isStartingGame = true;
    });

    try {
      final gameRepository = RepositoryProvider.of<GameRepository>(context);
      await gameRepository.startGameSession(gameId: widget.gameSession.id);
      
      // Initialize game with player names
      final gameBloc = BlocProvider.of<GameBloc>(context);
      final playerNames = widget.gameSession.players.map((playerId) {
        // In a real app, you would fetch player names from a user repository
        return 'Player ${playerId.substring(playerId.length - 4)}';
      }).toList();
      
      gameBloc.add(GameInitialized(
        playerNames: playerNames,
        isOnlineGame: true,
        gameSessionId: widget.gameSession.id,
      ));
      
      // Navigate to game screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MultiplayerGameScreen(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting game: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isStartingGame = false;
        });
      }
    }
  }

  Future<void> _leaveGame() async {
    try {
      final gameRepository = RepositoryProvider.of<GameRepository>(context);
      await gameRepository.leaveGameSession(
        gameId: widget.gameSession.id,
        playerId: widget.userId,
      );
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error leaving game: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Lobby: ${widget.gameSession.name}'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _leaveGame,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_wood.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<GameSession>(
            stream: _gameSessionStream,
            initialData: widget.gameSession,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              final gameSession = snapshot.data!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Game: ${gameSession.name}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Host: ${gameSession.hostId == widget.userId ? 'You' : 'Player ${gameSession.hostId.substring(gameSession.hostId.length - 4)}'}',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Players: ${gameSession.players.length}/${gameSession.maxPlayers}',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Status: ${gameSession.state}',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Players',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount: gameSession.players.length,
                                itemBuilder: (context, index) {
                                  final playerId = gameSession.players[index];
                                  final isCurrentUser = playerId == widget.userId;
                                  final isHost = playerId == gameSession.hostId;
                                  
                                  return AnimationHelper.slideTransition(
                                    visible: true,
                                    beginOffset: Offset(0.2, 0),
                                    child: Card(
                                      color: isCurrentUser
                                          ? AppColors.primary.withOpacity(0.2)
                                          : null,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: isCurrentUser
                                              ? AppColors.primary
                                              : Colors.grey,
                                          child: Text(
                                            'P${index + 1}',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        title: Text(
                                          isCurrentUser
                                              ? 'You'
                                              : 'Player ${playerId.substring(playerId.length - 4)}',
                                        ),
                                        subtitle: isHost
                                            ? const Text('Host')
                                            : null,
                                        trailing: isHost
                                            ? const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  if (widget.isHost)
                    AnimationHelper.pulseAnimation(
                      animate: !_isStartingGame && gameSession.players.length >= 2,
                      child: ElevatedButton(
                        onPressed: (_isStartingGame || gameSession.players.length < 2)
                            ? null
                            : _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isStartingGame
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Start Game',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class MultiplayerGameScreen extends StatelessWidget {
  const MultiplayerGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GameBloc, GameBlocState>(
        builder: (context, state) {
          if (state is GameLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is GameInProgress) {
            // Return the actual game screen
            return const Center(
              child: Text('Game in progress - Implement actual game UI here'),
            );
          }
          
          if (state is GameEnded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Game Over!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Winner: ${state.winner.name}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Back to Lobby'),
                  ),
                ],
              ),
            );
          }
          
          if (state is GameError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Error',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Back to Lobby'),
                  ),
                ],
              ),
            );
          }
          
          return const Center(
            child: Text('Waiting for game to start...'),
          );
        },
      ),
    );
  }
}
