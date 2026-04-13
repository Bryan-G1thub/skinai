import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/skin_analysis_copy.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/skin_journey_ui.dart';
import '../../data/local_skin_catalog.dart';
import '../../models/cabinet_item.dart';
import '../../models/local_catalog_product.dart';
import '../../models/onboarding_data.dart';
import '../../models/routine_evaluation.dart';
import '../../models/skin_analysis.dart';
import '../../models/routine_step.dart';
import '../../models/skin_check_in.dart';
import '../../models/skin_journey_state.dart';
import '../../services/onboarding_service.dart';
import '../../services/routine_rules_engine.dart';
import '../../services/skin_journey_storage.dart';

String _genId() => 'sj_${DateTime.now().microsecondsSinceEpoch}';

// ── Routine tab ─────────────────────────────────────────────────────────────

class RoutineWorkspace extends StatelessWidget {
  final SkinJourneyState journey;
  final OnboardingData profile;
  final ValueChanged<SkinJourneyState> onJourneyChanged;

  const RoutineWorkspace({
    super.key,
    required this.journey,
    required this.profile,
    required this.onJourneyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final insights = RoutineRulesEngine.evaluate(profile: profile, journey: journey);

    return Container(
      decoration: SkinJourneyUi.pageGradientBg(),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Routine',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Assign products from your cabinet to AM / PM. Feedback updates instantly — no account needed.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              sliver: SliverToBoxAdapter(
                child: SkinJourneyUi.glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.auto_fix_high_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Coach notes',
                              style: AppTextStyles.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...insights.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: SkinJourneyUi.tonePill(r.tone, _toneLabel(r.tone)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.title,
                                      style: AppTextStyles.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      r.detail,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
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
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: SkinJourneyUi.sectionHeader(
                  'Morning',
                  action: 'Add step',
                  onAction: () => _addStep(context, isAm: true),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              sliver: SliverToBoxAdapter(
                child: _RoutinePhaseList(
                  steps: journey.routine.morning,
                  journey: journey,
                  onJourneyChanged: onJourneyChanged,
                  isAm: true,
                  onAssign: (stepId) => _pickCabinetForStep(context, stepId, isAm: true),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: SkinJourneyUi.sectionHeader(
                  'Evening',
                  action: 'Add step',
                  onAction: () => _addStep(context, isAm: false),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
              sliver: SliverToBoxAdapter(
                child: _RoutinePhaseList(
                  steps: journey.routine.evening,
                  journey: journey,
                  onJourneyChanged: onJourneyChanged,
                  isAm: false,
                  onAssign: (stepId) => _pickCabinetForStep(context, stepId, isAm: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _toneLabel(EvaluationTone t) {
    return switch (t) {
      EvaluationTone.positive => 'Nice',
      EvaluationTone.gap => 'Tip',
      EvaluationTone.caution => 'Careful',
    };
  }

  void _addStep(BuildContext context, {required bool isAm}) {
    final step = RoutineStep(id: _genId());
    final next = isAm
        ? journey.copyWith(
            routine: journey.routine.copyWith(
              morning: [...journey.routine.morning, step],
            ),
          )
        : journey.copyWith(
            routine: journey.routine.copyWith(
              evening: [...journey.routine.evening, step],
            ),
          );
    onJourneyChanged(next);
  }

  Future<void> _pickCabinetForStep(
    BuildContext context,
    String stepId, {
    required bool isAm,
  }) async {
    if (journey.cabinet.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add products in Profile → My cabinet first.',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryDark,
        ),
      );
      return;
    }
    final items = journey.cabinet
        .map((c) => LocalSkinCatalog.getById(c.catalogProductId))
        .whereType<LocalCatalogProduct>()
        .toList();

    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CabinetPickerSheet(products: items),
    );
    if (picked == null || !context.mounted) return;

    List<RoutineStep> replace(List<RoutineStep> list) {
      return list
          .map(
            (s) => s.id == stepId
                ? RoutineStep(id: s.id, catalogProductId: picked, customLabel: '')
                : s,
          )
          .toList();
    }

    final next = journey.copyWith(
      routine: isAm
          ? journey.routine.copyWith(morning: replace(journey.routine.morning))
          : journey.routine.copyWith(evening: replace(journey.routine.evening)),
    );
    onJourneyChanged(next);
  }
}

class _CabinetPickerSheet extends StatelessWidget {
  final List<LocalCatalogProduct> products;

  const _CabinetPickerSheet({required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: AppColors.shadowStrong, blurRadius: 30)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Assign product', style: AppTextStyles.headlineSmall),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: products
                  .map(
                    (p) => ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onTap: () => Navigator.pop(context, p.id),
                      title: Text(p.name, style: AppTextStyles.titleMedium),
                      subtitle: Text(
                        '${p.brand} · ${p.role}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutinePhaseList extends StatelessWidget {
  final List<RoutineStep> steps;
  final SkinJourneyState journey;
  final ValueChanged<SkinJourneyState> onJourneyChanged;
  final bool isAm;
  final void Function(String stepId) onAssign;

  const _RoutinePhaseList({
    required this.steps,
    required this.journey,
    required this.onJourneyChanged,
    required this.isAm,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return SkinJourneyUi.glassCard(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline_rounded, color: AppColors.primary.withValues(alpha: 0.7)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No steps yet — tap "Add step" to build your routine.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final p = s.catalogProductId != null
            ? LocalSkinCatalog.getById(s.catalogProductId!)
            : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: Key(s.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 18),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            ),
            onDismissed: (_) {
              final list = [...steps]..removeAt(i);
              final next = journey.copyWith(
                routine: isAm
                    ? journey.routine.copyWith(morning: list)
                    : journey.routine.copyWith(evening: list),
              );
              onJourneyChanged(next);
            },
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onAssign(s.id),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                    boxShadow: const [
                      BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p?.name ?? 'Tap to assign product',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: p == null ? AppColors.textTertiary : AppColors.textPrimary,
                                ),
                              ),
                              if (p != null)
                                Text(
                                  p.brand,
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Insights tab ────────────────────────────────────────────────────────────

class InsightsWorkspace extends StatefulWidget {
  final SkinJourneyState journey;
  final OnboardingData profile;
  final SkinAnalysis? analysis;
  final ValueChanged<SkinJourneyState> onJourneyChanged;

  const InsightsWorkspace({
    super.key,
    required this.journey,
    required this.profile,
    required this.analysis,
    required this.onJourneyChanged,
  });

  @override
  State<InsightsWorkspace> createState() => _InsightsWorkspaceState();
}

class _InsightsWorkspaceState extends State<InsightsWorkspace> {
  double _irritation = 1;
  double _breakouts = 1;
  double _moisture = 2;

  @override
  Widget build(BuildContext context) {
    final checkIns = [...widget.journey.checkIns]
      ..sort((a, b) => b.dateIso.compareTo(a.dateIso));

    return Container(
      decoration: SkinJourneyUi.pageGradientBg(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Insights',
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Quick weekly check-ins build a honest picture over time — stored only on this device.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              SkinJourneyUi.glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How your skin feels today', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 16),
                    _sliderRow('Irritation', _irritation, (v) => setState(() => _irritation = v)),
                    _sliderRow('Breakouts', _breakouts, (v) => setState(() => _breakouts = v)),
                    _sliderRow('Comfort / moisture', _moisture, (v) => setState(() => _moisture = v)),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final c = SkinCheckIn(
                            id: _genId(),
                            dateIso: DateTime.now().toIso8601String(),
                            irritation: _irritation.round().clamp(0, 3),
                            breakouts: _breakouts.round().clamp(0, 3),
                            moistureComfort: _moisture.round().clamp(0, 3),
                          );
                          widget.onJourneyChanged(
                            widget.journey.copyWith(
                              checkIns: [c, ...widget.journey.checkIns],
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Check-in saved', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        child: Text('Log check-in', style: AppTextStyles.button),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text('Recent check-ins', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 10),
              if (checkIns.isEmpty)
                Text(
                  'No entries yet.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                )
              else
                ...checkIns.take(8).map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SkinJourneyUi.glassCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c.dateIso.substring(0, 10),
                                  style: AppTextStyles.titleMedium,
                                ),
                              ),
                              Text(
                                'Irr ${c.irritation} · Break ${c.breakouts} · Moist ${c.moistureComfort}',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              Text('Analysis snapshot', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 10),
              SkinJourneyUi.glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score ${widget.analysis?.score ?? '—'}',
                      style: AppTextStyles.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      SkinAnalysisCopy.generalFooter,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sliderRow(String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.labelLarge),
              Text(
                value.round().toString(),
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceVariant,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 3,
              divisions: 3,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile + Cabinet ───────────────────────────────────────────────────────

class CabinetProfileWorkspace extends StatelessWidget {
  final SkinJourneyState journey;
  final OnboardingData profile;
  final ValueChanged<SkinJourneyState> onJourneyChanged;

  const CabinetProfileWorkspace({
    super.key,
    required this.journey,
    required this.profile,
    required this.onJourneyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SkinJourneyUi.pageGradientBg(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cabinet & profile',
                          style: AppTextStyles.displaySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Everything runs offline — your shelf, your rules.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FloatingActionButton.small(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    onPressed: () => _openCatalog(context),
                    child: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SkinJourneyUi.glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your focus', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 12),
                    _miniRow('Goal', profile.primaryGoal ?? '—'),
                    _miniRow('Skin', profile.skinType ?? '—'),
                    _miniRow('Concern', profile.concern ?? '—'),
                    _miniRow('Intent', profile.intentLabel),
                    if (profile.productPreferences.isNotEmpty)
                      _miniRow('Preferences', profile.productPreferences.join(', ')),
                    if (profile.sensitivities.isNotEmpty)
                      _miniRow('Sensitivities', profile.sensitivities.join(', ')),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SkinJourneyUi.sectionHeader('My cabinet'),
              const SizedBox(height: 10),
              if (journey.cabinet.isEmpty)
                SkinJourneyUi.glassCard(
                  child: Text(
                    'Tap + to add products from the built-in catalog. We match ingredients locally to power coach notes.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.45),
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: journey.cabinet.map((c) {
                    final p = LocalSkinCatalog.getById(c.catalogProductId);
                    if (p == null) return const SizedBox.shrink();
                    return GestureDetector(
                      onLongPress: () {
                        final next = journey.copyWith(
                          cabinet: journey.cabinet.where((x) => x.id != c.id).toList(),
                        );
                        onJourneyChanged(next);
                      },
                      child: Container(
                        width: (MediaQuery.sizeOf(context).width - 54) / 2,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
                          boxShadow: const [
                            BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                p.role.toUpperCase(),
                                style: AppTextStyles.labelSmall.copyWith(
                                  letterSpacing: 0.4,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.brand,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),
              Text(
                'Long-press a card to remove',
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: () async {
                  await OnboardingService.clear();
                  await SkinJourneyStorage.clear();
                  if (!context.mounted) return;
                  context.go('/welcome');
                },
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset app data'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCatalog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CatalogBrowserSheet(
        onPick: (product) {
          final item = CabinetItem(
            id: _genId(),
            catalogProductId: product.id,
            addedAtIso: DateTime.now().toIso8601String(),
          );
          if (journey.cabinet.any((c) => c.catalogProductId == product.id)) return;
          onJourneyChanged(
            journey.copyWith(cabinet: [...journey.cabinet, item]),
          );
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Widget _miniRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(k, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
          ),
          Expanded(child: Text(v, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

class _CatalogBrowserSheet extends StatefulWidget {
  final ValueChanged<LocalCatalogProduct> onPick;

  const _CatalogBrowserSheet({required this.onPick});

  @override
  State<_CatalogBrowserSheet> createState() => _CatalogBrowserSheetState();
}

class _CatalogBrowserSheetState extends State<_CatalogBrowserSheet> {
  late List<LocalCatalogProduct> _results;

  @override
  void initState() {
    super.initState();
    _results = LocalSkinCatalog.search('');
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.45,
      builder: (context, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text('Add from catalog', style: AppTextStyles.headlineSmall),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (v) => setState(() {
                    _results = LocalSkinCatalog.search(v);
                  }),
                  decoration: const InputDecoration(
                    hintText: 'Search brand, name, or active…',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  itemCount: _results.length,
                  itemBuilder: (context, i) {
                    final p = _results[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => widget.onPick(p),
                        title: Text(p.name, style: AppTextStyles.titleMedium),
                        subtitle: Text(
                          '${p.brand} · ${p.actives.join(", ")}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
