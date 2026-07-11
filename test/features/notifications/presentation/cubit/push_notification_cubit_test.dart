import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/notifications/data/dto/push_device_registration_dto.dart';
import 'package:do_gym/features/notifications/data/repositories/notification_repository.dart';
import 'package:do_gym/features/notifications/data/services/push_notification_service.dart';
import 'package:do_gym/features/notifications/presentation/cubit/push_notification_cubit.dart';

void main() {
  test('uploads the FCM token after permission is granted', () async {
    final repository = _RecordingNotificationRepository();
    final cubit = PushNotificationCubit(
      repository: repository,
      pushNotificationService: _FakePushNotificationService(),
    );

    await cubit.startForAuthenticatedMember(locale: 'id-ID');

    expect(cubit.state.status, PushNotificationLifecycleStatus.ready);
    expect(repository.registration?.registrationToken, 'firebase-token-value');
    expect(repository.registration?.permissionStatus, 'authorized');
    expect(repository.registration?.locale, 'id-ID');

    await cubit.close();
  });
}

class _FakePushNotificationService implements PushNotificationService {
  @override
  String get currentPlatform => 'android';

  @override
  Stream<PushNotificationEvent> get foregroundMessages => const Stream.empty();

  @override
  Stream<Map<String, String>> get openedNotifications => const Stream.empty();

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Future<String?> getRegistrationToken() async => 'firebase-token-value';

  @override
  Future<void> initialize() async {}

  @override
  Future<PushAuthorizationStatus> requestPermission() async {
    return PushAuthorizationStatus.authorized;
  }
}

class _RecordingNotificationRepository implements NotificationRepository {
  PushDeviceRegistrationDto? registration;

  @override
  Future<void> registerPushDevice(
    PushDeviceRegistrationDto registration,
  ) async {
    this.registration = registration;
  }

  @override
  Future<void> disablePushDevice({String? registrationToken}) async {}

  @override
  Future<MemberNotificationInboxResult> fetchNotifications({
    required int page,
    required int pageSize,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> markAllNotificationsRead() async {}

  @override
  Future<void> markNotificationRead(String notificationId) async {}
}
