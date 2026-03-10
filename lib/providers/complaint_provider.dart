import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/complaint.dart';
import '../services/complaint_service.dart';

class ComplaintProvider with ChangeNotifier {
  final ComplaintService _complaintService;

  List<Complaint> _complaints = [];
  List<Complaint> _filteredComplaints = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastSubmissionTime;
  StreamSubscription<List<Complaint>>? _complaintsSubscription;

  // Filter state
  String _searchQuery = '';
  String? _filterCategory;
  String? _filterStatus;
  String? _filterPriority;
  String _sortBy = 'newest'; // newest, oldest, priority

  ComplaintProvider({ComplaintService? complaintService})
      : _complaintService = complaintService ?? ComplaintService();

  List<Complaint> get complaints => _filteredComplaints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get filterCategory => _filterCategory;
  String? get filterStatus => _filterStatus;
  String? get filterPriority => _filterPriority;
  String get sortBy => _sortBy;

  Future<bool> submitComplaint({
    required String category,
    required String description,
    required String userId,
    required String userEmail,
    String priority = 'Medium',
    List<String> imageUrls = const [],
  }) async {
    final now = DateTime.now();
    if (_lastSubmissionTime != null &&
        now.difference(_lastSubmissionTime!) < const Duration(minutes: 1)) {
      _errorMessage = 'Please wait before submitting another complaint';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final complaint = Complaint(
        id: '',
        userId: userId,
        userEmail: userEmail,
        category: category,
        description: description,
        status: 'Pending',
        priority: priority,
        timestamp: DateTime.now(),
        imageUrls: imageUrls,
      );

      await _complaintService.createComplaint(complaint);
      _lastSubmissionTime = now;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateComplaint({
    required String complaintId,
    required String userId,
    String? category,
    String? description,
    String? priority,
    List<String>? imageUrls,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _complaintService.updateComplaint(
        complaintId: complaintId,
        userId: userId,
        category: category,
        description: description,
        priority: priority,
        imageUrls: imageUrls,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteComplaint(String complaintId, String userId, {bool isAdmin = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _complaintService.deleteComplaint(complaintId, userId, isAdmin: isAdmin);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addNote({
    required String complaintId,
    required String text,
    required String authorId,
    required String authorEmail,
    required bool isAdminNote,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _complaintService.addNote(
        complaintId: complaintId,
        text: text,
        authorId: authorId,
        authorEmail: authorEmail,
        isAdminNote: isAdminNote,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void watchUserComplaints(String userId) {
    _complaintsSubscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _complaintsSubscription =
        _complaintService.getComplaintsByUser(userId).listen(
      (complaints) {
        _complaints = complaints;
        _applyFiltersAndSort();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void watchAllComplaints() {
    _complaintsSubscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _complaintsSubscription = _complaintService.getAllComplaints().listen(
      (complaints) {
        _complaints = complaints;
        _applyFiltersAndSort();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> updateStatus(String complaintId, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _complaintService.updateComplaintStatus(complaintId, newStatus);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Search and filter methods
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setFilterCategory(String? category) {
    _filterCategory = category;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setFilterStatus(String? status) {
    _filterStatus = status;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setFilterPriority(String? priority) {
    _filterPriority = priority;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterCategory = null;
    _filterStatus = null;
    _filterPriority = null;
    _sortBy = 'newest';
    _applyFiltersAndSort();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    List<Complaint> filtered = List.from(_complaints);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((complaint) {
        return complaint.description.toLowerCase().contains(_searchQuery) ||
            complaint.category.toLowerCase().contains(_searchQuery) ||
            complaint.userEmail.toLowerCase().contains(_searchQuery) ||
            complaint.status.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply category filter
    if (_filterCategory != null && _filterCategory != 'All') {
      filtered = filtered
          .where((complaint) => complaint.category == _filterCategory)
          .toList();
    }

    // Apply status filter
    if (_filterStatus != null && _filterStatus != 'All') {
      filtered = filtered
          .where((complaint) => complaint.status == _filterStatus)
          .toList();
    }

    // Apply priority filter
    if (_filterPriority != null && _filterPriority != 'All') {
      filtered = filtered
          .where((complaint) => complaint.priority == _filterPriority)
          .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'oldest':
        filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'priority':
        final priorityOrder = {'Urgent': 0, 'High': 1, 'Medium': 2, 'Low': 3};
        filtered.sort((a, b) {
          final aPriority = priorityOrder[a.priority] ?? 4;
          final bPriority = priorityOrder[b.priority] ?? 4;
          return aPriority.compareTo(bPriority);
        });
        break;
      case 'newest':
      default:
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
    }

    _filteredComplaints = filtered;
  }

  // Get analytics data
  Map<String, int> getCategoryStats() {
    final stats = <String, int>{};
    for (final complaint in _complaints) {
      stats[complaint.category] = (stats[complaint.category] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> getStatusStats() {
    final stats = <String, int>{};
    for (final complaint in _complaints) {
      stats[complaint.status] = (stats[complaint.status] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> getPriorityStats() {
    final stats = <String, int>{};
    for (final complaint in _complaints) {
      stats[complaint.priority] = (stats[complaint.priority] ?? 0) + 1;
    }
    return stats;
  }

  double getAverageResolutionTime() {
    final resolvedComplaints = _complaints
        .where((c) => c.status.toLowerCase() == 'resolved' && c.resolutionTime != null)
        .toList();

    if (resolvedComplaints.isEmpty) return 0;

    final totalHours = resolvedComplaints.fold<int>(
      0,
      (sum, complaint) => sum + (complaint.resolutionTime?.inHours ?? 0),
    );

    return totalHours / resolvedComplaints.length / 24; // Return in days
  }

  double getResolutionRate() {
    if (_complaints.isEmpty) return 0;
    final resolved =
        _complaints.where((c) => c.status.toLowerCase() == 'resolved').length;
    return (resolved / _complaints.length) * 100;
  }

  Future<bool> toggleUpvote(String complaintId, String userId) async {
    try {
      await _complaintService.toggleUpvote(complaintId, userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _complaintsSubscription?.cancel();
    super.dispose();
  }
}
