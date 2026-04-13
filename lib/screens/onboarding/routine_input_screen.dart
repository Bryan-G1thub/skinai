import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/onboarding_data.dart';
import '../../services/onboarding_service.dart';

class RoutineInputScreen extends StatefulWidget {
  final OnboardingData data;

  const RoutineInputScreen({super.key, required this.data});

  @override
  State<RoutineInputScreen> createState() => _RoutineInputScreenState();
}

class _RoutineInputScreenState extends State<RoutineInputScreen> {
  final TextEditingController _controller = TextEditingController();
  late final List<String> _products = List<String>.from(
    widget.data.resolvedProductLines.isNotEmpty
        ? widget.data.resolvedProductLines
        : widget.data.currentProducts,
  );
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addProduct() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    if (_products.contains(value)) {
      _controller.clear();
      return;
    }
    setState(() {
      _products.add(value);
      _controller.clear();
    });
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);

    final existingAnalysis = widget.data.analysis;
    final updated = widget.data.copyWith(
      currentProducts: _products,
      analysis: existingAnalysis?.copyWith(currentProducts: _products),
    );
    await OnboardingService.save(updated);
    if (mounted) {
      context.go('/dashboard', extra: updated);
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
          onPressed: _saving ? null : () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What are you currently using?', style: AppTextStyles.displaySmall),
              const SizedBox(height: 8),
              Text(
                'Add your routine products so we can avoid duplicate recommendations.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addProduct(),
                      decoration: const InputDecoration(
                        hintText: 'e.g. CeraVe Hydrating Cleanser',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _saving ? null : _addProduct,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_products.isEmpty)
                Text(
                  'No products added yet.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _products
                      .map(
                        (product) => Chip(
                          label: Text(product),
                          onDeleted: _saving
                              ? null
                              : () => setState(() => _products.remove(product)),
                        ),
                      )
                      .toList(),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _finish,
                  child: Text(_saving ? 'Saving...' : 'Continue to dashboard'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _saving ? null : _finish,
                  child: const Text('Skip'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
