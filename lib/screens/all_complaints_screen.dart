import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/complaint_provider.dart';
import '../models/complaint.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/status_badge.dart';

class AllComplaintsScreen extends StatefulWidget {
  const AllComplaintsScreen({super.key});

  @override
  State<AllComplaintsScreen> createState() => _AllComplaintsScreenState();
}

class _AllComplaintsScreenState extends State<AllComplaintsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
      complaintProvider.watchAllComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final currentUserId = authProvider.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Complaints'),
        actions: const [
          OfflineIndicator(),
          SizedBox(width: 16),
        ],
      ),
      body: complaintProvider.isLoading && complaintProvider.complaints.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : complaintProvider.errorMessage != null
              ? Center(
                  child: Text('Error: ${complaintProvider.errorMessage}'),
                )
              : complaintProvider.complaints.isEmpty
                  ? const EmptyStateWidget(
                      message: 'No complaints found',
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        complaintProvider.watchAllComplaints();
                      },
                      child: ListView.builder(
                        itemCount: complaintProvider.complaints.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final complaint = complaintProvider.complaints[index];
                          final hasUpvoted = complaint.upvotedBy.contains(currentUserId);
                          final isOwnComplaint = complaint.userId == currentUserId;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
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
                                          complaint.category,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      StatusBadge(status: complaint.status),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isOwnComplaint ? 'You' : complaint.userEmail,
                                    style:
                                        Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey[700],
                                            ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    complaint.description,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Submitted: ${_formatDate(complaint.timestamp)}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey,
                                            ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          await complaintProvider.toggleUpvote(
                                            complaint.id,
                                            currentUserId,
                                          );
                                        },
                                        icon: Icon(
                                          hasUpvoted
                                              ? Icons.thumb_up
                                              : Icons.thumb_up_outlined,
                                          color: hasUpvoted
                                              ? Theme.of(context).colorScheme.primary
                                              : null,
                                        ),
                                      ),
                                      Text(
                                        '${complaint.upvoteCount}',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                      const SizedBox(width: 16),
                                      if (complaint.priority != 'Medium')
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(complaint.priority)
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: _getPriorityColor(complaint.priority),
                                            ),
                                          ),
                                          child: Text(
                                            complaint.priority,
                                            style: TextStyle(
                                              color: _getPriorityColor(complaint.priority),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return const Color(0xFFEF4444);
      case 'high':
        return const Color(0xFFF97316);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
