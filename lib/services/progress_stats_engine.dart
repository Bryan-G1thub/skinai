import '../models/progress_stats.dart';
import '../models/skin_check_in.dart';

class ProgressStatsEngine {
  ProgressStatsEngine._();

  static ProgressStats build({
    required List<SkinCheckIn> checkIns,
    required bool hasAmPlan,
    required bool hasPmPlan,
    DateTime? now,
  }) {
    final today = DateTime(now?.year ?? DateTime.now().year, now?.month ?? DateTime.now().month, now?.day ?? DateTime.now().day);
    final byDay = _groupByDay(checkIns);
    final current = _computeCurrentStreak(byDay: byDay, today: today, hasAmPlan: hasAmPlan, hasPmPlan: hasPmPlan);
    final best = _computeBestStreak(byDay: byDay, hasAmPlan: hasAmPlan, hasPmPlan: hasPmPlan);
    final rate7 = _completionRate(byDay: byDay, days: 7, today: today, hasAmPlan: hasAmPlan, hasPmPlan: hasPmPlan);
    final rate30 = _completionRate(byDay: byDay, days: 30, today: today, hasAmPlan: hasAmPlan, hasPmPlan: hasPmPlan);
    final badges = <String>[
      if (current >= 3) 'streak_3',
      if (current >= 7) 'streak_7',
      if (rate30 >= 0.75) 'consistency_75',
      if (checkIns.length >= 20) 'checkin_20',
    ];
    return ProgressStats(
      currentStreak: current,
      bestStreak: best,
      completionRate7d: rate7,
      completionRate30d: rate30,
      totalCheckIns: checkIns.length,
      badgeIds: badges,
    );
  }

  static Map<String, List<SkinCheckIn>> _groupByDay(List<SkinCheckIn> checkIns) {
    final map = <String, List<SkinCheckIn>>{};
    for (final c in checkIns) {
      final day = c.dateIso.length >= 10 ? c.dateIso.substring(0, 10) : c.dateIso;
      map.putIfAbsent(day, () => []).add(c);
    }
    return map;
  }

  static int _computeCurrentStreak({
    required Map<String, List<SkinCheckIn>> byDay,
    required DateTime today,
    required bool hasAmPlan,
    required bool hasPmPlan,
  }) {
    var streak = 0;
    for (var i = 0; i < 3650; i++) {
      final day = today.subtract(Duration(days: i));
      if (_isDayComplete(byDay[_isoDay(day)] ?? const [], hasAmPlan: hasAmPlan, hasPmPlan: hasPmPlan)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static int _computeBestStreak({
    required Map<String, List<SkinCheckIn>> byDay,
    required bool hasAmPlan,
    required bool hasPmPlan,
  }) {
    final days = byDay.keys.toList()..sort();
    var best = 0;
    var run = 0;
    DateTime? prev;
    for (final key in days) {
      final day = DateTime.tryParse(key);
      if (day == null) continue;
      final complete = _isDayComplete(byDay[key] ?? const [], hasAmPlan: hasAmPlan, hasPmPlan: hasPmPlan);
      if (!complete) {
        run = 0;
        prev = day;
        continue;
      }
      if (prev == null || day.difference(prev).inDays == 1) {
        run += 1;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      prev = day;
    }
    return best;
  }

  static double _completionRate({
    required Map<String, List<SkinCheckIn>> byDay,
    required int days,
    required DateTime today,
    required bool hasAmPlan,
    required bool hasPmPlan,
  }) {
    var plannedSlots = 0;
    var doneSlots = 0;
    for (var i = 0; i < days; i++) {
      final day = today.subtract(Duration(days: i));
      final entries = byDay[_isoDay(day)] ?? const <SkinCheckIn>[];
      if (hasAmPlan) {
        plannedSlots++;
        if (_isPeriodDone(entries, CheckInPeriod.am)) doneSlots++;
      }
      if (hasPmPlan) {
        plannedSlots++;
        if (_isPeriodDone(entries, CheckInPeriod.pm)) doneSlots++;
      }
    }
    if (plannedSlots == 0) return 0;
    return doneSlots / plannedSlots;
  }

  static bool _isDayComplete(
    List<SkinCheckIn> entries, {
    required bool hasAmPlan,
    required bool hasPmPlan,
  }) {
    final amOk = !hasAmPlan || _isPeriodDone(entries, CheckInPeriod.am);
    final pmOk = !hasPmPlan || _isPeriodDone(entries, CheckInPeriod.pm);
    return amOk && pmOk;
  }

  static bool _isPeriodDone(List<SkinCheckIn> entries, CheckInPeriod period) {
    for (final e in entries) {
      if (e.period == period && e.status == CheckInStatus.done && e.planned) {
        return true;
      }
    }
    return false;
  }

  static String _isoDay(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
