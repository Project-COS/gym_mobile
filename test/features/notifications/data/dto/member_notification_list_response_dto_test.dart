import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/notifications/data/dto/member_notification_list_response_dto.dart';

void main() {
  test('parses notification inbox response', () {
    final response = MemberNotificationListResponseDto.fromJson({
      'success': true,
      'items': [
        {
          'id': 'notification-1',
          'type': 'MEMBERSHIP_EXPIRING',
          'title': 'Membership segera berakhir',
          'body': 'Paket Gold akan berakhir dalam 3 hari.',
          'data': {'destination': '/membership'},
          'readAt': null,
          'createdAt': '2026-07-11T02:30:00.000Z',
        },
      ],
      'unreadCount': 1,
      'pagination': {
        'page': 1,
        'pageSize': 20,
        'totalItems': 1,
        'totalPages': 1,
      },
    });

    expect(response.items.single.type, 'MEMBERSHIP_EXPIRING');
    expect(response.items.single.data['destination'], '/membership');
    expect(response.items.single.isRead, isFalse);
    expect(response.unreadCount, 1);
  });

  test('rejects an invalid notification timestamp', () {
    expect(
      () => MemberNotificationListResponseDto.fromJson({
        'items': [
          {
            'id': 'notification-1',
            'type': 'TEST',
            'title': 'Title',
            'body': 'Body',
            'data': null,
            'readAt': null,
            'createdAt': 'not-a-date',
          },
        ],
        'unreadCount': 1,
        'pagination': {
          'page': 1,
          'pageSize': 20,
          'totalItems': 1,
          'totalPages': 1,
        },
      }),
      throwsFormatException,
    );
  });
}
