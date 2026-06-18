import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:do_gym/core/network/api_client.dart';
import 'package:do_gym/core/network/api_exception.dart';

void main() {
  group('ApiClient', () {
    test('adds query parameters and Bearer authorization', () async {
      late http.Request capturedRequest;
      final mockClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({'success': true, 'locations': <Object>[]}),
          200,
        );
      });
      final apiClient = ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile'),
        client: mockClient,
        accessTokenProvider: () async => 'member-token',
      );

      final result = await apiClient.get(
        'locations',
        queryParameters: {'area': 'Denpasar'},
      );

      expect(capturedRequest.url.path, '/api/mobile/locations');
      expect(capturedRequest.url.queryParameters['area'], 'Denpasar');
      expect(capturedRequest.headers['authorization'], 'Bearer member-token');
      expect(result, {'success': true, 'locations': <Object>[]});
    });

    test('sends a JSON body without authorization when disabled', () async {
      late http.Request capturedRequest;
      final mockClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(jsonEncode({'success': true}), 200);
      });
      final apiClient = ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: mockClient,
        accessTokenProvider: () async => 'member-token',
      );

      await apiClient.post(
        'auth/login',
        authenticated: false,
        body: {'email': 'member@example.com', 'password': 'password123'},
      );

      expect(capturedRequest.headers['authorization'], isNull);
      expect(
        capturedRequest.headers['content-type'],
        'application/json; charset=UTF-8',
      );
      expect(jsonDecode(capturedRequest.body), {
        'email': 'member@example.com',
        'password': 'password123',
      });
    });

    test('maps an HTTP error and preserves the server message', () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Please choose your gym before signing in.',
          }),
          409,
        );
      });
      final apiClient = ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: mockClient,
      );

      await expectLater(
        apiClient.post('auth/login', authenticated: false),
        throwsA(
          isA<ApiException>()
              .having((error) => error.type, 'type', ApiExceptionType.conflict)
              .having((error) => error.statusCode, 'statusCode', 409)
              .having(
                (error) => error.message,
                'message',
                'Please choose your gym before signing in.',
              ),
        ),
      );
    });

    test('maps request timeout', () async {
      final mockClient = MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return http.Response('{}', 200);
      });
      final apiClient = ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: mockClient,
        timeout: const Duration(milliseconds: 1),
      );

      await expectLater(
        apiClient.get('me'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiExceptionType.timeout,
          ),
        ),
      );
    });

    test('maps client connection failures', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('No connection', request.url);
      });
      final apiClient = ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: mockClient,
      );

      await expectLater(
        apiClient.get('me'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiExceptionType.network,
          ),
        ),
      );
    });

    test('rejects an invalid JSON success response', () async {
      final mockClient = MockClient((_) async {
        return http.Response('not-json', 200);
      });
      final apiClient = ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: mockClient,
      );

      await expectLater(
        apiClient.get('me'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiExceptionType.invalidResponse,
          ),
        ),
      );
    });
  });
}
