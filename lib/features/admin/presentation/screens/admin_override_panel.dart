import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../../../core/widgets/ai_scene.dart';
import '../../../../core/widgets/ai_loading_animation.dart';
import '../../../../core/widgets/ai_error_animation.dart';
import '../../../../core/widgets/priority_chip.dart';
import '../../../../models/query_model.dart';
import '../../../query/presentation/bloc/query_bloc.dart';
import '../../../query/presentation/bloc/query_event.dart';
import '../../../query/presentation/bloc/query_state.dart';

class AdminOverridePanel extends StatefulWidget {
  const AdminOverridePanel({super.key});

  @override
  State<AdminOverridePanel> createState() => _AdminOverridePanelState();
}

class _AdminOverridePanelState extends State<AdminOverridePanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QueryBloc>().add(QueryFetchAllRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF021224),
              Color(0xFF00060F),
            ],
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    AiGhostIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Manual Override',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance the back button
                  ],
                ),
              ),
            ),
            BlocListener<QueryBloc, QueryState>(
              listener: (context, state) {
                if (state.status == QueryStatus.updating) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Priority updated'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tap on any query to manually override its AI-assigned priority',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(
                          duration: const Duration(milliseconds: 500),
                        ),
                    Expanded(
                      child: BlocBuilder<QueryBloc, QueryState>(
                        builder: (context, state) {
                          if (state.status == QueryStatus.loading &&
                              state.queries.isEmpty) {
                            return const AiLoadingAnimation();
                          }

                          if (state.status == QueryStatus.error &&
                              state.queries.isEmpty) {
                            return AiErrorAnimation(
                              message: state.errorMessage ?? 'Failed to load queries',
                            );
                          }

                          if (state.queries.isEmpty) {
                            return const EmptyState(
                              title: 'No Queries Found',
                              subtitle: 'No queries available for manual override',
                              icon: Icons.edit_off_outlined,
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: state.queries.length,
                            itemBuilder: (context, index) {
                              final query = state.queries[index];
                              return _OverrideCard(
                                query: query,
                                index: index,
                              ).animate().fadeIn(
                                delay: (index * 60).ms,
                                duration: 400.ms,
                              ).slideX(begin: 0.1, end: 0);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverrideCard extends StatelessWidget {
  final QueryModel query;
  final int index;

  const _OverrideCard({
    required this.query,
    required this.index,
  });

  void _showOverrideDialog(BuildContext context, Priority newPriority) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Override Priority',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Change priority of "${query.title}" from ${query.priority.value} to ${newPriority.value}?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<QueryBloc>().add(
                    QueryOverridePriority(
                      queryId: query.id,
                      priority: newPriority,
                    ),
                  );
            },
            child: Text(
              'Override',
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset((1 - value) * 30, 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
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
                    query.title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                PriorityChip(priority: query.priority),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Override to:',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      _PriorityButton(
                        priority: Priority.HIGH,
                        color: AppColors.highPriority,
                        isSelected: query.priority == Priority.HIGH,
                        onTap: query.priority == Priority.HIGH
                            ? null
                            : () => _showOverrideDialog(
                                  context,
                                  Priority.HIGH,
                                ),
                      ),
                      const SizedBox(width: 8),
                      _PriorityButton(
                        priority: Priority.MEDIUM,
                        color: AppColors.mediumPriority,
                        isSelected: query.priority == Priority.MEDIUM,
                        onTap: query.priority == Priority.MEDIUM
                            ? null
                            : () => _showOverrideDialog(
                                  context,
                                  Priority.MEDIUM,
                                ),
                      ),
                      const SizedBox(width: 8),
                      _PriorityButton(
                        priority: Priority.LOW,
                        color: AppColors.lowPriority,
                        isSelected: query.priority == Priority.LOW,
                        onTap: query.priority == Priority.LOW
                            ? null
                            : () =>
                                  _showOverrideDialog(context, Priority.LOW),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  query.mode == QueryMode.AI
                      ? Icons.smart_toy_outlined
                      : Icons.person_outline_rounded,
                  size: 14,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  'Mode: ${query.mode.value}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityButton extends StatelessWidget {
  final Priority priority;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PriorityButton({
    required this.priority,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          priority.value,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? color : color.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
