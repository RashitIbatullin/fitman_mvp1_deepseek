class WorkSchedule {
  final int id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isDayOff;

  WorkSchedule({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isDayOff,
  });

  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    return WorkSchedule(
      id: json['id'] ?? 0,
      dayOfWeek: json['day_of_week'] ?? 0,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      isDayOff: json['is_day_off'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_day_off': isDayOff,
    };
  }
}
