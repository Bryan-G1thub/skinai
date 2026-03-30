import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/onboarding_data.dart';
import 'onboarding_widgets.dart';

class GoalScreen extends StatefulWidget {
  final OnboardingData data;

  const GoalScreen({super.key, required this.data});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen>
    with SingleTickerProviderStateMixin {
  String? _selected;

  late AnimationController _controller;
  late Animation<double> _fadeIn;

  static const _goals = [
    _GoalOption(
      id: 'clear_skin',
      icon: Icons.wb_sunny_outlined,
      label: 'Clear, radiant skin',
      description: 'Glowing complexion free of blemishes',
      color: Color(0xFFE8C55A),
    ),
    _GoalOption(
      id: 'fight_breakouts',
      icon: Icons.block_outlined,
      label: 'Fight breakouts',
      description: 'Get acne and breakouts under control',
      color: Color(0xFFE87D7D),
    ),
    _GoalOption(
      id: 'anti_aging',
      icon: Icons.hourglass_top_outlined,
      label: 'Anti-aging',
      description: 'Reduce fine lines and improve firmness',
      color: Color(0xFF9B72F0),
    ),
    _GoalOption(
      id: 'even_tone',
      icon: Icons.palette_outlined,
      label: 'Even skin tone',
      description: 'Fade dark spots and discoloration',
      color: Color(0xFF72ADF0),
    ),
    _GoalOption(
      id: 'hydration',
      icon: Icons.water_drop_outlined,
      label: 'Deep hydration',
      description: 'Plump, moisturized skin all day',
      color: Color(0xFF72D4F0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.data.primaryGoal;
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
          onPressed: () => context.go('/intent', extra: widget.data),
        ),
        actions: [
          OnboardingStepIndicator(current: 2, total: 3),
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
                      "What's your\n#1 skin goal?",
                      style: AppTextStyles.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We'll build your routine around this",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _goals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _GoalCard(
                    option: _goals[i],
                    isSelected: _selected == _goals[i].id,
                    onTap: () => setState(() => _selected = _goals[i].id),
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
                              '/quiz',
                              extra: widget.data
                                  .copyWith(primaryGoal: _selected),
                            ),
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: AppColors.surfaceVariant,
                      disabledForegroundColor: AppColors.textTertiary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text('Continue', style: AppTextStyles.button),
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

class _GoalCard extends StatelessWidget {
  final _GoalOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.04)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.shadow,
              blurRadius: isSelected ? 16 : 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Colored icon badge
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: option.color.withValues(alpha: isSelected ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.icon,
                size: 24,
                color: option.color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
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

class _GoalOption {
  final String id;
  final IconData icon;
  final String label;
  final String description;
  final Color color;

  const _GoalOption({
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
  });
}
