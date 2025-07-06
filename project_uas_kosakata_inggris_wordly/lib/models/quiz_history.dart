import 'dart:convert'; // Required for jsonEncode and jsonDecode
import 'quiz.dart';    // Ensure QuizWord class is correctly imported

class QuizHistory {
  final int? id; // Renamed from userId to id for clarity as primary key in DB
  final int userId; // The ID of the user who took this quiz
  final int score;
  final int totalQuestions;
  final DateTime date;
  final int level;
  final String partOfSpeech;
  final List<QuizWord> questions;

  QuizHistory({
    this.id, // Optional, typically set by the database when inserting
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.date,
    required this.level,
    required this.partOfSpeech,
    required this.questions,
  });

  /// Converts a [QuizHistory] object into a [Map<String, dynamic>].
  /// This is used for serialization, such as saving to SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include id if it exists (for updates or specific queries)
      'userId': userId,
      'score': score,
      'totalQuestions': totalQuestions,
      'date': date.toIso8601String(), // Store DateTime as a string
      'level': level,
      'partOfSpeech': partOfSpeech,
      // Convert the list of QuizWord objects to a JSON string
      'questions': jsonEncode(questions.map((q) => q.toMap()).toList()),
    };
  }

  /// Creates a [QuizHistory] object from a [Map<String, dynamic>].
  /// This is used for deserialization, such as loading from SQLite.
  factory QuizHistory.fromMap(Map<String, dynamic> map) {
    return QuizHistory(
      id: map['id'] as int?, // Cast to int? to handle potential null or different type
      userId: map['userId'] as int,
      score: map['score'] as int,
      totalQuestions: map['totalQuestions'] as int,
      date: DateTime.parse(map['date'] as String), // Parse string back to DateTime
      level: map['level'] as int,
      partOfSpeech: map['partOfSpeech'] as String,
      // Decode the JSON string back into a List of QuizWord objects
      questions: (jsonDecode(map['questions'] as String) as List)
          .map((item) => QuizWord.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }
}