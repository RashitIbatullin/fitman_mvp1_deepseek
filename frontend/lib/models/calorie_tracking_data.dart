class CalorieTrackingData {
  final DateTime date;
  final String training;
  final int consumed;
  final int burned;
  final int balance;

  CalorieTrackingData({
    required this.date,
    required this.training,
    required this.consumed,
    required this.burned,
    required this.balance,
  });

  factory CalorieTrackingData.fromJson(Map<String, dynamic> json) {
    return CalorieTrackingData(
      date: DateTime.parse(json['date']),
      training: json['training'],
      consumed: json['consumed'],
      burned: json['burned'],
      balance: json['balance'],
    );
  }
}
