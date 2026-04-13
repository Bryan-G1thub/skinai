import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/onboarding_data.dart';

const _kPreferenceOptions = <String, String>{
  'vegan': 'Vegan formulas',
  'fragrance_free': 'Fragrance-free',
  'cruelty_free': 'Cruelty-free',
  'minimal_ingredients': 'Minimal ingredient lists',
};

/// Product shopping / ethics preferences (feeds ranking + copy).
class ProductPreferencesScreen extends StatefulWidget {
  final OnboardingData data;

  const ProductPreferencesScreen({super.key, required this.data});

  @override
  State<ProductPreferencesScreen> createState() => _ProductPreferencesScreenState();
}

class _ProductPreferencesScreenState extends State<ProductPreferencesScreen> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.data.productPreferences);
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
          onPressed: () {
            if (widget.data.hasExistingRoutine == true) {
              context.go('/routine-slots', extra: widget.data);
            } else {
              context.go('/routine-presence', extra: widget.data);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preferences', style: AppTextStyles.displaySmall),
              const SizedBox(height: 8),
              Text(
                'What matters when we suggest products? (Optional — you can skip.)',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kPreferenceOptions.entries.map((e) {
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
                    '/sensitivities',
                    extra: widget.data.copyWith(productPreferences: _selected.toList()),
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
