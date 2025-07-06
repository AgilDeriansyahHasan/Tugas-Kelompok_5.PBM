// models/quiz_history.dart
import 'dart:convert';
import 'quiz.dart'; // supaya bisa pakai QuizWord

class QuizHistory {
  final int score;
  final int totalQuestions;
  final int level;
  final String partOfSpeech;
  final DateTime date;
  final List<QuizWord> questions;

  QuizHistory({
    required this.score,
    required this.totalQuestions,
    required this.level,
    required this.partOfSpeech,
    required this.date,
    required this.questions,
  });

  // Konversi ke Map untuk disimpan di database
  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'totalQuestions': totalQuestions,
      'level': level,
      'partOfSpeech': partOfSpeech,
      'date': date.toIso8601String(),
      'questions': jsonEncode(questions.map((q) => q.toMap()).toList()),
    };
  }

  // Buat dari Map (misalnya saat load dari database)
  factory QuizHistory.fromMap(Map<String, dynamic> map) {
    final List<dynamic> decodedQuestions = jsonDecode(map['questions'] ?? '[]');
    return QuizHistory(
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      level: map['level'] ?? 0,
      partOfSpeech: map['partOfSpeech'] ?? '',
      date: DateTime.parse(map['date']),
      questions: decodedQuestions.map((e) => QuizWord.fromMap(e)).toList(),
    );
  }
}