class SkinCheckIn {
  final String id;
  final String dateIso;

  /// 0–3 scale
  final int irritation;
  final int breakouts;
  final int moistureComfort;
  final String? note;

  const SkinCheckIn({
    required this.id,
    required this.dateIso,
    this.irritation = 0,
    this.breakouts = 0,
    this.moistureComfort = 2,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateIso': dateIso,
        'irritation': irritation,
        'breakouts': breakouts,
        'moistureComfort': moistureComfort,
        'note': note,
      };

  factory SkinCheckIn.fromJson(Map<String, dynamic> json) => SkinCheckIn(
        id: json['id'] as String,
        dateIso: json['dateIso'] as String,
        irritation: json['irritation'] as int? ?? 0,
        breakouts: json['breakouts'] as int? ?? 0,
        moistureComfort: json['moistureComfort'] as int? ?? 2,
        note: json['note'] as String?,
      );
}
