import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_data.dart';

class OnboardingService {
  static const _kComplete = 'onboarding_complete';
  static const _kData = 'onboarding_data';

  /// Returns true if the user has already completed onboarding.
  static Future<bool> isComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kComplete) ?? false;
  }

  /// Saves the completed onboarding data and marks onboarding as done.
  static Future<void> save(OnboardingData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kComplete, true);
    await prefs.setString(_kData, jsonEncode(data.toJson()));
  }

  /// Loads the saved onboarding data. Returns null if not saved.
  static Future<OnboardingData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kData);
    if (raw == null) return null;
    try {
      return OnboardingData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Clears saved onboarding data (for testing / "reset account").
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kComplete);
    await prefs.remove(_kData);
  }
}
