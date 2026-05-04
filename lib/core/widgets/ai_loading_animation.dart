import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AiLoadingAnimation extends StatefulWidget {
  const AiLoadingAnimation({super.key});

  @override
  State<AiLoadingAnimation> createState() => _AiLoadingAnimationState();
}

class _AiLoadingAnimationState extends State<AiLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
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
        final glowStrength = 0.22 + (_controller.value * 0.18);
        return Stack(
          children: [
            const Center(
              child: SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
