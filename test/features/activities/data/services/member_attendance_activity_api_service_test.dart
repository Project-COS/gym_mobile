import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:do_gym/core/network/api_client.dart';
import 'package:do_gym/features/activities/data/services/member_attendance_activity_api_service.dart';

void main() {
  test(
    'fetches member attendance history with range pagination query',
    () async {
      late http.Request capturedRequest;
      final httpClient = MockClient((request) async {
        capturedRequest = request;

        return http.Response(
          jsonEncode({
            'success': true,
            'attendances': [_attendanceJson()],
            'pagination': {
              'page': 1,
              'pageSize': 50,
              'totalItems': 1,
              'totalPages': 1,
            },
          }),
          200,
        );
      });
      final service = MemberAttendanceActivityApiService(
        apiClient: ApiClient(
          baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
          client: httpClient,
          accessTokenProvider: () async => 'member-token',
        ),
      );

      final response = await service.fetchAttendances(
        range: 'today',
        page: 1,
        pageSize: 50,
      );

      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.url.path, '/api/mobile/attendance');
      expect(capturedRequest.url.queryParameters['range'], 'today');
      expect(capturedRequest.url.queryParameters['pageSize'], '50');
      expect(capturedRequest.headers['authorization'], 'Bearer member-token');
      expect(response.attendances.first.id, 'attendance-1');
    },
  );
}

Map<String, Object?> _attendanceJson() {
  return {
    'id': 'attendance-1',
    'location': {
      'id': 'location-1',
      'name': 'DO GYM Denpasar',
      'area': 'Denpasar',
    },
    'membership': null,
    'checkedInAt': '2026-07-05T00:00:00.000Z',
    'checkedOutAt': null,
    'checkInMethod': 'QR_SCAN',
    'checkOutMethod': null,
    'status': 'OPEN',
    'durationMinutes': null,
  };
}
