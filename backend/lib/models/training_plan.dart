class TrainingPlan {
  final int id;
  final String name;
  final String goal;
  final String level;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrainingPlan({
    required this.id,
    required this.name,
    required this.goal,
    required this.level,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrainingPlan.fromMap(Map<String, dynamic> map) {
    return TrainingPlan(
      id: map['id'] as int,
      name: map['name'].toString(),
      goal: map['goal'].toString(),
      level: map['level'].toString(),
      description: map['description'].toString(),
      createdAt: DateTime.parse(map['created_at'].toString()),
      updatedAt: DateTime.parse(map['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'goal': goal,
      'level': level,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}