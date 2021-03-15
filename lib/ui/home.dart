import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

class QuizApp extends StatefulWidget {
  @override
  _QuizAppState createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  List _questionBank = [];
  bool _isStarted = false;
  bool _isEnded = false;
  bool _isWinner = false;
  bool _allowedAnswer = true;
  List _question;
  int _points = 0;
  int _questionCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Quiz!"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent.shade400,
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _isStarted && !_isEnded
              ? <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Image.asset(
                        "assets/images/choice.png",
                        width: 100,
                      ),
                    ),
                  ),
                  Container(
                    height: 230,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: Text(
                          _question != null ? _question[0] : "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.green))),
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.green.shade300;
                                return Colors.green;
                              },
                            ),
                          ),
                          onPressed: () => _checkAnswer(true, context),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.check_rounded,
                              size: 30,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.red))),
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.red.shade300;
                                return Colors.red;
                              },
                            ),
                          ),
                          onPressed: () => _checkAnswer(false, context),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.clear_rounded,
                              size: 30,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Text(
                      "Overal Point: $_points",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Spacer(),
                ]
              : !_isStarted && !_isEnded
                  ? <Widget>[
                      Center(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.blue))),
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.blue.shade300;
                                return Colors.blue;
                              },
                            ),
                          ),
                          onPressed: () {
                            return _startGame();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              "Start",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ]
                  : <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Center(
                          child: _isWinner
                              ? Image.asset(
                                  "assets/images/quiz.png",
                                  width: 150,
                                )
                              : Image.asset(
                                  "assets/images/delete.png",
                                  width: 150,
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Center(
                            child: _isWinner
                                ? Text("You Win!",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green))
                                : Text(
                                    "You Lose!",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red),
                                  )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Center(
                          child: Text(
                            "Points: $_points",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.blue))),
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.blue.shade300;
                                return Colors.blue;
                              },
                            ),
                          ),
                          onPressed: () => _reStart(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.refresh_rounded,
                              size: 30,
                            ),
                          ),
                        ),
                      )
                    ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  _startReadingFile() async {
    if (_questionBank.length > 1) return;
    String data =
        await DefaultAssetBundle.of(context).loadString("assets/quize.json");
    List quizList = json.decode(data);

    setState(() {
      _questionBank = quizList;
    });
  }

  // ----------------------------------------------------------
  _checkAnswer(bool value, BuildContext context) {
    if (!_allowedAnswer) return;
    _allowedAnswer = false;

    if (value == _question[1]) {
      final snackBar = SnackBar(
        content: Text("Correct"),
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 500),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      setState(() {
        _points++;
      });
    } else {
      final SnackBar snackBar = SnackBar(
        content: Text("InCorrect"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 500),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    Timer(Duration(seconds: 1), () => _allowedAnswer = true);

    _askQuestion();
  }

  // ----------------------------------------------------------
  _startGame() async {
    if (_questionBank.length == 0) await _startReadingFile();

    setState(() {
      _isStarted = true;
    });

    _askQuestion();
  }

  // ----------------------------------------------------------
  _askQuestion() {
    Random rnd = new Random();
    int i = rnd.nextInt(_questionBank.length);

    setState(() {
      _question = _questionBank[i];
    });

    if (_questionCount < 10) {
      _questionCount++;
    } else {
      setState(() {
        _isEnded = true;
        _isStarted = true;
        _isWinner = _points > 6;
      });
    }
  }

  _reStart() {
    setState(() {
      _isStarted = false;
      _isEnded = false;
      _isWinner = false;
      _points = 0;
      _questionCount = 0;
    });
  }
}
