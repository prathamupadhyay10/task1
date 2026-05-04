import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/query_repository.dart';
import '../../../../models/query_model.dart';
import 'query_event.dart';
import 'query_state.dart';

class QueryBloc extends Bloc<QueryEvent, QueryState> {
  final QueryRepository _queryRepository;
  String? _currentUserId;
  Priority? _currentFilter;
  List<QueryModel> _allQueries = const [];

  QueryBloc({required QueryRepository queryRepository})
      : _queryRepository = queryRepository,
        super(const QueryState.initial()) {
    on<QueryCreateRequested>(_onCreateRequested);
    on<QueryUpdateRequested>(_onUpdateRequested);
    on<QueryDeleteRequested>(_onDeleteRequested);
    on<QueryFetchUserRequested>(_onFetchUserRequested);
    on<QueryFetchAllRequested>(_onFetchAllRequested);
    on<QueryFilterByPriority>(_onFilterByPriority);
    on<QueryOverridePriority>(_onOverridePriority);
    on<QueryAIAnalyzeRequested>(_onAIAnalyzeRequested);
  }

  Future<void> _onCreateRequested(
    QueryCreateRequested event,
    Emitter<QueryState> emit,
  ) async {
    emit(QueryState.creating());
    try {
      await _queryRepository.createQuery(
        userId: event.userId,
        title: event.title,
        description: event.description,
      );
      if (_currentUserId != null) {
        _currentUserId = event.userId;
      }
      emit(QueryState.created());
      if (_currentUserId != null) {
        add(QueryFetchUserRequested(userId: _currentUserId!));
      } else {
        add(QueryFetchAllRequested());
      }
    } catch (e) {
      emit(QueryState.error(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    QueryUpdateRequested event,
    Emitter<QueryState> emit,
  ) async {
    emit(QueryState.updating());
    try {
      await _queryRepository.updateQuery(
        queryId: event.queryId,
        title: event.title,
        description: event.description,
      );
      emit(QueryState.updated());
      if (_currentUserId != null) {
        add(QueryFetchUserRequested(userId: _currentUserId!));
      } else {
        add(QueryFetchAllRequested());
      }
    } catch (e) {
      emit(QueryState.error(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    QueryDeleteRequested event,
    Emitter<QueryState> emit,
  ) async {
    emit(QueryState.deleting());
    try {
      await _queryRepository.deleteQuery(event.queryId);
      emit(QueryState.deleted());
      if (_currentUserId != null) {
        add(QueryFetchUserRequested(userId: _currentUserId!));
      } else {
        add(QueryFetchAllRequested());
      }
    } catch (e) {
      emit(QueryState.error(e.toString()));
    }
  }

  Future<void> _onFetchUserRequested(
    QueryFetchUserRequested event,
    Emitter<QueryState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(const QueryState(status: QueryStatus.loading, queries: []));

    await emit.forEach<List<QueryModel>>(
      _queryRepository.getUserQueries(event.userId),
      onData: (queries) {
        _allQueries = queries;
        return QueryState(
          status: QueryStatus.success,
          queries: _applyFilter(queries),
          filterPriority: _currentFilter,
        );
      },
      onError: (e, _) {
        return state.copyWith(
          status: QueryStatus.error,
          errorMessage: e.toString(),
        );
      },
    );
  }

  Future<void> _onFetchAllRequested(
    QueryFetchAllRequested event,
    Emitter<QueryState> emit,
  ) async {
    emit(const QueryState(status: QueryStatus.loading, queries: []));

    await emit.forEach<List<QueryModel>>(
      _queryRepository.getAllQueries(),
      onData: (queries) {
        _allQueries = queries;
        return QueryState(
          status: QueryStatus.success,
          queries: _applyFilter(queries),
          filterPriority: _currentFilter,
        );
      },
      onError: (e, _) {
        return state.copyWith(
          status: QueryStatus.error,
          errorMessage: e.toString(),
        );
      },
    );
  }

  void _onFilterByPriority(
    QueryFilterByPriority event,
    Emitter<QueryState> emit,
  ) {
    _currentFilter = event.priority;
    emit(state.copyWith(
      filterPriority: event.priority,
      queries: _applyFilter(_allQueries),
    ));
  }

  Future<void> _onOverridePriority(
    QueryOverridePriority event,
    Emitter<QueryState> emit,
  ) async {
    emit(state.copyWith(status: QueryStatus.updating));
    try {
      await _queryRepository.overridePriority(event.queryId, event.priority);
    } catch (e) {
      emit(QueryState.error(e.toString()));
    }
  }

  Future<void> _onAIAnalyzeRequested(
    QueryAIAnalyzeRequested event,
    Emitter<QueryState> emit,
  ) async {
    emit(state.copyWith(isAnalyzing: true));
    try {
      final result = await _queryRepository.analyzeQuery(
        event.title,
        event.description,
      );
      emit(state.copyWith(
        analysisResult: result,
        isAnalyzing: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        analysisResult: null,
        isAnalyzing: false,
      ));
    }
  }

  List<QueryModel> _applyFilter(List<QueryModel> queries) {
    if (_currentFilter == null) return queries;
    return queries.where((query) => query.priority == _currentFilter).toList();
  }
}
