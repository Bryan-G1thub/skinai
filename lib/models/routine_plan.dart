import 'routine_step.dart';

class RoutinePlan {
  final List<RoutineStep> morning;
  final List<RoutineStep> evening;

  const RoutinePlan({
    this.morning = const [],
    this.evening = const [],
  });

  RoutinePlan copyWith({
    List<RoutineStep>? morning,
    List<RoutineStep>? evening,
  }) {
    return RoutinePlan(
      morning: morning ?? this.morning,
      evening: evening ?? this.evening,
    );
  }

  Map<String, dynamic> toJson() => {
        'morning': morning.map((e) => e.toJson()).toList(),
        'evening': evening.map((e) => e.toJson()).toList(),
      };

  factory RoutinePlan.fromJson(Map<String, dynamic> json) => RoutinePlan(
        morning: (json['morning'] as List?)
                ?.map((e) => RoutineStep.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        evening: (json['evening'] as List?)
                ?.map((e) => RoutineStep.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
