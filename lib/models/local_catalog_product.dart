/// Offline catalog entry — no network calls.
class LocalCatalogProduct {
  final String id;
  final String name;
  final String brand;

  /// cleanser, serum, treatment, moisturizer, spf, exfoliant, eye, misc
  final String role;

  final List<String> actives;
  final List<String> skinTypesGood;
  final List<String> concernTags;

  /// Flags for rules (e.g. fragrance_heavy, photosensitizer)
  final Set<String> flags;

  final String blurb;

  /// Optional fixed affiliate link; if null, UI may fall back to Amazon search.
  final String? affiliateUrl;
  final String? imageUrl;

  /// Snapshot price for display (e.g. "~\$15.97") — Amazon changes prices; re-verify periodically.
  final String? priceDisplay;

  /// Product UPC when known (helps you match in-store / inventory).
  final String? upc;

  const LocalCatalogProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.role,
    this.actives = const [],
    this.skinTypesGood = const [],
    this.concernTags = const [],
    this.flags = const {},
    required this.blurb,
    this.affiliateUrl,
    this.imageUrl,
    this.priceDisplay,
    this.upc,
  });
}
