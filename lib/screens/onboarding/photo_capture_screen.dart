import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/onboarding_data.dart';

class PhotoCaptureScreen extends StatefulWidget {
  final OnboardingData data;

  const PhotoCaptureScreen({super.key, required this.data});

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnalyzing = false;

  late AnimationController _pulseController;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) {
      context.go('/dashboard', extra: widget.data);
    }
  }

  void _skip() => context.go('/dashboard', extra: widget.data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _isAnalyzing
              ? null
              : () => context.go('/quiz', extra: widget.data),
        ),
        actions: [
          if (!_isAnalyzing)
            TextButton(
              onPressed: _skip,
              child: Text(
                'Skip for now',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Header
              Text(
                _isAnalyzing ? 'Analyzing your skin...' : 'Capture your skin',
                style: AppTextStyles.displaySmall,
              ),
              const SizedBox(height: 6),
              Text(
                _isAnalyzing
                    ? 'Our AI is building your personalized profile'
                    : 'A quick photo helps us personalize your analysis',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              // Face frame
              Expanded(
                child: Center(
                  child: _isAnalyzing
                      ? _buildAnalyzingState()
                      : _buildCameraFrame(),
                ),
              ),
              if (!_isAnalyzing) ...[
                const SizedBox(height: 24),
                _buildTipsRow(),
                const SizedBox(height: 28),
              ],
              if (!_isAnalyzing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _capturePhoto,
                    icon: const Icon(Icons.camera_alt_outlined, size: 20),
                    label: Text('Take photo', style: AppTextStyles.button),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraFrame() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Transform.scale(
        scale: _pulse.value,
        child: child,
      ),
      child: Container(
        width: 260,
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(130),
            topRight: Radius.circular(130),
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.face_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Position your face\nwithin the frame',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.primaryLight.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildAnalysisStep('Mapping your skin tone', true),
        const SizedBox(height: 12),
        _buildAnalysisStep('Detecting pores & texture', true),
        const SizedBox(height: 12),
        _buildAnalysisStep('Building your profile', false),
      ],
    );
  }

  Widget _buildAnalysisStep(String label, bool done) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.surfaceVariant,
          ),
          child: done
              ? const Icon(Icons.check, size: 12, color: AppColors.success)
              : const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.primary,
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: done ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTipsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTipItem(Icons.wb_sunny_outlined, 'Natural\nlight'),
          _buildTipDivider(),
          _buildTipItem(Icons.face_outlined, 'No\nmakeup'),
          _buildTipDivider(),
          _buildTipItem(Icons.sentiment_neutral_outlined, 'Neutral\nexpression'),
        ],
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTipDivider() {
    return Container(width: 1, height: 36, color: AppColors.border);
  }
}
