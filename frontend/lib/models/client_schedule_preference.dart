
import 'package:json_annotation/json_annotation.dart';

part 'client_schedule_preference.g.dart';

@JsonSerializable()
class ClientSchedulePreference {
  final int? id;
  @JsonKey(name: 'client_id')
  final int clientId;
  @JsonKey(name: 'day_of_week')
  final int dayOfWeek;
  @JsonKey(name: 'preferred_start_time')
  final String preferredStartTime;
  @JsonKey(name: 'preferred_end_time')
  final String preferredEndTime;

  ClientSchedulePreference({
    this.id,
    required this.clientId,
    required this.dayOfWeek,
    required this.preferredStartTime,
    required this.preferredEndTime,
  });

  factory ClientSchedulePreference.fromJson(Map<String, dynamic> json) => _$ClientSchedulePreferenceFromJson(json);
  Map<String, dynamic> toJson() => _$ClientSchedulePreferenceToJson(this);
}
