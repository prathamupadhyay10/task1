import 'package:equatable/equatable.dart';
import '../../../../models/query_model.dart';

abstract class QueryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class QueryCreateRequested extends QueryEvent {
  final String userId;
  final String title;
  final String description;

  QueryCreateRequested({
    required this.userId,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [userId, title, description];
}

class QueryUpdateRequested extends QueryEvent {
  final String queryId;
  final String title;
  final String description;

  QueryUpdateRequested({
    required this.queryId,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [queryId, title, description];
}

class QueryDeleteRequested extends QueryEvent {
  final String queryId;

  QueryDeleteRequested({required this.queryId});

  @override
  List<Object?> get props => [queryId];
}

class QueryFetchUserRequested extends QueryEvent {
  final String userId;

  QueryFetchUserRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class QueryFetchAllRequested extends QueryEvent {}

class QueryFilterByPriority extends QueryEvent {
  final Priority? priority;

  QueryFilterByPriority({this.priority});

  @override
  List<Object?> get props => [priority];
}

class QueryOverridePriority extends QueryEvent {
  final String queryId;
  final Priority priority;

  QueryOverridePriority({required this.queryId, required this.priority});

  @override
  List<Object?> get props => [queryId, priority];
}

class QueryAIAnalyzeRequested extends QueryEvent {
  final String title;
  final String description;

  QueryAIAnalyzeRequested({required this.title, required this.description});

  @override
  List<Object?> get props => [title, description];
}
