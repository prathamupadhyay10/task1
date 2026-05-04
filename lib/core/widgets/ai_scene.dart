import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AiSceneBackground extends StatelessWidget {
  final Widget child;
  final bool showGrid;

  const AiSceneBackground({
    super.key,
    required this.child,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF021224),
        image: const DecorationImage(
          image: AssetImage('assets/bg.png'),
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF021224).withValues(alpha: 0.8),
            const Color(0xFF010A15).withValues(alpha: 0.9),
            const Color(0xFF00060F),
          ],
        ),
      ),
      child: Stack(
        children: [
          if (showGrid)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _PerspectiveGridPainter(),
                ),
              ),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class AiGlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? accent;
  final VoidCallback? onTap;

  const AiGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.radius = 20,
    this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final panel = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cardGradient1,
                AppColors.cardGradient2,
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: (accent ?? AppColors.glassBorder).withValues(alpha: 0.90),
            ),
            boxShadow: [
              BoxShadow(
                color: (accent ?? AppColors.primary).withValues(alpha: 0.14),
                blurRadius: 26,
                spreadRadius: -8,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return panel;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: panel,
      ),
    );
  }
}

class AiGhostIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const AiGhostIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class AiSegmentedControl<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  const AiSegmentedControl({
    super.key,
    required this.values,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final selectedIndex = values.indexOf(selected);
        final innerWidth = constraints.maxWidth - 12;
        final segmentWidth = innerWidth / values.length;

        return Container(
          height: 52,
          padding: const EdgeInsets.all(6),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0x220A1A2D),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0x3356B8FF),
              width: 0.8,
            ),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutQuart,
                left: selectedIndex * segmentWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  width: segmentWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1B3C5A).withValues(alpha: 0.7),
                        const Color(0xFF0F2540).withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0x9956B8FF),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              Row(
                children: values.map((value) {
                  final isSelected = value == selected;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(value),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text(
                          labelBuilder(value),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF8EA8C5).withValues(alpha: 0.6),
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PerspectiveGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.72;
    final centerX = size.width / 2;
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    double y = horizonY;
    double step = 12;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      y += step;
      step *= 1.15;
    }

    const verticalLines = 11;
    for (int i = -verticalLines; i <= verticalLines; i++) {
      final bottomX = centerX + (i * size.width / 12);
      final topX = centerX + (i * size.width / 48);
      canvas.drawLine(
        Offset(topX, horizonY),
        Offset(bottomX, size.height),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
