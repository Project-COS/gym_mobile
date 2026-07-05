import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/activities/data/dto/member_attendance_history_response_dto.dart';
import 'package:do_gym/features/activities/data/repositories/member_attendance_activity_repository.dart';
import 'package:do_gym/features/activities/data/services/member_attendance_activity_api_service.dart';

void main() {
  test('maps attendance history response into app data', () async {
    final repository = RemoteMemberAttendanceActivityRepository(
      apiService: _FakeMemberAttendanceActivityApiService(
        response: MemberAttendanceHistoryResponseDto.fromJson({
          'success': true,
          'attendances': [_attendanceJson()],
          'pagination': {
            'page': 1,
            'pageSize': 50,
            'totalItems': 1,
            'totalPages': 1,
          },
        }),
      ),
    );

    final page = await repository.fetchMemberAttendanceHistory(
      filter: MemberAttendanceHistoryFilter.today,
    );

    expect(page.totalItems, 1);
    expect(page.items.first.locationName, 'DO GYM Denpasar');
    expect(page.items.first.locationArea, 'Denpasar');
    expect(page.items.first.durationMinutes, 75);
  });
}

class _FakeMemberAttendanceActivityApiService
    implements MemberAttendanceActivityApiService {
  _FakeMemberAttendanceActivityApiService({required this.response});

  final MemberAttendanceHistoryResponseDto response;

  @override
  Future<MemberAttendanceHistoryResponseDto> fetchAttendances({
    required String range,
    int page = 1,
    int pageSize = 20,
  }) async {
    return response;
  }
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
