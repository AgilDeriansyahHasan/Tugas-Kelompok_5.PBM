class QuizWord {
  final String word; // The answer or the word itself
  final String definition; // The question or the meaning
  final String partOfSpeech; // The type of word (noun, verb, etc.)

  // These fields are specifically for QuizHistory's internal use when storing a list of QuizWords,
  // representing questions asked within a quiz instance. They are not part of a QuizWord's core identity.
  final int? score; // Score for THIS specific word if part of a detailed history item
  final int? totalQuestions; // Total questions in the quiz this word was part of
  final DateTime? date; // Date this specific word was encountered in a quiz

  QuizWord({
    required this.word,
    required this.definition,
    required this.partOfSpeech,
    this.score, // Optional for when storing within a QuizHistory's questions list
    this.totalQuestions, // Optional
    this.date, // Optional
  });

  /// Parses a [QuizWord] from a JSON API response (e.g., dictionaryapi.dev).
  /// This factory constructor extracts the word, its primary definition, and part of speech.
  factory QuizWord.fromJson(Map<String, dynamic> json) {
    final word = json['word']?.toString() ?? ''; // Ensure word is a string, handle null
    final meanings = json['meanings'] as List<dynamic>?;

    String definition = 'No definition found';
    String partOfSpeech = '';

    if (meanings != null && meanings.isNotEmpty) {
      final firstMeaning = meanings.first as Map<String, dynamic>;
      partOfSpeech = firstMeaning['partOfSpeech']?.toString() ?? '';

      final definitions = firstMeaning['definitions'] as List<dynamic>?;
      if (definitions != null && definitions.isNotEmpty) {
        final firstDef = definitions.first as Map<String, dynamic>;
        definition = firstDef['definition']?.toString() ?? 'No definition found';
      }
    }

    return QuizWord(
      word: word,
      definition: definition,
      partOfSpeech: partOfSpeech,
    );
  }

  /// Converts a [QuizWord] object into a [Map<String, dynamic>].
  /// This is typically used for serialization, such as saving to SQLite or JSON.
  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'definition': definition,
      'partOfSpeech': partOfSpeech,
      // Only include score, totalQuestions, and date if they are present.
      // This is particularly useful when QuizWord objects are part of a QuizHistory's 'questions' list,
      // where each word might have its own context of being asked.
      if (score != null) 'score': score,
      if (totalQuestions != null) 'totalQuestions': totalQuestions,
      if (date != null) 'date': date!.toIso8601String(),
    };
  }

  /// Creates a [QuizWord] object from a [Map<String, dynamic>].
  /// This is typically used for deserialization, such as loading from SQLite or JSON.
  factory QuizWord.fromMap(Map<String, dynamic> map) {
    return QuizWord(
      word: map['word']?.toString() ?? '',
      definition: map['definition']?.toString() ?? '',
      partOfSpeech: map['partOfSpeech']?.toString() ?? '',
      // Safely parse optional fields, assuming they might not always be present in the map
      score: map['score'] is int ? map['score'] : (map['score'] != null ? int.tryParse(map['score'].toString()) : null),
      totalQuestions: map['totalQuestions'] is int
          ? map['totalQuestions']
          : (map['totalQuestions'] != null ? int.tryParse(map['totalQuestions'].toString()) : null),
      date: map['date'] != null ? DateTime.tryParse(map['date'].toString()) : null,
    );
  }
}