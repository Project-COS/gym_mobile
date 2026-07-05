import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:do_gym/core/network/api_client.dart';
import 'package:do_gym/features/classes/data/services/booking_class_api_service.dart';

void main() {
  test(
    'fetches classes across all locations when location is omitted',
    () async {
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
              'startsTo': '2026-06-17T00:00:00.000Z',
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

      await service.fetchClasses(
        startsFrom: DateTime.utc(2026, 6, 16),
        startsTo: DateTime.utc(2026, 6, 17),
      );

      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.url.path, '/api/mobile/classes');
      expect(
        capturedRequest.url.queryParameters.containsKey('locationId'),
        false,
      );
      expect(capturedRequest.headers['authorization'], 'Bearer member-token');
    },
  );

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

  test('fetches class booking history with status pagination query', () async {
    late http.Request capturedRequest;
    final httpClient = MockClient((request) async {
      capturedRequest = request;

      return http.Response(
        jsonEncode({
          'success': true,
          'bookings': [
            {
              'id': 'class-booking-1',
              'bookingCode': 'CLB-TEST001',
              'qrPayload': 'class_booking:CLB-TEST001',
              'className': 'Yoga Flow',
              'source': 'MOBILE_APP',
              'status': 'COMPLETED',
              'startsAt': '2026-06-16T10:00:00.000Z',
              'endsAt': '2026-06-16T11:00:00.000Z',
              'notes': null,
              'class': {
                'id': 'class-1',
                'name': 'Yoga Flow',
                'durationMinutes': 60,
              },
              'session': {'id': 'session-1', 'roomName': 'Studio 1'},
              'trainer': {
                'id': 'trainer-1',
                'name': 'Coach Maya',
                'specialty': 'Yoga',
              },
              'location': {
                'id': 'location-1',
                'name': 'DO GYM Denpasar',
                'area': 'Denpasar',
                'address': 'Jl. Gatot Subroto',
              },
            },
          ],
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
    final service = BookingClassApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: httpClient,
        accessTokenProvider: () async => 'member-token',
      ),
    );

    final response = await service.fetchBookings(status: 'all', pageSize: 50);

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/api/mobile/bookings/classes');
    expect(capturedRequest.url.queryParameters['status'], 'all');
    expect(capturedRequest.url.queryParameters['page'], '1');
    expect(capturedRequest.url.queryParameters['pageSize'], '50');
    expect(capturedRequest.headers['authorization'], 'Bearer member-token');
    expect(response.bookings.single.bookingCode, 'CLB-TEST001');
  });

  test('creates class booking through mobile class booking endpoint', () async {
    late http.Request capturedRequest;
    final httpClient = MockClient((request) async {
      capturedRequest = request;

      return http.Response(
        jsonEncode({
          'success': true,
          'booking': {
            'id': 'class-booking-1',
            'bookingCode': 'CLB-TEST001',
            'qrPayload': 'class_booking:CLB-TEST001',
            'className': 'Yoga Flow',
            'source': 'AD_HOC',
            'status': 'SCHEDULED',
            'startsAt': '2026-06-16T10:00:00.000Z',
            'endsAt': '2026-06-16T11:00:00.000Z',
            'notes': null,
            'class': {
              'id': 'class-1',
              'name': 'Yoga Flow',
              'durationMinutes': 60,
            },
            'session': {'id': 'session-1', 'roomName': 'Studio 1'},
            'trainer': {
              'id': 'trainer-1',
              'name': 'Coach Maya',
              'specialty': 'Yoga',
            },
            'location': {
              'id': 'location-1',
              'name': 'DO GYM Denpasar',
              'area': 'Denpasar',
              'address': 'Jl. Gatot Subroto',
            },
          },
        }),
        201,
      );
    });
    final service = BookingClassApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: httpClient,
        accessTokenProvider: () async => 'member-token',
      ),
    );

    final response = await service.createClassBooking(
      classSessionId: 'session-1',
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/api/mobile/bookings/classes');
    expect(capturedRequest.headers['authorization'], 'Bearer member-token');
    expect(jsonDecode(capturedRequest.body), {'classSessionId': 'session-1'});
    expect(response.booking.bookingCode, 'CLB-TEST001');
  });
}
