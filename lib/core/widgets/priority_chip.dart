import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/query_model.dart';

class PriorityChip extends StatelessWidget {
  final Priority priority;
  final double? confidence;
  final bool animated;

  const PriorityChip({
    super.key,
    required this.priority,
    this.confidence,
    this.animated = true,
  });

  Color get _color {
    switch (priority) {
      case Priority.HIGH:
        return AppColors.highPriority;
      case Priority.MEDIUM:
        return AppColors.mediumPriority;
      case Priority.LOW:
        return AppColors.lowPriority;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _color.withOpacity(0.50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _color.withOpacity(0.55),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            priority.value[0] + priority.value.substring(1).toLowerCase(),
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (confidence != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(confidence! * 100).toInt()}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: _color,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (!animated) return chip;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: chip,
    );
  }
}
