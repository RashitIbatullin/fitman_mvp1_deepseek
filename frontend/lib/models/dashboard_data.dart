class DashboardData {
  final NextTraining nextTraining;
  final TrainingProgress trainingProgress;
  final GoalProgress goalProgress;
  final List<Achievement> achievements;

  DashboardData({
    required this.nextTraining,
    required this.trainingProgress,
    required this.goalProgress,
    required this.achievements,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      nextTraining: NextTraining.fromJson(json['nextTraining']),
      trainingProgress: TrainingProgress.fromJson(json['trainingProgress']),
      goalProgress: GoalProgress.fromJson(json['goalProgress']),
      achievements: (json['achievements'] as List)
          .map((i) => Achievement.fromJson(i))
          .toList(),
    );
  }
}

class NextTraining {
  final String title;
  final DateTime time;

  NextTraining({required this.title, required this.time});

  factory NextTraining.fromJson(Map<String, dynamic> json) {
    return NextTraining(
      title: json['title'],
      time: DateTime.parse(json['time']),
    );
  }
}

class TrainingProgress {
  final int completed;
  final int total;
  final int caloriesBurned;
  final int attendance;

  TrainingProgress({
    required this.completed,
    required this.total,
    required this.caloriesBurned,
    required this.attendance,
  });

  factory TrainingProgress.fromJson(Map<String, dynamic> json) {
    return TrainingProgress(
      completed: json['completed'],
      total: json['total'],
      caloriesBurned: json['caloriesBurned'],
      attendance: json['attendance'],
    );
  }
}

class GoalProgress {
  final String goal;
  final double currentWeight;
  final double targetWeight;
  final int avgDeficit;

  GoalProgress({
    required this.goal,
    required this.currentWeight,
    required this.targetWeight,
    required this.avgDeficit,
  });

  factory GoalProgress.fromJson(Map<String, dynamic> json) {
    return GoalProgress(
      goal: json['goal'],
      currentWeight: (json['currentWeight'] as num).toDouble(),
      targetWeight: (json['targetWeight'] as num).toDouble(),
      avgDeficit: json['avgDeficit'],
    );
  }
}

class Achievement {
  final String icon;
  final String color;

  Achievement({required this.icon, required this.color});

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      icon: json['icon'],
      color: json['color'],
    );
  }
}
