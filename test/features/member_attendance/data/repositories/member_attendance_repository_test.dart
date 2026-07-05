import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/member_attendance/data/dto/member_attendance_qr_response_dto.dart';
import 'package:do_gym/features/member_attendance/data/repositories/member_attendance_repository.dart';
import 'package:do_gym/features/member_attendance/data/services/member_attendance_api_service.dart';

void main() {
  test('maps member attendance QR response into app data', () async {
    final repository = RemoteMemberAttendanceRepository(
      apiService: _FakeMemberAttendanceApiService(
        response: MemberAttendanceQrResponseDto.fromJson({
          'success': true,
          'data': _qrDataJson(),
        }),
      ),
    );

    final qr = await repository.createMemberAttendanceQr();

    expect(qr.qrPayload, 'member_checkin:token');
    expect(qr.memberCode, 'MEM-001');
    expect(qr.memberName, 'Andi Member');
    expect(qr.planName, 'Premium Access');
    expect(qr.membershipExpiryLabel, '31 Jul 2026');
  });
}

class _FakeMemberAttendanceApiService implements MemberAttendanceApiService {
  _FakeMemberAttendanceApiService({required this.response});

  final MemberAttendanceQrResponseDto response;

  @override
  Future<MemberAttendanceQrResponseDto> createMemberAttendanceQr() async {
    return response;
  }
}

Map<String, Object?> _qrDataJson() {
  return {
    'qrPayload': 'member_checkin:token',
    'expiresAt': '2026-07-04T04:05:00.000Z',
    'member': {
      'id': 'member-1',
      'memberCode': 'MEM-001',
      'name': 'Andi Member',
      'email': 'member@example.com',
      'phone': '+628123',
    },
    'activeMembership': {
      'id': 'membership-1',
      'planName': 'Premium Access',
      'startsAt': '2026-07-01T00:00:00.000Z',
      'expiresAt': '2026-07-31T04:00:00.000Z',
    },
  };
}
