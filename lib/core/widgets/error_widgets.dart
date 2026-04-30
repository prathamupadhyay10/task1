import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'primary_button.dart';

class JitterErrorWidget extends StatefulWidget {
  final String message;
  final VoidCallback? onRetry;

  const JitterErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  JitterErrorWidgetState createState() => JitterErrorWidgetState();
}

class JitterErrorWidgetState extends State<JitterErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final sequence = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4, end: 2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 2, end: 0), weight: 1),
    ]);

    _animation = sequence.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _retry() {
    _controller.reset();
    _controller.forward();
    widget.onRetry?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_animation.value, 0),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.onRetry != null) ...[
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Try Again',
                  onPressed: _retry,
                  icon: Icons.refresh_rounded,
                  width: 160,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class JitterField extends StatefulWidget {
  final Widget child;

  const JitterField({super.key, required this.child});

  @override
  JitterFieldState createState() => JitterFieldState();
}

class JitterFieldState extends State<JitterField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  void trigger() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!_controller.isAnimating) {
          return child!;
        }
        final progress = _controller.value;
        final offset = math.sin(progress * math.pi * 4) * (1 - progress) * 8;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
