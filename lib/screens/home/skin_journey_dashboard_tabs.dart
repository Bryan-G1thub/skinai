import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
import '../../models/progress_stats.dart';
import '../../models/skin_photo_entry.dart';
import '../../models/skin_journey_state.dart';
import '../../services/onboarding_service.dart';
import '../../services/progress_stats_engine.dart';
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
  final Set<String> _symptomTags = {};
  final _noteController = TextEditingController();
  String? _comparePhotoId;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkIns = [...widget.journey.checkIns]
      ..sort((a, b) => b.dateIso.compareTo(a.dateIso));
    final hasAmPlan = widget.journey.routine.morning.isNotEmpty;
    final hasPmPlan = widget.journey.routine.evening.isNotEmpty;
    final stats = ProgressStatsEngine.build(
      checkIns: widget.journey.checkIns,
      hasAmPlan: hasAmPlan,
      hasPmPlan: hasPmPlan,
    );
    final photos = [...widget.journey.photos]
      ..sort((a, b) => b.createdAtIso.compareTo(a.createdAtIso));
    final latestPhoto = photos.isNotEmpty ? photos.first : null;
    final comparePhoto = _comparePhotoId == null
        ? (photos.length > 1 ? photos[1] : null)
        : photos.where((p) => p.id == _comparePhotoId).firstOrNull;

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
                'Track routine completion and skin changes over time. Everything stays on this device.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              _buildRewards(stats),
              const SizedBox(height: 16),
              _buildCalendar(
                checkIns: widget.journey.checkIns,
                hasAmPlan: hasAmPlan,
                hasPmPlan: hasPmPlan,
              ),
              const SizedBox(height: 22),
              SkinJourneyUi.glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Routine check-in', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 16),
                    _sliderRow('Irritation', _irritation, (v) => setState(() => _irritation = v)),
                    _sliderRow('Breakouts', _breakouts, (v) => setState(() => _breakouts = v)),
                    _sliderRow('Comfort / moisture', _moisture, (v) => setState(() => _moisture = v)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const ['breakout', 'dryness', 'redness', 'new_product_reaction']
                          .map((tag) => FilterChip(
                                label: Text(tag),
                                selected: _symptomTags.contains(tag),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _symptomTags.add(tag);
                                    } else {
                                      _symptomTags.remove(tag);
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Optional note (e.g. breakout on chin after gym)',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        if (hasAmPlan)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _saveCheckIn(CheckInPeriod.am, CheckInStatus.done),
                              child: Text('Done AM', style: AppTextStyles.button),
                            ),
                          ),
                        if (hasAmPlan && hasPmPlan) const SizedBox(width: 8),
                        if (hasPmPlan)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _saveCheckIn(CheckInPeriod.pm, CheckInStatus.done),
                              child: Text('Done PM', style: AppTextStyles.button),
                            ),
                          ),
                      ],
                    ),
                    if (hasAmPlan || hasPmPlan) const SizedBox(height: 8),
                    if (hasAmPlan || hasPmPlan)
                      Row(
                        children: [
                          if (hasAmPlan)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _saveCheckIn(CheckInPeriod.am, CheckInStatus.skipped),
                                child: const Text('Skip AM'),
                              ),
                            ),
                          if (hasAmPlan && hasPmPlan) const SizedBox(width: 8),
                          if (hasPmPlan)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _saveCheckIn(CheckInPeriod.pm, CheckInStatus.skipped),
                                child: const Text('Skip PM'),
                              ),
                            ),
                        ],
                      ),
                    if (!hasAmPlan && !hasPmPlan)
                      Text(
                        'Add AM/PM routine steps in the Routine tab to enable completion tracking.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text('Photo timeline', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 10),
              SkinJourneyUi.glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Local-only photos for progress checks',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _addPhoto,
                          icon: const Icon(Icons.add_a_photo_outlined),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (latestPhoto == null)
                      Text('No photos yet.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary))
                    else
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _photoCard('Latest', latestPhoto)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: comparePhoto == null
                                    ? Container()
                                    : _photoCard('Compare', comparePhoto),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 84,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (_, i) {
                                final p = photos[i];
                                final selected = p.id == _comparePhotoId;
                                return GestureDetector(
                                  onTap: () => setState(() => _comparePhotoId = p.id),
                                  child: Container(
                                    width: 84,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: selected ? AppColors.primary : AppColors.border,
                                      ),
                                      image: DecorationImage(
                                        image: FileImage(File(p.path)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemCount: photos.length,
                            ),
                          ),
                        ],
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
                ...checkIns.take(10).map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SkinJourneyUi.glassCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${c.dateIso.substring(0, 10)} · ${c.period.name.toUpperCase()}',
                                      style: AppTextStyles.titleMedium,
                                    ),
                                  ),
                                  Text(
                                    c.status == CheckInStatus.done ? 'Done' : 'Skipped',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: c.status == CheckInStatus.done ? AppColors.success : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Irr ${c.irritation} · Break ${c.breakouts} · Moist ${c.moistureComfort}',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                              if ((c.note ?? '').trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(c.note!.trim(), style: AppTextStyles.bodySmall),
                              ],
                              if (c.symptomTags.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: c.symptomTags
                                      .map((t) => Chip(
                                            label: Text(t),
                                            visualDensity: VisualDensity.compact,
                                          ))
                                      .toList(),
                                ),
                              ],
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

  Widget _buildRewards(ProgressStats stats) {
    return SkinJourneyUi.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress rewards', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metricTile('Current streak', '${stats.currentStreak} days')),
              const SizedBox(width: 8),
              Expanded(child: _metricTile('Best streak', '${stats.bestStreak} days')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _metricTile('7d consistency', '${(stats.completionRate7d * 100).round()}%')),
              const SizedBox(width: 8),
              Expanded(child: _metricTile('30d consistency', '${(stats.completionRate30d * 100).round()}%')),
            ],
          ),
          if (stats.badgeIds.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats.badgeIds.map((b) => Chip(label: Text(_badgeLabel(b)))).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }

  Widget _buildCalendar({
    required List<SkinCheckIn> checkIns,
    required bool hasAmPlan,
    required bool hasPmPlan,
  }) {
    final now = DateTime.now();
    final byDay = <String, List<SkinCheckIn>>{};
    for (final c in checkIns) {
      final day = c.dateIso.substring(0, 10);
      byDay.putIfAbsent(day, () => []).add(c);
    }
    final days = List.generate(14, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: i))).reversed.toList();
    return SkinJourneyUi.glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last 14 days', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: days.map((d) {
              final key = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
              final entries = byDay[key] ?? const <SkinCheckIn>[];
              final am = _periodState(entries, CheckInPeriod.am, hasAmPlan);
              final pm = _periodState(entries, CheckInPeriod.pm, hasPmPlan);
              return Container(
                width: 46,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text('${d.day}', style: AppTextStyles.labelSmall),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _periodDot(am),
                        const SizedBox(width: 4),
                        _periodDot(pm),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text('Dots: AM then PM', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Color _periodState(List<SkinCheckIn> entries, CheckInPeriod period, bool planned) {
    if (!planned) return AppColors.border;
    final hit = entries.where((e) => e.period == period).toList();
    if (hit.any((e) => e.status == CheckInStatus.done)) return AppColors.success;
    if (hit.any((e) => e.status == CheckInStatus.skipped)) return AppColors.warning;
    return AppColors.textTertiary;
  }

  Widget _periodDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Future<void> _saveCheckIn(CheckInPeriod period, CheckInStatus status) async {
    final note = _noteController.text.trim();
    final c = SkinCheckIn(
      id: _genId(),
      dateIso: DateTime.now().toIso8601String(),
      period: period,
      status: status,
      planned: true,
      irritation: _irritation.round().clamp(0, 3),
      breakouts: _breakouts.round().clamp(0, 3),
      moistureComfort: _moisture.round().clamp(0, 3),
      note: note.isEmpty ? null : note,
      symptomTags: _symptomTags.toList()..sort(),
    );
    widget.onJourneyChanged(
      widget.journey.copyWith(
        checkIns: [c, ...widget.journey.checkIns],
      ),
    );
    _noteController.clear();
    _symptomTags.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Check-in saved', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
    setState(() {});
  }

  Future<void> _addPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final entry = SkinPhotoEntry(
      id: _genId(),
      path: picked.path,
      createdAtIso: DateTime.now().toIso8601String(),
      note: null,
      linkedCheckInId: null,
    );
    widget.onJourneyChanged(
      widget.journey.copyWith(photos: [entry, ...widget.journey.photos]),
    );
    if (!mounted) return;
    setState(() {
      _comparePhotoId ??= entry.id;
    });
  }

  Widget _photoCard(String label, SkinPhotoEntry photo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(photo.path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _badgeLabel(String id) {
    switch (id) {
      case 'streak_3':
        return '3-day streak';
      case 'streak_7':
        return '7-day streak';
      case 'consistency_75':
        return '75% consistency';
      case 'checkin_20':
        return '20 check-ins';
      default:
        return id;
    }
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
