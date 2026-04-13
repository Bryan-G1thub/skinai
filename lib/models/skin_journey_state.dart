import 'cabinet_item.dart';
import 'routine_plan.dart';
import 'skin_check_in.dart';

class SkinJourneyState {
  final List<CabinetItem> cabinet;
  final RoutinePlan routine;
  final List<SkinCheckIn> checkIns;

  const SkinJourneyState({
    this.cabinet = const [],
    this.routine = const RoutinePlan(),
    this.checkIns = const [],
  });

  SkinJourneyState copyWith({
    List<CabinetItem>? cabinet,
    RoutinePlan? routine,
    List<SkinCheckIn>? checkIns,
  }) {
    return SkinJourneyState(
      cabinet: cabinet ?? this.cabinet,
      routine: routine ?? this.routine,
      checkIns: checkIns ?? this.checkIns,
    );
  }

  Map<String, dynamic> toJson() => {
        'cabinet': cabinet.map((e) => e.toJson()).toList(),
        'routine': routine.toJson(),
        'checkIns': checkIns.map((e) => e.toJson()).toList(),
      };

  factory SkinJourneyState.fromJson(Map<String, dynamic> json) {
    return SkinJourneyState(
      cabinet: (json['cabinet'] as List?)
              ?.map((e) => CabinetItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      routine: json['routine'] != null
          ? RoutinePlan.fromJson(json['routine'] as Map<String, dynamic>)
          : const RoutinePlan(),
      checkIns: (json['checkIns'] as List?)
              ?.map((e) => SkinCheckIn.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
