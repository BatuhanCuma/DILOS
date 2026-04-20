import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_tagging_service.dart';

const _geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);

final aiTaggingServiceProvider = Provider<AiTaggingService>((ref) {
  return AiTaggingService(apiKey: _geminiApiKey);
});
