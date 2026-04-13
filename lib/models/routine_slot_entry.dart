import '../data/local_skin_catalog.dart';

/// One step in the user's self-reported routine (catalog match or manual).
class RoutineSlotEntry {
  /// cleanser | toner | moisturizer | active_treatment | spf
  final String categoryId;
  final String? catalogProductId;
  final String? manualBrand;
  final String? manualName;
  final List<String> manualActives;

  const RoutineSlotEntry({
    required this.categoryId,
    this.catalogProductId,
    this.manualBrand,
    this.manualName,
    this.manualActives = const [],
  });

  bool get isEmpty =>
      (catalogProductId == null || catalogProductId!.isEmpty) &&
      (manualBrand == null || manualBrand!.trim().isEmpty) &&
      (manualName == null || manualName!.trim().isEmpty) &&
      manualActives.isEmpty;

  String get resolvedLabel {
    if (catalogProductId != null && catalogProductId!.isNotEmpty) {
      final p = LocalSkinCatalog.getById(catalogProductId!);
      if (p != null) return '${p.brand} ${p.name}';
    }
    final parts = <String>[
      if (manualBrand != null && manualBrand!.trim().isNotEmpty) manualBrand!.trim(),
      if (manualName != null && manualName!.trim().isNotEmpty) manualName!.trim(),
      if (manualActives.isNotEmpty) manualActives.join(', '),
    ];
    return parts.join(' — ');
  }

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'catalogProductId': catalogProductId,
        'manualBrand': manualBrand,
        'manualName': manualName,
        'manualActives': manualActives,
      };

  factory RoutineSlotEntry.fromJson(Map<String, dynamic> json) {
    return RoutineSlotEntry(
      categoryId: json['categoryId'] as String? ?? 'cleanser',
      catalogProductId: json['catalogProductId'] as String?,
      manualBrand: json['manualBrand'] as String?,
      manualName: json['manualName'] as String?,
      manualActives: (json['manualActives'] as List?)?.map((e) => e as String).toList() ?? const [],
    );
  }
}
