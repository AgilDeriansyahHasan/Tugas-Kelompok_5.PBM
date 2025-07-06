import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:confetti/confetti.dart';
import '../models/user.dart';
import '../models/quiz.dart';
import '../models/quiz_history.dart';
import '../database/database_helper_quiz.dart';

class QuizPage extends StatefulWidget {
  final User currentUser;
  const QuizPage({super.key, required this.currentUser});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<QuizWord> words = [];
  bool isLoading = false;
  bool isStarted = false;
  bool isFinished = false;

  int? selectedLevel;
  String? selectedPartOfSpeech;
  int currentIndex = 0;
  int correctCount = 0;

  final TextEditingController _answerController = TextEditingController();
  late ConfettiController _confettiController;

  final List<Map<String, String>> levels = [
    {'level': '1', 'partOfSpeech': 'noun'},
    {'level': '2', 'partOfSpeech': 'verb'},
    {'level': '3', 'partOfSpeech': 'adjective'},
    {'level': '4', 'partOfSpeech': 'adverb'},
    {'level': '5', 'partOfSpeech': 'preposition'},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _answerController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadWordsFromApi() async {
    setState(() => isLoading = true);
    List<QuizWord> loadedWords = [];

    try {
      while (loadedWords.length < 1) {
        final response = await http.get(Uri.parse('https://random-word-api.herokuapp.com/word?number=10'));
        if (response.statusCode == 200) {
          final List randomWords = json.decode(response.body);
          for (String word in randomWords) {
            if (loadedWords.length >= 1) break;
            try {
              final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
              final detailResponse = await http.get(url);
              if (detailResponse.statusCode == 200) {
                final data = json.decode(detailResponse.body);
                if (data is List && data.isNotEmpty) {
                  final quizWord = QuizWord.fromJson(data[0]);
                  if (quizWord.definition.isNotEmpty &&
                      (selectedPartOfSpeech == null ||
                          quizWord.partOfSpeech.toLowerCase() == selectedPartOfSpeech!.toLowerCase())) {
                    loadedWords.add(quizWord);
                  }
                }
              }
            } catch (_) {}
          }
        }
      }

      setState(() {
        words = loadedWords..shuffle();
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  void _startQuiz() async {
    await _loadWordsFromApi();
    if (words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load quiz words.')),
      );
      return;
    }
    setState(() {
      isStarted = true;
      isFinished = false;
      currentIndex = 0;
      correctCount = 0;
      _answerController.clear();
    });
  }

  void _checkAnswer() async {
    final correctWord = words[currentIndex].word.trim().toLowerCase();
    final userAnswer = _answerController.text.trim().toLowerCase();

    if (userAnswer == correctWord) correctCount++;

    if (currentIndex < words.length - 1) {
      setState(() {
        currentIndex++;
        _answerController.clear();
      });
    } else {
      final history = QuizHistory(
        userId: widget.currentUser.userId,
        score: correctCount,
        totalQuestions: words.length,
        level: selectedLevel ?? 0,
        partOfSpeech: selectedPartOfSpeech ?? '-',
        date: DateTime.now(),
        questions: words,
      );
      await DatabaseHelper().insertQuizHistory(history);
      if (correctCount == words.length) _confettiController.play();
      setState(() {
        isFinished = true;
        isStarted = false;
      });
    }
  }

  void _resetQuiz() {
    setState(() {
      words = [];
      isStarted = false;
      isFinished = false;
      selectedLevel = null;
      selectedPartOfSpeech = null;
      correctCount = 0;
      currentIndex = 0;
      _answerController.clear();
      _confettiController.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(
          isFinished
              ? 'Hasil Quiz'
              : isStarted
              ? 'Quiz Dimulai'
              : 'Quiz Kosakata',
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isStarted
          ? _buildQuizContent()
          : isFinished
          ? _buildResult()
          : _buildLevelCards(),
    );
  }

  Widget _buildLevelCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Pilih Level Quiz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: levels.map((level) {
                final levelNum = int.parse(level['level']!);
                final partOfSpeech = level['partOfSpeech']!;
                final selected = selectedLevel == levelNum;

                return Card(
                  color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
                  child: ListTile(
                    title: Text('Level $levelNum'),
                    subtitle: Text('Part of speech: $partOfSpeech'),
                    trailing: selected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                    onTap: () => setState(() {
                      selectedLevel = levelNum;
                      selectedPartOfSpeech = partOfSpeech;
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
          ElevatedButton.icon(
            onPressed: selectedLevel != null ? _startQuiz : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Mulai Quiz'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    final word = words[currentIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (currentIndex + 1) / words.length,
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                word.definition,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _answerController,
            decoration: InputDecoration(
              labelText: 'Jawabanmu',
              border: const OutlineInputBorder(),
              suffixIcon: _answerController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _answerController.clear,
              )
                  : null,
            ),
            onSubmitted: (_) {
              if (_answerController.text.trim().isNotEmpty) _checkAnswer();
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _answerController.text.trim().isEmpty ? null : _checkAnswer,
            child: const Text('Kirim Jawaban'),
          ),
          const SizedBox(height: 12),
          Text('Soal ${currentIndex + 1} dari ${words.length}', textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final score = ((correctCount / words.length) * 100).round();
    final isPerfect = correctCount == words.length;

    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 7,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPerfect ? Icons.emoji_events : Icons.check_circle,
                    color: isPerfect ? Colors.amber.shade700 : Colors.green,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPerfect ? 'Sempurna!' : 'Bagus!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Skor kamu:\n$correctCount dari ${words.length} soal\n($score%)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Level: $selectedLevel\nKategori: $selectedPartOfSpeech',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _resetQuiz,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Ulangi Quiz'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [Colors.red, Colors.green, Colors.blue, Colors.orange],
        ),
      ],
    );
  }
}
