import 'package:flutter/material.dart';
import '../../models/routine_evaluation.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shared visual language for Skin Journey surfaces (light, editorial cards).
class SkinJourneyUi {
  SkinJourneyUi._();

  static BoxDecoration pageGradientBg() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF8F6FF),
          Color(0xFFFDFCFA),
          Color(0xFFF5F0EB),
        ],
        stops: [0.0, 0.45, 1.0],
      ),
    );
  }

  static Widget sectionHeader(String title, {String? action, VoidCallback? onAction}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (action != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(action, style: AppTextStyles.labelLarge),
          ),
      ],
    );
  }

  static Widget glassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget tonePill(EvaluationTone tone, String label) {
    final (bg, fg) = switch (tone) {
      EvaluationTone.positive => (AppColors.successLight, AppColors.success),
      EvaluationTone.gap => (AppColors.infoLight, AppColors.info),
      EvaluationTone.caution => (AppColors.warningLight, AppColors.warning),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
