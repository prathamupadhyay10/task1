import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/query_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createQuery(QueryModel query) async {
    final docRef = await _firestore.collection('queries').add(query.toJson());
    return docRef.id;
  }

  Future<void> updateQuery(String queryId, Map<String, dynamic> data) async {
    await _firestore.collection('queries').doc(queryId).update({
      ...data,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteQuery(String queryId) async {
    await _firestore.collection('queries').doc(queryId).delete();
  }

  Future<QueryModel?> getQuery(String queryId) async {
    final doc = await _firestore.collection('queries').doc(queryId).get();
    if (!doc.exists) return null;
    return QueryModel.fromJson(doc.data()!, doc.id);
  }

  Stream<List<QueryModel>> getUserQueriesStream(String userId) {
    return _firestore
        .collection('queries')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => _sortByNewest(snapshot.docs
            .map((doc) => QueryModel.fromJson(doc.data(), doc.id))
            .toList()));
  }

  Stream<List<QueryModel>> getAllQueriesStream() {
    return _firestore
        .collection('queries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QueryModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<List<QueryModel>> getQueriesByPriorityStream(Priority priority) {
    return _firestore
        .collection('queries')
        .where('priority', isEqualTo: priority.value)
        .snapshots()
        .map((snapshot) => _sortByNewest(snapshot.docs
            .map((doc) => QueryModel.fromJson(doc.data(), doc.id))
            .toList()));
  }

  Future<void> overridePriority(
    String queryId,
    Priority priority,
  ) async {
    await _firestore.collection('queries').doc(queryId).update({
      'priority': priority.value,
      'mode': QueryMode.MANUAL.value,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  List<QueryModel> _sortByNewest(List<QueryModel> queries) {
    queries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return queries;
  }
}
