import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  bool _isOnline = true;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _isOnline = !results.contains(ConnectivityResult.none) && results.isNotEmpty;
    _connectionStatusController.add(_isOnline);
  }

  bool get isOnline => _isOnline;

  void dispose() {
    _connectionStatusController.close();
  }
}
