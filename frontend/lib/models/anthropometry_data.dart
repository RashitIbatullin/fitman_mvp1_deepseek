class AnthropometryData {
  final AnthropometryFixed fixed;
  final AnthropometryMeasurements start;
  final AnthropometryMeasurements finish;

  AnthropometryData({
    required this.fixed,
    required this.start,
    required this.finish,
  });

  factory AnthropometryData.fromJson(Map<String, dynamic> json) {
    return AnthropometryData(
      fixed: AnthropometryFixed.fromJson(json['fixed']),
      start: AnthropometryMeasurements.fromJson(json['start']),
      finish: AnthropometryMeasurements.fromJson(json['finish']),
    );
  }
}

class AnthropometryFixed {
  final int height;
  final int wristCirc;
  final int ankleCirc;

  AnthropometryFixed({
    required this.height,
    required this.wristCirc,
    required this.ankleCirc,
  });

  factory AnthropometryFixed.fromJson(Map<String, dynamic> json) {
    return AnthropometryFixed(
      height: json['height'],
      wristCirc: json['wrist_circ'],
      ankleCirc: json['ankle_circ'],
    );
  }
}

class AnthropometryMeasurements {
  final double weight;
  final int shouldersCirc;
  final int breastCirc;
  final int waistCirc;
  final int hipsCirc;

  AnthropometryMeasurements({
    required this.weight,
    required this.shouldersCirc,
    required this.breastCirc,
    required this.waistCirc,
    required this.hipsCirc,
  });

  factory AnthropometryMeasurements.fromJson(Map<String, dynamic> json) {
    return AnthropometryMeasurements(
      weight: (json['weight'] as num).toDouble(),
      shouldersCirc: json['shoulders_circ'],
      breastCirc: json['breast_circ'],
      waistCirc: json['waist_circ'],
      hipsCirc: json['hips_circ'],
    );
  }
}
