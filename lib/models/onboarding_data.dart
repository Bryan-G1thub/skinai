import 'skin_analysis.dart';
import 'routine_slot_entry.dart';

/// Accumulated user answers collected throughout the onboarding flow.
class OnboardingData {
  final String? intent;
  final String? primaryGoal;
  final String? skinType;
  final String? concern;
  final String? routineLevel;
  final String? breakouts;
  final List<String> currentProducts;
  final SkinAnalysis? analysis;

  /// Whether the user already uses a routine (structured capture follows if true).
  final bool? hasExistingRoutine;

  /// Per-category routine (cleanser → SPF). Empty if not collected.
  final List<RoutineSlotEntry> routineSlots;

  /// e.g. vegan, fragrance_free, cruelty_free, minimal_ingredients
  final List<String> productPreferences;

  /// e.g. fragrance, essential_oils, sulfates, nuts, alcohol_denat
  final List<String> sensitivities;

  const OnboardingData({
    this.intent,
    this.primaryGoal,
    this.skinType,
    this.concern,
    this.routineLevel,
    this.breakouts,
    this.currentProducts = const [],
    this.analysis,
    this.hasExistingRoutine,
    this.routineSlots = const [],
    this.productPreferences = const [],
    this.sensitivities = const [],
  });

  OnboardingData copyWith({
    String? intent,
    String? primaryGoal,
    String? skinType,
    String? concern,
    String? routineLevel,
    String? breakouts,
    List<String>? currentProducts,
    SkinAnalysis? analysis,
    bool? hasExistingRoutine,
    List<RoutineSlotEntry>? routineSlots,
    List<String>? productPreferences,
    List<String>? sensitivities,
  }) {
    return OnboardingData(
      intent: intent ?? this.intent,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      skinType: skinType ?? this.skinType,
      concern: concern ?? this.concern,
      routineLevel: routineLevel ?? this.routineLevel,
      breakouts: breakouts ?? this.breakouts,
      currentProducts: currentProducts ?? this.currentProducts,
      analysis: analysis ?? this.analysis,
      hasExistingRoutine: hasExistingRoutine ?? this.hasExistingRoutine,
      routineSlots: routineSlots ?? this.routineSlots,
      productPreferences: productPreferences ?? this.productPreferences,
      sensitivities: sensitivities ?? this.sensitivities,
    );
  }

  // ── Serialization ──────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'intent': intent,
        'primaryGoal': primaryGoal,
        'skinType': skinType,
        'concern': concern,
        'routineLevel': routineLevel,
        'breakouts': breakouts,
        'currentProducts': currentProducts,
        'analysis': analysis?.toJson(),
        'hasExistingRoutine': hasExistingRoutine,
        'routineSlots': routineSlots.map((e) => e.toJson()).toList(),
        'productPreferences': productPreferences,
        'sensitivities': sensitivities,
      };

  factory OnboardingData.fromJson(Map<String, dynamic> json) => OnboardingData(
        intent: json['intent'] as String?,
        primaryGoal: json['primaryGoal'] as String?,
        skinType: json['skinType'] as String?,
        concern: json['concern'] as String?,
        routineLevel: json['routineLevel'] as String?,
        breakouts: json['breakouts'] as String?,
        currentProducts:
            (json['currentProducts'] as List?)?.map((e) => e as String).toList() ??
                const [],
        analysis: json['analysis'] != null
            ? SkinAnalysis.fromJson(json['analysis'] as Map<String, dynamic>)
            : null,
        hasExistingRoutine: json['hasExistingRoutine'] as bool?,
        routineSlots: (json['routineSlots'] as List?)
                ?.map((e) => RoutineSlotEntry.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        productPreferences:
            (json['productPreferences'] as List?)?.map((e) => e as String).toList() ??
                const [],
        sensitivities:
            (json['sensitivities'] as List?)?.map((e) => e as String).toList() ?? const [],
      );

  // ── Helpers ────────────────────────────────────────────────────────────

  /// True if quiz suggests they use any routine steps.
  bool get hasRoutineFromQuiz => routineLevel != null && routineLevel != 'none';

  /// True if user said they have a routine or quiz indicates routine usage.
  bool get effectiveHasRoutine =>
      hasExistingRoutine == true || hasRoutineFromQuiz;

  /// Lines used for matching, cabinet merge, and Claude (structured + legacy text).
  List<String> get resolvedProductLines {
    final fromSlots =
        routineSlots.map((s) => s.resolvedLabel).where((s) => s.isNotEmpty).toList();
    if (fromSlots.isNotEmpty) return fromSlots;
    return currentProducts;
  }

  String get intentLabel {
    switch (intent) {
      case 'build_routine':
        return 'Building a routine';
      case 'optimize_routine':
        return 'Optimizing my routine';
      case 'track_progress':
        return 'Tracking my progress';
      case 'fix_concern':
        return 'Fixing a concern';
      default:
        return 'Improving my skin';
    }
  }

  String get dashboardFocus {
    switch (intent) {
      case 'build_routine':
        return "Let's build your perfect routine";
      case 'optimize_routine':
        return "Let's level up your routine";
      case 'track_progress':
        return 'Track your daily goals';
      case 'fix_concern':
        return 'Your personalized treatment plan';
      default:
        return 'Your skin journey starts today';
    }
  }

  String get routineLevelLabel {
    switch (routineLevel) {
      case 'none':
        return 'No routine yet';
      case 'basic':
        return 'Basic routine';
      case 'full':
        return 'Full routine';
      case 'advanced':
        return 'Advanced routine';
      default:
        return 'Routine';
    }
  }
}
