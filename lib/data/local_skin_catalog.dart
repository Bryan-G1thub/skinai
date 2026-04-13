// Amazon.com (US) product detail URLs — one ASIN per catalog row.
//
// ASINs and titles were matched to live Amazon.com `/dp/{ASIN}` listings using public
// search/indexed results (not the Product Advertising API). Amazon may change
// listings, merges, or redirects over time — spot-check links periodically.
//
// For Amazon Associates: append your tracking id, e.g.
//   https://www.amazon.com/dp/B01MSSDEPK?tag=YOURSTORE-20
// (Use the exact format required by your Associates account and locale.)

import '../models/local_catalog_product.dart';

/// Bundled catalog — every item includes a real Amazon US detail URL (`affiliateUrl`).
class LocalSkinCatalog {
  LocalSkinCatalog._();

  static String _dp(String asin) => 'https://www.amazon.com/dp/$asin';

  static final List<LocalCatalogProduct> _products = [
    // ── Cleansers ─────────────────────────────────────────────────────────
    LocalCatalogProduct(
      id: 'amz_B01MSSDEPK',
      name: 'Hydrating Facial Cleanser',
      brand: 'CeraVe',
      role: 'cleanser',
      actives: ['ceramides', 'hyaluronic_acid', 'glycerin'],
      skinTypesGood: ['dry', 'normal', 'sensitive'],
      concernTags: ['dryness', 'barrier'],
      flags: {'fragrance_free', 'minimal'},
      blurb:
          'Cream non-foaming face wash; ceramides + HA. Tap card to open https://www.amazon.com/dp/B01MSSDEPK and verify price/size.',
      affiliateUrl: _dp('B01MSSDEPK'),
      // Price from indexed public sources (Amazon blocks automated scrape); confirm on listing.
      priceDisplay: r'~$15.97 (US, verify live)',
      upc: '301871370125',
    ),
    LocalCatalogProduct(
      id: 'amz_B01N1LL62W',
      name: 'Foaming Facial Cleanser (16 fl oz)',
      brand: 'CeraVe',
      role: 'cleanser',
      actives: ['ceramides', 'niacinamide', 'hyaluronic_acid'],
      skinTypesGood: ['oily', 'combination', 'normal'],
      concernTags: ['oiliness'],
      flags: {'fragrance_free'},
      blurb: 'Gel-to-foam cleanser for normal to oily skin (per Amazon listing).',
      affiliateUrl: _dp('B01N1LL62W'),
    ),
    LocalCatalogProduct(
      id: 'amz_B003YMJJSK',
      name: 'Foaming Facial Cleanser (12 fl oz)',
      brand: 'CeraVe',
      role: 'cleanser',
      actives: ['ceramides', 'niacinamide', 'hyaluronic_acid'],
      skinTypesGood: ['oily', 'combination', 'normal'],
      concernTags: ['oiliness'],
      flags: {'fragrance_free'},
      blurb: 'Foaming daily face wash for oily skin (per Amazon listing).',
      affiliateUrl: _dp('B003YMJJSK'),
    ),
    LocalCatalogProduct(
      id: 'amz_B08CQDF382',
      name: 'Hydrating Cream To Foam Cleanser',
      brand: 'CeraVe',
      role: 'cleanser',
      actives: ['ceramides', 'hyaluronic_acid'],
      skinTypesGood: ['dry', 'normal'],
      concernTags: ['dryness', 'barrier'],
      flags: {'fragrance_free'},
      blurb: 'Makeup-removing cream-to-foam for dry skin (per Amazon listing).',
      affiliateUrl: _dp('B08CQDF382'),
    ),
    LocalCatalogProduct(
      id: 'amz_B01N7T7JKJ',
      name: 'Toleriane Hydrating Gentle Cleanser',
      brand: 'La Roche-Posay',
      role: 'cleanser',
      actives: ['niacinamide', 'ceramides'],
      skinTypesGood: ['dry', 'normal', 'sensitive'],
      concernTags: ['barrier', 'redness'],
      flags: {'fragrance_free'},
      blurb: 'Fragrance-free cream cleanser for sensitive skin (per Amazon listing).',
      affiliateUrl: _dp('B01N7T7JKJ'),
    ),
    LocalCatalogProduct(
      id: 'amz_B01N34XW93',
      name: 'Toleriane Purifying Foaming Facial Cleanser',
      brand: 'La Roche-Posay',
      role: 'cleanser',
      actives: ['niacinamide', 'ceramides'],
      skinTypesGood: ['oily', 'combination'],
      concernTags: ['oiliness', 'acne'],
      flags: {'fragrance_free'},
      blurb: 'Oil-free foaming cleanser for oily skin (per Amazon listing).',
      affiliateUrl: _dp('B01N34XW93'),
    ),
    LocalCatalogProduct(
      id: 'amz_B000052YMV',
      name: 'Gentle Skin Cleanser',
      brand: 'Cetaphil',
      role: 'cleanser',
      actives: ['glycerin'],
      skinTypesGood: ['sensitive', 'dry', 'normal'],
      concernTags: ['barrier'],
      flags: {'fragrance_free', 'minimal'},
      blurb: 'Classic mild cleanser for sensitive skin (per Amazon listing).',
      affiliateUrl: _dp('B000052YMV'),
    ),
    LocalCatalogProduct(
      id: 'amz_B09WZB785B',
      name: 'Gentle Skin Cleanser (20 fl oz)',
      brand: 'Cetaphil',
      role: 'cleanser',
      actives: ['glycerin', 'vitamin_b3'],
      skinTypesGood: ['sensitive', 'dry', 'normal'],
      concernTags: ['barrier'],
      flags: {'fragrance_free'},
      blurb: 'Hydrating face & body cleanser, fragrance-free (per Amazon listing).',
      affiliateUrl: _dp('B09WZB785B'),
    ),
    LocalCatalogProduct(
      id: 'amz_B08BG5Y7FL',
      name: 'Calm + Restore Nourishing Oat Cleanser',
      brand: 'Aveeno',
      role: 'cleanser',
      actives: ['oat', 'feverfew'],
      skinTypesGood: ['sensitive', 'dry'],
      concernTags: ['redness', 'barrier'],
      flags: {'fragrance_free'},
      blurb: 'Non-foaming oat cleanser for sensitive skin (per Amazon listing).',
      affiliateUrl: _dp('B08BG5Y7FL'),
    ),
    LocalCatalogProduct(
      id: 'amz_B006RBR7NO',
      name: 'Sensibio H2O Micellar Water (3.4 fl oz)',
      brand: 'Bioderma',
      role: 'cleanser',
      actives: [],
      skinTypesGood: ['sensitive', 'normal'],
      concernTags: ['redness'],
      flags: {'fragrance_free', 'minimal'},
      blurb: 'Micellar makeup remover / cleanse, fragrance & alcohol free (per Amazon listing).',
      affiliateUrl: _dp('B006RBR7NO'),
    ),
    LocalCatalogProduct(
      id: 'amz_B0824BS8D6',
      name: 'Sensibio H2O (larger size)',
      brand: 'Bioderma',
      role: 'cleanser',
      actives: [],
      skinTypesGood: ['sensitive', 'normal'],
      concernTags: ['redness'],
      flags: {'fragrance_free'},
      blurb: 'Sensibio micellar cleansing water (per Amazon listing).',
      affiliateUrl: _dp('B0824BS8D6'),
    ),

    // ── Toners / essences ─────────────────────────────────────────────────
    LocalCatalogProduct(
      id: 'amz_B00PBX3L7K',
      name: 'Advanced Snail 96 Mucin Power Essence',
      brand: 'COSRX',
      role: 'toner',
      actives: ['snail_mucin'],
      skinTypesGood: ['dry', 'normal', 'combination'],
      concernTags: ['texture', 'barrier', 'dehydration'],
      blurb: 'Snail mucin hydrating essence (per Amazon listing).',
      affiliateUrl: _dp('B00PBX3L7K'),
    ),

    // ── Serums ────────────────────────────────────────────────────────────
    LocalCatalogProduct(
      id: 'amz_B01MDTVZTZ',
      name: 'Niacinamide 10% + Zinc 1%',
      brand: 'The Ordinary',
      role: 'serum',
      actives: ['niacinamide', 'zinc'],
      skinTypesGood: ['oily', 'combination'],
      concernTags: ['oiliness', 'acne'],
      flags: {'fragrance_free', 'vegan'},
      blurb: 'Niacinamide + zinc serum (per Amazon listing).',
      affiliateUrl: _dp('B01MDTVZTZ'),
    ),
    LocalCatalogProduct(
      id: 'amz_B01MYEZPC8',
      name: 'Hyaluronic Acid 2% + B5',
      brand: 'The Ordinary',
      role: 'serum',
      actives: ['hyaluronic_acid', 'b5'],
      skinTypesGood: ['dry', 'normal', 'combination'],
      concernTags: ['dehydration', 'dryness'],
      flags: {'fragrance_free', 'vegan'},
      blurb: 'HA + B5 hydration support (per Amazon listing).',
      affiliateUrl: _dp('B01MYEZPC8'),
    ),
    LocalCatalogProduct(
      id: 'amz_B07ZJY5G2Z',
      name: 'Hyaluronic Acid 2% + B5 (alt listing)',
      brand: 'The Ordinary',
      role: 'serum',
      actives: ['hyaluronic_acid', 'b5'],
      skinTypesGood: ['dry', 'normal', 'combination'],
      concernTags: ['dehydration'],
      flags: {'vegan'},
      blurb: 'Hydration support formula (per Amazon listing).',
      affiliateUrl: _dp('B07ZJY5G2Z'),
    ),
    LocalCatalogProduct(
      id: 'amz_B00KOAMZCW',
      name: 'RESIST Daily Pore-Refining Treatment 2% BHA',
      brand: "Paula's Choice",
      role: 'serum',
      actives: ['salicylic_acid', 'hyaluronic_acid'],
      skinTypesGood: ['oily', 'combination', 'normal'],
      concernTags: ['acne', 'pores'],
      flags: {'exfoliant', 'fragrance_free'},
      blurb: 'Leave-on BHA treatment with HA (per Amazon listing).',
      affiliateUrl: _dp('B00KOAMZCW'),
    ),

    // ── Exfoliants (leave-on) ─────────────────────────────────────────────
    LocalCatalogProduct(
      id: 'amz_B00949CTQQ',
      name: 'Skin Perfecting 2% BHA Liquid Exfoliant',
      brand: "Paula's Choice",
      role: 'exfoliant',
      actives: ['salicylic_acid'],
      skinTypesGood: ['oily', 'combination', 'normal'],
      concernTags: ['acne', 'blackheads', 'texture'],
      flags: {'exfoliant', 'fragrance_free'},
      blurb: 'Salicylic acid leave-on exfoliant (per Amazon listing).',
      affiliateUrl: _dp('B00949CTQQ'),
    ),

    // ── Treatments ────────────────────────────────────────────────────────
    LocalCatalogProduct(
      id: 'amz_B07L1PHSY9',
      name: 'Adapalene Gel 0.1% Acne Treatment',
      brand: 'Differin',
      role: 'treatment',
      actives: ['adapalene'],
      skinTypesGood: ['oily', 'combination'],
      concernTags: ['acne'],
      flags: {'retinoid_family', 'photosensitizer'},
      blurb: 'OTC adapalene acne treatment (per Amazon listing).',
      affiliateUrl: _dp('B07L1PHSY9'),
    ),
    LocalCatalogProduct(
      id: 'amz_B073QS6JLF',
      name: 'Adapalene Gel 0.1% (multi-pack listing)',
      brand: 'Differin',
      role: 'treatment',
      actives: ['adapalene'],
      skinTypesGood: ['oily', 'combination'],
      concernTags: ['acne'],
      flags: {'retinoid_family', 'photosensitizer'},
      blurb: 'Adapalene — check pack size on listing (per Amazon).',
      affiliateUrl: _dp('B073QS6JLF'),
    ),

    // ── Moisturizers ────────────────────────────────────────────────────────
    LocalCatalogProduct(
      id: 'amz_B00365DABC',
      name: 'PM Facial Moisturizing Lotion',
      brand: 'CeraVe',
      role: 'moisturizer',
      actives: ['niacinamide', 'hyaluronic_acid', 'ceramides'],
      skinTypesGood: ['normal', 'combination', 'dry'],
      concernTags: ['barrier', 'dryness'],
      flags: {'fragrance_free'},
      blurb: 'Night lotion with niacinamide + HA (per Amazon listing).',
      affiliateUrl: _dp('B00365DABC'),
    ),
    LocalCatalogProduct(
      id: 'amz_B074Y758CD',
      name: 'Moisturizing Skin Cream (with pump)',
      brand: 'Vanicream',
      role: 'moisturizer',
      actives: ['petrolatum'],
      skinTypesGood: ['sensitive', 'dry'],
      concernTags: ['barrier', 'dryness'],
      flags: {'fragrance_free', 'minimal'},
      blurb: 'Thick cream for sensitive skin (per Amazon listing).',
      affiliateUrl: _dp('B074Y758CD'),
    ),
    LocalCatalogProduct(
      id: 'amz_B010D05QVY',
      name: 'Moisturizing Skin Cream (1 lb tub)',
      brand: 'Vanicream',
      role: 'moisturizer',
      actives: ['petrolatum'],
      skinTypesGood: ['sensitive', 'dry'],
      concernTags: ['barrier'],
      flags: {'fragrance_free', 'minimal'},
      blurb: 'Rich barrier cream (per Amazon listing).',
      affiliateUrl: _dp('B010D05QVY'),
    ),
    LocalCatalogProduct(
      id: 'amz_B01G499KJC',
      name: 'Moisturizing Skin Cream (listing variant)',
      brand: 'Vanicream',
      role: 'moisturizer',
      actives: ['petrolatum'],
      skinTypesGood: ['sensitive', 'dry'],
      concernTags: ['barrier'],
      flags: {'fragrance_free'},
      blurb: 'Sensitive-skin moisturizer (per Amazon listing).',
      affiliateUrl: _dp('B01G499KJC'),
    ),
    LocalCatalogProduct(
      id: 'amz_B01LEJ5MSK',
      name: 'Snail Mucin 92% Repair Cream',
      brand: 'COSRX',
      role: 'moisturizer',
      actives: ['snail_mucin'],
      skinTypesGood: ['dry', 'normal', 'combination'],
      concernTags: ['texture', 'barrier'],
      blurb: 'Snail mucin moisturizer cream (per Amazon listing).',
      affiliateUrl: _dp('B01LEJ5MSK'),
    ),

    // ── Sunscreen (SPF) ────────────────────────────────────────────────────
    LocalCatalogProduct(
      id: 'amz_B002MSN3QQ',
      name: 'UV Clear Broad-Spectrum SPF 46',
      brand: 'EltaMD',
      role: 'spf',
      actives: ['zinc_oxide', 'niacinamide'],
      skinTypesGood: ['normal', 'combination', 'oily', 'sensitive'],
      concernTags: ['acne', 'redness'],
      blurb: 'Oil-free face SPF — tinted/un-tinted variants on listing (per Amazon).',
      affiliateUrl: _dp('B002MSN3QQ'),
    ),
    LocalCatalogProduct(
      id: 'amz_B0CTD8N6K6',
      name: 'UV Clear Face Sunscreen SPF 46 (listing variant)',
      brand: 'EltaMD',
      role: 'spf',
      actives: ['zinc_oxide', 'niacinamide'],
      skinTypesGood: ['normal', 'combination', 'oily'],
      concernTags: ['acne'],
      blurb: 'Oil-free SPF 46 face sunscreen (per Amazon listing).',
      affiliateUrl: _dp('B0CTD8N6K6'),
    ),
    LocalCatalogProduct(
      id: 'amz_B000EPA4GQ',
      name: 'Ultra Sheer Dry-Touch Sunscreen SPF 55',
      brand: 'Neutrogena',
      role: 'spf',
      actives: ['avobenzone'],
      skinTypesGood: ['normal', 'combination', 'oily'],
      concernTags: [],
      blurb: 'Broad spectrum SPF 55 face & body (per Amazon listing).',
      affiliateUrl: _dp('B000EPA4GQ'),
    ),
    LocalCatalogProduct(
      id: 'amz_B01A0NT3D6',
      name: 'Anthelios Clear Skin Dry Touch Sunscreen SPF 60',
      brand: 'La Roche-Posay',
      role: 'spf',
      actives: ['uv_filters'],
      skinTypesGood: ['oily', 'combination'],
      concernTags: ['oiliness'],
      blurb: 'Oil-absorbing SPF 60 face sunscreen (per Amazon listing).',
      affiliateUrl: _dp('B01A0NT3D6'),
    ),
    LocalCatalogProduct(
      id: 'amz_B00TBJWP9K',
      name: 'Anthelios Cooling Water Sunscreen Lotion SPF 60',
      brand: 'La Roche-Posay',
      role: 'spf',
      actives: ['uv_filters'],
      skinTypesGood: ['normal', 'combination', 'dry'],
      concernTags: [],
      blurb: 'Water-based SPF 60 lotion (per Amazon listing).',
      affiliateUrl: _dp('B00TBJWP9K'),
    ),
    LocalCatalogProduct(
      id: 'amz_B08CFVM1TT',
      name: 'Unseen Sunscreen SPF 40',
      brand: 'Supergoop!',
      role: 'spf',
      actives: ['uv_filters'],
      skinTypesGood: ['normal', 'combination', 'oily'],
      concernTags: [],
      flags: {'fragrance_heavy'},
      blurb: 'Clear primer-like SPF — check scent sensitivity (per Amazon listing).',
      affiliateUrl: _dp('B08CFVM1TT'),
    ),
    LocalCatalogProduct(
      id: 'amz_B08GCX5V9G',
      name: 'Unseen Sunscreen SPF 40 (0.5 fl oz)',
      brand: 'Supergoop!',
      role: 'spf',
      actives: ['uv_filters'],
      skinTypesGood: ['normal', 'combination'],
      concernTags: [],
      blurb: 'Travel-size Unseen SPF (per Amazon listing).',
      affiliateUrl: _dp('B08GCX5V9G'),
    ),
  ];

