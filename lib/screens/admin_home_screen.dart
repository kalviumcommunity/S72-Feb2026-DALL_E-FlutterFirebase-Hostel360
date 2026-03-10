import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/complaint_provider.dart';
import '../providers/app_notification_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/status_badge.dart';
import '../widgets/admin_reply_dialog.dart';
import 'settings_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final List<String> _statuses = ['Pending', 'In Progress', 'Resolved'];
  final TextEditingController _searchController = TextEditingController();
  bool _showMetrics = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
      complaintProvider.watchAllComplaints();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = Provider.of<ComplaintProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(_showMetrics ? Icons.list : Icons.bar_chart),
            onPressed: () {
              setState(() {
                _showMetrics = !_showMetrics;
              });
            },
            tooltip: _showMetrics ? 'Show List' : 'Show Metrics',
          ),
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
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search complaints...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              complaintProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    complaintProvider.setSearchQuery(value);
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All Status',
                        isSelected: complaintProvider.filterStatus == null,
                        onTap: () => complaintProvider.setFilterStatus(null),
                      ),
                      ..._statuses.map((status) => _FilterChip(
                            label: status,
                            isSelected: complaintProvider.filterStatus == status,
                            onTap: () => complaintProvider.setFilterStatus(status),
                          )),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'All Priority',
                        isSelected: complaintProvider.filterPriority == null,
                        onTap: () => complaintProvider.setFilterPriority(null),
                      ),
                      _FilterChip(
                        label: 'Urgent',
                        isSelected: complaintProvider.filterPriority == 'Urgent',
                        onTap: () => complaintProvider.setFilterPriority('Urgent'),
                      ),
                      _FilterChip(
                        label: 'High',
                        isSelected: complaintProvider.filterPriority == 'High',
                        onTap: () => complaintProvider.setFilterPriority('High'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: _showMetrics
                ? _buildMetricsView(complaintProvider)
                : _buildComplaintsList(complaintProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsView(ComplaintProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final statusStats = provider.getStatusStats();
    final categoryStats = provider.getCategoryStats();
    final priorityStats = provider.getPriorityStats();
    final resolutionRate = provider.getResolutionRate();
    final total = provider.complaints.length;

    return RefreshIndicator(
      onRefresh: () async {
        provider.watchAllComplaints();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total',
                  value: total.toString(),
                  icon: Icons.assignment,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Pending',
                  value: (statusStats['Pending'] ?? 0).toString(),
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'In Progress',
                  value: (statusStats['In Progress'] ?? 0).toString(),
                  icon: Icons.hourglass_empty,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Resolved',
                  value: (statusStats['Resolved'] ?? 0).toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Resolution Rate
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resolution Rate',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: resolutionRate / 100,
                    minHeight: 8,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      resolutionRate > 70
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${resolutionRate.toStringAsFixed(1)}% resolved',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status Pie Chart
          if (total > 0)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complaints by Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: Row(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 40,
                                sections: _buildStatusSections(statusStats, total),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: statusStats.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(entry.key),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${entry.key} (${entry.value})',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Category Bar Chart
          if (total > 0)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complaints by Category',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (categoryStats.values.isEmpty
                                  ? 1
                                  : categoryStats.values
                                      .reduce((a, b) => a > b ? a : b))
                              .toDouble() *
                              1.3,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final keys = categoryStats.keys.toList();
                                return BarTooltipItem(
                                  '${keys[group.x]}\n${rod.toY.toInt()}',
                                  TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  if (value == value.toInt().toDouble()) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (value, meta) {
                                  final keys = categoryStats.keys.toList();
                                  if (value.toInt() < keys.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        keys[value.toInt()].length > 6
                                            ? '${keys[value.toInt()].substring(0, 6)}.'
                                            : keys[value.toInt()],
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontSize: 10,
                                            ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: _buildCategoryBarGroups(categoryStats),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Priority Pie Chart
          if (total > 0)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complaints by Priority',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: Row(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 40,
                                sections: _buildPrioritySections(priorityStats, total),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: priorityStats.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(entry.key),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${entry.key} (${entry.value})',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildStatusSections(Map<String, int> stats, int total) {
    return stats.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        color: _getStatusColor(entry.key),
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<PieChartSectionData> _buildPrioritySections(Map<String, int> stats, int total) {
    return stats.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        color: _getPriorityColor(entry.key),
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildCategoryBarGroups(Map<String, int> stats) {
    return stats.entries.toList().asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.value.toDouble(),
            color: _getCategoryColor(entry.value.key),
            width: 22,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.amber.shade700;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildComplaintsList(ComplaintProvider complaintProvider) {
    if (complaintProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (complaintProvider.errorMessage != null) {
      return Center(child: Text('Error: ${complaintProvider.errorMessage}'));
    }

    if (complaintProvider.complaints.isEmpty) {
      return const EmptyStateWidget(message: 'No complaints found');
    }

    return RefreshIndicator(
      onRefresh: () async {
        complaintProvider.watchAllComplaints();
      },
      child: ListView.builder(
        itemCount: complaintProvider.complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaintProvider.complaints[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      StatusBadge(
                        status: complaint.status,
                        priority: complaint.priority,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(complaint.priority).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          complaint.priority,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getPriorityColor(complaint.priority),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User: ${complaint.isAnonymous ? 'Anonymous Student' : complaint.userEmail}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                  if (complaint.isAnonymous)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.shield_rounded, size: 14, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 4),
                          Text(
                            'Anonymous Complaint',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    complaint.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (complaint.imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Evidence Attached:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: complaint.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: EdgeInsets.zero,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        InteractiveViewer(
                                          child: Image.network(
                                            complaint.imageUrls[index],
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        Positioned(
                                          top: 16,
                                          right: 16,
                                          child: IconButton(
                                            icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                            onPressed: () => Navigator.of(context).pop(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  complaint.imageUrls[index],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: 100,
                                    width: 100,
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    child: const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.thumb_up,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${complaint.upvoteCount} upvotes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Submitted: ${_formatDate(complaint.timestamp)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
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
                                    final oldStatus = complaint.status;
                                    await complaintProvider.updateStatus(
                                      complaint.id,
                                      newStatus,
                                    );
                                    if (context.mounted) {
                                      // Send status change notification to student
                                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                      final notifProvider = Provider.of<AppNotificationProvider>(context, listen: false);
                                      await notifProvider.sendStatusChangeNotification(
                                        studentUserId: complaint.userId,
                                        complaintId: complaint.id,
                                        complaintCategory: complaint.category,
                                        oldStatus: oldStatus,
                                        newStatus: newStatus,
                                        adminEmail: authProvider.currentUser?.email ?? 'Admin',
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Status updated to $newStatus'),
                                          duration:
                                              const Duration(seconds: 2),
                                        ),
                                      );
                                    }
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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      if (!complaint.isAnonymous)
                        IconButton(
                          icon: Icon(
                            Icons.reply_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () => _showReplyDialog(context, complaint),
                          tooltip: 'Reply to Student',
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => _showDeleteDialog(context, complaint.id, complaintProvider),
                        tooltip: 'Delete Complaint',
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
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'maintenance':
        return Colors.blue;
      case 'cleanliness':
        return Colors.green;
      case 'food':
        return Colors.orange;
      case 'security':
        return Colors.red;
      default:
        return Colors.grey;
    }
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

  void _showReplyDialog(BuildContext context, dynamic complaint) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notifProvider = Provider.of<AppNotificationProvider>(context, listen: false);
    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
    final adminEmail = authProvider.currentUser?.email ?? 'Admin';
    final adminId = authProvider.currentUser?.uid ?? '';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AdminReplyDialog(
        complaintCategory: complaint.category,
        studentEmail: complaint.userEmail,
        onSend: (message) async {
          // 1. Add as a note on the complaint
          await complaintProvider.addNote(
            complaintId: complaint.id,
            text: message,
            authorId: adminId,
            authorEmail: adminEmail,
            isAdminNote: true,
          );
          // 2. Send notification to the student
          return await notifProvider.sendReplyNotification(
            studentUserId: complaint.userId,
            complaintId: complaint.id,
            complaintCategory: complaint.category,
            replyMessage: message,
            adminEmail: adminEmail,
          );
        },
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, String complaintId, ComplaintProvider complaintProvider) async {
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user!.uid;
      final success = await complaintProvider.deleteComplaint(complaintId, userId, isAdmin: true);
      
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


// Helper Widgets
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface.withOpacity(0.8),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary,
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : theme.colorScheme.outline.withOpacity(0.25),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _StatBar({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (value / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '$value (${(percentage * 100).toStringAsFixed(0)}%)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          minHeight: 6,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}
