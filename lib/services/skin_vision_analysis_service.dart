import 'dart:typed_data';

import '../core/constants/skin_analysis_copy.dart';
import '../models/onboarding_data.dart';
import '../models/skin_analysis.dart';
import '../models/skin_analysis_source.dart';

/// Contract for turning a profile + optional face photo into [SkinAnalysis].
/// Swap implementations when wiring a remote vision API.
abstract class SkinVisionAnalysisService {
  Future<SkinAnalysis> analyze(
    OnboardingData data, {
    Uint8List? faceImageBytes,
  });
}

/// Local pipeline: quiz-derived baseline + deterministic photo-derived overlays
/// (hash of image bytes). Replace with a real API implementation later.
class LocalSkinVisionAnalysisService implements SkinVisionAnalysisService {
  const LocalSkinVisionAnalysisService();

  @override
  Future<SkinAnalysis> analyze(
    OnboardingData data, {
    Uint8List? faceImageBytes,
  }) async {
    final base = SkinAnalysis.generate(data);
    if (faceImageBytes == null || faceImageBytes.isEmpty) {
      return base;
    }

    final sig = _signature(faceImageBytes);
    return _mergePhotoSignals(base, sig);
  }

  /// Stable fingerprint from image bytes (not cryptographic).
  int _signature(List<int> bytes) {
    if (bytes.isEmpty) return 0;
    var h = 0;
    final n = bytes.length < 2048 ? bytes.length : 2048;
    for (var i = 0; i < n; i++) {
      h = (h * 31 + bytes[i]) & 0x7fffffff;
    }
    return h ^ bytes.length;
  }

  SkinAnalysis _mergePhotoSignals(SkinAnalysis base, int sig) {
    final extra = <DetectedCondition>[];
    final existingIds = base.conditions.map((c) => c.id).toSet();

    // Deterministic “surface cue” overlays — stand in for real vision outputs.
    final pool = <DetectedCondition>[
      const DetectedCondition(
        id: 'surface_texture',
        label: 'Surface texture variation',
        detail: 'Estimated from lighting and contrast in your photo',
        severity: 'mild',
      ),
      const DetectedCondition(
        id: 'tone_evenness',
        label: 'Tone evenness',
        detail: 'Relative evenness vs shadow regions (estimated)',
        severity: 'mild',
      ),
      const DetectedCondition(
        id: 'reflectance',
        label: 'Surface reflectance',
        detail: 'Shine vs matte balance in the image (estimated)',
        severity: 'mild',
      ),
    ];

    final pick = sig % pool.length;
    final second = (pick + 1) % pool.length;
    for (final i in {pick, second}) {
      final c = pool[i];
      if (!existingIds.contains(c.id)) {
        extra.add(c);
        existingIds.add(c.id);
      }
    }

    final merged = [...base.conditions, ...extra];
    var score = base.score;
    score = (score + (sig % 7) - 3).clamp(30, 95);

    final actions = List<String>.from(base.priorityActions);
    if (extra.any((e) => e.id == 'reflectance')) {
      actions.insert(
        0,
        'If your skin looks shiny in photos, consider blotting papers or a lighter daytime moisturizer.',
      );
    }
    final trimmed = actions.take(4).toList();

    return SkinAnalysis(
      score: score,
      conditions: merged,
      priorityActions: trimmed,
      currentProducts: base.currentProducts,
      source: SkinAnalysisSource.quizWithPhotoLocalPipeline,
      visionHighlights: extra
          .map((e) => e.label)
          .toList(growable: false),
      consumerDisclaimer: SkinAnalysisCopy.photoPipelineBody,
    );
  }
}
