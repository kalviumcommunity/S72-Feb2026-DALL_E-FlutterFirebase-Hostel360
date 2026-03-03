import 'package:flutter/material.dart';

class StatusBadge extends StatefulWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(StatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _controller.forward().then((_) => _controller.reverse());
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          widget.status,
          style: TextStyle(
            color: _getStatusTextColor(context),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
