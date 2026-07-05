import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/activities/data/activity_data.dart';
import 'package:do_gym/features/activities/data/member_attendance_activity_mapper.dart';
import 'package:do_gym/features/activities/data/repositories/member_attendance_activity_repository.dart';

void main() {
  test('maps completed member attendance into activity history item', () {
    final item = mapMemberAttendanceToActivityHistoryItem(
      MemberAttendanceHistoryItem(
        id: 'attendance-1',
        locationName: 'DO GYM Denpasar',
        locationArea: 'Denpasar',
        planName: 'Premium Access',
        checkedInAt: DateTime(2026, 7, 5, 8, 0),
        checkedOutAt: DateTime(2026, 7, 5, 9, 15),
        status: 'COMPLETED',
        durationMinutes: 75,
      ),
      isFeatured: true,
    );

    expect(item.tab, ActivityTab.attendance);
    expect(item.title, 'DO GYM Denpasar');
    expect(item.status, 'Hadir');
    expect(item.isFeatured, isTrue);
    expect(item.metas.map((meta) => meta.value), contains('09:15'));
    expect(item.metas.map((meta) => meta.value), contains('1j 15m'));
  });

  test('maps open member attendance into ongoing activity history item', () {
    final item = mapMemberAttendanceToActivityHistoryItem(
      MemberAttendanceHistoryItem(
        id: 'attendance-1',
        locationName: 'DO GYM Renon',
        locationArea: 'Renon',
        planName: 'Premium Access',
        checkedInAt: DateTime(2026, 7, 5, 10, 0),
        checkedOutAt: null,
        status: 'OPEN',
        durationMinutes: null,
      ),
    );

    expect(item.status, 'Berlangsung');
    expect(item.metas.map((meta) => meta.value), contains('Belum check-out'));
    expect(item.metas.map((meta) => meta.value), contains('Berlangsung'));
  });
}
