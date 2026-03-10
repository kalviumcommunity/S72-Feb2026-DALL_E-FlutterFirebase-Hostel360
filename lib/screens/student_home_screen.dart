import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:io' show File; // Only import File explicitly to avoid Platform conflicts if used later
import 'package:image_picker/image_picker.dart';
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
  bool _isAnonymous = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

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
                    initialValue: _selectedCategory,
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
                    initialValue: _selectedPriority,
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
                  
                  // Image Attachment Section
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.attach_file),
                        label: Text(_selectedImage == null ? 'Attach Evidence' : 'Change Evidence'),
                      ),
                      if (_selectedImage != null) ...[
                        const SizedBox(width: 8),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: kIsWeb
                                      ? NetworkImage(_selectedImage!.path) as ImageProvider
                                      : FileImage(File(_selectedImage!.path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedImage = null),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Anonymous toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isAnonymous
                          ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.3)
                          : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isAnonymous
                            ? Theme.of(context).colorScheme.error.withOpacity(0.3)
                            : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          size: 20,
                          color: _isAnonymous
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'File Anonymously',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Your identity will be hidden from admin',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isAnonymous,
                          onChanged: (val) => setState(() => _isAnonymous = val),
                        ),
                      ],
                    ),
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
                                isAnonymous: _isAnonymous,
                                imageFile: _selectedImage,
                              );
                              if (context.mounted) {
                                _descriptionController.clear();
                                setState(() {
                                  _selectedCategory = 'Maintenance';
                                  _selectedPriority = 'Medium';
                                  _isAnonymous = false;
                                  _selectedImage = null;
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
                                final canEdit = complaint.canEdit;
                                final canDelete = complaint.canDelete;
                                final showActions = canEdit || canDelete;
                                
                                return ComplaintCard(
                                  complaint: complaint,
                                  index: index,
                                  showActions: showActions,
                                  onEdit: canEdit ? () => _showEditDialog(context, complaint) : null,
                                  onDelete: canDelete ? () => _showDeleteDialog(context, complaint.id) : null,
                                );
                              },
                            ),
                          ),
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
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final userId = authProvider.user!.uid;
          return await complaintProvider.updateComplaint(
            complaintId: complaint.id,
            userId: userId,
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user!.uid;
      final success = await complaintProvider.deleteComplaint(complaintId, userId);
      
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
