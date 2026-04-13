class FirestoreProduct {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String affiliateUrl;
  final String? imageUrl;
  final String? reason;
  final List<String> concernTags;
  final List<String> skinTypeTags;

  /// Combined tags used by [FirestoreProductService] queries and scoring.
  final List<String> searchTags;

  const FirestoreProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.affiliateUrl,
    this.imageUrl,
    this.reason,
    this.concernTags = const [],
    this.skinTypeTags = const [],
    this.searchTags = const [],
  });

  factory FirestoreProduct.fromJson(String id, Map<String, dynamic> json) {
    return FirestoreProduct(
      id: id,
      name: json['name'] as String? ?? 'Unknown Product',
      brand: json['brand'] as String? ?? 'Unknown Brand',
      category: json['category'] as String? ?? 'Product',
      affiliateUrl: json['affiliateUrl'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      reason: json['reason'] as String?,
      concernTags:
          (json['concernTags'] as List?)?.map((e) => e as String).toList() ?? const [],
      skinTypeTags:
          (json['skinTypeTags'] as List?)?.map((e) => e as String).toList() ?? const [],
      searchTags:
          (json['searchTags'] as List?)?.map((e) => e as String).toList() ?? const [],
    );
  }
}
