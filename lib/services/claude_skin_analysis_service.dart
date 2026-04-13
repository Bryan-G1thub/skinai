import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/constants/skin_analysis_copy.dart';
import '../models/onboarding_data.dart';
import '../models/skin_analysis.dart';
import '../models/skin_analysis_source.dart';
import 'skin_vision_analysis_service.dart';

const String _proxyUrl = 'https://skinai-proxy.skinai.workers.dev';

class ClaudeSkinAnalysisService implements SkinVisionAnalysisService {
  const ClaudeSkinAnalysisService({
    this.model = 'claude-sonnet-4-6',
    this.endpoint = _proxyUrl,
  });

  final String model;
  final String endpoint;

  static const String _system =
      'You are a professional skin analyst. Analyze the provided information and/or photo and return ONLY a valid JSON object with no markdown, no explanation, just raw JSON.';

  static const String _schema = r'''
Return this exact JSON structure:
{
  "skinType": "oily|dry|combination|normal",
  "concerns": ["acne", "hyperpigmentation", "redness", "texture", "dryness", "oiliness"],
  "overallScore": 72,
  "scores": {
    "acne": 60,
    "pigmentation": 55,
    "hydration": 80,
    "texture": 70,
    "redness": 65
  },
  "summary": "Brief 2-sentence plain-English summary of findings",
  "recommendations": ["Use a gentle cleanser", "Add SPF 30+"]
}
''';

  @override
  Future<SkinAnalysis> analyze(
    OnboardingData data, {
    Uint8List? faceImageBytes,
  }) async {
    final baseline = SkinAnalysis.generate(data);
    try {
      final userPrompt = _buildUserPrompt(data);
      final content = <Map<String, dynamic>>[
        {'type': 'text', 'text': '$userPrompt\n\n$_schema'},
      ];

      final bytes = faceImageBytes;
      if (bytes != null && bytes.isNotEmpty) {
        content.add({
          'type': 'image',
          'source': {
            'type': 'base64',
            'media_type': _guessMediaType(bytes),
            'data': base64Encode(bytes),
          },
        });
      }

      final body = jsonEncode({
        'model': model,
        'max_tokens': 700,
        'system': _system,
        'messages': [
          {
            'role': 'user',
            'content': content,
          }
        ],
      });

      final client = HttpClient();
      final req = await client.postUrl(Uri.parse(endpoint));
      req.headers.set('content-type', 'application/json');
      req.add(utf8.encode(body));

      final res = await req.close();
      final raw = await utf8.decodeStream(res);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        debugPrint('Claude skin analysis failed: ${res.statusCode} $raw');
        return baseline;
      }

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final contentList = decoded['content'];
      final text = _extractFirstText(contentList);
      if (text == null || text.trim().isEmpty) {
        debugPrint('Claude skin analysis: empty content');
        return baseline;
      }

      final parsedJson = _safeJsonObject(text);
      if (parsedJson == null) {
        debugPrint('Claude skin analysis: could not parse JSON: $text');
        return baseline;
      }

      return _toSkinAnalysis(parsedJson, baseline: baseline);
    } catch (e, st) {
      debugPrint('Claude skin analysis error: $e\n$st');
      return baseline;
    }
  }

  String _buildUserPrompt(OnboardingData data) {
    final skinType = data.skinType ?? '';
    final concern = data.concern ?? '';
    final breakouts = data.breakouts ?? '';
    final products = data.currentProducts;

    return '''
Quiz answers:
- skinType: $skinType
- primaryConcern: $concern
- breakouts: $breakouts
- currentProducts: ${products.isEmpty ? '[]' : products.join(' | ')}

If a photo is provided, use it to refine surface-level cues. Stay non-medical and conservative.
'''.trim();
  }

  String _guessMediaType(Uint8List bytes) {
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return 'image/jpeg';
    }
    return 'image/jpeg';
  }

  String? _extractFirstText(dynamic contentList) {
    if (contentList is! List) return null;
    for (final part in contentList) {
      if (part is Map<String, dynamic> && part['type'] == 'text') {
        final t = part['text'];
        if (t is String) return t;
      }
    }
    return null;
  }

  Map<String, dynamic>? _safeJsonObject(String text) {
    try {
      final direct = jsonDecode(text);
      if (direct is Map<String, dynamic>) return direct;
    } catch (_) {}

    // If Claude includes stray characters, attempt to extract the first {...} block.
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    final slice = text.substring(start, end + 1);
    try {
      final extracted = jsonDecode(slice);
      if (extracted is Map<String, dynamic>) return extracted;
    } catch (_) {}
    return null;
  }

  SkinAnalysis _toSkinAnalysis(
    Map<String, dynamic> json, {
    required SkinAnalysis baseline,
  }) {
    final overall = _asInt(json['overallScore']) ?? baseline.score;
    final summary = (json['summary'] as String?)?.trim();
    final recs = (json['recommendations'] as List?)
            ?.whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        const <String>[];

    final conditions = <DetectedCondition>[
      ...baseline.conditions,
      if (summary != null && summary.isNotEmpty)
        DetectedCondition(
          id: 'claude_summary',
          label: 'Summary',
          detail: summary,
          severity: 'mild',
        ),
    ];

    final highlights = <String>[];
    final skinType = (json['skinType'] as String?)?.trim();
    if (skinType != null && skinType.isNotEmpty) highlights.add('Skin type: $skinType');

    final concerns = (json['concerns'] as List?)
            ?.whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        const <String>[];
    if (concerns.isNotEmpty) {
      highlights.add('Concerns: ${concerns.take(4).join(', ')}');
    }

    final scoreNotes = _scoresToHighlights(json['scores']);
    highlights.addAll(scoreNotes);

    final actions = recs.isEmpty ? baseline.priorityActions : recs.take(4).toList();

    return SkinAnalysis(
      score: overall.clamp(30, 95),
      conditions: conditions,
      priorityActions: actions,
      currentProducts: baseline.currentProducts,
      source: SkinAnalysisSource.quizWithPhotoLocalPipeline,
      visionHighlights: highlights.take(6).toList(growable: false),
      consumerDisclaimer: SkinAnalysisCopy.photoPipelineBody,
    );
  }

  List<String> _scoresToHighlights(dynamic scores) {
    if (scores is! Map) return const [];
    final out = <String>[];
    final acne = _asInt(scores['acne']);
    final pigmentation = _asInt(scores['pigmentation']);
    final hydration = _asInt(scores['hydration']);
    final texture = _asInt(scores['texture']);
    final redness = _asInt(scores['redness']);

    void add(String label, int? v) {
      if (v == null) return;
      out.add('$label: $v/100');
    }

    add('Acne', acne);
    add('Pigmentation', pigmentation);
    add('Hydration', hydration);
    add('Texture', texture);
    add('Redness', redness);
    return out;
  }

  int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.round();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }
}

