import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_skin_catalog.dart';
import '../models/cabinet_item.dart';
import '../models/onboarding_data.dart';
import '../models/routine_plan.dart';
import '../models/skin_journey_state.dart';

const _kJourney = 'skin_journey_v1';

class SkinJourneyStorage {
  SkinJourneyStorage._();

  static Future<SkinJourneyState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kJourney);
    if (raw == null) {
      return SkinJourneyState(cabinet: const [], routine: const RoutinePlan(), checkIns: const []);
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return SkinJourneyState.fromJson(map);
    } catch (_) {
      return SkinJourneyState(cabinet: const [], routine: const RoutinePlan(), checkIns: const []);
    }
  }

  static Future<void> save(SkinJourneyState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kJourney, jsonEncode(state.toJson()));
  }

  /// Merge onboarding product strings into cabinet when we can match catalog.
  static SkinJourneyState mergeOnboardingProducts(
    SkinJourneyState state,
    OnboardingData data,
  ) {
    if (data.currentProducts.isEmpty) return state;
    final existing = state.cabinet.map((c) => c.catalogProductId).toSet();
    final add = <CabinetItem>[];
    for (final line in data.currentProducts) {
      final m = LocalSkinCatalog.matchLoose(line);
      if (m != null && !existing.contains(m.id)) {
        add.add(CabinetItem(
          id: 'cab_${DateTime.now().microsecondsSinceEpoch}_${m.id}',
          catalogProductId: m.id,
          addedAtIso: DateTime.now().toIso8601String(),
        ));
        existing.add(m.id);
      }
    }
    if (add.isEmpty) return state;
    return state.copyWith(cabinet: [...state.cabinet, ...add]);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kJourney);
  }
}
