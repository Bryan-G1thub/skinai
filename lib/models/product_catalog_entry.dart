/// Known product line for fuzzy matching user free-text to actives / categories.
class ProductCatalogEntry {
  final String id;
  final List<String> matchPhrases;
  final List<String> keyActives;
  final List<String> suitableForSkinTypes;
  final List<String> concernTags;
  final String summary;

  const ProductCatalogEntry({
    required this.id,
    required this.matchPhrases,
    required this.keyActives,
    this.suitableForSkinTypes = const [],
    this.concernTags = const [],
    required this.summary,
  });
}
