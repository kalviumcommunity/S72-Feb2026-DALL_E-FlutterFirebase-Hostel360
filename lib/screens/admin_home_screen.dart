import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/complaint_provider.dart';
import '../providers/theme_provider.dart';
import '../core/widgets/custom_card.dart';
import '../core/widgets/status_badge.dart';
import '../core/widgets/priority_badge.dart';
import '../core/widgets/empty_state.dart';
import '../core/widgets/loading_state.dart';
import '../core/widgets/section_header.dart';
import '../core/widgets/filter_chip_group.dart';
import '../core/constants/motion.dart';
import '../models/complaint.dart';
import '../widgets/add_note_dialog.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final Map<String, bool> _updatingStatus = {};
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

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
      final complaintProvider =
          Provider.of<ComplaintProvider>(context, listen: false);
      complaintProvider.watchAllComplaints();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(AppMotion.searchDebounce, () {
      final complaintProvider =
          Provider.of<ComplaintProvider>(context, listen: false);
      complaintProvider.setSearchQuery(query);
    });
  }

  Future<void> _updateComplaintStatus(
    String complaintId,
    String newStatus,
  ) async {
    setState(() {
      _updatingStatus[complaintId] = true;
    });

    final complaintProvider =
        Provider.of<ComplaintProvider>(context, listen: false);
    final success = await complaintProvider.updateStatus(
      complaintId,
      newStatus,
    );

    setState(() {
      _updatingStatus[complaintId] = false;
    });

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Status updated to $newStatus'),
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
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
                    'Admin Panel',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage all hostel complaints',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stats Cards
                  Consumer<ComplaintProvider>(
                    builder: (context, provider, child) {
                      final complaints = provider.complaints;
                      final pending = complaints
                          .where((c) => c.status.toLowerCase() == 'pending')
                          .length;
                      final inProgress = complaints
                          .where((c) => c.status.toLowerCase() == 'in progress')
                          .length;
                      final resolved = complaints
                          .where((c) => c.status.toLowerCase() == 'resolved')
                          .length;

                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.pending_actions_rounded,
                              label: 'Pending',
                              count: pending,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.hourglass_empty_rounded,
                              label: 'In Progress',
                              count: inProgress,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.check_circle_rounded,
                              label: 'Resolved',
                              count: resolved,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by description, email, category...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips
                  Consumer<ComplaintProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Filter
                          FilterChipGroup(
                            label: 'Category',
                            options: const ['All', 'Maintenance', 'Cleanliness', 'Food', 'Other'],
                            selectedOption: provider.filterCategory ?? 'All',
                            onSelected: (value) {
                              provider.setFilterCategory(value == 'All' ? null : value);
                            },
                          ),
                          const SizedBox(height: 12),
                          // Status Filter
                          FilterChipGroup(
                            label: 'Status',
                            options: const ['All', 'Pending', 'In Progress', 'Resolved'],
                            selectedOption: provider.filterStatus ?? 'All',
                            onSelected: (value) {
                              provider.setFilterStatus(value == 'All' ? null : value);
                            },
                          ),
                          const SizedBox(height: 12),
                          // Priority Filter
                          FilterChipGroup(
                            label: 'Priority',
                            options: const ['All', 'Urgent', 'High', 'Medium', 'Low'],
                            selectedOption: provider.filterPriority ?? 'All',
                            onSelected: (value) {
                              provider.setFilterPriority(value == 'All' ? null : value);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Sort and Result Count Row
                  Consumer<ComplaintProvider>(
                    builder: (context, provider, child) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${provider.complaints.length} result${provider.complaints.length != 1 ? 's' : ''}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Sort Dropdown
                          DropdownButton<String>(
                            value: provider.sortBy,
                            icon: const Icon(Icons.sort_rounded),
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'newest', child: Text('Newest')),
                              DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                              DropdownMenuItem(value: 'priority', child: Text('Priority')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                provider.setSortBy(value);
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // All Complaints Section
                  const SectionHeader(
                    title: 'All Complaints',
                    subtitle: 'Review and update complaint status',
                  ),
                  const SizedBox(height: 16),

                  // Complaints List
                  Consumer<ComplaintProvider>(
                    builder: (context, provider, child) {
                      final complaints = provider.complaints;

                      if (provider.isLoading && complaints.isEmpty) {
                        return const LoadingState(
                          message: 'Loading complaints...',
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
                          title: 'No complaints',
                          message: 'All complaints will appear here',
                        );
                      }

                      return Column(
                        children: complaints.map((complaint) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AdminComplaintCard(
                              complaint: complaint,
                              isUpdating: _updatingStatus[complaint.id] ?? false,
                              onStatusUpdate: _updateComplaintStatus,
                            ),
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final bool isUpdating;
  final Function(String, String) onStatusUpdate;

  const _AdminComplaintCard({
    required this.complaint,
    required this.isUpdating,
    required this.onStatusUpdate,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'maintenance':
        return Icons.build_rounded;
      case 'cleanliness':
        return Icons.cleaning_services_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      default:
        return Icons.report_problem_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(complaint.category),
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint.category,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        complaint.userEmail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(status: complaint.status),
                    const SizedBox(height: 4),
                    PriorityBadge(priority: complaint.priority),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              complaint.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            // Timestamp
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(complaint.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Admin Notes Button
            if (complaint.notes.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${complaint.notes.length} note${complaint.notes.length != 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            // Add Note Button
            OutlinedButton.icon(
              onPressed: () => _showAddNoteDialog(context, complaint),
              icon: const Icon(Icons.add_comment_outlined, size: 18),
              label: const Text('Add Note'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 16),
            // Status Update Dropdown
            DropdownButtonFormField<String>(
              initialValue: complaint.status,
              decoration: InputDecoration(
                labelText: 'Update Status',
                prefixIcon: const Icon(Icons.edit_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              items: ['Pending', 'In Progress', 'Resolved']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: isUpdating
                  ? null
                  : (newStatus) {
                      if (newStatus != null && newStatus != complaint.status) {
                        onStatusUpdate(complaint.id, newStatus);
                      }
                    },
            ),
            if (isUpdating)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Updating status...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showAddNoteDialog(BuildContext context, Complaint complaint) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AddNoteDialog(
        complaintId: complaint.id,
        onAddNote: (noteText, isAdminNote) async {
          final complaintProvider =
              Provider.of<ComplaintProvider>(context, listen: false);
          
          final success = await complaintProvider.addNote(
            complaintId: complaint.id,
            text: noteText,
            authorId: authProvider.currentUser!.uid,
            authorEmail: authProvider.currentUser!.email ?? '',
            isAdminNote: isAdminNote,
          );

          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Note added successfully'),
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
}
