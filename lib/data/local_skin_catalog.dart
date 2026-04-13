import '../models/local_catalog_product.dart';

/// Bundled offline catalog — swap for API later without changing UI.
class LocalSkinCatalog {
  LocalSkinCatalog._();

  static final List<LocalCatalogProduct> _products = [
    const LocalCatalogProduct(
      id: 'cv_hydrating_cleanser',
      name: 'Hydrating Facial Cleanser',
      brand: 'CeraVe',
      role: 'cleanser',
      actives: ['ceramides', 'hyaluronic_acid'],
      skinTypesGood: ['dry', 'normal', 'sensitive'],
      concernTags: ['dryness', 'barrier'],
      blurb: 'Non-foaming cream cleanser — gentle, barrier-friendly.',
    ),
    const LocalCatalogProduct(
      id: 'cv_foaming_cleanser',
      name: 'Foaming Facial Cleanser',
      brand: 'CeraVe',
      role: 'cleanser',
      actives: ['ceramides', 'niacinamide'],
      skinTypesGood: ['oily', 'combination', 'normal'],
      concernTags: ['oiliness'],
      blurb: 'Removes excess oil without stripping.',
    ),
    const LocalCatalogProduct(
      id: 'cv_sa_cleanser',
      name: 'SA Cleanser',
      brand: 'CeraVe',
      role: 'cleanser',
      actives: ['salicylic_acid', 'ceramides'],
      skinTypesGood: ['oily', 'combination'],
      concernTags: ['acne', 'congestion'],
      flags: {'exfoliant'},
      blurb: 'BHA cleanser for blemish-prone skin.',
    ),
    const LocalCatalogProduct(
      id: 'to_niacinamide',
      name: 'Niacinamide 10% + Zinc 1%',
      brand: 'The Ordinary',
      role: 'serum',
      actives: ['niacinamide', 'zinc'],
      skinTypesGood: ['oily', 'combination'],
      concernTags: ['oiliness', 'pores'],
      blurb: 'Oil and pore appearance support.',
    ),
    const LocalCatalogProduct(
      id: 'to_hyaluronic',
      name: 'Hyaluronic Acid 2% + B5',
      brand: 'The Ordinary',
      role: 'serum',
      actives: ['hyaluronic_acid', 'b5'],
      skinTypesGood: ['dry', 'normal', 'combination'],
      concernTags: ['dryness', 'dehydration'],
      blurb: 'Water-binding hydration booster.',
    ),
    const LocalCatalogProduct(
      id: 'to_retinoid',
      name: 'Granactive Retinoid 2% in Squalane',
      brand: 'The Ordinary',
      role: 'treatment',
      actives: ['retinoid'],
      skinTypesGood: ['normal', 'combination', 'oily'],
      concernTags: ['aging', 'texture'],
      flags: {'photosensitizer', 'retinoid_family'},
      blurb: 'Introduce slowly; always pair with SPF.',
    ),
    const LocalCatalogProduct(
      id: 'to_vitc',
      name: 'Vitamin C Suspension 23% + HA',
      brand: 'The Ordinary',
      role: 'serum',
      actives: ['vitamin_c'],
      skinTypesGood: ['normal', 'combination'],
      concernTags: ['dark_spots', 'dullness'],
      flags: {'photosensitizer'},
      blurb: 'Brightening; can tingle — patch test.',
    ),
    const LocalCatalogProduct(
      id: 'pc_bha',
      name: 'Skin Perfecting 2% BHA Liquid',
      brand: "Paula's Choice",
      role: 'exfoliant',
      actives: ['salicylic_acid'],
      skinTypesGood: ['oily', 'combination'],
      concernTags: ['acne', 'blackheads'],
      flags: {'exfoliant'},
      blurb: 'Leave-on BHA for pores and texture.',
    ),
    const LocalCatalogProduct(
      id: 'lrp_toleriane',
      name: 'Toleriane Double Repair Moisturizer',
      brand: 'La Roche-Posay',
      role: 'moisturizer',
      actives: ['ceramide', 'niacinamide'],
      skinTypesGood: ['dry', 'sensitive', 'normal'],
      concernTags: ['barrier', 'redness'],
      blurb: 'Barrier-focused daily moisturizer.',
    ),
    const LocalCatalogProduct(
      id: 'lrp_effaclar',
      name: 'Effaclar Duo (+)',
      brand: 'La Roche-Posay',
      role: 'treatment',
      actives: ['niacinamide', 'salicylic_acid'],
      skinTypesGood: ['oily', 'combination'],
      concernTags: ['acne'],
      blurb: 'Blemish-targeted care — can be drying.',
    ),
    const LocalCatalogProduct(
      id: 'neutrogena_hydro',
      name: 'Hydro Boost Water Gel',
      brand: 'Neutrogena',
      role: 'moisturizer',
      actives: ['hyaluronic_acid'],
      skinTypesGood: ['oily', 'combination', 'normal'],
      concernTags: ['dehydration'],
      blurb: 'Light gel-cream hydration.',
    ),
    const LocalCatalogProduct(
      id: 'vanicream_moist',
      name: 'Moisturizing Cream',
      brand: 'Vanicream',
      role: 'moisturizer',
      actives: ['petrolatum'],
      skinTypesGood: ['sensitive', 'dry'],
      concernTags: ['barrier'],
      flags: {'minimal'},
      blurb: 'Minimal ingredients — sensitive-skin staple.',
    ),
    const LocalCatalogProduct(
      id: 'eltamd_uv',
      name: 'UV Clear SPF 46',
      brand: 'EltaMD',
      role: 'spf',
      actives: ['zinc_oxide', 'niacinamide'],
      skinTypesGood: ['normal', 'combination', 'oily', 'sensitive'],
      concernTags: [],
      blurb: 'Broad-spectrum daily SPF — reapply as directed.',
    ),
    const LocalCatalogProduct(
      id: 'laroche_anthelios',
      name: 'Anthelios Melt-In Milk SPF 60',
      brand: 'La Roche-Posay',
      role: 'spf',
      actives: ['uv_filters'],
      skinTypesGood: ['dry', 'normal', 'combination'],
      concernTags: [],
      blurb: 'High-protection sunscreen — cornerstone of routine.',
    ),
    const LocalCatalogProduct(
      id: 'supergoop_unseen',
      name: 'Unseen Sunscreen SPF 40',
      brand: 'Supergoop!',
      role: 'spf',
      actives: ['uv_filters'],
      skinTypesGood: ['normal', 'combination', 'oily'],
      concernTags: [],
      blurb: 'Weightless primer-like SPF.',
    ),
    const LocalCatalogProduct(
      id: 'cosrx_snail',
      name: 'Advanced Snail 96 Mucin',
      brand: 'COSRX',
      role: 'serum',
      actives: ['snail_mucin'],
      skinTypesGood: ['dry', 'normal', 'combination'],
      concernTags: ['texture', 'barrier'],
      blurb: 'Soothing, hydrating essence texture.',
    ),
    const LocalCatalogProduct(
      id: 'good_genes',
      name: 'Good Genes',
      brand: 'Sunday Riley',
      role: 'exfoliant',
      actives: ['lactic_acid'],
      skinTypesGood: ['normal', 'combination'],
      concernTags: ['texture', 'dullness'],
      flags: {'exfoliant', 'photosensitizer'},
      blurb: 'AHA for glow — alternate with retinoids.',
    ),
    const LocalCatalogProduct(
      id: 'skinceuticals_ce',
      name: 'C E Ferulic',
      brand: 'SkinCeuticals',
      role: 'serum',
      actives: ['vitamin_c', 'vitamin_e', 'ferulic_acid'],
      skinTypesGood: ['normal', 'dry', 'combination'],
      concernTags: ['dark_spots', 'dullness'],
      blurb: 'Antioxidant daytime serum — store properly.',
    ),
    const LocalCatalogProduct(
      id: 'aveeno_oat',
      name: 'Calm + Restore Oat Gel Moisturizer',
      brand: 'Aveeno',
      role: 'moisturizer',
      actives: ['oat'],
      skinTypesGood: ['sensitive', 'dry', 'normal'],
      concernTags: ['redness'],
      blurb: 'Soothing gel-cream for reactive skin.',
    ),
    const LocalCatalogProduct(
      id: 'differin',
      name: 'Adapalene Gel 0.1%',
      brand: 'Differin',
      role: 'treatment',
      actives: ['adapalene'],
      skinTypesGood: ['oily', 'combination'],
      concernTags: ['acne'],
      flags: {'retinoid_family', 'photosensitizer'},
      blurb: 'OTC retinoid for acne — follow label; SPF daily.',
    ),
    const LocalCatalogProduct(
      id: 'micellar_simple',
      name: 'Micellar Cleansing Water',
      brand: 'Simple',
      role: 'cleanser',
      actives: [],
      skinTypesGood: ['sensitive', 'dry', 'normal'],
      concernTags: [],
      flags: {'minimal'},
      blurb: 'First cleanse / light cleanse option.',
    ),
  ];

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
