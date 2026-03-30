/// Accumulated user answers collected throughout the onboarding flow.
/// Passed between screens via GoRouter's `extra` parameter.
class OnboardingData {
  /// Why the user is here.
  /// Values: 'build_routine' | 'optimize_routine' | 'track_progress' | 'fix_concern'
  final String? intent;

  /// Primary skin goal.
  /// Values: 'clear_skin' | 'fight_breakouts' | 'anti_aging' | 'even_tone' | 'hydration'
  final String? primaryGoal;

  /// Skin type.
  /// Values: 'oily' | 'dry' | 'combination' | 'normal' | 'sensitive'
  final String? skinType;

  /// Primary concern from the skin quiz.
  /// Values: 'acne' | 'aging' | 'dark_spots' | 'redness' | 'dullness'
  final String? concern;

  /// Current routine level.
  /// Values: 'none' | 'basic' | 'full' | 'advanced'
  final String? routineLevel;

  /// Breakout frequency.
  /// Values: 'frequently' | 'occasionally' | 'rarely' | 'never'
  final String? breakouts;

  const OnboardingData({
    this.intent,
    this.primaryGoal,
    this.skinType,
    this.concern,
    this.routineLevel,
    this.breakouts,
  });

  OnboardingData copyWith({
    String? intent,
    String? primaryGoal,
    String? skinType,
    String? concern,
    String? routineLevel,
    String? breakouts,
  }) {
    return OnboardingData(
      intent: intent ?? this.intent,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      skinType: skinType ?? this.skinType,
      concern: concern ?? this.concern,
      routineLevel: routineLevel ?? this.routineLevel,
      breakouts: breakouts ?? this.breakouts,
    );
  }

  /// Human-readable intent label for UI display.
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

  /// Dashboard greeting/focus line based on intent.
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
}
