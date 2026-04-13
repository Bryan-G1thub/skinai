/// How [SkinAnalysis] was produced — drives honest UI copy.
enum SkinAnalysisSource {
  /// Profile inferred only from quiz answers (no face image in pipeline).
  quizOnly,

  /// Quiz + local on-device pipeline using the photo file (stub until a remote vision API is integrated).
  quizWithPhotoLocalPipeline,
}
