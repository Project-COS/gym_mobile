import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/notifications/data/dto/member_notification_list_response_dto.dart';
import 'package:do_gym/features/notifications/data/dto/push_device_registration_dto.dart';
import 'package:do_gym/features/notifications/data/repositories/notification_repository.dart';
import 'package:do_gym/features/notifications/data/services/notification_api_service.dart';

void main() {
  test('maps the notification API response into an inbox result', () async {
    final repository = RemoteNotificationRepository(
      apiService: _FakeNotificationApiService(),
    );

    final result = await repository.fetchNotifications(page: 1, pageSize: 20);

    expect(result.items.single.title, 'Membership segera berakhir');
    expect(result.unreadCount, 1);
    expect(result.totalItems, 1);
  });
}

class _FakeNotificationApiService implements NotificationApiService {
  @override
  Future<MemberNotificationListResponseDto> fetchNotifications({
    required int page,
    required int pageSize,
  }) async {
    return MemberNotificationListResponseDto.fromJson({
      'items': [
        {
          'id': 'notification-1',
          'type': 'MEMBERSHIP_EXPIRING',
          'title': 'Membership segera berakhir',
          'body': 'Paket Gold akan berakhir dalam 3 hari.',
          'data': const <String, Object?>{},
          'readAt': null,
          'createdAt': '2026-07-11T02:30:00.000Z',
        },
      ],
      'unreadCount': 1,
      'pagination': {
        'page': page,
        'pageSize': pageSize,
        'totalItems': 1,
        'totalPages': 1,
      },
    });
  }

  @override
  Future<void> registerPushDevice(
    PushDeviceRegistrationDto registration,
  ) async {}

  @override
  Future<void> disablePushDevice({String? registrationToken}) async {}

  @override
  Future<void> markAllNotificationsRead() async {}

  @override
  Future<void> markNotificationRead(String notificationId) async {}
}
