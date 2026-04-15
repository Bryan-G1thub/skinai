import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_skin_catalog.dart';
import '../models/cabinet_item.dart';
import '../models/onboarding_data.dart';
import '../models/routine_plan.dart';
import '../models/skin_journey_state.dart';

const _kJourneyV2 = 'skin_journey_v2';
const _kJourneyV1 = 'skin_journey_v1';

class SkinJourneyStorage {
  SkinJourneyStorage._();

  static Future<SkinJourneyState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawV2 = prefs.getString(_kJourneyV2);
    final raw = rawV2 ?? prefs.getString(_kJourneyV1);
    if (raw == null) {
      return SkinJourneyState(
        cabinet: const [],
        routine: const RoutinePlan(),
        checkIns: const [],
        photos: const [],
      );
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final state = SkinJourneyState.fromJson(map);
      if (rawV2 == null) {
        await save(state);
      }
      return state;
    } catch (_) {
      return SkinJourneyState(
        cabinet: const [],
        routine: const RoutinePlan(),
        checkIns: const [],
        photos: const [],
      );
    }
  }

  static Future<void> save(SkinJourneyState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kJourneyV2, jsonEncode(state.toJson()));
  }

  /// Merge onboarding routine slots and free-text products into cabinet when we can match catalog.
  static SkinJourneyState mergeOnboardingProducts(
    SkinJourneyState state,
    OnboardingData data,
  ) {
    final existing = state.cabinet.map((c) => c.catalogProductId).toSet();
    final add = <CabinetItem>[];

    for (final slot in data.routineSlots) {
      final id = slot.catalogProductId;
      if (id != null && id.isNotEmpty && !existing.contains(id)) {
        final m = LocalSkinCatalog.getById(id);
        if (m != null) {
          add.add(CabinetItem(
            id: 'cab_${DateTime.now().microsecondsSinceEpoch}_${m.id}',
            catalogProductId: m.id,
            addedAtIso: DateTime.now().toIso8601String(),
          ));
          existing.add(m.id);
        }
      }
    }

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
    await prefs.remove(_kJourneyV2);
    await prefs.remove(_kJourneyV1);
  }
}
