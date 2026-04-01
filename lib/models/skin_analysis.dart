import 'onboarding_data.dart';

/// A single detected skin condition from the AI photo analysis.
class DetectedCondition {
  final String id;
  final String label;
  final String detail;
  final String severity; // 'mild' | 'moderate' | 'significant'

  const DetectedCondition({
    required this.id,
    required this.label,
    required this.detail,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'detail': detail,
        'severity': severity,
      };

  factory DetectedCondition.fromJson(Map<String, dynamic> json) =>
      DetectedCondition(
        id: json['id'] as String,
        label: json['label'] as String,
        detail: json['detail'] as String,
        severity: json['severity'] as String,
      );
}

/// The result of the AI skin analysis step.
class SkinAnalysis {
  final int score;
  final List<DetectedCondition> conditions;
  final List<String> priorityActions;
  final List<String> currentProducts; // filled in by routine_input_screen

  const SkinAnalysis({
    required this.score,
    required this.conditions,
    required this.priorityActions,
    this.currentProducts = const [],
  });

  SkinAnalysis copyWith({List<String>? currentProducts}) {
    return SkinAnalysis(
      score: score,
      conditions: conditions,
      priorityActions: priorityActions,
      currentProducts: currentProducts ?? this.currentProducts,
    );
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'conditions': conditions.map((c) => c.toJson()).toList(),
        'priorityActions': priorityActions,
        'currentProducts': currentProducts,
      };

  factory SkinAnalysis.fromJson(Map<String, dynamic> json) => SkinAnalysis(
        score: json['score'] as int,
        conditions: (json['conditions'] as List)
            .map((c) => DetectedCondition.fromJson(c as Map<String, dynamic>))
            .toList(),
        priorityActions:
            (json['priorityActions'] as List).map((e) => e as String).toList(),
        currentProducts:
            (json['currentProducts'] as List?)?.map((e) => e as String).toList() ??
                [],
      );

