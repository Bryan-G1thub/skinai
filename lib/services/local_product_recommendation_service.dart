import '../data/local_skin_catalog.dart';
import '../models/local_catalog_product.dart';
import '../models/onboarding_data.dart';
import '../models/skin_analysis.dart';

/// Scores bundled catalog products using profile, analysis, preferences, and sensitivities.
class LocalProductRecommendationEngine {
  LocalProductRecommendationEngine._();

  static List<RankedLocalProduct> rank({
    required OnboardingData data,
    SkinAnalysis? analysis,
    Set<String> ownedCatalogIds = const {},
    int take = 10,
  }) {
    final products = LocalSkinCatalog.all;
    if (products.isEmpty) return const [];

    final conditionIds =
        analysis?.conditions.map((c) => c.id).toSet() ?? <String>{};
    final skin = data.skinType?.toLowerCase();
    final concern = data.concern?.toLowerCase();

    final prefs = data.productPreferences.map((e) => e.toLowerCase()).toSet();
    final sens = data.sensitivities.map((e) => e.toLowerCase()).toSet();

    final ranked = <RankedLocalProduct>[];
    for (final p in products) {
      if (ownedCatalogIds.contains(p.id)) continue;

      if (_hardExclude(p, prefs, sens)) continue;

      var score = 0.0;
      final tags = <String>{
        ...p.concernTags.map((e) => e.toLowerCase()),
        ...p.skinTypesGood.map((e) => e.toLowerCase()),
      };

      if (skin != null && tags.contains(skin)) score += 3;
      if (concern != null && tags.contains(concern)) score += 4;

      for (final id in conditionIds) {
        if (tags.contains(id)) score += 2.5;
        if (_conditionAlias(id).any(tags.contains)) score += 1.5;
      }

      score += _preferenceBoost(p, prefs);
      score -= _sensitivityPenalty(p, sens);

      final explanation = _explain(
        p,
        skin: skin,
        concern: concern,
        conditionIds: conditionIds,
        prefs: prefs,
      );

      ranked.add(RankedLocalProduct(
        product: p,
        score: score,
        explanation: explanation,
      ));
    }

    ranked.sort((a, b) => b.score.compareTo(a.score));
    return ranked.take(take).toList();
  }

  static bool _hardExclude(
    LocalCatalogProduct p,
    Set<String> prefs,
    Set<String> sens,
  ) {
    if (prefs.contains('fragrance_free') && p.flags.contains('fragrance_heavy')) {
      return true;
    }
    if (sens.contains('fragrance') && p.flags.contains('fragrance_heavy')) {
      return true;
    }
    return false;
  }

  static double _preferenceBoost(LocalCatalogProduct p, Set<String> prefs) {
    var b = 0.0;
    if (prefs.contains('vegan') && p.flags.contains('vegan')) b += 2;
    if (prefs.contains('cruelty_free') && p.flags.contains('cruelty_free')) b += 1.5;
    if (prefs.contains('fragrance_free') && p.flags.contains('fragrance_free')) b += 2;
    if (prefs.contains('minimal_ingredients') && p.flags.contains('minimal')) b += 1.5;
    return b;
  }

  static double _sensitivityPenalty(LocalCatalogProduct p, Set<String> sens) {
    var pen = 0.0;
    if (sens.contains('essential_oils') && p.flags.contains('essential_oils')) pen += 4;
    if (sens.contains('sulfates') && p.flags.contains('sulfates')) pen += 3;
    if (sens.contains('nuts') && p.flags.contains('nut_oils')) pen += 5;
    if (sens.contains('alcohol_denat') && p.flags.contains('drying_alcohol')) pen += 3;
    return pen;
  }

  static List<String> _conditionAlias(String id) {
    switch (id) {
      case 'hyperpigmentation':
      case 'uneven_tone':
        return ['dark_spots', 'dullness'];
      case 'blemishes':
      case 'blackheads':
        return ['acne'];
      default:
        return const [];
    }
  }

  static String _explain(
    LocalCatalogProduct p, {
    required String? skin,
    required String? concern,
    required Set<String> conditionIds,
    required Set<String> prefs,
  }) {
    final parts = <String>[p.blurb];
    if (concern != null && p.concernTags.map((e) => e.toLowerCase()).contains(concern)) {
      parts.add('Aligned with your focus.');
    }
    if (skin != null && p.skinTypesGood.map((e) => e.toLowerCase()).contains(skin)) {
      parts.add('Fits your skin type.');
    }
    if (prefs.contains('vegan') && p.flags.contains('vegan')) {
      parts.add('Matches your vegan preference.');
    }
    return parts.take(2).join(' ');
  }
}

class RankedLocalProduct {
  final LocalCatalogProduct product;
  final double score;
  final String explanation;

  const RankedLocalProduct({
    required this.product,
    required this.score,
    required this.explanation,
  });
}
