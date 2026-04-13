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
  });
}
