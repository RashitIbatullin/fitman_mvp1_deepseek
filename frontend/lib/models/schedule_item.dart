class ScheduleItem {
  final int id;
  final String trainingPlanName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String trainerName;

  ScheduleItem({
    required this.id,
    required this.trainingPlanName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.trainerName,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'] as int,
      trainingPlanName: json['training_plan_name'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] as String,
      trainerName: json['trainer_name'] as String,
    );
  }
}
