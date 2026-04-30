import 'package:dio/dio.dart';
import '../models/query_model.dart';
import '../core/constants/app_constants.dart';

class GeminiService {
  final Dio _dio;

  GeminiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: Duration(milliseconds: AppConstants.apiTimeout),
              receiveTimeout: Duration(milliseconds: AppConstants.apiTimeout),
              headers: {'Content-Type': 'application/json'},
            ));

  Future<AIAnalysisResult> analyzeQuery({
    required String title,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent',
        queryParameters: {'key': AppConstants.geminiApiKey},
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {
                  'text':
                      'Analyze this query and return ONLY valid JSON with no markdown formatting, no code blocks, no backticks. Just raw JSON.\n{\"priority\": \"HIGH\" or \"MEDIUM\" or \"LOW\", \"confidence\": 0.0 to 1.0, \"reason\": \"short reason\"}\nQuery Title: $title\nQuery Description: $description',
                },
              ],
            },
          ],
          'generationConfig': {
            'thinkingConfig': {
              'thinkingBudget': 0,
            },
            'temperature': 0.1,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final text = _extractTextFromResponse(data);
        return _parseAIResponse(text);
      } else {
        return AIAnalysisResult.fallback();
      }
    } catch (e) {
      return AIAnalysisResult.fallback();
    }
  }

  String _extractTextFromResponse(Map<String, dynamic> data) {
    try {
      final candidates = data['candidates'] as List;
      if (candidates.isEmpty) return '';

      final content = candidates[0]['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List;
      if (parts.isEmpty) return '';

      return parts[0]['text'] as String;
    } catch (e) {
      return '';
    }
  }

  AIAnalysisResult _parseAIResponse(String text) {
    try {
      final cleaned = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .replaceAll('\n', '')
          .trim();

      final startIndex = cleaned.indexOf('{');
      final endIndex = cleaned.lastIndexOf('}');

      if (startIndex == -1 || endIndex == -1) {
        return AIAnalysisResult.fallback();
      }

      final jsonString = cleaned.substring(startIndex, endIndex + 1);

      Map<String, dynamic> json;
      try {
        json = _simpleJsonParse(jsonString);
      } catch (e) {
        return AIAnalysisResult.fallback();
      }

      if (!json.containsKey('priority')) {
        return AIAnalysisResult.fallback();
      }

      return AIAnalysisResult.fromJson(json);
    } catch (e) {
      return AIAnalysisResult.fallback();
    }
  }

  Map<String, dynamic> _simpleJsonParse(String jsonString) {
    final map = <String, dynamic>{};

    String inner = jsonString.trim();
    if (inner.startsWith('{')) inner = inner.substring(1);
    if (inner.endsWith('}')) inner = inner.substring(0, inner.length - 1);
    inner = inner.trim();

    if (inner.isEmpty) return map;

    final pairs = _splitJsonPairs(inner);

    for (final pair in pairs) {
      final trimmed = pair.trim();
      if (trimmed.isEmpty) continue;

      final colonIndex = trimmed.indexOf(':');
      if (colonIndex == -1) continue;

      var key = trimmed.substring(0, colonIndex).trim();
      if (key.startsWith('"')) key = key.substring(1);
      if (key.endsWith('"')) key = key.substring(0, key.length - 1);

      var value = trimmed.substring(colonIndex + 1).trim();
      if (value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
        map[key] = value;
      } else if (value.contains('.')) {
        map[key] = double.tryParse(value) ?? 0.5;
      } else {
        map[key] = int.tryParse(value)?.toDouble() ?? 0.5;
      }
    }

    return map;
  }

  List<String> _splitJsonPairs(String str) {
    final result = <String>[];
    int depth = 0;
    bool inString = false;
    int lastSplit = 0;

    for (int i = 0; i < str.length; i++) {
      final char = str[i];

      if (char == '"' && (i == 0 || str[i - 1] != '\\')) {
        inString = !inString;
      }

      if (!inString) {
        if (char == '{' || char == '[') {
          depth++;
        } else if (char == '}' || char == ']') {
          depth--;
        } else if (char == ',' && depth == 0) {
          result.add(str.substring(lastSplit, i));
          lastSplit = i + 1;
        }
      }
    }

    if (lastSplit < str.length) {
      result.add(str.substring(lastSplit));
    }

    return result;
  }
}
