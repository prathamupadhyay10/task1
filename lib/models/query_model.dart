import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { HIGH, MEDIUM, LOW }

enum QueryMode { AI, MANUAL }

extension PriorityExtension on Priority {
  String get value {
    switch (this) {
      case Priority.HIGH:
        return 'HIGH';
      case Priority.MEDIUM:
        return 'MEDIUM';
      case Priority.LOW:
        return 'LOW';
    }
  }

  static Priority fromString(String value) {
    switch (value.toUpperCase()) {
      case 'HIGH':
        return Priority.HIGH;
      case 'MEDIUM':
        return Priority.MEDIUM;
      case 'LOW':
        return Priority.LOW;
      default:
        return Priority.MEDIUM;
    }
  }
}

extension QueryModeExtension on QueryMode {
  String get value {
    switch (this) {
      case QueryMode.AI:
        return 'AI';
      case QueryMode.MANUAL:
        return 'MANUAL';
    }
  }

  static QueryMode fromString(String value) {
    switch (value.toUpperCase()) {
      case 'AI':
        return QueryMode.AI;
      case 'MANUAL':
        return QueryMode.MANUAL;
      default:
        return QueryMode.AI;
    }
  }
}

class QueryModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final Priority priority;
  final double confidence;
  final String reason;
  final QueryMode mode;
  final DateTime createdAt;
  final DateTime updatedAt;

  QueryModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.priority,
    required this.confidence,
    required this.reason,
    required this.mode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QueryModel.fromJson(Map<String, dynamic> json, String docId) {
    return QueryModel(
      id: docId,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: PriorityExtension.fromString(json['priority'] ?? 'MEDIUM'),
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      reason: json['reason'] ?? 'AI unavailable',
      mode: QueryModeExtension.fromString(json['mode'] ?? 'AI'),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'priority': priority.value,
      'confidence': confidence,
      'reason': reason,
      'mode': mode.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  QueryModel copyWith({
    String? title,
    String? description,
    Priority? priority,
    double? confidence,
    String? reason,
    QueryMode? mode,
    DateTime? updatedAt,
  }) {
    return QueryModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      confidence: confidence ?? this.confidence,
      reason: reason ?? this.reason,
      mode: mode ?? this.mode,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AIAnalysisResult {
  final Priority priority;
  final double confidence;
  final String reason;

  AIAnalysisResult({
    required this.priority,
    required this.confidence,
    required this.reason,
  });

  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResult(
      priority: PriorityExtension.fromString(json['priority']?.toString() ?? 'MEDIUM'),
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      reason: json['reason']?.toString() ?? 'AI unavailable',
    );
  }

  static AIAnalysisResult fallback() {
    return AIAnalysisResult(
      priority: Priority.MEDIUM,
      confidence: 0.5,
      reason: 'AI unavailable',
    );
  }
}
