import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session_storage.dart';

// Platform-backed session storage. The wrapper keeps flutter_secure_storage out
// of repositories so tests can use an in-memory SessionStorage instead.
class SecureSessionStorage implements SessionStorage {
  const SecureSessionStorage({
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
  }) : _secureStorage = secureStorage;

  // Version the key so a future incompatible session format can migrate without
  // accidentally parsing old values as the new shape.
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
