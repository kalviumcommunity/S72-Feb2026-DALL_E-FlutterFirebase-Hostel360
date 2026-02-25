import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/complaint_provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final complaints = complaintProvider.complaints;

          if (complaintProvider.isLoading && complaints.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (complaintProvider.errorMessage != null) {
            return Center(child: Text('Error: ${complaintProvider.errorMessage}'));
          }

          if (complaints.isEmpty) {
            return const Center(
              child: Text('No complaints to display'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Stream will auto-refresh
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
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
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Chip(
                              label: Text(complaint.status),
                              backgroundColor: _getStatusColor(complaint.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(complaint.description),
                        const SizedBox(height: 8),
                        Text(
                          'User: ${complaint.userEmail}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: complaint.status,
                          decoration: const InputDecoration(
                            labelText: 'Update Status',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: ['Pending', 'In Progress', 'Resolved']
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                          onChanged: (newStatus) async {
                            if (newStatus != null && newStatus != complaint.status) {
                              final success = await complaintProvider.updateStatus(
                                complaint.id,
                                newStatus,
                              );
                              if (context.mounted && success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Status updated to $newStatus'),
                                  ),
                                );
                              }
                            }
                          },
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade200;
      case 'in progress':
        return Colors.blue.shade200;
      case 'resolved':
        return Colors.green.shade200;
      default:
        return Colors.grey.shade200;
    }
  }
}
