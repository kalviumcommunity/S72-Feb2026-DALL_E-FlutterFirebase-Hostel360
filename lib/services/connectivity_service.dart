import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  bool _isOnline = true;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _isOnline = result != ConnectivityResult.none;
    _connectionStatusController.add(_isOnline);
  }

  bool get isOnline => _isOnline;

  void dispose() {
    _connectionStatusController.close();
  }
}