  /// Prefer this URL for purchases; append `?tag=` for Associates.
  static String purchaseOrSearchUrl(LocalCatalogProduct p) {
    final fixed = p.affiliateUrl?.trim();
    if (fixed != null && fixed.isNotEmpty) return fixed;
    final q = '${p.brand} ${p.name}';
    return 'https://www.amazon.com/s?k=${Uri.encodeComponent(q)}';
  }

  static List<LocalCatalogProduct> get all => List.unmodifiable(_products);

  static LocalCatalogProduct? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<LocalCatalogProduct> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.of(_products);
    return _products.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.role.contains(q) ||
          p.actives.any((a) => a.contains(q));
    }).toList();
  }

  /// Match free-text from onboarding to catalog (best-effort).
  static LocalCatalogProduct? matchLoose(String raw) {
    final q = raw.toLowerCase().trim();
    if (q.isEmpty) return null;
    LocalCatalogProduct? best;
    var bestScore = 0;
    for (final p in _products) {
      var s = 0;
      if (q.contains(p.brand.toLowerCase())) s += 2;
      final words = p.name.toLowerCase().split(RegExp(r'\s+|\+'));
      for (final w in words) {
        if (w.length > 2 && q.contains(w)) s += 2;
      }
      if ('${p.brand} ${p.name}'.toLowerCase().contains(q)) s += 4;
      if (s > bestScore) {
        bestScore = s;
        best = p;
      }
    }
    return bestScore >= 3 ? best : null;
  }
}
