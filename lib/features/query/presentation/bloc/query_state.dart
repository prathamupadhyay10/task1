import 'package:equatable/equatable.dart';
import '../../../../models/query_model.dart';

enum QueryStatus { initial, loading, success, error, creating, updating, deleting }

class QueryState extends Equatable {
  final QueryStatus status;
  final List<QueryModel> queries;
  final QueryModel? selectedQuery;
  final Priority? filterPriority;
  final String? errorMessage;
  final AIAnalysisResult? analysisResult;
  final bool isAnalyzing;

  const QueryState({
    this.status = QueryStatus.initial,
    this.queries = const [],
    this.selectedQuery,
    this.filterPriority,
    this.errorMessage,
    this.analysisResult,
    this.isAnalyzing = false,
  });

  const QueryState.initial()
      : status = QueryStatus.initial,
        queries = const [],
        selectedQuery = null,
        filterPriority = null,
        errorMessage = null,
        analysisResult = null,
        isAnalyzing = false;

  factory QueryState.loading() {
    return const QueryState(status: QueryStatus.loading);
  }

  factory QueryState.success(List<QueryModel> queries) {
    return QueryState(
      status: QueryStatus.success,
      queries: queries,
    );
  }

  factory QueryState.creating() {
    return const QueryState(status: QueryStatus.creating);
  }

  factory QueryState.created() {
    return const QueryState(status: QueryStatus.success);
  }

  factory QueryState.updating() {
    return const QueryState(status: QueryStatus.updating);
  }

  factory QueryState.updated() {
    return const QueryState(status: QueryStatus.success);
  }

  factory QueryState.deleting() {
    return const QueryState(status: QueryStatus.deleting);
  }

  factory QueryState.deleted() {
    return const QueryState(status: QueryStatus.success);
  }

  factory QueryState.error(String message) {
    return QueryState(
      status: QueryStatus.error,
      errorMessage: message,
    );
  }

  factory QueryState.analyzing() {
    return const QueryState(isAnalyzing: true);
  }

  factory QueryState.analyzed(AIAnalysisResult result) {
    return QueryState(
      analysisResult: result,
      isAnalyzing: false,
    );
  }

  QueryState copyWith({
    QueryStatus? status,
    List<QueryModel>? queries,
    QueryModel? selectedQuery,
    Priority? filterPriority,
    String? errorMessage,
    AIAnalysisResult? analysisResult,
    bool? isAnalyzing,
  }) {
    return QueryState(
      status: status ?? this.status,
      queries: queries ?? this.queries,
      selectedQuery: selectedQuery ?? this.selectedQuery,
      filterPriority: filterPriority ?? this.filterPriority,
      errorMessage: errorMessage ?? this.errorMessage,
      analysisResult: analysisResult ?? this.analysisResult,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    );
  }

  @override
  List<Object?> get props => [
        status,
        queries,
        selectedQuery,
        filterPriority,
        errorMessage,
        analysisResult,
        isAnalyzing,
      ];
}
