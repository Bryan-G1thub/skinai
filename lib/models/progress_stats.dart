class ProgressStats {
  final int currentStreak;
  final int bestStreak;
  final double completionRate7d;
  final double completionRate30d;
  final int totalCheckIns;
  final List<String> badgeIds;

  const ProgressStats({
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.completionRate7d = 0,
    this.completionRate30d = 0,
    this.totalCheckIns = 0,
    this.badgeIds = const [],
  });
}