  /// Generate a deterministic analysis from the user's onboarding answers.
  /// In a real app this would come from a backend AI model.
  static SkinAnalysis generate(OnboardingData data) {
    final conditions = <DetectedCondition>[];

    // ── Skin-type conditions ──────────────────────────────────────────────
    switch (data.skinType) {
      case 'oily':
        conditions.addAll([
          const DetectedCondition(
            id: 'enlarged_pores',
            label: 'Enlarged pores',
            detail: 'Visible in the T-zone and cheek area',
            severity: 'moderate',
          ),
          const DetectedCondition(
            id: 'excess_sebum',
            label: 'Excess sebum',
            detail: 'Surface shine detected, especially mid-face',
            severity: 'moderate',
          ),
        ]);
      case 'dry':
        conditions.addAll([
          const DetectedCondition(
            id: 'dehydration',
            label: 'Dehydration',
            detail: 'Tight, low-moisture zones detected',
            severity: 'moderate',
          ),
          const DetectedCondition(
            id: 'flakiness',
            label: 'Flaky patches',
            detail: 'Dry texture around nose and forehead',
            severity: 'mild',
          ),
        ]);
      case 'combination':
        conditions.addAll([
          const DetectedCondition(
            id: 'tzone_oil',
            label: 'T-zone oiliness',
            detail: 'Oiliness concentrated on nose and forehead',
            severity: 'mild',
          ),
          const DetectedCondition(
            id: 'dry_cheeks',
            label: 'Dry cheeks',
            detail: 'Moisture imbalance on the cheek area',
            severity: 'mild',
          ),
        ]);
      case 'sensitive':
        conditions.addAll([
          const DetectedCondition(
            id: 'sensitivity',
            label: 'Skin sensitivity',
            detail: 'Reactivity markers detected',
            severity: 'moderate',
          ),
          const DetectedCondition(
            id: 'thin_barrier',
            label: 'Compromised barrier',
            detail: 'Skin barrier showing signs of weakness',
            severity: 'mild',
          ),
        ]);
      default:
        conditions.add(const DetectedCondition(
          id: 'balanced',
          label: 'Balanced skin',
          detail: 'Skin appears generally well-balanced',
          severity: 'mild',
        ));
    }

    // ── Concern-based conditions ──────────────────────────────────────────
    switch (data.concern) {
      case 'acne':
        conditions.addAll([
          const DetectedCondition(
            id: 'blackheads',
            label: 'Blackheads',
            detail: 'Detected along nose and chin',
            severity: 'moderate',
          ),
          const DetectedCondition(
            id: 'blemishes',
            label: 'Active blemishes',
            detail: 'Inflammatory spots detected',
            severity: 'significant',
          ),
        ]);
      case 'aging':
        conditions.addAll([
          const DetectedCondition(
            id: 'fine_lines',
            label: 'Fine lines',
            detail: 'Around eyes and forehead',
            severity: 'moderate',
          ),
          const DetectedCondition(
            id: 'firmness',
            label: 'Reduced firmness',
            detail: 'Slight loss of elasticity detected',
            severity: 'mild',
          ),
        ]);
      case 'dark_spots':
        conditions.addAll([
          const DetectedCondition(
            id: 'hyperpigmentation',
            label: 'Hyperpigmentation',
            detail: 'Uneven melanin distribution detected',
            severity: 'moderate',
          ),
          const DetectedCondition(
            id: 'uneven_tone',
            label: 'Uneven skin tone',
            detail: 'Color inconsistency across the face',
            severity: 'moderate',
          ),
        ]);
      case 'redness':
        conditions.addAll([
          const DetectedCondition(
            id: 'redness',
            label: 'Redness',
            detail: 'Diffuse redness on cheeks and nose',
            severity: 'significant',
          ),
          const DetectedCondition(
            id: 'capillaries',
            label: 'Visible capillaries',
            detail: 'Surface blood vessel visibility',
            severity: 'mild',
          ),
        ]);
      case 'dullness':
        conditions.addAll([
          const DetectedCondition(
            id: 'dullness',
            label: 'Dullness',
            detail: 'Lack of surface radiance detected',
            severity: 'moderate',
          ),
          const DetectedCondition(
            id: 'texture',
            label: 'Uneven texture',
            detail: 'Rough texture and dead cell buildup',
            severity: 'mild',
          ),
        ]);
    }

    // ── Breakout modifier ─────────────────────────────────────────────────
    if (data.breakouts == 'frequently' &&
        !conditions.any((c) => c.id == 'blemishes')) {
      conditions.add(const DetectedCondition(
        id: 'congestion',
        label: 'Pore congestion',
        detail: 'Blocked pores contributing to breakouts',
        severity: 'moderate',
      ));
    }

    // ── Score: start at 80, deduct for severity ────────────────────────────
    var score = 82;
    for (final c in conditions) {
      if (c.severity == 'significant') score -= 8;
      if (c.severity == 'moderate') score -= 4;
      if (c.severity == 'mild') score -= 2;
    }
    score = score.clamp(30, 95);

    // ── Priority actions ───────────────────────────────────────────────────
    final actions = _buildActions(data, conditions);

    return SkinAnalysis(
      score: score,
      conditions: conditions,
      priorityActions: actions,
      currentProducts: data.currentProducts,
    );
  }

  static List<String> _buildActions(
      OnboardingData data, List<DetectedCondition> conditions) {
    final actions = <String>[];
    final ids = conditions.map((c) => c.id).toSet();

    if (ids.contains('blemishes') || ids.contains('blackheads')) {
      actions.add('Introduce a gentle BHA (salicylic acid) cleanser');
    }
    if (ids.contains('hyperpigmentation') || ids.contains('uneven_tone')) {
      actions.add('Add a Vitamin C serum to your morning routine');
    }
    if (ids.contains('fine_lines') || ids.contains('firmness')) {
      actions.add('Start with a retinol product 2–3x per week');
    }
    if (ids.contains('redness') || ids.contains('sensitivity')) {
      actions.add('Switch to a fragrance-free, barrier-repairing moisturizer');
    }
    if (ids.contains('dehydration') || ids.contains('flakiness')) {
      actions.add('Layer a hyaluronic acid serum under your moisturizer');
    }
    if (ids.contains('dullness') || ids.contains('texture')) {
      actions.add('Exfoliate 2x per week with a gentle AHA');
    }
    if (ids.contains('excess_sebum') || ids.contains('enlarged_pores')) {
      actions.add('Use a niacinamide serum to control oil and minimize pores');
    }
    if (ids.contains('tzone_oil')) {
      actions.add('Try a lightweight, non-comedogenic moisturizer');
    }

    // Always add SPF if not already in actions
    if (actions.length < 4) {
      actions.add('Apply SPF 30+ every morning — non-negotiable');
    }

    return actions.take(3).toList();
  }

