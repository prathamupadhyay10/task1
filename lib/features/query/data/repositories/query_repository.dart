import '../../../../models/query_model.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/gemini_service.dart';

abstract class QueryRepository {
  Future<String> createQuery({
    required String userId,
    required String title,
    required String description,
  });
  Future<void> updateQuery({
    required String queryId,
    required String title,
    required String description,
  });
  Future<void> deleteQuery(String queryId);
  Stream<List<QueryModel>> getUserQueries(String userId);
  Stream<List<QueryModel>> getAllQueries();
  Stream<List<QueryModel>> getQueriesByPriority(Priority priority);
  Future<void> overridePriority(String queryId, Priority priority);
  Future<AIAnalysisResult> analyzeQuery(String title, String description);
}

class QueryRepositoryImpl implements QueryRepository {
  final FirestoreService _firestoreService;
  final GeminiService _geminiService;

  QueryRepositoryImpl({
    FirestoreService? firestoreService,
    GeminiService? geminiService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _geminiService = geminiService ?? GeminiService();

  @override
  Future<String> createQuery({
    required String userId,
    required String title,
    required String description,
  }) async {
    final analysis = await _geminiService.analyzeQuery(
      title: title,
      description: description,
    );

    final query = QueryModel(
      id: '',
      userId: userId,
      title: title,
      description: description,
      priority: analysis.priority,
      confidence: analysis.confidence,
      reason: analysis.reason,
      mode: QueryMode.AI,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _firestoreService.createQuery(query);
  }

  @override
  Future<void> updateQuery({
    required String queryId,
    required String title,
    required String description,
  }) async {
    final analysis = await _geminiService.analyzeQuery(
      title: title,
      description: description,
    );

    await _firestoreService.updateQuery(queryId, {
      'title': title,
      'description': description,
      'priority': analysis.priority.value,
      'confidence': analysis.confidence,
      'reason': analysis.reason,
      'mode': QueryMode.AI.value,
    });
  }

  @override
  Future<void> deleteQuery(String queryId) {
    return _firestoreService.deleteQuery(queryId);
  }

  @override
  Stream<List<QueryModel>> getUserQueries(String userId) {
    return _firestoreService.getUserQueriesStream(userId);
  }

  @override
  Stream<List<QueryModel>> getAllQueries() {
    return _firestoreService.getAllQueriesStream();
  }

  @override
  Stream<List<QueryModel>> getQueriesByPriority(Priority priority) {
    return _firestoreService.getQueriesByPriorityStream(priority);
  }

  @override
  Future<void> overridePriority(String queryId, Priority priority) {
    return _firestoreService.overridePriority(queryId, priority);
  }

  @override
  Future<AIAnalysisResult> analyzeQuery(String title, String description) {
    return _geminiService.analyzeQuery(title: title, description: description);
  }
}
