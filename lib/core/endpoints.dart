class ApiEndpoints {
  const ApiEndpoints._();

  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String currentMember = 'me';
  static const String locations = 'locations';
  static const String classes = 'classes';

  static String locationTrainers(String locationId) {
    return 'locations/$locationId/trainers';
  }
}
