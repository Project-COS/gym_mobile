class ApiEndpoints {
  const ApiEndpoints._();

  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String currentMember = 'me';
  static const String locations = 'locations';
  static const String classes = 'classes';
  static const String trainers = 'trainers';
  static const String personalTrainingBookings = 'bookings/personal-training';
  static const String classBookings = 'bookings/classes';
  static const String memberAttendanceQr = 'attendance/qr';

  static String locationTrainers(String locationId) {
    return 'locations/$locationId/trainers';
  }

  static String trainerDetail(String trainerId) {
    return 'trainers/$trainerId';
  }

  static String trainerRating(String trainerId) {
    return 'trainers/$trainerId/rating';
  }
}
