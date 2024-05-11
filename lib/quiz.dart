import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quizz_app/models/quiz_question.dart';
import 'dart:convert';
import 'package:quizz_app/start_screen.dart';
import 'package:quizz_app/questions_screen.dart';
//import 'package:quizz_app/data/questions.dart';
import 'package:quizz_app/results_screen.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() {
    return _QuizState();
  }
}

class _QuizState extends State<Quiz> {
  List<String> _selectedAnswers = [];
  List<QuizQuestion> loadedQuestionsList = [];

  var _activeScreen = 'start-screen';
  @override
  void initState() {
    //_insertQuestions();
    //Getting Questions list from firebase relatime database.
    _loadQuestions();
    super.initState();
  }

// _insertQuestions method used for insert the questions in firebase relatime database.
  void _insertQuestions() async {
    List<Map<String, dynamic>> questionsData = [
      {
        "question": "What is the capital of France?",
        "options": ["Berlin", "Madrid", "Paris", "Rome"],
        "answerIndex": 2
      },
      {
        "question": "What is the largest planet in the solar system?",
        "options": ["Jupiter", "Saturn", "Mars", "Earth"],
        "answerIndex": 0
      },
      {
        "question": "Who painted the Mona Lisa?",
        "options": [
          "Vincent van Gogh",
          "Pablo Picasso",
          "Leonardo da Vinci",
          "Michelangelo"
        ],
        "answerIndex": 2
      }
    ];
    final fireBaseURL = Uri.https(
        "quizzapp-939a4-default-rtdb.firebaseio.com", 'questions-list.json');
    http.post(fireBaseURL,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(questionsData));
  }

  void _loadQuestions() async {
    final fireBaseURL = Uri.https(
        "quizzapp-939a4-default-rtdb.firebaseio.com", 'questions-list.json');
    final response = await http.get(fireBaseURL);
    final Map<String, dynamic> listQuestions = json.decode(response.body);
    for (final item in listQuestions.entries) {
      for (final que in item.value) {
        loadedQuestionsList.add(QuizQuestion(que['question'], List<String>.from(que['options']),que['answerIndex']));
      }
    }
  }

  void _switchScreen() {
    setState(() {
      _activeScreen = 'questions-screen';
    });
  }

  void _chooseAnswer(String answer) {
    _selectedAnswers.add(answer);

    if (_selectedAnswers.length == loadedQuestionsList.length) {
      setState(() {
        _activeScreen = 'results-screen';
      });
    }
  }

  void restartQuiz() {
    _selectedAnswers = [];
    setState(() {
      _activeScreen = 'questions-screen';
    });
  }

  @override
  Widget build(context) {
    Widget screenWidget = StartScreen(_switchScreen);

    if (_activeScreen == 'questions-screen') {
      screenWidget = QuestionsScreen(
        onSelectAnswer: _chooseAnswer,
        questionsList: loadedQuestionsList,
      );
    }

    if (_activeScreen == 'results-screen') {
      screenWidget = ResultsScreen(
        chosenAnswers: _selectedAnswers,
        onRestart: restartQuiz,
        questionsList: loadedQuestionsList,
      );
    }

    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 78, 13, 151),
                Color.fromARGB(255, 107, 15, 168),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: screenWidget,
        ),
      ),
    );
  }
}
