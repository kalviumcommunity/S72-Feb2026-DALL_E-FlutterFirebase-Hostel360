import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/complaint_provider.dart';
import '../models/complaint.dart';
import '../widgets/complaint_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/offline_indicator.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Maintenance';
  final List<String> _categories = [
    'Maintenance',
    'Cleanliness',
    'Food',
    'Security',
    'Other'
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final userId = authProvider.user!.uid;
    final userEmail = authProvider.user!.email!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        actions: const [
          OfflineIndicator(),
          SizedBox(width: 16),
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
                  ElevatedButton(
                    onPressed: complaintProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              await complaintProvider.submitComplaint(
                                userId: userId,
                                userEmail: userEmail,
                                category: _selectedCategory,
                                description: _descriptionController.text,
                              );
                              _descriptionController.clear();
                              setState(() {});
                            }
                          },
                    child: complaintProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Submit Complaint'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
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
          ),
        ],
      ),
    );
  }
}
