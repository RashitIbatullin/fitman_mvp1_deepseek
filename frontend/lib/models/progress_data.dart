class ProgressData {
  final List<ChartDataPoint> weight;
  final List<ChartDataPoint> calories;
  final List<ChartDataPoint> balance;
  final KpiData kpi;
  final String recommendations;

  ProgressData({
    required this.weight,
    required this.calories,
    required this.balance,
    required this.kpi,
    required this.recommendations,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    return ProgressData(
      weight: (json['weight'] as List)
          .map((i) => ChartDataPoint.fromJson(i))
          .toList(),
      calories: (json['calories'] as List)
          .map((i) => ChartDataPoint.fromJson(i))
          .toList(),
      balance: (json['balance'] as List)
          .map((i) => ChartDataPoint.fromJson(i))
          .toList(),
      kpi: KpiData.fromJson(json['kpi']),
      recommendations: json['recommendations'],
    );
  }
}

class ChartDataPoint {
  final DateTime date;
  final double value;

  ChartDataPoint({required this.date, required this.value});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      date: DateTime.parse(json['date']),
      value: (json['value'] as num).toDouble(),
    );
  }
}

class KpiData {
  final double avgWeight;
  final double weightChange;
  final int avgCalories;

  KpiData({
    required this.avgWeight,
    required this.weightChange,
    required this.avgCalories,
  });

  factory KpiData.fromJson(Map<String, dynamic> json) {
    return KpiData(
      avgWeight: (json['avgWeight'] as num).toDouble(),
      weightChange: (json['weightChange'] as num).toDouble(),
      avgCalories: json['avgCalories'],
    );
  }
}
