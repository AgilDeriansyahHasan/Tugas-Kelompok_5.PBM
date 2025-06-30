class Habit {
  final int id;
  String name;
  String description;
  String example;
  bool isDone;

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    this.example = '',
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'example': example,
      'isDone': isDone ? 1 : 0,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      example: json['example'] ?? '',
      isDone: json['isDone'] == 1,
    );
  }
}
