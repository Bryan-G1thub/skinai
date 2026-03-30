import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/onboarding_data.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late Animation<double> _heroFade;
  late Animation<double> _heroScale;
  late Animation<double> _contentSlide;
  late Animation<double> _contentFade;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _masterController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _heroFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );

    _heroScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    _contentSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _masterController.forward();
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.55, 1.0],
              colors: [
                Color(0xFF2E1270),
                Color(0xFF3E1A7F),
                Color(0xFF1E0C52),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Decorative blobs
                _buildBlob(
                  top: size.height * 0.05,
                  right: -size.width * 0.2,
                  size: size.width * 0.7,
                  color: AppColors.primaryLight.withValues(alpha: 0.15),
                ),
                _buildBlob(
                  top: size.height * 0.25,
                  left: -size.width * 0.15,
                  size: size.width * 0.5,
                  color: AppColors.accent.withValues(alpha: 0.08),
                ),
                _buildBlob(
                  bottom: size.height * 0.1,
                  right: -size.width * 0.1,
                  size: size.width * 0.45,
                  color: AppColors.rose.withValues(alpha: 0.1),
                ),
                // Content
                Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: AnimatedBuilder(
                        animation: _masterController,
                        builder: (context, child) => Opacity(
                          opacity: _heroFade.value,
                          child: Transform.scale(
                            scale: _heroScale.value,
                            child: child,
                          ),
                        ),
                        child: _buildHero(),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: AnimatedBuilder(
                        animation: _masterController,
                        builder: (context, child) => Opacity(
                          opacity: _contentFade.value,
                          child: Transform.translate(
                            offset: Offset(0, _contentSlide.value),
                            child: child,
                          ),
                        ),
                        child: _buildContent(),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _masterController,
                      builder: (context, child) => Opacity(
                        opacity: _buttonFade.value,
                        child: child,
                      ),
                      child: _buildActions(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outermost ring
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
          ),
          // Middle ring
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
          ),
          // Inner glow ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1.5,
              ),
            ),
          ),
          // Center icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.28),
                  Colors.white.withValues(alpha: 0.14),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.face_retouching_natural,
              size: 38,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          // Gold accent dot
          Positioned(
            top: 52,
            right: 70,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent,
              ),
            ),
          ),
          Positioned(
            bottom: 58,
            left: 68,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.rose.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Overline tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'AI-POWERED SKIN CARE',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.accent,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Headline (serif)
          Text(
            'Science meets\nyour skin.',
            textAlign: TextAlign.center,
            style: AppTextStyles.displayLarge.copyWith(
              color: Colors.white,
              fontSize: 42,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 18),
          // Subheadline
          Text(
            'Personalized routines, daily tracking,\nand insights tailored to you.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(
                '/intent',
                extra: const OnboardingData(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get started',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primary,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Join 50,000+ people on their skin journey',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
