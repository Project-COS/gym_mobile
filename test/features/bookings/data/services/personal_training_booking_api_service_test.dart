import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:do_gym/core/network/api_client.dart';
import 'package:do_gym/features/bookings/data/services/personal_training_booking_api_service.dart';

void main() {
  test('fetches PT booking history with status pagination query', () async {
    late http.Request capturedRequest;
    final httpClient = MockClient((request) async {
      capturedRequest = request;

      return http.Response(
        jsonEncode({
          'success': true,
          'bookings': [_bookingJson(status: 'COMPLETED')],
          'pagination': {
            'page': 1,
            'pageSize': 20,
            'totalItems': 1,
            'totalPages': 1,
          },
        }),
        200,
      );
    });
    final service = PersonalTrainingBookingApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: httpClient,
        accessTokenProvider: () async => 'member-token',
      ),
    );

    final response = await service.fetchBookings(status: 'history');

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/api/mobile/bookings/personal-training');
    expect(capturedRequest.url.queryParameters['status'], 'history');
    expect(capturedRequest.url.queryParameters['page'], '1');
    expect(capturedRequest.headers['authorization'], 'Bearer member-token');
    expect(response.bookings.first.status, 'COMPLETED');
  });
}

Map<String, Object?> _bookingJson({required String status}) {
  return {
    'id': 'booking-1',
    'bookingCode': 'PTB-TEST001',
    'qrPayload': 'pt_booking:PTB-TEST001',
    'source': 'CUSTOM_SESSION',
    'status': status,
    'startsAt': '2026-06-24T01:00:00.000Z',
    'endsAt': '2026-06-24T02:00:00.000Z',
    'notes': null,
    'trainer': {
      'id': 'trainer-1',
      'name': 'Coach Maya',
      'specialty': 'Strength',
    },
    'program': {
      'id': 'program-1',
      'name': 'Strength PT',
      'durationMinutes': 60,
    },
    'location': {
      'id': 'location-1',
      'name': 'DO GYM Denpasar',
      'area': 'Denpasar',
      'address': 'Jl. Gatot Subroto',
    },
  };
}
