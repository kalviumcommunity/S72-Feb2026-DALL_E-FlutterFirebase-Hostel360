import 'package:flutter/material.dart';

class StatusBadge extends StatefulWidget {
  final String status;
  final String? priority;

  const StatusBadge({super.key, required this.status, this.priority});

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseOpacity;

  bool get _shouldPulse =>
      widget.priority == 'Urgent' && widget.status != 'Resolved';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (_shouldPulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldPulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!_shouldPulse && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
    if (oldWidget.status != widget.status) {
      _controller.forward().then((_) {
        if (_shouldPulse) {
          _controller.repeat(reverse: true);
        } else {
          _controller.reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor(BuildContext context) {
    switch (widget.status) {
      case 'Pending':
        return Colors.orange.shade600;
      case 'In Progress':
        return Theme.of(context).colorScheme.primary;
      case 'Resolved':
        return Colors.green.shade600;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    }
  }

  Color _getStatusTextColor(BuildContext context) {
    switch (widget.status) {
      case 'Resolved':
      case 'Pending':
        return Colors.white;
      default:
        return Theme.of(context).colorScheme.onPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse ring (only for urgent)
            if (_shouldPulse)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFEF4444)
                        .withOpacity(_pulseOpacity.value),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444)
                          .withOpacity(_pulseOpacity.value * 0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  widget.status,
                  style: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // Badge content
            Transform.scale(
              scale: _shouldPulse ? _scaleAnimation.value : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_shouldPulse) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      widget.status,
                      style: TextStyle(
                        color: _getStatusTextColor(context),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
