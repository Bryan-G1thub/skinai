class RoutineStep {
  final String id;
  final String? catalogProductId;
  final String customLabel;

  const RoutineStep({
    required this.id,
    this.catalogProductId,
    this.customLabel = '',
  });

  bool get isPlaceholder =>
      catalogProductId == null && customLabel.trim().isEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'catalogProductId': catalogProductId,
        'customLabel': customLabel,
      };

  factory RoutineStep.fromJson(Map<String, dynamic> json) => RoutineStep(
        id: json['id'] as String,
        catalogProductId: json['catalogProductId'] as String?,
        customLabel: json['customLabel'] as String? ?? '',
      );
}
