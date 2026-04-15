enum CheckInPeriod { am, pm }

enum CheckInStatus { done, skipped }

class SkinCheckIn {
  final String id;
  final String dateIso;
  final CheckInPeriod period;
  final CheckInStatus status;
  final bool planned;

  /// 0–3 scale
  final int irritation;
  final int breakouts;
  final int moistureComfort;
  final String? note;
  final List<String> symptomTags;

  const SkinCheckIn({
    required this.id,
    required this.dateIso,
    this.period = CheckInPeriod.am,
    this.status = CheckInStatus.done,
    this.planned = true,
    this.irritation = 0,
    this.breakouts = 0,
    this.moistureComfort = 2,
    this.note,
    this.symptomTags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateIso': dateIso,
        'period': period.name,
        'status': status.name,
        'planned': planned,
        'irritation': irritation,
        'breakouts': breakouts,
        'moistureComfort': moistureComfort,
        'note': note,
        'symptomTags': symptomTags,
      };

  factory SkinCheckIn.fromJson(Map<String, dynamic> json) {
    final periodRaw = json['period'] as String?;
    final statusRaw = json['status'] as String?;
    return SkinCheckIn(
      id: json['id'] as String,
      dateIso: json['dateIso'] as String,
      period: periodRaw == 'pm' ? CheckInPeriod.pm : CheckInPeriod.am,
      status: statusRaw == 'skipped' ? CheckInStatus.skipped : CheckInStatus.done,
      planned: json['planned'] as bool? ?? true,
      irritation: json['irritation'] as int? ?? 0,
      breakouts: json['breakouts'] as int? ?? 0,
      moistureComfort: json['moistureComfort'] as int? ?? 2,
      note: json['note'] as String?,
      symptomTags: (json['symptomTags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}
