import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/complaint_provider.dart';
import '../models/complaint.dart';
import '../widgets/complaint_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/edit_complaint_dialog.dart';
import '../core/widgets/custom_button.dart';
import 'settings_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Maintenance';
  String _selectedPriority = 'Medium';
  final List<String> _categories = [
    'Maintenance',
    'Cleanliness',
    'Food',
    'Security',
    'Other'
  ];
  final List<String> _priorities = [
    'Low',
    'Medium',
    'High',
    'Urgent',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
      final userId = authProvider.currentUser!.uid;
      complaintProvider.watchUserComplaints(userId);
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final userId = authProvider.currentUser!.uid;
    final userEmail = authProvider.currentUser!.email!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('My Complaints'),
        actions: [
          const OfflineIndicator(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: _priorities.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: const OutlineInputBorder(),
                      counterText:
                          '${_descriptionController.text.length}/500 characters',
                    ),
                    maxLines: 3,
                    maxLength: 500,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Submit Complaint',
                    isLoading: complaintProvider.isLoading,
                    icon: Icons.send_rounded,
                    onPressed: complaintProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              await complaintProvider.submitComplaint(
                                userId: userId,
                                userEmail: userEmail,
                                category: _selectedCategory,
                                description: _descriptionController.text,
                                priority: _selectedPriority,
                              );
                              if (context.mounted) {
                                _descriptionController.clear();
                                setState(() {
                                  _selectedCategory = 'Maintenance';
                                  _selectedPriority = 'Medium';
                                });
                                if (complaintProvider.errorMessage == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Complaint submitted successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
<<<<<<< HEAD
            child: Consumer<ComplaintProvider>(
              builder: (context, complaintProvider, _) {
                complaintProvider.watchUserComplaints(userId);
                final complaints = complaintProvider.complaints;

                if (complaintProvider.isLoading && complaints.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (complaintProvider.errorMessage != null) {
                  return Center(child: Text('Error: ${complaintProvider.errorMessage}'));
                }

                if (complaints.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No complaints yet',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      return ComplaintCard(
                        complaint: complaints[index],
                        index: index,
                      );
                    },
                  ),
                );
              },
            ),
=======
            child: complaintProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : complaintProvider.errorMessage != null
                    ? Center(child: Text('Error: ${complaintProvider.errorMessage}'))
                    : complaintProvider.complaints.isEmpty
                        ? const EmptyStateWidget(
                            message: 'No complaints yet',
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              complaintProvider.watchUserComplaints(userId);
                            },
                            child: ListView.builder(
                              itemCount: complaintProvider.complaints.length,
                              itemBuilder: (context, index) {
                                final complaint = complaintProvider.complaints[index];
                                return ComplaintCard(
                                  complaint: complaint,
                                  index: index,
                                  showActions: true,
                                  onEdit: complaint.canEdit
                                      ? () => _showEditDialog(context, complaint)
                                      : null,
                                  onDelete: complaint.canDelete
                                      ? () => _showDeleteDialog(context, complaint.id)
                                      : null,
                                );
                              },
                            ),
                          ),
>>>>>>> ed1eca950d0a94440eefedb5ec814c0d20d264df
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Complaint complaint) async {
    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditComplaintDialog(
        complaint: complaint,
        onUpdate: (category, description, priority) async {
          return await complaintProvider.updateComplaint(
            complaintId: complaint.id,
            category: category,
            description: description,
            priority: priority,
          );
        },
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, String complaintId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Complaint'),
        content: const Text('Are you sure you want to delete this complaint? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
      final success = await complaintProvider.deleteComplaint(complaintId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Complaint deleted successfully' : 'Failed to delete complaint'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
