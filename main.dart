import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(SnakeGame());
}

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String difficulty = 'easy';
  int highestScore = 0;

  @override
  void initState() {
    super.initState();
    // _loadHighestScore();
  }

  // Future<void> _loadHighestScore() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     highestScore = prefs.getInt('highestScore') ?? 0;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/home_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GamePage(difficulty: difficulty),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  textStyle: TextStyle(color: Colors.black, fontSize: 18),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                  onPrimary: Colors.white.withOpacity(0.9),
                ),
                child: Text('Start Game'),
              ),
              SizedBox(height: 20),
              Text(
                'Select Difficulty:',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              SizedBox(height: 15),
              DropdownButton<String>(
                value: difficulty,
                onChanged: (String? value) {
                  setState(() {
                    difficulty = value!;
                  });
                },
                style: TextStyle(color: Colors.white, fontSize: 18),
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  height: 2,
                  color: Colors.blueAccent,
                ),
                dropdownColor: Colors.black,
                items: <String>['easy', 'medium', 'hard']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
              )
              // SizedBox(height: 20),
              // Text(
              //   'Highest Score: $highestScore',
              //   style: TextStyle(color: Colors.white, fontSize: 18),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class GamePage extends StatelessWidget {
  final String difficulty;

  GamePage({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/game_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SnakeGameScreen(difficulty: difficulty),
      ),
    );
  }
}

class GameOverPage extends StatelessWidget {
  final int score;

  GameOverPage(this.score);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/game_over_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Game Over',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              Text(
                'Your Score: $score',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                child: Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SnakeGameScreen extends StatefulWidget {
  final String difficulty;

  SnakeGameScreen({required this.difficulty});

  @override
  _SnakeGameScreenState createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static List<int> snakePosition = [45, 65, 85, 105, 125];
  int numberOfSquares = 760;
  static var randomNumber = Random();
  int food = randomNumber.nextInt(700);
  var direction = 'down';
  bool gameHasStarted = false;
  int score = 0;

  late Timer _timer;
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _setDifficulty(widget.difficulty);
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    RawKeyboard.instance.addListener(handleKey);
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 10,
          child: GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/game_background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: numberOfSquares,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 20,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (snakePosition.contains(index)) {
                    return Center(
                      child: Container(
                        padding: EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  }
                  if (index == food) {
                    return Center(
                      child: Container(
                        padding: EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      padding: EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Score: $score',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _setDifficulty(String difficulty) {
    switch (difficulty) {
      case 'easy':
        _duration = Duration(milliseconds: 300);
        break;
      case 'medium':
        _duration = Duration(milliseconds: 200);
        break;
      case 'hard':
        _duration = Duration(milliseconds: 100);
        break;
      default:
        _duration = Duration(milliseconds: 300);
    }
  }

  void startGame() {
    gameHasStarted = true;
    score = 0;
    snakePosition = [45, 65, 85, 105, 125];
    _timer = Timer.periodic(_duration, (Timer timer) {
      _snakeMovements();
      if (!gameHasStarted) {
        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameOverPage(score),
          ),
        );
      }
    });
  }

  void _snakeMovements() {
    if (gameHasStarted) {
      switch (direction) {
        case 'down':
          if (snakePosition.last + 20 < numberOfSquares &&
              !snakePosition
                  .sublist(0, snakePosition.length - 1)
                  .contains(snakePosition.last + 20)) {
            setState(() {
              snakePosition.add(snakePosition.last + 20);
            });
          } else {
            setState(() {
              gameHasStarted = false;
            });
          }
          break;
        case 'up':
          if (snakePosition.last - 20 >= 0 &&
              !snakePosition
                  .sublist(0, snakePosition.length - 1)
                  .contains(snakePosition.last - 20)) {
            setState(() {
              snakePosition.add(snakePosition.last - 20);
            });
          } else {
            setState(() {
              gameHasStarted = false;
            });
          }
          break;
        case 'left':
          if (snakePosition.last % 20 != 0 &&
              !snakePosition
                  .sublist(0, snakePosition.length - 1)
                  .contains(snakePosition.last - 1)) {
            setState(() {
              snakePosition.add(snakePosition.last - 1);
            });
          } else {
            setState(() {
              gameHasStarted = false;
            });
          }
          break;
        case 'right':
          if ((snakePosition.last + 1) % 20 != 0 &&
              !snakePosition
                  .sublist(0, snakePosition.length - 1)
                  .contains(snakePosition.last + 1)) {
            setState(() {
              snakePosition.add(snakePosition.last + 1);
            });
          } else {
            setState(() {
              gameHasStarted = false;
            });
          }
          break;
      }
      if (snakePosition.last == food) {
        setState(() {
          food = randomNumber.nextInt(700);
          score += 10;
        });
      } else {
        setState(() {
          snakePosition.removeAt(0);
        });
      }
    }
  }

  void handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        direction = 'up';
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        direction = 'down';
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        direction = 'left';
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        direction = 'right';
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    RawKeyboard.instance.removeListener(handleKey);
    super.dispose();
  }
}
