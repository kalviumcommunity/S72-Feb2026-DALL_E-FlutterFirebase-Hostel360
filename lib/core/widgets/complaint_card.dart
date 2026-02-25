import 'package:flutter/material.dart';
import '../../models/complaint.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ComplaintCard({
    super.key,
    required this.complaint,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
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
                  StatusBadge(status: complaint.status),
                ],
              ),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                complaint.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
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
}
