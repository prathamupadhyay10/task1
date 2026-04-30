import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/query_model.dart';
import 'ai_scene.dart';
import 'priority_chip.dart';

class QueryCard extends StatelessWidget {
  final QueryModel query;
  final VoidCallback onTap;
  final int index;

  const QueryCard({
    super.key,
    required this.query,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _getPriorityColor(query.priority);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 380 + (index * 70)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 26),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: AiGlassPanel(
          accent: accent,
          onTap: onTap,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      query.title,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  PriorityChip(priority: query.priority, animated: false),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                query.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: AppColors.glassBorder.withOpacity(0.30),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMM yyyy').format(query.createdAt),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      query.mode == QueryMode.AI ? 'AI' : 'Manual',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: query.mode == QueryMode.AI
                            ? AppColors.primaryLight
                            : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.HIGH:
        return AppColors.highPriority;
      case Priority.MEDIUM:
        return AppColors.mediumPriority;
      case Priority.LOW:
        return AppColors.lowPriority;
    }
  }
}
