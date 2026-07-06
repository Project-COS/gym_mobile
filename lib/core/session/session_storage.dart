// Minimal storage contract for persisted sessions. Implementations can be
// secure platform storage in production or simple fakes in unit tests.
abstract interface class SessionStorage {
  Future<String?> read();

  Future<void> write(String value);

  Future<void> delete();
}
