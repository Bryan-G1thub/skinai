import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/onboarding_data.dart';

/// Anonymous auth + Firestore profile sync for cross-session backup.
/// Requires Anonymous sign-in enabled in Firebase Console.
class UserProfileService {
  UserProfileService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Call after [Firebase.initializeApp]. Safe to fail silently offline.
  static Future<void> initialize() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
    } catch (_) {
      // Auth may be disabled in dev — local prefs still work.
    }
  }

  static User? get currentUser => _auth.currentUser;

  /// Merges onboarding payload into `users/{uid}`.
  static Future<void> syncOnboarding(OnboardingData data) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _db.collection('users').doc(user.uid).set(
        {
          'onboarding': data.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  /// Optional: append analysis history without replacing full onboarding.
  static Future<void> appendAnalysisSnapshot(Map<String, dynamic> analysisJson) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _db.collection('users').doc(user.uid).collection('analysisHistory').add({
        'analysis': analysisJson,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}
