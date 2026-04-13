class CabinetItem {
  final String id;
  final String catalogProductId;
  final String addedAtIso;

  const CabinetItem({
    required this.id,
    required this.catalogProductId,
    required this.addedAtIso,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'catalogProductId': catalogProductId,
        'addedAtIso': addedAtIso,
      };

  factory CabinetItem.fromJson(Map<String, dynamic> json) => CabinetItem(
        id: json['id'] as String,
        catalogProductId: json['catalogProductId'] as String,
        addedAtIso: json['addedAtIso'] as String,
      );
}
