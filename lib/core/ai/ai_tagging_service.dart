import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'session_tags.dart';
import '../../features/session/data/models/session_answer.dart';

class AiTaggingService {
  AiTaggingService({String? apiKey})
      : _model = apiKey != null && apiKey.isNotEmpty
            ? GenerativeModel(
                model: 'gemini-1.5-flash',
                apiKey: apiKey,
              )
            : null;

  final GenerativeModel? _model;

  bool get isEnabled => _model != null;

  Future<SessionTags> tagSession(List<SessionAnswer> answers) async {
    final model = _model;
    if (model == null || answers.isEmpty) return SessionTags.fallback;

    try {
      final prompt = _buildPrompt(answers);
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      return _parseResponse(text);
    } on Exception {
      return SessionTags.fallback;
    }
  }

  String _buildPrompt(List<SessionAnswer> answers) {
    final buffer = StringBuffer()
      ..writeln(
          'Analyze these mental wellness journal answers. Return ONLY valid JSON.')
      ..writeln(
          'Required format: {"mood":"<positive|neutral|negative|anxious|sad|excited>","topics":["<topic>"],"energy":"<low|medium|high>"}')
      ..writeln()
      ..writeln('Answers:');

    for (var i = 0; i < answers.length; i++) {
      buffer.writeln('${i + 1}. ${answers[i].text}');
    }
    return buffer.toString();
  }

  SessionTags _parseResponse(String text) {
    final jsonStr = _extractJson(text);
    if (jsonStr == null) return SessionTags.fallback;

    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      return SessionTags.fromJson(decoded);
    } on FormatException {
      return SessionTags.fallback;
    }
  }

  String? _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    return text.substring(start, end + 1);
  }
}
