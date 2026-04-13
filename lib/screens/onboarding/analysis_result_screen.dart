import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/skin_analysis_copy.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/onboarding_data.dart';
import '../../models/skin_analysis.dart';
import '../../models/skin_analysis_source.dart';
import '../../services/onboarding_service.dart';

class AnalysisResultScreen extends StatefulWidget {
  final OnboardingData data;

  const AnalysisResultScreen({super.key, required this.data});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen>
    with SingleTickerProviderStateMixin {
  late SkinAnalysis _analysis;
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _analysis = widget.data.analysis ?? SkinAnalysis.generate(widget.data);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scoreAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final updated = widget.data.copyWith(analysis: _analysis);
    if (updated.effectiveHasRoutine && updated.resolvedProductLines.isEmpty) {
      context.go('/routine-input', extra: updated);
    } else {
      await OnboardingService.save(updated);
      if (!mounted) return;
      context.go('/dashboard', extra: updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeIn,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDisclaimerCard(),
                    const SizedBox(height: 12),
                    _buildScoreRow(),
                    const SizedBox(height: 28),
                    _buildDetectedSection(),
                    const SizedBox(height: 28),
                    _buildPrioritySection(),
                    const SizedBox(height: 32),
                    _buildContinueButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    final isPhoto = _analysis.source == SkinAnalysisSource.quizWithPhotoLocalPipeline;
    final text = _analysis.consumerDisclaimer ??
        (isPhoto ? SkinAnalysisCopy.photoPipelineBody : SkinAnalysisCopy.quizOnlyBody);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$text ${SkinAnalysisCopy.generalFooter}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E1270), Color(0xFF1E0C52)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 13, color: Color(0xFF5CE8A4)),
                    const SizedBox(width: 5),
                    Text(
                      'ANALYSIS COMPLETE',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF5CE8A4),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your skin\nanalysis',
                style: AppTextStyles.displayMedium.copyWith(
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Here\'s what we found',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow() {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _scoreAnim,
              builder: (context, child) => Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: CircularProgressIndicator(
                      value: _scoreAnim.value * (_analysis.score / 100),
                      strokeWidth: 6,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${(_scoreAnim.value * _analysis.score).round()}',
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '/100',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall skin score',
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _scoreLabel(_analysis.score),
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_analysis.conditions.length} condition${_analysis.conditions.length != 1 ? 's' : ''} identified',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detected conditions', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Based on your photo and skin profile',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 16),
        ...(_analysis.conditions.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ConditionCard(condition: c),
            ))),
      ],
    );
  }

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your action plan', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Top priorities based on your skin',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: _analysis.priorityActions
                .asMap()
                .entries
                .map((e) => Padding(
                      padding:
                          EdgeInsets.only(bottom: e.key < _analysis.priorityActions.length - 1 ? 14 : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.value,
                              style: AppTextStyles.bodyMedium.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        if (widget.data.effectiveHasRoutine) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 18, color: AppColors.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Since you already have a routine, we'll ask what you're using so we can build on it.",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _continue,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: Text(
          widget.data.effectiveHasRoutine
              ? 'Tell us about your routine'
              : 'See my personalized plan',
          style: AppTextStyles.button,
        ),
      ),
    );
  }

  String _scoreLabel(int score) {
    if (score >= 80) return 'Looking great';
    if (score >= 65) return 'On the right track';
    if (score >= 50) return 'Room to improve';
    return 'Needs attention';
  }
}

class _ConditionCard extends StatelessWidget {
  final DetectedCondition condition;

  const _ConditionCard({required this.condition});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor, severityLabel) = _severityStyle(condition.severity);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(_conditionIcon(condition.id), color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(condition.label, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(
                  condition.detail,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              severityLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, String) _severityStyle(String severity) {
    switch (severity) {
      case 'significant':
        return (
          AppColors.error,
          AppColors.error.withValues(alpha: 0.1),
          'Significant'
        );
      case 'moderate':
        return (
          AppColors.warning,
          AppColors.warningLight,
          'Moderate'
        );
      default:
        return (
          AppColors.info,
          AppColors.infoLight,
          'Mild'
        );
    }
  }

  IconData _conditionIcon(String id) {
    switch (id) {
      case 'blackheads':
      case 'blemishes':
      case 'congestion':
        return Icons.circle_outlined;
      case 'redness':
      case 'capillaries':
        return Icons.flare_outlined;
      case 'dehydration':
      case 'dry_cheeks':
      case 'flakiness':
        return Icons.water_drop_outlined;
      case 'excess_sebum':
      case 'enlarged_pores':
      case 'tzone_oil':
        return Icons.opacity_outlined;
      case 'fine_lines':
      case 'firmness':
        return Icons.hourglass_top_outlined;
      case 'hyperpigmentation':
      case 'uneven_tone':
        return Icons.lens_outlined;
      case 'dullness':
      case 'texture':
        return Icons.brightness_low_outlined;
      case 'sensitivity':
      case 'thin_barrier':
        return Icons.shield_outlined;
      default:
        return Icons.spa_outlined;
    }
  }
}
