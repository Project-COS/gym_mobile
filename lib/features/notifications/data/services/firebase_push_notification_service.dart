import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../firebase_options.dart';
import 'push_notification_service.dart';

const AndroidNotificationChannel memberUpdatesNotificationChannel =
    AndroidNotificationChannel(
      'member_updates',
      'Member updates',
      description: 'Membership, booking, payment, and gym updates.',
      importance: Importance.high,
    );

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background execution owns a separate isolate on Android. Initialize only
  // Firebase here; notification payloads are displayed by the operating system.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class FirebasePushNotificationService implements PushNotificationService {
  FirebasePushNotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final StreamController<PushNotificationEvent> _foregroundMessageController =
      StreamController<PushNotificationEvent>.broadcast();
  final StreamController<Map<String, String>> _openedNotificationController =
      StreamController<Map<String, String>>.broadcast();

  bool _initialized = false;

  @override
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  @override
  Stream<PushNotificationEvent> get foregroundMessages =>
      _foregroundMessageController.stream;

  @override
  Stream<Map<String, String>> get openedNotifications =>
      _openedNotificationController.stream;

  @override
  String get currentPlatform {
    if (kIsWeb) {
      return 'web';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => 'ios',
      _ => 'android',
    };
  }

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_gym_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final data = _decodeNotificationPayload(response.payload);

        if (data.isNotEmpty) {
          _openedNotificationController.add(data);
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(memberUpdatesNotificationChannel);

    // Foreground messages are displayed by the local notification plugin on
    // both platforms, so native foreground presentation remains disabled.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    FirebaseMessaging.onMessage.listen(_receiveForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) =>
          _openedNotificationController.add(_normalizeData(message.data)),
    );
    _initialized = true;

    final initialRemoteMessage = await _messaging.getInitialMessage();

    if (initialRemoteMessage != null) {
      _openedNotificationController.add(
        _normalizeData(initialRemoteMessage.data),
      );
    }

    final localLaunchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    final localPayload = localLaunchDetails?.notificationResponse?.payload;

    if (localLaunchDetails?.didNotificationLaunchApp ?? false) {
      final data = _decodeNotificationPayload(localPayload);

      if (data.isNotEmpty) {
        _openedNotificationController.add(data);
      }
    }
  }

  @override
  Future<PushAuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    return switch (settings.authorizationStatus) {
      AuthorizationStatus.authorized => PushAuthorizationStatus.authorized,
      AuthorizationStatus.provisional => PushAuthorizationStatus.provisional,
      AuthorizationStatus.denied => PushAuthorizationStatus.denied,
      AuthorizationStatus.notDetermined =>
        PushAuthorizationStatus.notDetermined,
    };
  }

  @override
  Future<String?> getRegistrationToken() async {
    // Apple requires an APNs token before making FCM token API requests. A real
    // device may need a short time after permission is granted to receive it.
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      var applePushToken = await _messaging.getAPNSToken();

      for (var attempt = 0; attempt < 10 && applePushToken == null; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        applePushToken = await _messaging.getAPNSToken();
      }

      if (applePushToken == null) {
        return null;
      }
    }

    return _messaging.getToken();
  }

  Future<void> _receiveForegroundMessage(RemoteMessage message) async {
    final event = PushNotificationEvent(
      title: message.notification?.title,
      body: message.notification?.body,
      data: _normalizeData(message.data),
    );
    final title = event.title;
    final body = event.body;

    if ((title?.isNotEmpty ?? false) || (body?.isNotEmpty ?? false)) {
      await _localNotifications.show(
        _notificationId(message),
        title ?? 'Do Gym',
        body ?? 'You have a new update.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'member_updates',
            'Member updates',
            channelDescription:
                'Membership, booking, payment, and gym updates.',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_stat_gym_notification',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(event.data),
      );
    }

    _foregroundMessageController.add(event);
  }

  int _notificationId(RemoteMessage message) {
    return (message.messageId ?? message.hashCode.toString()).hashCode &
        0x7fffffff;
  }

  Map<String, String> _decodeNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic>
          ? _normalizeData(decoded)
          : const {};
    } on FormatException {
      return const {};
    }
  }

  Map<String, String> _normalizeData(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, value.toString()));
  }
}
