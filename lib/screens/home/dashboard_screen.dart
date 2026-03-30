import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSkinScoreCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Today\'s Routine'),
              const SizedBox(height: 12),
              _buildRoutineCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Skin Insights'),
              const SizedBox(height: 12),
              _buildInsightsGrid(),
              const SizedBox(height: 24),
              _buildSectionTitle('Recommended Products'),
              const SizedBox(height: 12),
              _buildProductsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Sarah',
              style: AppTextStyles.displaySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Your skin is looking good today!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSkinScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skin Health Score',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Good',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '78',
                style: AppTextStyles.displayLarge.copyWith(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 4),
                child: Text(
                  '/100',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+5 this week',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headlineSmall,
    );
  }

  Widget _buildRoutineCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildRoutineItem(
            icon: Icons.wb_sunny_outlined,
            title: 'Morning Routine',
            subtitle: '3 steps • 5 min',
            progress: 0.66,
            completed: 2,
            total: 3,
          ),
          const Divider(height: 24),
          _buildRoutineItem(
            icon: Icons.nightlight_outlined,
            title: 'Night Routine',
            subtitle: '4 steps • 8 min',
            progress: 0.0,
            completed: 0,
            total: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    required int completed,
    required int total,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$completed/$total',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  minHeight: 6,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildInsightCard(
            icon: Icons.water_drop_outlined,
            title: 'Hydration',
            value: 'Good',
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInsightCard(
            icon: Icons.opacity,
            title: 'Oil Level',
            value: 'Balanced',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    final products = [
      _Product(
        name: 'Hydrating Cleanser',
        brand: 'CeraVe',
        category: 'Cleanser',
      ),
      _Product(
        name: 'Vitamin C Serum',
        brand: 'The Ordinary',
        category: 'Serum',
      ),
      _Product(
        name: 'Daily Moisturizer',
        brand: 'La Roche-Posay',
        category: 'Moisturizer',
      ),
    ];

    return Column(
      children: products
          .map((product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildProductCard(product),
              ))
          .toList(),
    );
  }

  Widget _buildProductCard(_Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_pharmacy_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${product.brand} • ${product.category}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _Product {
  final String name;
  final String brand;
  final String category;

  _Product({
    required this.name,
    required this.brand,
    required this.category,
  });
}
