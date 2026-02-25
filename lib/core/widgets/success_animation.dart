import 'package:flutter/material.dart';
import '../constants/motion.dart';

class SuccessAnimation extends StatefulWidget {
  final VoidCallback? onComplete;

  const SuccessAnimation({
    super.key,
    this.onComplete,
  });

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.successAnimation,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        Future.delayed(const Duration(milliseconds: 200), widget.onComplete);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circle background
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                // Checkmark
                CustomPaint(
                  size: const Size(40, 40),
                  painter: CheckmarkPainter(
                    progress: _checkAnimation.value,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Checkmark path
    final startX = size.width * 0.2;
    final startY = size.height * 0.5;
    final midX = size.width * 0.4;
    final midY = size.height * 0.7;
    final endX = size.width * 0.8;
    final endY = size.height * 0.3;

    if (progress < 0.5) {
      // First part of checkmark (down stroke)
      final t = progress * 2;
      path.moveTo(startX, startY);
      path.lineTo(
        startX + (midX - startX) * t,
        startY + (midY - startY) * t,
      );
    } else {
      // Complete first part and draw second part (up stroke)
      final t = (progress - 0.5) * 2;
      path.moveTo(startX, startY);
      path.lineTo(midX, midY);
      path.lineTo(
        midX + (endX - midX) * t,
        midY + (endY - midY) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Simple success overlay widget
class SuccessOverlay extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const SuccessOverlay({
    super.key,
    this.message = 'Success!',
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SuccessAnimation(onComplete: onDismiss),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
