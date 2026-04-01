import 'skin_analysis.dart';

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

  const OnboardingData({
    this.intent,
    this.primaryGoal,
    this.skinType,
    this.concern,
    this.routineLevel,
    this.breakouts,
    this.currentProducts = const [],
    this.analysis,
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
      );

  // ── Helpers ────────────────────────────────────────────────────────────

  bool get hasRoutine => routineLevel != null && routineLevel != 'none';

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
