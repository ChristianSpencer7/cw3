import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "";
  int happinessLevel = 50;
  int hungerLevel = 50;
  bool gameStarted = false;
  Timer? hungerTimer;
  Timer? winTimer;
  bool isGameOver = false;
  TextEditingController _nameController = TextEditingController();

  // Function to increase happiness and update hunger when playing with the pet
  void _playWithPet() {
    if (!gameStarted || isGameOver) return;

    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
    });
  }

  // Function to decrease hunger and update happiness when feeding the pet
  void _feedPet() {
    if (!gameStarted || isGameOver) return;

    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
    });
  }

  // Update happiness based on hunger level
  void _updateHappiness() {
    if (hungerLevel >= 100 && happinessLevel <= 10) {
      _gameOver();
    } else if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  // Increase hunger level slightly when playing with the pet
  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel >= 100) {
      _gameOver();
    }
  }

  // Get the pet's color based on happiness level
  Color _getPetColor() {
    if (happinessLevel > 70) {
      return Colors.green; // Happy
    } else if (happinessLevel >= 30 && happinessLevel <= 70) {
      return Colors.yellow; // Neutral
    } else {
      return Colors.red; // Unhappy
    }
  }

  // Get the pet's mood based on happiness level
  String _getPetMood() {
    if (happinessLevel > 70) {
      return "Happy";
    } else if (happinessLevel >= 30 && happinessLevel <= 70) {
      return "Neutral";
    } else {
      return "Unhappy";
    }
  }

  // Get an icon that represents the pet's mood
  IconData _getMoodIcon() {
    if (happinessLevel > 70) {
      return Icons.sentiment_very_satisfied; // Happy emoji
    } else if (happinessLevel >= 30 && happinessLevel <= 70) {
      return Icons.sentiment_neutral; // Neutral emoji
    } else {
      return Icons.sentiment_very_dissatisfied; // Unhappy emoji
    }
  }

  // Start the hunger timer (increases hunger every 30 seconds)
  void _startHungerTimer() {
    hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (!gameStarted || isGameOver) return;

      setState(() {
        hungerLevel = (hungerLevel + 5).clamp(0, 100);
        if (hungerLevel >= 100) {
          _gameOver();
        }
      });
    });
  }

  // Start the win condition timer (3 minutes)
  void _startWinTimer() {
    winTimer = Timer(Duration(minutes: 3), () {
      if (!isGameOver && happinessLevel > 80) {
        _showWinMessage();
      }
    });
  }

  // Show game over message and stop the game
  void _gameOver() {
    setState(() {
      isGameOver = true;
    });

    if (hungerTimer != null) hungerTimer!.cancel();
    if (winTimer != null) winTimer!.cancel();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Game Over'),
        content: Text('Your pet is too hungry and unhappy!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  // Show win message and stop the game
  void _showWinMessage() {
    setState(() {
      isGameOver = true;
    });

    if (hungerTimer != null) hungerTimer!.cancel();
    if (winTimer != null) winTimer!.cancel();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('You Win!'),
        content: Text('Your pet has been happy for 3 minutes!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  // Reset the game state
  void _resetGame() {
    setState(() {
      petName = "";
      happinessLevel = 50;
      hungerLevel = 50;
      gameStarted = false;
      isGameOver = false;
    });
  }

  // Start the game after setting the pet name
  void _startGame() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        petName = _nameController.text;
        gameStarted = true;
      });
      _startHungerTimer();
      _startWinTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Center(
        child: gameStarted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Name: $petName',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getPetColor(), // Pet color changes dynamically
                    ),
                    child: Center(
                      child: Icon(
                        Icons.pets, // Use the built-in animal icon
                        size: 60.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        _getMoodIcon(), // Display the mood icon
                        size: 40.0,
                        color:
                            _getPetColor(), // Match the icon color with pet color
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        _getPetMood(), // Display the mood text
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Happiness Level: $happinessLevel',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Hunger Level: $hungerLevel',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: _playWithPet,
                    child: Text('Play with Your Pet'),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _feedPet,
                    child: Text('Feed Your Pet'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Enter a name for your pet:',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Pet Name',
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _startGame,
                    child: Text('Go'), // The "Go" button
                  ),
                ],
              ),
      ),
    );
  }
}
