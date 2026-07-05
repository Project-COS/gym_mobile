import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/network/api_exception.dart';
import 'package:do_gym/features/activities/data/repositories/member_attendance_activity_repository.dart';
import 'package:do_gym/features/activities/presentation/cubit/member_attendance_activity_cubit.dart';

void main() {
  test('loads member attendance activity history', () async {
    final cubit = MemberAttendanceActivityCubit(
      repository: _FakeMemberAttendanceActivityRepository(
        page: MemberAttendanceHistoryPage(
          items: [_createAttendance()],
          totalItems: 1,
        ),
      ),
    );

    await cubit.fetchAttendances(filter: MemberAttendanceHistoryFilter.today);

    expect(cubit.state.status, MemberAttendanceActivityLoadStatus.success);
    expect(cubit.state.filter, MemberAttendanceHistoryFilter.today);
    expect(cubit.state.items.first.locationName, 'DO GYM Denpasar');

    await cubit.close();
  });

  test('maps API errors into user-friendly message', () async {
    final cubit = MemberAttendanceActivityCubit(
      repository: _FakeMemberAttendanceActivityRepository(
        error: const ApiException(
          type: ApiExceptionType.timeout,
          message: 'Timeout',
        ),
      ),
    );

    await cubit.fetchAttendances();

    expect(cubit.state.status, MemberAttendanceActivityLoadStatus.failure);
    expect(cubit.state.errorMessage, contains('terlalu lama'));

    await cubit.close();
  });
}

class _FakeMemberAttendanceActivityRepository
    implements MemberAttendanceActivityRepository {
  _FakeMemberAttendanceActivityRepository({
    this.page = const MemberAttendanceHistoryPage(items: [], totalItems: 0),
    this.error,
  });

  final MemberAttendanceHistoryPage page;
  final Object? error;

  @override
  Future<MemberAttendanceHistoryPage> fetchMemberAttendanceHistory({
    MemberAttendanceHistoryFilter filter = MemberAttendanceHistoryFilter.all,
  }) async {
    final Object? error = this.error;

    if (error != null) {
      throw error;
    }

    return page;
  }
}

MemberAttendanceHistoryItem _createAttendance() {
  return MemberAttendanceHistoryItem(
    id: 'attendance-1',
    locationName: 'DO GYM Denpasar',
    locationArea: 'Denpasar',
    planName: 'Premium Access',
    checkedInAt: DateTime(2026, 7, 5, 8, 0),
    checkedOutAt: DateTime(2026, 7, 5, 9, 15),
    status: 'COMPLETED',
    durationMinutes: 75,
  );
}
