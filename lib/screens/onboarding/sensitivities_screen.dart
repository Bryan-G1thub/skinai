import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/onboarding_data.dart';

const _kSensitivityOptions = <String, String>{
  'fragrance': 'Fragrance / perfume',
  'essential_oils': 'Essential oils',
  'sulfates': 'Sulfates',
  'nuts': 'Nut oils (e.g. almond)',
  'alcohol_denat': 'Drying alcohols',
};

/// Common sensitivities — used to filter / down-rank catalog picks.
class SensitivitiesScreen extends StatefulWidget {
  final OnboardingData data;

  const SensitivitiesScreen({super.key, required this.data});

  @override
  State<SensitivitiesScreen> createState() => _SensitivitiesScreenState();
}

class _SensitivitiesScreenState extends State<SensitivitiesScreen> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.data.sensitivities);
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
          onPressed: () => context.go('/product-preferences', extra: widget.data),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sensitivities', style: AppTextStyles.displaySmall),
              const SizedBox(height: 8),
              Text(
                'Anything that usually irritates your skin? We will steer picks away when our catalog tags support it.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kSensitivityOptions.entries.map((e) {
                  final on = _selected.contains(e.key);
                  return FilterChip(
                    label: Text(e.value),
                    selected: on,
                    onSelected: (v) => setState(() {
                      if (v) {
                        _selected.add(e.key);
                      } else {
                        _selected.remove(e.key);
                      }
                    }),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(
                    '/photo-capture',
                    extra: widget.data.copyWith(sensitivities: _selected.toList()),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Text('Continue', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
