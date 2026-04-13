import '../models/product_catalog_entry.dart';

/// In-app product knowledge for fuzzy matching typed routine names.
/// Extend or sync from Firestore for production.
class ProductKnowledgeService {
  ProductKnowledgeService._();

  static const List<ProductCatalogEntry> _catalog = [
    ProductCatalogEntry(
      id: 'cerave_hydrating_cleanser',
      matchPhrases: [
        'cerave hydrating',
        'cerave hydrating cleanser',
        'hydrating cleanser cerave',
      ],
      keyActives: ['ceramides', 'hyaluronic acid'],
      suitableForSkinTypes: ['dry', 'normal', 'sensitive'],
      concernTags: ['dryness'],
      summary:
          'Gentle cream cleanser with ceramides — supports barrier, low irritation risk.',
    ),
    ProductCatalogEntry(
      id: 'cerave_sa',
      matchPhrases: ['cerave sa', 'cerave salicylic', 'sa cleanser cerave'],
      keyActives: ['salicylic acid', 'ceramides'],
      suitableForSkinTypes: ['oily', 'combination'],
      concernTags: ['acne', 'congestion'],
      summary: 'BHA cleanser — helps clear pores; can be drying if overused.',
    ),
    ProductCatalogEntry(
      id: 'the_ordinary_niacinamide',
      matchPhrases: [
        'niacinamide 10',
        'ordinary niacinamide',
        'the ordinary niacinamide',
      ],
      keyActives: ['niacinamide', 'zinc'],
      suitableForSkinTypes: ['oily', 'combination'],
      concernTags: ['oiliness', 'pores'],
      summary: 'Oil and pore appearance control; patch test if sensitive.',
    ),
    ProductCatalogEntry(
      id: 'the_ordinary_retinol',
      matchPhrases: [
        'ordinary retinol',
        'granactive retinoid',
        'the ordinary retinoid',
      ],
      keyActives: ['retinoid', 'retinol'],
      suitableForSkinTypes: ['normal', 'combination', 'oily'],
      concernTags: ['aging', 'texture'],
      summary: 'Cell-turnover support; use SPF, introduce slowly.',
    ),
    ProductCatalogEntry(
      id: 'paula_choice_bha',
      matchPhrases: ['paula', 'bha', 'salicylic acid 2'],
      keyActives: ['salicylic acid'],
      suitableForSkinTypes: ['oily', 'combination'],
      concernTags: ['acne', 'blackheads'],
      summary: 'BHA exfoliation for pores and blemish-prone skin.',
    ),
    ProductCatalogEntry(
      id: 'laroche_toleriane',
      matchPhrases: ['la roche', 'toleriane', 'laroche'],
      keyActives: ['ceramide', 'glycerin'],
      suitableForSkinTypes: ['dry', 'sensitive'],
      concernTags: ['redness', 'barrier'],
      summary: 'Barrier-friendly moisturizer line; widely tolerated.',
    ),
    ProductCatalogEntry(
      id: 'vanicream',
      matchPhrases: ['vanicream', 'vani cream'],
      keyActives: ['petrolatum', 'ceramides'],
      suitableForSkinTypes: ['sensitive', 'dry'],
      concernTags: ['redness'],
      summary: 'Minimal-ingredient moisturizers for reactive skin.',
    ),
    ProductCatalogEntry(
      id: 'generic_sunscreen',
      matchPhrases: ['spf', 'sunscreen', 'sun screen', 'uv'],
      keyActives: ['uv filters'],
      suitableForSkinTypes: ['normal', 'oily', 'dry', 'combination', 'sensitive'],
      concernTags: [],
      summary: 'Daily UV protection is foundational for any routine.',
    ),
  ];

  /// Best-effort matches for user-entered product strings.
  static List<ProductKnowledgeMatch> matchUserProducts(List<String> rawNames) {
    final out = <ProductKnowledgeMatch>[];
    for (final raw in rawNames) {
      final q = raw.trim().toLowerCase();
      if (q.isEmpty) continue;
      ProductCatalogEntry? best;
      var bestScore = 0;
      for (final entry in _catalog) {
        for (final phrase in entry.matchPhrases) {
          if (q.contains(phrase) || phrase.contains(q)) {
            final s = phrase.length.clamp(1, 50);
            if (s > bestScore) {
              bestScore = s;
              best = entry;
            }
          }
        }
      }
      if (best != null) {
        out.add(ProductKnowledgeMatch(
          userInput: raw,
          entry: best,
        ));
      }
    }
    return out;
  }
}

class ProductKnowledgeMatch {
  final String userInput;
  final ProductCatalogEntry entry;

  const ProductKnowledgeMatch({
    required this.userInput,
    required this.entry,
  });
}
