import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session_storage.dart';

class SecureSessionStorage implements SessionStorage {
  const SecureSessionStorage({
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
  }) : _secureStorage = secureStorage;

  static const String _sessionKey = 'do_gym.auth_session.v1';

  final FlutterSecureStorage _secureStorage;

  @override
  Future<String?> read() {
    return _secureStorage.read(key: _sessionKey);
  }

  @override
  Future<void> write(String value) {
    return _secureStorage.write(key: _sessionKey, value: value);
  }

  @override
  Future<void> delete() {
    return _secureStorage.delete(key: _sessionKey);
  }
}
