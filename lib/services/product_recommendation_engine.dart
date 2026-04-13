import '../models/firestore_product.dart';
import '../models/onboarding_data.dart';
import '../models/skin_analysis.dart';
import 'product_knowledge_service.dart';

/// Scores catalog products using profile tags, detected conditions, and
/// matched routine knowledge — unifies Firestore fetch with explanations.
class ProductRecommendationEngine {
  ProductRecommendationEngine._();

  static List<RankedFirestoreProduct> rank({
    required List<FirestoreProduct> products,
    required OnboardingData data,
    SkinAnalysis? analysis,
    List<ProductKnowledgeMatch> knowledgeMatches = const [],
  }) {
    if (products.isEmpty) return const [];

    final conditionIds =
        analysis?.conditions.map((c) => c.id).toSet() ?? <String>{};
    final matchedActives = knowledgeMatches
        .expand((m) => m.entry.keyActives)
        .map((a) => a.toLowerCase())
        .toSet();

    final skin = data.skinType?.toLowerCase();
    final concern = data.concern?.toLowerCase();

    final ranked = <RankedFirestoreProduct>[];
    for (final p in products) {
      var score = 0.0;
      final tags = <String>{
        ...p.concernTags.map((e) => e.toLowerCase()),
        ...p.skinTypeTags.map((e) => e.toLowerCase()),
        ...p.searchTags.map((e) => e.toLowerCase()),
      };

      if (skin != null && tags.contains(skin)) score += 3;
      if (concern != null && tags.contains(concern)) score += 4;
      for (final id in conditionIds) {
        if (tags.contains(id)) score += 2.5;
      }

      // Boost if recommendation aligns with a known active the user may already use
      for (final m in knowledgeMatches) {
        for (final active in m.entry.keyActives) {
          if (p.reason?.toLowerCase().contains(active.toLowerCase()) ?? false) {
            score += 1;
          }
        }
      }

      // Small diversity bonus for categories not covered by user's matched products
      var overlapPenalty = 0.0;
      for (final m in knowledgeMatches) {
        if (p.category.toLowerCase().contains(m.entry.id.split('_').first)) {
          overlapPenalty += 0.5;
        }
      }
      score -= overlapPenalty;

      final explanation = _explain(
        p,
        skin: skin,
        concern: concern,
        conditionIds: conditionIds,
        knowledgeMatches: knowledgeMatches,
        matchedActives: matchedActives,
      );

      ranked.add(RankedFirestoreProduct(
        product: p,
        score: score,
        explanation: explanation,
      ));
    }

    ranked.sort((a, b) => b.score.compareTo(a.score));
    return ranked;
  }

  static String _explain(
    FirestoreProduct p, {
    required String? skin,
    required String? concern,
    required Set<String> conditionIds,
    required List<ProductKnowledgeMatch> knowledgeMatches,
    required Set<String> matchedActives,
  }) {
    final parts = <String>[];
    if (p.reason != null && p.reason!.trim().isNotEmpty) {
      parts.add(p.reason!);
    } else {
      parts.add('Matched to your profile tags.');
    }
    if (concern != null &&
        p.concernTags.map((e) => e.toLowerCase()).contains(concern)) {
      parts.add('Aligned with your focus: $concern.');
    }
    if (skin != null &&
        p.skinTypeTags.map((e) => e.toLowerCase()).contains(skin)) {
      parts.add('Fits ${_skinLabel(skin)} skin.');
    }
    if (knowledgeMatches.isNotEmpty &&
        matchedActives.any(
          (a) => p.name.toLowerCase().contains(a.split(' ').first),
        )) {
      parts.add('Complements actives you may already use — avoid doubling strong actives without spacing.');
    }
    return parts.take(2).join(' ');
  }

  static String _skinLabel(String s) {
    switch (s) {
      case 'combination':
        return 'combination';
      default:
        return s;
    }
  }
}

class RankedFirestoreProduct {
  final FirestoreProduct product;
  final double score;
  final String explanation;

  const RankedFirestoreProduct({
    required this.product,
    required this.score,
    required this.explanation,
  });
}
