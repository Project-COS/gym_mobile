import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/network/api_exception.dart';
import 'package:do_gym/features/member_attendance/data/repositories/member_attendance_repository.dart';
import 'package:do_gym/features/member_attendance/presentation/cubit/member_attendance_qr_cubit.dart';

void main() {
  test('loads member attendance QR', () async {
    final cubit = MemberAttendanceQrCubit(
      repository: _FakeMemberAttendanceRepository(),
    );

    await cubit.createQr();

    expect(cubit.state.status, MemberAttendanceQrLoadStatus.success);
    expect(cubit.state.qr?.memberCode, 'MEM-001');

    await cubit.close();
  });

  test('maps conflict errors into active membership message', () async {
    final cubit = MemberAttendanceQrCubit(
      repository: _FakeMemberAttendanceRepository(
        error: const ApiException(
          type: ApiExceptionType.conflict,
          message: 'Active membership required.',
          statusCode: 409,
        ),
      ),
    );

    await cubit.createQr();

    expect(cubit.state.status, MemberAttendanceQrLoadStatus.failure);
    expect(cubit.state.errorMessage, contains('Membership aktif'));

    await cubit.close();
  });
}

class _FakeMemberAttendanceRepository implements MemberAttendanceRepository {
  _FakeMemberAttendanceRepository({this.error});

  final Object? error;

  @override
  Future<MemberAttendanceQr> createMemberAttendanceQr() async {
    final Object? error = this.error;

    if (error != null) {
      throw error;
    }

    return MemberAttendanceQr(
      qrPayload: 'member_checkin:token',
      expiresAt: DateTime.now().add(const Duration(minutes: 2)),
      memberName: 'Andi Member',
      memberCode: 'MEM-001',
      planName: 'Premium Access',
      membershipExpiresAt: DateTime(2026, 7, 31),
      membershipExpiryLabel: '31 Jul 2026',
      qrExpiryLabel: '12:00',
    );
  }
}
