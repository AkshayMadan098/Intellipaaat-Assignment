import 'dart:async';
import 'package:new_project/core/network/network_info.dart';

class TestNetworkInfo implements NetworkInfo {
  bool _isConnected;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  TestNetworkInfo({bool isConnected = true}) : _isConnected = isConnected;

  @override
  Future<bool> get isConnected async => _isConnected;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void setConnected(bool value) {
    _isConnected = value;
    _controller.add(value);
  }

  void dispose() {
    _controller.close();
  }
}
