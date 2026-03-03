import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/complaint_provider.dart';
import '../models/complaint.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/status_badge.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final List<String> _statuses = ['Pending', 'In Progress', 'Resolved'];

  @override
  Widget build(BuildContext context) {
    final complaintProvider = Provider.of<ComplaintProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Complaints'),
        actions: const [
          OfflineIndicator(),
          SizedBox(width: 16),
        ],
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, complaintProvider, _) {
          complaintProvider.watchAllComplaints();
          final complaints = complaintProvider.complaints;

          if (complaintProvider.isLoading && complaints.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (complaintProvider.errorMessage != null) {
            return Center(child: Text('Error: ${complaintProvider.errorMessage}'));
          }

          if (complaints.isEmpty) {
            return const EmptyStateWidget(
              message: 'No complaints found',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              complaint.category,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            StatusBadge(status: complaint.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'User: ${complaint.userEmail}',
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text('Status: '),
                            Expanded(
                              child: DropdownButton<String>(
                                value: complaint.status,
                                isExpanded: true,
                                items: _statuses.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                                onChanged: complaintProvider.isLoading
                                    ? null
                                    : (newStatus) async {
                                        if (newStatus != null) {
                                          await complaintProvider
                                              .updateStatus(
                                            complaint.id,
                                            newStatus,
                                          );
                                        }
                                      },
                              ),
                            ),
                            if (complaintProvider.isLoading)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
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
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
