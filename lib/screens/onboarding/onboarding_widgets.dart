import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Pill-style step indicator shown in the AppBar actions area.
class OnboardingStepIndicator extends StatelessWidget {
  final int current;
  final int total;

  const OnboardingStepIndicator({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i < current;
        final isCurrent = i == current - 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(left: 4),
          width: isCurrent ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