  /// Returns product recommendations based on detected conditions and
  /// what the user already has in their routine.
  List<ProductRecommendation> recommendedProducts(
      {List<String> excluding = const []}) {
    final all = _allRecommendations();
    return all
        .where((p) => !excluding.any((e) =>
            e.toLowerCase().contains(p.category.toLowerCase()) ||
            p.category.toLowerCase().contains(e.toLowerCase())))
        .take(4)
        .toList();
  }

  List<ProductRecommendation> _allRecommendations() {
    final ids = conditions.map((c) => c.id).toSet();
    final recs = <ProductRecommendation>[];

    if (ids.contains('blemishes') || ids.contains('blackheads') || ids.contains('congestion')) {
      recs.add(const ProductRecommendation(
        name: 'CeraVe SA Cleanser',
        brand: 'CeraVe',
        category: 'Cleanser',
        reason: 'BHA cleanser clears blackheads and prevents breakouts',
        priority: 1,
      ));
      recs.add(const ProductRecommendation(
        name: '2% Salicylic Acid Solution',
        brand: 'Paula\'s Choice',
        category: 'Exfoliant',
        reason: 'Unclogs pores and reduces blemish frequency',
        priority: 2,
      ));
    }

    if (ids.contains('hyperpigmentation') || ids.contains('uneven_tone') || ids.contains('dullness')) {
      recs.add(const ProductRecommendation(
        name: 'Vitamin C Suspension 23%',
        brand: 'The Ordinary',
        category: 'Serum',
        reason: 'Fades dark spots and boosts radiance',
        priority: 1,
      ));
    }

    if (ids.contains('fine_lines') || ids.contains('firmness')) {
      recs.add(const ProductRecommendation(
        name: 'Granactive Retinoid 2%',
        brand: 'The Ordinary',
        category: 'Serum',
        reason: 'Reduces fine lines and improves skin texture',
        priority: 2,
      ));
    }

    if (ids.contains('redness') || ids.contains('sensitivity') || ids.contains('thin_barrier')) {
      recs.add(const ProductRecommendation(
        name: 'Cicaplast Baume B5',
        brand: 'La Roche-Posay',
        category: 'Moisturizer',
        reason: 'Calms redness and repairs the skin barrier',
        priority: 1,
      ));
    }

    if (ids.contains('dehydration') || ids.contains('dry_cheeks') || ids.contains('flakiness')) {
      recs.add(const ProductRecommendation(
        name: 'Hyaluronic Acid 2% + B5',
        brand: 'The Ordinary',
        category: 'Serum',
        reason: 'Draws moisture into skin and plumps fine lines',
        priority: 1,
      ));
      recs.add(const ProductRecommendation(
        name: 'Toleriane Double Repair Moisturizer',
        brand: 'La Roche-Posay',
        category: 'Moisturizer',
        reason: 'Rich barrier moisturizer for dry skin',
        priority: 2,
      ));
    }

    if (ids.contains('excess_sebum') || ids.contains('enlarged_pores') || ids.contains('tzone_oil')) {
      recs.add(const ProductRecommendation(
        name: 'Niacinamide 10% + Zinc 1%',
        brand: 'The Ordinary',
        category: 'Serum',
        reason: 'Controls oil and visibly minimizes pores',
        priority: 1,
      ));
    }

    // Always recommend SPF
    recs.add(const ProductRecommendation(
      name: 'Ultra-Light Daily UV Defense SPF 50',
      brand: 'Kiehl\'s',
      category: 'SPF',
      reason: 'Daily sun protection is essential for every skin type',
      priority: 1,
    ));

    // Sort by priority, deduplicate by category
    recs.sort((a, b) => a.priority.compareTo(b.priority));
    final seen = <String>{};
    return recs.where((r) => seen.add(r.category)).toList();
  }
}

class ProductRecommendation {
  final String name;
  final String brand;
  final String category;
  final String reason;
  final int priority;

  const ProductRecommendation({
    required this.name,
    required this.brand,
    required this.category,
    required this.reason,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'brand': brand,
        'category': category,
        'reason': reason,
        'priority': priority,
      };

  factory ProductRecommendation.fromJson(Map<String, dynamic> json) =>
      ProductRecommendation(
        name: json['name'] as String,
        brand: json['brand'] as String,
        category: json['category'] as String,
        reason: json['reason'] as String,
        priority: json['priority'] as int,
      );
}
