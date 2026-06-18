import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:do_gym/core/network/api_client.dart';
import 'package:do_gym/features/booking/data/services/booking_class_api_service.dart';

void main() {
  test('fetches classes with location and date query parameters', () async {
    late http.Request capturedRequest;
    final httpClient = MockClient((request) async {
      capturedRequest = request;

      return http.Response(
        jsonEncode({
          'success': true,
          'categories': <Object>[],
          'classes': <Object>[],
          'range': {
            'startsFrom': '2026-06-16T00:00:00.000Z',
            'startsTo': '2026-06-30T00:00:00.000Z',
          },
        }),
        200,
      );
    });
    final service = BookingClassApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: httpClient,
        accessTokenProvider: () async => 'member-token',
      ),
    );

    final response = await service.fetchClassesForLocation(
      locationId: 'location-1',
      startsFrom: DateTime.utc(2026, 6, 16),
      startsTo: DateTime.utc(2026, 6, 30),
    );

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/api/mobile/classes');
    expect(capturedRequest.url.queryParameters['locationId'], 'location-1');
    expect(capturedRequest.url.queryParameters['startsFrom'], contains('2026'));
    expect(capturedRequest.headers['authorization'], 'Bearer member-token');
    expect(response.classes, isEmpty);
  });
}
