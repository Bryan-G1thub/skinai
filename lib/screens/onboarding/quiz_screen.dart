import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/onboarding_data.dart';
import 'onboarding_widgets.dart';

class QuizScreen extends StatefulWidget {
  final OnboardingData data;

  const QuizScreen({super.key, required this.data});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late List<String?> _answers;

  late AnimationController _slideController;
  late Animation<Offset> _slideIn;
  late Animation<double> _fadeIn;

  late List<_QuizQuestion> _questions;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    _questions = [
      const _QuizQuestion(
        question: 'How would you describe\nyour skin type?',
        subtitle: 'Shapes product matches and routine steps for you',
        options: ['Oily', 'Dry', 'Combination', 'Normal', 'Sensitive'],
        icons: [
          Icons.water_outlined,
          Icons.thermostat_outlined,
          Icons.compare_arrows_outlined,
          Icons.check_circle_outline,
          Icons.warning_amber_outlined,
        ],
      ),
      const _QuizQuestion(
        question: "What's your biggest\nskin concern?",
        subtitle: 'We prioritize this on your home screen and picks',
        options: ['Acne', 'Aging', 'Dark spots', 'Redness', 'Dullness'],
        icons: [
          Icons.circle_outlined,
          Icons.hourglass_top_outlined,
          Icons.lens_outlined,
          Icons.flare_outlined,
          Icons.brightness_low_outlined,
        ],
      ),
      const _QuizQuestion(
        question: 'Where are you with\nyour routine?',
        subtitle: 'Be honest — no judgment here',
        options: [
          'No routine yet',
          'Basic (cleanser + moisturizer)',
          'Full routine',
          'Advanced multi-step',
        ],
        icons: [
          Icons.sentiment_neutral_outlined,
          Icons.spa_outlined,
          Icons.format_list_bulleted_outlined,
          Icons.science_outlined,
        ],
      ),
      const _QuizQuestion(
        question: 'How often do you\nexperience breakouts?',
        subtitle: 'Think about the last few months',
        options: ['Frequently', 'Occasionally', 'Rarely', 'Never'],
        icons: [
          Icons.warning_outlined,
          Icons.notifications_outlined,
          Icons.check_outlined,
          Icons.sentiment_very_satisfied_outlined,
        ],
      ),
    ];

    _answers = [
      widget.data.skinType,
      widget.data.concern,
      _routineValueToLabel(widget.data.routineLevel),
      _breakoutsValueToLabel(widget.data.breakouts),
    ];
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  String? _routineValueToLabel(String? v) {
    switch (v) {
      case 'none':
        return 'No routine yet';
      case 'basic':
        return 'Basic (cleanser + moisturizer)';
      case 'full':
        return 'Full routine';
      case 'advanced':
        return 'Advanced multi-step';
      default:
        return null;
    }
  }

  String? _breakoutsValueToLabel(String? v) {
    if (v == null) return null;
    return '${v[0].toUpperCase()}${v.substring(1)}';
  }

  OnboardingData _buildData() {
    return widget.data.copyWith(
      skinType: _labelToSkinType(_answers[0]),
      concern: _labelToConcern(_answers[1]),
      routineLevel: _labelToRoutine(_answers[2]),
      breakouts: _labelToBreakouts(_answers[3]),
    );
  }

  String? _labelToSkinType(String? l) {
    if (l == null) return null;
    return l.toLowerCase();
  }

  String? _labelToConcern(String? l) {
    if (l == null) return null;
    return l.toLowerCase().replaceAll(' ', '_');
  }

  String? _labelToRoutine(String? l) {
    switch (l) {
      case 'No routine yet':
        return 'none';
      case 'Basic (cleanser + moisturizer)':
        return 'basic';
      case 'Full routine':
        return 'full';
      case 'Advanced multi-step':
        return 'advanced';
      default:
        return null;
    }
  }

  String? _labelToBreakouts(String? l) {
    return l?.toLowerCase();
  }

  void _selectAnswer(String answer) {
    setState(() => _answers[_currentIndex] = answer);
  }

  Future<void> _next() async {
    if (_currentIndex < _questions.length - 1) {
      await _slideController.reverse();
      setState(() => _currentIndex++);
      _slideController.forward();
    } else {
      context.go('/routine-presence', extra: _buildData());
    }
  }

  Future<void> _back() async {
    if (_currentIndex > 0) {
      await _slideController.reverse();
      setState(() => _currentIndex--);
      _slideController.forward();
    } else {
      context.go('/goal', extra: widget.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];
    final selected = _answers[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _back,
        ),
        actions: [
          OnboardingStepIndicator(current: 3, total: 3),
          const SizedBox(width: 24),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.surfaceVariant,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_currentIndex + 1}/${_questions.length}',
                        style: AppTextStyles.labelMedium,
                      ),
                    ],
                  ),
                  if (_currentIndex == 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.layers_outlined,
                            size: 22,
                            color: AppColors.primary.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Next: a quick photo scan, then your dashboard with '
                              'routine ideas and tailored product picks—grounded in '
                              'what you tell us here.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: _currentIndex == 0 ? 16 : 24),
            // Animated question + options
            Expanded(
              child: SlideTransition(
                position: _slideIn,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.question,
                              style: AppTextStyles.displaySmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              question.subtitle,
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
                          itemCount: question.options.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) => _OptionTile(
                            text: question.options[i],
                            icon: question.icons[i],
                            isSelected: selected == question.options[i],
                            onTap: () => _selectAnswer(question.options[i]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selected != null ? _next : null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: AppColors.surfaceVariant,
                    disabledForegroundColor: AppColors.textTertiary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1
                        ? 'Continue'
                        : 'Almost there',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.text,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : AppColors.shadow,
              blurRadius: isSelected ? 14 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.18)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.titleLarge.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                child: const Icon(Icons.check, size: 13, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final String question;
  final String subtitle;
  final List<String> options;
  final List<IconData> icons;

  const _QuizQuestion({
    required this.question,
    required this.subtitle,
    required this.options,
    required this.icons,
  });
}
