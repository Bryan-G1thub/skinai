import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/onboarding_data.dart';
import '../../services/onboarding_service.dart';

class PhotoCaptureScreen extends StatefulWidget {
  final OnboardingData data;

  const PhotoCaptureScreen({super.key, required this.data});

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnalyzing = false;
  File? _selectedImage;

  late AnimationController _pulseController;
  late Animation<double> _pulse;

  final _picker = ImagePicker();

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (_) {
      // Camera/gallery not available on this platform — skip silently
    }
  }

  Future<void> _analyze() async {
    setState(() => _isAnalyzing = true);
    // Simulate AI analysis delay
    await Future.delayed(const Duration(milliseconds: 2400));
    if (mounted) {
      context.go('/analysis-result', extra: widget.data);
    }
  }

  Future<void> _skip() async {
    await OnboardingService.save(widget.data);
    if (mounted) {
      context.go('/dashboard', extra: widget.data);
    }
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
          onPressed: _isAnalyzing
              ? null
              : () => context.go('/quiz', extra: widget.data),
        ),
        actions: [
          if (!_isAnalyzing)
            TextButton(
              onPressed: () => _skip(),
              child: Text(
                'Skip analysis for now',
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
              Text(
                _isAnalyzing ? 'Analyzing your skin...' : 'Capture your skin',
                style: AppTextStyles.displaySmall,
              ),
              const SizedBox(height: 6),
              Text(
                _isAnalyzing
                    ? 'Our AI is building your personalized profile'
                    : 'A clear photo helps us spot redness, pores, texture & more',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // Face frame / preview
              Expanded(
                child: Center(
                  child: _isAnalyzing
                      ? _buildAnalyzingState()
                      : _buildPhotoArea(),
                ),
              ),
              if (!_isAnalyzing) ...[
                const SizedBox(height: 20),
                _buildTipsRow(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoArea() {
    if (_selectedImage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(120),
              topRight: Radius.circular(120),
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
            child: Image.file(
              _selectedImage!,
              width: 240,
              height: 280,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => setState(() => _selectedImage = null),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              'Choose a different photo',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Transform.scale(
        scale: _pulse.value,
        child: child,
      ),
      child: Container(
        width: 240,
        height: 280,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(120),
            topRight: Radius.circular(120),
            bottomLeft: Radius.circular(36),
            bottomRight: Radius.circular(36),
          ),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.face_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
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
        _buildAnalysisStep('Identifying concerns', false),
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
              : const Padding(
                  padding: EdgeInsets.all(3),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTipItem(Icons.wb_sunny_outlined, 'Natural\nlight'),
          Container(width: 1, height: 32, color: AppColors.border),
          _buildTipItem(Icons.face_outlined, 'No\nmakeup'),
          Container(width: 1, height: 32, color: AppColors.border),
          _buildTipItem(Icons.sentiment_neutral_outlined, 'Neutral\nexpression'),
        ],
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final hasImage = _selectedImage != null;

    return Column(
      children: [
        // Primary: take photo or analyze
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: hasImage
                ? _analyze
                : () => _pickImage(ImageSource.camera),
            icon: Icon(
              hasImage ? Icons.auto_awesome_outlined : Icons.camera_alt_outlined,
              size: 20,
            ),
            label: Text(
              hasImage ? 'Analyze my skin' : 'Take photo',
              style: AppTextStyles.button,
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Secondary: choose from gallery
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined, size: 20),
            label: Text(
              'Choose from gallery',
              style: AppTextStyles.button,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
