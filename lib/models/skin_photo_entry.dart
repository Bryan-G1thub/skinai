class SkinPhotoEntry {
  final String id;
  final String path;
  final String createdAtIso;
  final String? note;
  final String? linkedCheckInId;

  const SkinPhotoEntry({
    required this.id,
    required this.path,
    required this.createdAtIso,
    this.note,
    this.linkedCheckInId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'createdAtIso': createdAtIso,
        'note': note,
        'linkedCheckInId': linkedCheckInId,
      };

  factory SkinPhotoEntry.fromJson(Map<String, dynamic> json) => SkinPhotoEntry(
        id: json['id'] as String,
        path: json['path'] as String,
        createdAtIso: json['createdAtIso'] as String,
        note: json['note'] as String?,
        linkedCheckInId: json['linkedCheckInId'] as String?,
      );
}
