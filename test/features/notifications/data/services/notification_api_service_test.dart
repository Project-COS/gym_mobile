import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:do_gym/core/network/api_client.dart';
import 'package:do_gym/features/notifications/data/dto/push_device_registration_dto.dart';
import 'package:do_gym/features/notifications/data/services/notification_api_service.dart';

void main() {
  test('registers an authenticated push device', () async {
    late http.Request capturedRequest;
    final service = NotificationApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        accessTokenProvider: () async => 'member-token',
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'success': true, 'message': 'Registered'}),
            200,
          );
        }),
      ),
    );

    await service.registerPushDevice(
      const PushDeviceRegistrationDto(
        registrationToken: 'fcm-registration-token-value',
        platform: 'android',
        permissionStatus: 'authorized',
        locale: 'id-ID',
      ),
    );

    expect(capturedRequest.method, 'POST');
    expect(
      capturedRequest.url.path,
      '/api/mobile/notifications/push-registrations',
    );
    expect(capturedRequest.headers['authorization'], 'Bearer member-token');
    expect(jsonDecode(capturedRequest.body), containsPair('locale', 'id-ID'));
  });

  test('fetches the paginated member inbox', () async {
    late http.Request capturedRequest;
    final service = NotificationApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        accessTokenProvider: () async => 'member-token',
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'success': true,
              'items': <Object>[],
              'unreadCount': 0,
              'pagination': {
                'page': 2,
                'pageSize': 10,
                'totalItems': 0,
                'totalPages': 1,
              },
            }),
            200,
          );
        }),
      ),
    );

    await service.fetchNotifications(page: 2, pageSize: 10);

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/api/mobile/notifications');
    expect(capturedRequest.url.queryParameters, {
      'page': '2',
      'pageSize': '10',
    });
  });
}
