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
  static const String memberAttendances = 'attendance';
  static const String memberAttendanceQr = 'attendance/qr';
  static const String shareLinks = 'share-links';
  static const String notifications = 'notifications';
  static const String notificationPushRegistrations =
      'notifications/push-registrations';
  static const String readAllNotifications = 'notifications/read-all';

  static String readNotification(String notificationId) {
    return 'notifications/$notificationId/read';
  }

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
