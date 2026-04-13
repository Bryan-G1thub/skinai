import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/skin_analysis_copy.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/onboarding_data.dart';
import '../../models/skin_analysis.dart';
import '../../services/firestore_product_service.dart';
import '../../services/product_knowledge_service.dart';
import '../../services/product_recommendation_engine.dart';
import '../../services/skin_journey_storage.dart';
import '../../models/skin_journey_state.dart';
import 'skin_journey_dashboard_tabs.dart';

class DashboardScreen extends StatefulWidget {
  final OnboardingData data;

  const DashboardScreen({super.key, required this.data});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0;
  final FirestoreProductService _productService = FirestoreProductService();
  late final Future<List<RankedFirestoreProduct>> _rankedProductsFuture;

  SkinJourneyState _journey = const SkinJourneyState();
  bool _journeyLoading = true;

  OnboardingData get data => widget.data;
  SkinAnalysis? get _analysis => data.analysis;

  @override
  void initState() {
    super.initState();
    _rankedProductsFuture = _loadRankedProducts();
    _bootJourney();
  }

  Future<void> _bootJourney() async {
    var raw = await SkinJourneyStorage.load();
    final merged = SkinJourneyStorage.mergeOnboardingProducts(raw, widget.data);
    if (merged.cabinet.length > raw.cabinet.length) {
      await SkinJourneyStorage.save(merged);
    }
    if (!mounted) return;
    setState(() {
      _journey = merged;
      _journeyLoading = false;
    });
  }

  void _setJourney(SkinJourneyState next) {
    setState(() => _journey = next);
    SkinJourneyStorage.save(next);
  }

