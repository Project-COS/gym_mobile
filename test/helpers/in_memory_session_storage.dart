import 'package:do_gym/core/session/session_storage.dart';

class InMemorySessionStorage implements SessionStorage {
  InMemorySessionStorage({this.value, this.readError});

  String? value;
  Object? readError;
  int deleteCount = 0;

  @override
  Future<String?> read() async {
    final error = readError;

    if (error != null) {
      throw error;
    }

    return value;
  }

  @override
  Future<void> write(String value) async {
    this.value = value;
  }

  @override
  Future<void> delete() async {
    deleteCount += 1;
    value = null;
  }
}
