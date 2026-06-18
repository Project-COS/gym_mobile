import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:do_gym/core/network/api_client.dart';
import 'package:do_gym/features/auth/data/dto/login_request_dto.dart';
import 'package:do_gym/features/auth/data/services/auth_api_service.dart';

void main() {
  test('posts login credentials without Bearer authorization', () async {
    late http.Request capturedRequest;
    final httpClient = MockClient((request) async {
      capturedRequest = request;

      return http.Response(
        jsonEncode({
          'success': true,
          'token': 'member-token',
          'expiresAt': '2026-06-13T12:00:00.000Z',
          'member': {
            'id': 'member-1',
            'memberCode': 'MEM-001',
            'name': 'Member Test',
            'email': 'member@example.com',
            'phone': null,
            'company': {'id': 'company-1', 'name': 'DO GYM'},
          },
        }),
        200,
      );
    });
    final service = AuthApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: httpClient,
        accessTokenProvider: () async => 'existing-token',
      ),
    );

    final response = await service.login(
      const LoginRequestDto(
        email: ' Member@Example.com ',
        password: 'password123',
      ),
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/api/mobile/auth/login');
    expect(capturedRequest.headers['authorization'], isNull);
    expect(jsonDecode(capturedRequest.body), {
      'email': 'member@example.com',
      'password': 'password123',
    });
    expect(response.token, 'member-token');
  });
}