  Future<List<RankedFirestoreProduct>> _loadRankedProducts() async {
    final raw = await _productService.getProductsForProfile(
      skinType: data.skinType,
      concern: data.concern,
      conditionIds: _analysis?.conditions.map((c) => c.id).toList() ?? const [],
      limit: 24,
    );
    final km = ProductKnowledgeService.matchUserProducts(data.currentProducts);
    return ProductRecommendationEngine.rank(
      products: raw,
      data: data,
      analysis: _analysis,
      knowledgeMatches: km,
    ).take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: _selectedTab == 0
          ? _buildHomeBody(context)
          : _journeyLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
              : _selectedTab == 1
                  ? RoutineWorkspace(
                      journey: _journey,
                      profile: data,
                      onJourneyChanged: _setJourney,
                    )
                  : _selectedTab == 2
                      ? InsightsWorkspace(
                          journey: _journey,
                          profile: data,
                          analysis: _analysis,
                          onJourneyChanged: _setJourney,
                        )
                      : CabinetProfileWorkspace(
                          journey: _journey,
                          profile: data,
                          onJourneyChanged: _setJourney,
                        ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    return Column(
      children: [
        // ── Dark header ───────────────────────────────────────────────────
        Container(
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 22),
                  _buildScoreCard(context),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),

        // ── Scrollable white content ───────────────────────────────────
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
              child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMedicalDisclaimerBanner(),
                  const SizedBox(height: 20),
                  _buildFocusBanner(),
                  const SizedBox(height: 28),
                  if (_analysis == null) ...[
                    _buildAnalysisReminder(),
                    const SizedBox(height: 20),
                  ],
                  _buildSectionLabel("Today's Routine"),
                  const SizedBox(height: 14),
                  _buildRoutineCard(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('Skin Snapshot'),
                  const SizedBox(height: 14),
                  _buildSnapshotRow(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('Recommended For You'),
                  const SizedBox(height: 14),
                  _buildProductsList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF24105A),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowStrong,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildNavItem(0, Icons.home_rounded, 'Home'),
            _buildNavItem(1, Icons.auto_awesome_rounded, 'Routine'),
            _buildNavItem(2, Icons.insights_rounded, 'Insights'),
            _buildNavItem(3, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.primaryDark : Colors.white.withValues(alpha: 0.75),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color:
                      selected ? AppColors.primaryDark : Colors.white.withValues(alpha: 0.8),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header components ──────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Sarah',
              style: AppTextStyles.displaySmall.copyWith(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _HeaderIconButton(
              icon: Icons.notifications_none_rounded,
              badge: true,
            ),
            const SizedBox(width: 10),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryLight,
                    AppColors.primary,
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  'S',
                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Score circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 82,
                height: 82,
                child: CircularProgressIndicator(
                  value: ((_analysis?.score ?? 78) / 100).clamp(0.0, 1.0),
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${_analysis?.score ?? 78}',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '/100',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skin Health Score',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _scoreLabel(_analysis?.score ?? 78),
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        size: 14,
                        color: Color(0xFF5CE8A4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+5 this week',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF5CE8A4),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Content components ────────────────────────────────────────────────────

  Widget _buildFocusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B4EFF), AppColors.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.flag_outlined,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's focus",
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.65),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.dashboardFocus,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: AppTextStyles.headlineSmall);
  }

  Widget _buildMedicalDisclaimerBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        SkinAnalysisCopy.generalFooter,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white.withValues(alpha: 0.78),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildAnalysisReminder() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.photo_camera_outlined, color: AppColors.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Add a face photo during onboarding to layer photo-based estimates on your quiz profile.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard() {
    final am = _journey.routine.morning;
    final pm = _journey.routine.evening;
    final amFilled = am.where((s) => s.catalogProductId != null).length;
    final pmFilled = pm.where((s) => s.catalogProductId != null).length;
    final amT = am.isEmpty ? 4 : am.length;
    final pmT = pm.isEmpty ? 3 : pm.length;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRoutineRow(
            icon: Icons.wb_sunny_outlined,
            iconColor: const Color(0xFFE8B94A),
            iconBg: const Color(0xFFFDF4E0),
            title: 'Morning Routine',
            subtitle: am.isEmpty ? 'Add steps in Routine tab' : '${am.length} steps',
            completed: amFilled,
            total: amT,
            isTop: true,
          ),
          Container(height: 1, color: AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: 18)),
          _buildRoutineRow(
            icon: Icons.nightlight_outlined,
            iconColor: AppColors.primaryLight,
            iconBg: AppColors.surfaceVariant,
            title: 'Night Routine',
            subtitle: pm.isEmpty ? 'Add steps in Routine tab' : '${pm.length} steps',
            completed: pmFilled,
            total: pmT,
            isTop: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required int completed,
    required int total,
    required bool isTop,
  }) {
    final progress = total > 0 ? completed / total : 0.0;
    final isDone = completed == total;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, isTop ? 18 : 14, 18, isTop ? 14 : 18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$completed/$total',
                style: AppTextStyles.titleMedium.copyWith(
                  color: isDone ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isDone ? 'Done!' : 'In progress',
                style: AppTextStyles.caption.copyWith(
                  color:
                      isDone ? AppColors.success : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotRow() {
    final conditions = _analysis?.conditions ?? const [];
    final topConditions = conditions.take(3).toList();
    if (topConditions.isEmpty) {
      return Row(
        children: [
          Expanded(
            child: _SnapshotCard(
              icon: Icons.check_circle_outline,
              label: 'Status',
              value: 'Ready',
              color: AppColors.success,
              bgColor: AppColors.successLight,
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < topConditions.length; i++) ...[
          Expanded(
            child: _SnapshotCard(
              icon: _conditionIcon(topConditions[i].id),
              label: topConditions[i].label,
              value: _severityLabel(topConditions[i].severity),
              color: _severityColor(topConditions[i].severity),
              bgColor: _severityBgColor(topConditions[i].severity),
            ),
          ),
          if (i != topConditions.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }

  Widget _buildProductsList() {
    return FutureBuilder<List<RankedFirestoreProduct>>(
      future: _rankedProductsFuture,
      builder: (context, snapshot) {
        final ranked = snapshot.data ?? const <RankedFirestoreProduct>[];
        final localProducts = (_analysis?.recommendedProducts(
              excluding: _analysis?.currentProducts ?? const [],
            ) ??
                const <ProductRecommendation>[])
            .map(
              (p) => _ProductItem(
                name: p.name,
                brand: p.brand,
                tag: p.category,
                tagColor: _tagBgColor(p.category),
                tagTextColor: _tagTextColor(p.category),
                subtitle: p.reason,
              ),
            )
            .toList();

        final products = ranked.isNotEmpty
            ? ranked
                .map(
                  (r) => _ProductItem(
                    name: r.product.name,
                    brand: r.product.brand,
                    tag: r.product.category,
                    tagColor: _tagBgColor(r.product.category),
                    tagTextColor: _tagTextColor(r.product.category),
                    subtitle: r.explanation.isNotEmpty
                        ? r.explanation
                        : r.product.reason,
                    imageUrl: r.product.imageUrl,
                    affiliateUrl: r.product.affiliateUrl,
                  ),
                )
                .toList()
            : localProducts;

        if (products.isEmpty) {
          return Text(
            'Complete onboarding and skin analysis to unlock recommendations.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          );
        }

        return Column(
          children: products
              .map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildProductCard(p),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildProductCard(_ProductItem product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProductImage(product),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTextStyles.titleMedium),
                const SizedBox(height: 3),
                Text(
                  product.brand,
                  style: AppTextStyles.bodySmall,
                ),
                if (product.subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    product.subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: product.tagColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  product.tag,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: product.tagTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: product.affiliateUrl == null ? null : () => _openAffiliateLink(product),
                child: Icon(
                  Icons.open_in_new_rounded,
                  size: 14,
                  color: product.affiliateUrl == null
                      ? AppColors.textTertiary
                      : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(_ProductItem product) {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.network(
          product.imageUrl!,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultProductIcon(),
        ),
      );
    }
    return _defaultProductIcon();
  }

  Widget _defaultProductIcon() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Icon(
        Icons.spa_outlined,
        color: AppColors.primary,
        size: 26,
      ),
    );
  }

  Future<void> _openAffiliateLink(_ProductItem product) async {
    final url = product.affiliateUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _scoreLabel(int score) {
    if (score >= 80) return 'Looking great!';
    if (score >= 65) return 'On track';
    if (score >= 50) return 'Improving';
    return 'Needs attention';
  }

  String _severityLabel(String severity) {
    switch (severity) {
      case 'significant':
        return 'High';
      case 'moderate':
        return 'Medium';
      default:
        return 'Mild';
    }
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'significant':
        return AppColors.error;
      case 'moderate':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  Color _severityBgColor(String severity) {
    switch (severity) {
      case 'significant':
        return AppColors.error.withValues(alpha: 0.1);
      case 'moderate':
        return AppColors.warningLight;
      default:
        return AppColors.infoLight;
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

  Color _tagBgColor(String category) {
    switch (category.toLowerCase()) {
      case 'spf':
        return AppColors.tintGold;
      case 'moisturizer':
        return AppColors.tintSage;
      case 'serum':
        return AppColors.infoLight;
      default:
        return AppColors.surfaceVariant;
    }
  }

  Color _tagTextColor(String category) {
    switch (category.toLowerCase()) {
      case 'spf':
        return AppColors.warning;
      case 'moisturizer':
        return AppColors.success;
      case 'serum':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final bool badge;

  const _HeaderIconButton({required this.icon, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        if (badge)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent,
              ),
            ),
          ),
      ],
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _SnapshotCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _ProductItem {
  final String name;
  final String brand;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final String? subtitle;
  final String? imageUrl;
  final String? affiliateUrl;

  const _ProductItem({
    required this.name,
    required this.brand,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    this.subtitle,
    this.imageUrl,
    this.affiliateUrl,
  });
}
