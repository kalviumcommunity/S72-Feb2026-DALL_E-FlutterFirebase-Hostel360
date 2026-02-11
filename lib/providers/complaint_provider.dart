import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/complaint.dart';
import '../services/complaint_service.dart';

class ComplaintProvider with ChangeNotifier {
  final ComplaintService _complaintService;
  
  List<Complaint> _complaints = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastSubmissionTime;
  StreamSubscription<List<Complaint>>? _complaintsSubscription;

  ComplaintProvider({ComplaintService? complaintService})
      : _complaintService = complaintService ?? ComplaintService();

  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> submitComplaint(String category, String description, String userId, String userEmail) async {
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
        timestamp: DateTime.now(),
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

  void watchUserComplaints(String userId) {
    _complaintsSubscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _complaintsSubscription = _complaintService.getComplaintsByUser(userId).listen(
      (complaints) {
        _complaints = complaints;
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

  @override
  void dispose() {
    _complaintsSubscription?.cancel();
    super.dispose();
  }
}
