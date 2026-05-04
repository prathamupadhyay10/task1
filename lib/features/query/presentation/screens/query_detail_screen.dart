import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ai_scene.dart';
import '../../../../core/widgets/priority_chip.dart';
import '../../../../models/query_model.dart';
import '../bloc/query_bloc.dart';
import '../bloc/query_event.dart';
import '../bloc/query_state.dart';
import 'add_edit_query_screen.dart';

class QueryDetailScreen extends StatefulWidget {
  const QueryDetailScreen({super.key});

  @override
  State<QueryDetailScreen> createState() => _QueryDetailScreenState();
}

class _QueryDetailScreenState extends State<QueryDetailScreen> {
  late QueryModel _query;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _query = ModalRoute.of(context)!.settings.arguments as QueryModel;
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Query',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this query? This action cannot be undone.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<QueryBloc>().add(
                    QueryDeleteRequested(queryId: _query.id),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(
              'Delete',
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editQuery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditQueryScreen(
          isEditing: true,
          query: _query,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Query Details',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _editQuery,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: _showDeleteDialog,
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: AiSceneBackground(
        child: BlocListener<QueryBloc, QueryState>(
        listener: (context, state) {
          if (state.status == QueryStatus.success &&
              state.queries.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Query deleted successfully'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          } else if (state.status == QueryStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to delete query'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.cardGradient1,
                      AppColors.cardGradient2,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _query.title,
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        PriorityChip(
                          priority: _query.priority,
                          confidence: _query.confidence,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _query.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 24),
              Text(
                'AI Analysis',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    _buildAnalysisRow(
                      icon: Icons.priority_high_rounded,
                      label: 'Priority',
                      value: _query.priority.value,
                    ),
                    const SizedBox(height: 12),
                    _buildAnalysisRow(
                      icon: Icons.analytics_outlined,
                      label: 'Confidence',
                      value: '${(_query.confidence * 100).toInt()}%',
                    ),
                    const SizedBox(height: 12),
                    _buildAnalysisRow(
                      icon: Icons.lightbulb_outline_rounded,
                      label: 'Reason',
                      value: _query.reason,
                    ),
                    const SizedBox(height: 12),
                    _buildAnalysisRow(
                      icon: _query.mode == QueryMode.AI
                          ? Icons.smart_toy_outlined
                          : Icons.person_outline_rounded,
                      label: 'Mode',
                      value: _query.mode.value,
                      valueColor: _query.mode == QueryMode.AI
                          ? AppColors.primary
                          : AppColors.warning,
                    ),
                  ],
                ),
              ).animate().slideY(
                    delay: const Duration(milliseconds: 300),
                    begin: 0.2,
                    duration: const Duration(milliseconds: 400),
                  ),
              const SizedBox(height: 24),
              Text(
                'Metadata',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    _buildAnalysisRow(
                      icon: Icons.access_time_rounded,
                      label: 'Created',
                      value: DateFormat('MMM dd, yyyy HH:mm')
                          .format(_query.createdAt),
                    ),
                    const SizedBox(height: 12),
                    _buildAnalysisRow(
                      icon: Icons.update_rounded,
                      label: 'Updated',
                      value: DateFormat('MMM dd, yyyy HH:mm')
                          .format(_query.updatedAt),
                    ),
                  ],
                ),
              ).animate().slideY(
                    delay: const Duration(milliseconds: 500),
                    begin: 0.2,
                    duration: const Duration(milliseconds: 400),
                  ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildAnalysisRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textHint,
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
