import 'dart:async';

enum PushAuthorizationStatus { notDetermined, authorized, provisional, denied }

class PushNotificationEvent {
  const PushNotificationEvent({
    required this.title,
    required this.body,
    required this.data,
  });

  final String? title;
  final String? body;
  final Map<String, String> data;
}

abstract interface class PushNotificationService {
  Future<void> initialize();

  Future<PushAuthorizationStatus> requestPermission();

  Future<String?> getRegistrationToken();

  String get currentPlatform;

  Stream<String> get tokenRefreshes;

  Stream<PushNotificationEvent> get foregroundMessages;

  Stream<Map<String, String>> get openedNotifications;
}
