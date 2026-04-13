import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local_skin_catalog.dart';
import '../../models/local_catalog_product.dart';
import '../../models/onboarding_data.dart';
import '../../models/routine_slot_entry.dart';

const _kCategories = <(String id, String label)>[
  ('cleanser', 'Cleanser'),
  ('toner', 'Toner / essence'),
  ('moisturizer', 'Moisturizer'),
  ('active_treatment', 'Active / treatment'),
  ('spf', 'Sunscreen (SPF)'),
];

/// Per-step routine capture: catalog search + manual fallback.
class RoutineSlotsScreen extends StatefulWidget {
  final OnboardingData data;

  const RoutineSlotsScreen({super.key, required this.data});

  @override
  State<RoutineSlotsScreen> createState() => _RoutineSlotsScreenState();
}

class _RoutineSlotsScreenState extends State<RoutineSlotsScreen> {
  late final Map<String, RoutineSlotEntry> _slots = {
    for (final c in _kCategories) c.$1: RoutineSlotEntry(categoryId: c.$1),
  };

  final Map<String, TextEditingController> _search = {};
  final Map<String, String> _query = {};

  @override
  void initState() {
    super.initState();
    for (final c in _kCategories) {
      _search[c.$1] = TextEditingController();
    }
    for (final s in widget.data.routineSlots) {
      if (_slots.containsKey(s.categoryId)) {
        _slots[s.categoryId] = s;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _search.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<LocalCatalogProduct> _resultsFor(String categoryId) {
    final q = _query[categoryId] ?? '';
    final list = LocalSkinCatalog.search(q);
    return list.take(8).toList();
  }

  Future<void> _manualDialog(String categoryId) async {
    final brand = TextEditingController();
    final name = TextEditingController();
    final actives = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manual product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: brand,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Product name'),
              ),
              TextField(
                controller: actives,
                decoration: const InputDecoration(
                  labelText: 'Key actives (comma-separated)',
                  hintText: 'e.g. niacinamide, hyaluronic acid',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final parts = actives.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              setState(() {
                _slots[categoryId] = RoutineSlotEntry(
                  categoryId: categoryId,
                  manualBrand: brand.text.trim().isEmpty ? null : brand.text.trim(),
                  manualName: name.text.trim().isEmpty ? null : name.text.trim(),
                  manualActives: parts,
                );
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _pickCatalog(String categoryId, LocalCatalogProduct p) {
    setState(() {
      _slots[categoryId] = RoutineSlotEntry(
        categoryId: categoryId,
        catalogProductId: p.id,
      );
    });
  }

  void _clearSlot(String categoryId) {
    setState(() {
      _slots[categoryId] = RoutineSlotEntry(categoryId: categoryId);
      _search[categoryId]?.clear();
      _query[categoryId] = '';
    });
  }

  List<String> _buildProductLines() {
    return _kCategories
        .map((c) => _slots[c.$1])
        .whereType<RoutineSlotEntry>()
        .where((s) => !s.isEmpty)
        .map((s) => s.resolvedLabel)
        .toList();
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
          onPressed: () => context.go('/routine-presence', extra: widget.data),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your products', style: AppTextStyles.displaySmall),
                  const SizedBox(height: 8),
                  Text(
                    'Search our offline catalog for each step, or enter details manually so we still understand actives.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: _kCategories.length,
                itemBuilder: (context, i) {
                  final id = _kCategories[i].$1;
                  final label = _kCategories[i].$2;
                  final slot = _slots[id]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(label, style: AppTextStyles.titleMedium),
                              ),
                              if (!slot.isEmpty)
                                TextButton(
                                  onPressed: () => _clearSlot(id),
                                  child: const Text('Clear'),
                                ),
                            ],
                          ),
                          if (!slot.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                slot.resolvedLabel,
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                              ),
                            ),
                          TextField(
                            controller: _search[id],
                            decoration: InputDecoration(
                              hintText: 'Search catalog…',
                              isDense: true,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.edit_note_outlined),
                                tooltip: 'Enter manually',
                                onPressed: () => _manualDialog(id),
                              ),
                            ),
                            onChanged: (v) => setState(() => _query[id] = v),
                          ),
                          const SizedBox(height: 8),
                          ..._resultsFor(id).map(
                            (p) => ListTile(
                              dense: true,
                              title: Text(p.name, style: AppTextStyles.bodyMedium),
                              subtitle: Text('${p.brand} · ${p.role}', style: AppTextStyles.caption),
                              onTap: () => _pickCatalog(id, p),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final slots = _kCategories.map((c) => _slots[c.$1]!).toList();
                    final lines = _buildProductLines();
                    context.go(
                      '/product-preferences',
                      extra: widget.data.copyWith(
                        routineSlots: slots,
                        currentProducts: lines,
                        hasExistingRoutine: true,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Text('Continue', style: AppTextStyles.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
