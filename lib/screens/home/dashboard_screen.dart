import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/onboarding_data.dart';

class DashboardScreen extends StatelessWidget {
  final OnboardingData data;

  const DashboardScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
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
                    _buildFocusBanner(),
                    const SizedBox(height: 28),
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
                  value: 0.78,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
              Column(
                children: [
                  Text(
                    '78',
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
                  'Looking good!',
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

  Widget _buildRoutineCard() {
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
            subtitle: '3 steps · 5 min',
            completed: 2,
            total: 3,
            isTop: true,
          ),
          Container(height: 1, color: AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: 18)),
          _buildRoutineRow(
            icon: Icons.nightlight_outlined,
            iconColor: AppColors.primaryLight,
            iconBg: AppColors.surfaceVariant,
            title: 'Night Routine',
            subtitle: '4 steps · 8 min',
            completed: 0,
            total: 4,
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
    return Row(
      children: [
        Expanded(
          child: _SnapshotCard(
            icon: Icons.water_drop_outlined,
            label: 'Hydration',
            value: 'Good',
            color: AppColors.info,
            bgColor: AppColors.infoLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SnapshotCard(
            icon: Icons.opacity_outlined,
            label: 'Oil Level',
            value: 'Balanced',
            color: AppColors.success,
            bgColor: AppColors.successLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SnapshotCard(
            icon: Icons.stars_outlined,
            label: 'Clarity',
            value: 'Great',
            color: const Color(0xFFB77C2A),
            bgColor: AppColors.tintGold,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    final products = [
      _ProductItem(
        name: 'Hydrating Cleanser',
        brand: 'CeraVe',
        tag: 'Cleanser',
        tagColor: AppColors.infoLight,
        tagTextColor: AppColors.info,
      ),
      _ProductItem(
        name: 'Vitamin C Serum',
        brand: 'The Ordinary',
        tag: 'Serum',
        tagColor: AppColors.tintGold,
        tagTextColor: AppColors.warning,
      ),
      _ProductItem(
        name: 'Daily Moisturizer SPF 30',
        brand: 'La Roche-Posay',
        tag: 'Moisturizer',
        tagColor: AppColors.tintSage,
        tagTextColor: AppColors.success,
      ),
    ];

    return Column(
      children: products
          .map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildProductCard(p),
              ))
          .toList(),
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
          Container(
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
          ),
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
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
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

  const _ProductItem({
    required this.name,
    required this.brand,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
  });
}
