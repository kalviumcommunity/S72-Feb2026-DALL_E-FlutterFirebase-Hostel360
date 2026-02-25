import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/complaint_provider.dart';
import '../providers/theme_provider.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';
import '../core/widgets/custom_card.dart';
import '../core/widgets/complaint_card.dart';
import '../core/widgets/empty_state.dart';
import '../core/widgets/loading_state.dart';
import '../core/widgets/section_header.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Maintenance';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final complaintProvider =
          Provider.of<ComplaintProvider>(context, listen: false);
      complaintProvider.watchUserComplaints(authProvider.currentUser!.uid);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    final complaintProvider =
        Provider.of<ComplaintProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await complaintProvider.submitComplaint(
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      userId: authProvider.currentUser!.uid,
      userEmail: authProvider.currentUser!.email ?? '',
    );

    if (mounted && success) {
      _descriptionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Complaint submitted successfully'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final complaintProvider = Provider.of<ComplaintProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Hostel360',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Text(
                    'Welcome back!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authProvider.currentUser?.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Complaint Section
                  const SectionHeader(
                    title: 'Submit Complaint',
                    subtitle: 'Let us know about any issues',
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Category Dropdown
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              prefixIcon: const Icon(Icons.category_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: [
                              'Maintenance',
                              'Cleanliness',
                              'Food',
                              'Other'
                            ]
                                .map((category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Description Field
                          CustomTextField(
                            controller: _descriptionController,
                            label: 'Description',
                            hint: 'Describe your complaint in detail...',
                            prefixIcon: Icons.description_rounded,
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a description';
                              }
                              if (value.trim().length < 10) {
                                return 'Description must be at least 10 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Submit Button
                          CustomButton(
                            text: 'Submit Complaint',
                            onPressed: complaintProvider.isLoading
                                ? null
                                : _submitComplaint,
                            isLoading: complaintProvider.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // My Complaints Section
                  const SectionHeader(
                    title: 'My Complaints',
                    subtitle: 'Track your submitted complaints',
                  ),
                  const SizedBox(height: 16),

                  // Complaints List
                  Consumer<ComplaintProvider>(
                    builder: (context, provider, child) {
                      final complaints = provider.complaints
                          .where((c) => c.userId == authProvider.currentUser!.uid)
                          .toList();

                      if (provider.isLoading && complaints.isEmpty) {
                        return const LoadingState(
                          message: 'Loading your complaints...',
                        );
                      }

                      if (provider.errorMessage != null) {
                        return CustomCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    provider.errorMessage!,
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (complaints.isEmpty) {
                        return const EmptyState(
                          icon: Icons.inbox_rounded,
                          title: 'No complaints yet',
                          message:
                              'Your submitted complaints will appear here',
                        );
                      }

                      return Column(
                        children: complaints.map((complaint) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ComplaintCard(complaint: complaint),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
