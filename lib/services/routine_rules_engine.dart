import '../data/local_skin_catalog.dart';
import '../models/local_catalog_product.dart';
import '../models/onboarding_data.dart';
import '../models/routine_evaluation.dart';
import '../models/routine_step.dart';
import '../models/skin_journey_state.dart';

/// Offline rules — no ML. Outputs coach-style insights.
class RoutineRulesEngine {
  RoutineRulesEngine._();

  static List<RoutineInsight> evaluate({
    required OnboardingData profile,
    required SkinJourneyState journey,
  }) {
    final out = <RoutineInsight>[];
    final plan = journey.routine;
    final skin = profile.skinType?.toLowerCase();
    final concern = profile.concern?.toLowerCase() ?? '';

    final amProducts = _resolvedProducts(plan.morning);
    final pmProducts = _resolvedProducts(plan.evening);
    final cabinetIds = journey.cabinet.map((c) => c.catalogProductId).toSet();

    // ── Gaps: SPF ───────────────────────────────────────────────────────────
    final amRoles = amProducts.map((p) => p.role).toSet();
    if (!amRoles.contains('spf') && plan.morning.isNotEmpty) {
      out.add(const RoutineInsight(
        tone: EvaluationTone.gap,
        title: 'Morning SPF',
        detail:
            'No SPF step detected in your AM routine. Daily sunscreen is the single best anti-aging and spot-prevention habit.',
      ));
    }

    // ── Gaps: concern alignment ─────────────────────────────────────────────
    if (concern.contains('acne') || concern.contains('break')) {
      final hasBha =
          _hasActive(amProducts, 'salicylic_acid') ||
              _hasActive(pmProducts, 'salicylic_acid');
      if (!hasBha && journey.cabinet.isNotEmpty) {
        out.add(const RoutineInsight(
          tone: EvaluationTone.gap,
          title: 'Blemish focus',
          detail:
              'For breakout-prone skin, a gentle BHA (salicylic) in cleanser or leave-on form often helps — introduce slowly.',
        ));
      }
    }

    if ((skin == 'dry' || skin == 'sensitive') &&
        _hasFlag(pmProducts, 'retinoid_family') &&
        !_hasRole(pmProducts, 'moisturizer')) {
      out.add(const RoutineInsight(
        tone: EvaluationTone.caution,
        title: 'Barrier + retinoids',
        detail:
            'Retinoids work best with a supportive moisturizer the same night to reduce peeling and irritation.',
      ));
    }

    final pmActives = _allActives(pmProducts);
    if (pmActives.contains('retinoid') &&
        (pmActives.contains('salicylic_acid') || pmActives.contains('lactic_acid'))) {
      out.add(const RoutineInsight(
        tone: EvaluationTone.caution,
        title: 'Strong actives stacking',
        detail:
            'Retinoids plus strong acids the same evening can overload skin. Consider alternating nights.',
      ));
    }

    // ── Positive ───────────────────────────────────────────────────────────
    if (amRoles.contains('spf') && amRoles.contains('cleanser')) {
      out.add(const RoutineInsight(
        tone: EvaluationTone.positive,
        title: 'Solid AM base',
        detail: 'Cleanser + SPF is a strong foundation for any skin goal.',
      ));
    }

    if (cabinetIds.length >= 3) {
      out.add(RoutineInsight(
        tone: EvaluationTone.positive,
        title: 'Cabinet diversity',
        detail:
            'You’ve added ${cabinetIds.length} products — we can better spot gaps and overlaps.',
      ));
    }

    if (out.isEmpty) {
      out.add(const RoutineInsight(
        tone: EvaluationTone.gap,
        title: 'Build your routine',
        detail:
            'Add products from your shelf to the Cabinet, then assign them to AM/PM steps for tailored feedback.',
      ));
    }

    return out.take(6).toList();
  }

  static List<LocalCatalogProduct> _resolvedProducts(List<RoutineStep> steps) {
    final list = <LocalCatalogProduct>[];
    for (final s in steps) {
      if (s.catalogProductId == null) continue;
      final p = LocalSkinCatalog.getById(s.catalogProductId!);
      if (p != null) list.add(p);
    }
    return list;
  }

  static bool _hasActive(List<LocalCatalogProduct> products, String key) {
    return products.any((p) => p.actives.contains(key));
  }

  static bool _hasRole(List<LocalCatalogProduct> products, String role) {
    return products.any((p) => p.role == role);
  }

  static bool _hasFlag(List<LocalCatalogProduct> products, String flag) {
    return products.any((p) => p.flags.contains(flag));
  }

  static Set<String> _allActives(List<LocalCatalogProduct> products) {
    return products.expand((p) => p.actives).toSet();
  }
}
