import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/activities/data/dto/member_attendance_history_response_dto.dart';

void main() {
  test('parses member attendance history response', () {
    final response = MemberAttendanceHistoryResponseDto.fromJson({
      'success': true,
      'attendances': [_attendanceJson()],
      'pagination': {
        'page': 1,
        'pageSize': 20,
        'totalItems': 1,
        'totalPages': 1,
      },
    });

    expect(response.attendances, hasLength(1));
    expect(response.attendances.first.location.name, 'DO GYM Denpasar');
    expect(response.attendances.first.membership?.planName, 'Premium Access');
    expect(response.attendances.first.status, 'COMPLETED');
    expect(response.pagination.totalItems, 1);
  });

  test('rejects missing attendance list', () {
    expect(
      () => MemberAttendanceHistoryResponseDto.fromJson({
        'success': true,
        'pagination': {
          'page': 1,
          'pageSize': 20,
          'totalItems': 0,
          'totalPages': 1,
        },
      }),
      throwsFormatException,
    );
  });
}

Map<String, Object?> _attendanceJson() {
  return {
    'id': 'attendance-1',
    'location': {
      'id': 'location-1',
      'name': 'DO GYM Denpasar',
      'area': 'Denpasar',
    },
    'membership': {
      'id': 'membership-1',
      'planName': 'Premium Access',
      'startsAt': '2026-07-01T00:00:00.000Z',
      'expiresAt': '2026-07-31T00:00:00.000Z',
    },
    'checkedInAt': '2026-07-05T00:00:00.000Z',
    'checkedOutAt': '2026-07-05T01:15:00.000Z',
    'checkInMethod': 'QR_SCAN',
    'checkOutMethod': 'QR_SCAN',
    'status': 'COMPLETED',
    'durationMinutes': 75,
  };
}
