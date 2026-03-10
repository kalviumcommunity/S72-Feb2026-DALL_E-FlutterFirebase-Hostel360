import 'package:flutter/material.dart';
import '../models/complaint.dart';
import 'status_badge.dart';

class ComplaintCard extends StatefulWidget {
  final Complaint complaint;
  final int index;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ComplaintCard({
    super.key,
    required this.complaint,
    this.index = 0,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ComplaintCard> createState() => _ComplaintCardState();
}

class _ComplaintCardState extends State<ComplaintCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.complaint.category,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    StatusBadge(
                      status: widget.complaint.status,
                      priority: widget.complaint.priority,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.complaint.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.complaint.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.complaint.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: EdgeInsets.zero,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      InteractiveViewer(
                                        child: Image.network(
                                          widget.complaint.imageUrls[index],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Positioned(
                                        top: 16,
                                        right: 16,
                                        child: IconButton(
                                          icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                          onPressed: () => Navigator.of(context).pop(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.complaint.imageUrls[index],
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 80,
                                  width: 80,
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Submitted: ${_formatDate(widget.complaint.timestamp)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                            ),
                      ),
                    ),
                    if (widget.showActions && (widget.onEdit != null || widget.onDelete != null))
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.onEdit != null)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: widget.onEdit,
                              tooltip: 'Edit',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          if (widget.onDelete != null)
                            IconButton(
                              icon: Icon(Icons.delete,
                                  size: 20,
                                  color:
                                      Theme.of(context).colorScheme.error),
                              onPressed: widget.onDelete,
                              tooltip: 'Delete',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
