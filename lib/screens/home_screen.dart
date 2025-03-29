import 'package:flutter/material.dart';
import 'package:credit_mania/screens/game_screen.dart';
import 'package:credit_mania/services/game_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_wood.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/Credit-Mania.png',
                width: 300,
                height: 200,
              ),
              const SizedBox(height: 50),
              
              // Start Game Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  _showPlayerSelectionDialog(context);
                },
                child: const Text('Start Game'),
              ),
              
              const SizedBox(height: 20),
              
              // Rules Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  // Show rules screen
                },
                child: const Text('Rules'),
              ),
              
              const SizedBox(height: 20),
              
              // Settings Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade800,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  // Show settings screen
                },
                child: const Text('Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showPlayerSelectionDialog(BuildContext context) {
    int numberOfPlayers = 2;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Number of Players'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('How many players?'),
                  Slider(
                    value: numberOfPlayers.toDouble(),
                    min: 2,
                    max: 5,
                    divisions: 3,
                    label: numberOfPlayers.toString(),
                    onChanged: (double value) {
                      setState(() {
                        numberOfPlayers = value.toInt();
                      });
                    },
                  ),
                  Text(
                    '$numberOfPlayers Players',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              );
            },
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
                Navigator.of(context).pop();
                
                // Setup game with selected number of players
                final gameService = Provider.of<GameService>(context, listen: false);
                gameService.setupGame(numberOfPlayers);
                
                // Navigate to game screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(),
                  ),
                );
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }
}
