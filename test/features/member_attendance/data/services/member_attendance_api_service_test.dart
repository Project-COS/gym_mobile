import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:do_gym/core/network/api_client.dart';
import 'package:do_gym/features/member_attendance/data/services/member_attendance_api_service.dart';

void main() {
  test(
    'creates member attendance QR through authenticated POST endpoint',
    () async {
      late http.Request capturedRequest;
      final httpClient = MockClient((request) async {
        capturedRequest = request;

        return http.Response(
          jsonEncode({'success': true, 'data': _qrDataJson()}),
          200,
        );
      });
      final service = MemberAttendanceApiService(
        apiClient: ApiClient(
          baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
          client: httpClient,
          accessTokenProvider: () async => 'member-token',
        ),
      );

      final response = await service.createMemberAttendanceQr();

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.path, '/api/mobile/attendance/qr');
      expect(capturedRequest.headers['authorization'], 'Bearer member-token');
      expect(response.data.member.memberCode, 'MEM-001');
    },
  );
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
