import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/member_attendance/data/dto/member_attendance_qr_response_dto.dart';

void main() {
  test('parses member attendance QR response', () {
    final response = MemberAttendanceQrResponseDto.fromJson({
      'success': true,
      'data': _qrDataJson(),
    });

    expect(response.data.qrPayload, 'member_checkin:token');
    expect(response.data.member.memberCode, 'MEM-001');
    expect(response.data.activeMembership.planName, 'Premium Access');
  });

  test('rejects missing QR payload', () {
    final data = _qrDataJson()..remove('qrPayload');

    expect(
      () => MemberAttendanceQrResponseDto.fromJson({
        'success': true,
        'data': data,
      }),
      throwsFormatException,
    );
  });
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
      'expiresAt': '2026-07-31T23:59:59.000Z',
    },
  };
}
