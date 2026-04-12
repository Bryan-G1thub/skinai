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
    'Balance',
    'Glow',
    'Calm',
    'Protect',
  ];

  static const List<TextStyle Function()> _keywordStyles = [
    _stylePlayfair,
    _styleCormorant,
    _styleFraunces,
    _styleDmSerif,
    _styleLora,
  ];

  static TextStyle _stylePlayfair() => GoogleFonts.playfairDisplay(
        fontSize: 44,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFF5EDE4),
        height: 1.05,
      );

  static TextStyle _styleCormorant() => GoogleFonts.cormorantGaramond(
        fontSize: 52,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        color: const Color(0xFFE8D5C4),
        height: 1.0,
      );

  static TextStyle _styleFraunces() => GoogleFonts.fraunces(
        fontSize: 46,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFF0E6DC),
        height: 1.05,
      );

  static TextStyle _styleDmSerif() => GoogleFonts.dmSerifDisplay(
        fontSize: 48,
        color: const Color(0xFFE5D9CE),
        height: 1.0,
      );

  static TextStyle _styleLora() => GoogleFonts.lora(
        fontSize: 42,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFF2E8DF),
        height: 1.05,
      );

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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
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
      backgroundColor: const Color(0xFF0E0A12),
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF08060A),
                  const Color(0xFF1E1630),
                  wash,
                )!,
                Color.lerp(
                  const Color(0xFF120E18),
                  const Color(0xFF2D2445),
                  wash,
                )!,
                const Color(0xFF15101C),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -40,
          right: -30,
          child: Opacity(
            opacity: 0.35 + 0.25 * wash,
            child: Transform.translate(
              offset: Offset(20 * (1 - orb), -15 * (1 - orb)),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryLight.withValues(alpha: 0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.42,
          left: -50,
          child: Opacity(
            opacity: 0.2 + 0.2 * wash,
            child: Transform.translate(
              offset: Offset(-25 * (1 - orb), 10 * orb),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
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
                'SKINAI',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                  color: Colors.white.withValues(alpha: 0.45),
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
                      duration: const Duration(milliseconds: 550),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) {
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.15),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        );
                      },
                      child: FittedBox(
                        key: ValueKey<int>(_keywordIndex),
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _keywords[_keywordIndex],
                          style: _keywordStyles[_keywordIndex % _keywordStyles.length](),
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
                    AppColors.accent,
                    AppColors.accent.withValues(alpha: 0.2),
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
          decoration: const BoxDecoration(
            color: Color(0xFFF7F2EC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 40,
                offset: Offset(0, -8),
              ),
            ],
          ),
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
                            backgroundColor: const Color(0xFF1C1826),
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
