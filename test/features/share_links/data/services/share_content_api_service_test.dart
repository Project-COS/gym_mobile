import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:do_gym/core/network/api_client.dart';
import 'package:do_gym/features/share_links/data/services/share_content_api_service.dart';

void main() {
  test('creates a mobile share link with authenticated payload', () async {
    late http.Request capturedRequest;
    final httpClient = MockClient((request) async {
      capturedRequest = request;

      return http.Response(
        jsonEncode({
          'success': true,
          'message': 'Share link is ready.',
          'shareLink': {
            'token': 'share-token',
            'publicUrl': 'https://gym.example.com/s/share-token',
            'targetType': 'TRAINER',
            'title': 'Coach Maya',
            'description': 'Personal training tersedia di aplikasi.',
            'imageUrl': null,
            'expiresAt': null,
          },
        }),
        201,
      );
    });
    final service = ShareContentApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: httpClient,
        accessTokenProvider: () async => 'member-token',
      ),
    );

    final response = await service.createShareLink(
      targetType: 'TRAINER',
      targetId: 'trainer-1',
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/api/mobile/share-links');
    expect(capturedRequest.headers['authorization'], 'Bearer member-token');
    expect(jsonDecode(capturedRequest.body), {
      'targetType': 'TRAINER',
      'targetId': 'trainer-1',
    });
    expect(
      response.shareLink.publicUrl,
      'https://gym.example.com/s/share-token',
    );
    expect(response.shareLink.title, 'Coach Maya');
  });
}
