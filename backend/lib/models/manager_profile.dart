class ManagerProfile {
  final int userId;
  final String? specialization;
  final int? workExperience;
  final bool isDuty;

  ManagerProfile({
    required this.userId,
    this.specialization,
    this.workExperience,
    required this.isDuty,
  });

  factory ManagerProfile.fromMap(Map<String, dynamic> map) {
    return ManagerProfile(
      userId: map['user_id'],
      specialization: map['specialization'],
      workExperience: map['work_experience'],
      isDuty: map['is_duty'],
    );
  }
}
