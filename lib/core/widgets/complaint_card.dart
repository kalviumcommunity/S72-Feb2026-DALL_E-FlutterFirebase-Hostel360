import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/complaint.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';
import 'priority_badge.dart';
import 'timeline_widget.dart';
import '../../widgets/edit_complaint_dialog.dart';

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showActions;

  const ComplaintCard({
    super.key,
    required this.complaint,
    this.onTap,
    this.trailing,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwner = authProvider.currentUser?.uid == complaint.userId;
    final canModify = isOwner && complaint.canEdit;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _buildCategoryIcon(context),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                complaint.category,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppTheme.spacing4),
                              Text(
                                _formatDate(complaint.timestamp),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusBadge(status: complaint.status),
                      const SizedBox(height: AppTheme.spacing4),
                      PriorityBadge(priority: complaint.priority),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing12),
              
              // Description
              Text(
                complaint.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Timeline (if status history exists)
              if (complaint.statusHistory.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacing16),
                TimelineWidget(statusHistory: complaint.statusHistory),
              ],
              
              // Action Buttons (Edit/Delete for pending complaints)
              if (showActions && canModify) ...[
                const SizedBox(height: AppTheme.spacing12),
                const Divider(),
                const SizedBox(height: AppTheme.spacing8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditDialog(context),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    TextButton.icon(
                      onPressed: () => _showDeleteDialog(context),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
              
              if (trailing != null) ...[
                const SizedBox(height: AppTheme.spacing12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (complaint.category.toLowerCase()) {
      case 'maintenance':
        icon = Icons.build_rounded;
        color = const Color(0xFF8B5CF6); // Purple
        break;
      case 'cleanliness':
        icon = Icons.cleaning_services_rounded;
        color = const Color(0xFF06B6D4); // Cyan
        break;
      case 'food':
        icon = Icons.restaurant_rounded;
        color = const Color(0xFFF59E0B); // Amber
        break;
      default:
        icon = Icons.info_rounded;
        color = const Color(0xFF6B7280); // Gray
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditComplaintDialog(
        complaint: complaint,
        onUpdate: (category, description, priority) async {
          final complaintProvider =
              Provider.of<ComplaintProvider>(context, listen: false);
          
          final success = await complaintProvider.updateComplaint(
            complaintId: complaint.id,
            category: category,
            description: description,
            priority: priority,
          );

          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Complaint updated successfully'),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Complaint'),
        content: const Text(
          'Are you sure you want to delete this complaint? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final complaintProvider =
                  Provider.of<ComplaintProvider>(context, listen: false);
              
              final success = await complaintProvider.deleteComplaint(complaint.id);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Complaint deleted successfully'),
                      ],
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
