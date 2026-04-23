import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/onboarding_data.dart';

/// Immersive welcome: staged opening animation, rotating keyword (bounded),
/// no unbounded horizontal rows — avoids carousel overflow issues.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  /// Nullable so hot reload works — [initState] may not run again.
  AnimationController? _intro;
  Animation<double>? _heroWash;
  Animation<double>? _orbDrift;
  Animation<double>? _keywordReveal;
  Animation<double>? _panelRise;
  Animation<double>? _titleReveal;
  Animation<double>? _bodyReveal;
  Animation<double>? _ctaReveal;

  Timer? _keywordTimer;
  int _keywordIndex = 0;

  static const List<String> _keywords = [
    'Hydrate',
    'Protect',
    'Balance',
    'Glow',
  ];

  String get _currentKeyword => _keywords[_keywordIndex % _keywords.length];

  void _ensureIntro() {
    if (_intro != null) return;

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    final c = _intro!;
    _heroWash = CurvedAnimation(
      parent: c,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );

    _orbDrift = CurvedAnimation(
      parent: c,
      curve: const Interval(0.08, 0.55, curve: Curves.easeOut),
    );

    _keywordReveal = CurvedAnimation(
      parent: c,
      curve: const Interval(0.18, 0.52, curve: Curves.easeOutCubic),
    );

    _panelRise = CurvedAnimation(
      parent: c,
      curve: const Interval(0.38, 0.78, curve: Curves.easeOutCubic),
    );

    _titleReveal = CurvedAnimation(
      parent: c,
      curve: const Interval(0.52, 0.82, curve: Curves.easeOut),
    );

    _bodyReveal = CurvedAnimation(
      parent: c,
      curve: const Interval(0.62, 0.90, curve: Curves.easeOut),
    );

    _ctaReveal = CurvedAnimation(
      parent: c,
      curve: const Interval(0.72, 1.0, curve: Curves.easeOutCubic),
    );

    c.forward();

    _keywordTimer ??= Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _keywordIndex = (_keywordIndex + 1) % _keywords.length);
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _keywordIndex = _keywordIndex % _keywords.length;
    _ensureIntro();
  }

  @override
  void dispose() {
    _keywordTimer?.cancel();
    _intro?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureIntro();
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _intro!,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _buildAtmosphere(),
              SafeArea(
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: constraints.maxHeight * 0.52,
                              child: _buildHeroStage(),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28),
                              child: Divider(
                                color: AppColors.border.withValues(alpha: 0.9),
                                thickness: 1,
                                height: 1,
                              ),
                            ),
                            _buildLowerSheet(bottomInset),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAtmosphere() {
    final wash = _heroWash!.value;
    final orb = _orbDrift!.value;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(AppColors.background, AppColors.surfaceVariant, wash)!,
                Color.lerp(AppColors.background, AppColors.surface, wash)!,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
        Positioned(
          top: 120,
          left: 80,
          child: Opacity(
            opacity: 0.16 + 0.1 * wash,
            child: Transform.translate(
              offset: Offset(6 * (1 - orb), 10 * (1 - orb)),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 150,
          right: 60,
          child: Opacity(
            opacity: 0.12 + 0.1 * wash,
            child: Transform.translate(
              offset: Offset(-6 * (1 - orb), 8 * orb),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 248,
          left: 56,
          child: Opacity(
            opacity: 0.14 + 0.08 * wash,
            child: Transform.translate(
              offset: Offset(6 * orb, -4 * (1 - orb)),
              child: Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 278,
          right: 90,
          child: Opacity(
            opacity: 0.15 + 0.08 * wash,
            child: Transform.translate(
              offset: Offset(-5 * orb, 3 * (1 - orb)),
              child: Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroStage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: _keywordReveal!.value,
            child: Transform.translate(
              offset: Offset(0, 24 * (1 - _keywordReveal!.value)),
              child: Text(
                'SKINSIGNAL',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                  color: AppColors.textTertiary.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Bounded keyword — FittedBox prevents overflow on narrow screens.
          SizedBox(
            height: 64,
            width: double.infinity,
            child: Opacity(
              opacity: _keywordReveal!.value,
              child: Transform.translate(
                offset: Offset(0, 32 * (1 - _keywordReveal!.value)),
                child: Transform.scale(
                  scale: 0.92 + 0.08 * _keywordReveal!.value,
                  alignment: Alignment.centerLeft,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 700),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) {
                        final isCurrent = child.key == ValueKey<int>(_keywordIndex);
                        final position = isCurrent
                            ? Tween<Offset>(
                                begin: const Offset(0, -0.14),
                                end: Offset.zero,
                              ).animate(anim)
                            : Tween<Offset>(
                                begin: const Offset(0, 0.16),
                                end: Offset.zero,
                              ).animate(anim);
                        return ClipRect(
                          child: FadeTransition(
                            opacity: anim,
                            child: SlideTransition(position: position, child: child),
                          ),
                        );
                      },
                      child: FittedBox(
                        key: ValueKey<int>(_keywordIndex),
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _currentKeyword,
                          style: GoogleFonts.inter(
                            fontSize: 64,
                            fontWeight: FontWeight.w300,
                            color: AppColors.accent,
                            letterSpacing: -1.2,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: _keywordReveal!.value,
            child: Container(
              width: 56,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    AppColors.border,
                    AppColors.border.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildLowerSheet(double bottomInset) {
    return Transform.translate(
      offset: Offset(0, 48 * (1 - _panelRise!.value)),
      child: Opacity(
        opacity: _panelRise!.value.clamp(0.0, 1.0),
        child: Container(
          width: double.infinity,
          color: AppColors.background,
          padding: EdgeInsets.fromLTRB(28, 36, 28, 28 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(
                opacity: _titleReveal!.value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - _titleReveal!.value)),
                  child: Text(
                    'Skincare that\nlistens first.',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 38,
                      height: 1.12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Opacity(
                opacity: _bodyReveal!.value,
                child: Transform.translate(
                  offset: Offset(0, 16 * (1 - _bodyReveal!.value)),
                  child: Text(
                    'Build a routine, track how your skin responds, '
                    'and get ideas tailored to you.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.55,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Opacity(
                opacity: _ctaReveal!.value,
                child: Transform.translate(
                  offset: Offset(0, 24 * (1 - _ctaReveal!.value)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go(
                            '/intent',
                            extra: const OnboardingData(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get started',
                                style: AppTextStyles.button.copyWith(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Join our community on your skin care journey',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
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
