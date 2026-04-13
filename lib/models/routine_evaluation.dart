enum EvaluationTone { positive, gap, caution }

class RoutineInsight {
  final EvaluationTone tone;
  final String title;
  final String detail;

  const RoutineInsight({
    required this.tone,
    required this.title,
    required this.detail,
  });
}
