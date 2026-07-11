import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/notifications/data/dto/member_notification_dto.dart';
import 'package:do_gym/features/notifications/data/dto/push_device_registration_dto.dart';
import 'package:do_gym/features/notifications/data/repositories/notification_repository.dart';
import 'package:do_gym/features/notifications/presentation/cubit/notification_inbox_cubit.dart';

void main() {
  test('loads inbox and marks one notification read', () async {
    final repository = _FakeNotificationRepository();
    final cubit = NotificationInboxCubit(repository: repository);

    await cubit.fetchNotifications();
    expect(cubit.state.status, NotificationInboxLoadStatus.success);
    expect(cubit.state.unreadCount, 1);

    await cubit.markNotificationRead('notification-1');
    expect(repository.readNotificationId, 'notification-1');
    expect(cubit.state.items.single.isRead, isTrue);
    expect(cubit.state.unreadCount, 0);

    await cubit.close();
  });
}

class _FakeNotificationRepository implements NotificationRepository {
  String? readNotificationId;

  @override
  Future<MemberNotificationInboxResult> fetchNotifications({
    required int page,
    required int pageSize,
  }) async {
    return MemberNotificationInboxResult(
      items: [
        MemberNotificationDto(
          id: 'notification-1',
          type: 'TEST',
          title: 'Test notification',
          body: 'Test body',
          data: const {},
          readAt: null,
          createdAt: DateTime.utc(2026, 7, 11),
        ),
      ],
      unreadCount: 1,
      page: page,
      pageSize: pageSize,
      totalItems: 1,
      totalPages: 1,
    );
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    readNotificationId = notificationId;
  }

  @override
  Future<void> markAllNotificationsRead() async {}

  @override
  Future<void> registerPushDevice(
    PushDeviceRegistrationDto registration,
  ) async {}

  @override
  Future<void> disablePushDevice({String? registrationToken}) async {}
}
