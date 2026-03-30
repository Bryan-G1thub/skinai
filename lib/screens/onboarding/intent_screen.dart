import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/onboarding_data.dart';
import 'onboarding_widgets.dart';

class IntentScreen extends StatefulWidget {
  final OnboardingData data;

  const IntentScreen({super.key, required this.data});

  @override
  State<IntentScreen> createState() => _IntentScreenState();
}

class _IntentScreenState extends State<IntentScreen>
    with SingleTickerProviderStateMixin {
  String? _selected;

  late AnimationController _controller;
  late Animation<double> _fadeIn;

  static const _options = [
    _IntentOption(
      id: 'build_routine',
      icon: Icons.eco_outlined,
      title: 'Build a new routine',
      subtitle: "I'm starting my skincare journey",
      tint: AppColors.tintSage,
      iconColor: AppColors.success,
    ),
    _IntentOption(
      id: 'optimize_routine',
      icon: Icons.auto_awesome_outlined,
      title: 'Upgrade my routine',
      subtitle: 'I have one but want better results',
      tint: AppColors.tintGold,
      iconColor: AppColors.warning,
    ),
    _IntentOption(
      id: 'track_progress',
      icon: Icons.track_changes_outlined,
      title: 'Track my daily habits',
      subtitle: 'I want to hit goals and see progress',
      tint: AppColors.tintBlue,
      iconColor: AppColors.info,
    ),
    _IntentOption(
      id: 'fix_concern',
      icon: Icons.healing_outlined,
      title: 'Fix a skin concern',
      subtitle: "I'm dealing with a specific issue",
      tint: AppColors.tintRose,
      iconColor: AppColors.rose,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.data.intent;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/welcome'),
        ),
        actions: [
          OnboardingStepIndicator(current: 1, total: 3),
          const SizedBox(width: 24),
        ],
      ),
      body: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What brings you\nto SkinAI?",
                      style: AppTextStyles.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Help us personalize your experience',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _IntentCard(
                    option: _options[i],
                    isSelected: _selected == _options[i].id,
                    onTap: () => setState(() => _selected = _options[i].id),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selected == null
                        ? null
                        : () => context.go(
                              '/goal',
                              extra: widget.data.copyWith(intent: _selected),
                            ),
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: AppColors.surfaceVariant,
                      disabledForegroundColor: AppColors.textTertiary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(
                      'Continue',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntentCard extends StatelessWidget {
  final _IntentOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _IntentCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.04)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ]
              : [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  )
                ],
        ),
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : option.tint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                option.icon,
                size: 26,
                color: isSelected ? AppColors.primary : option.iconColor,
              ),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _IntentOption {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final Color iconColor;

  const _IntentOption({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.iconColor,
  });
}

