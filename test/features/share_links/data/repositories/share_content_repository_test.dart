import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:do_gym/core/network/api_client.dart';
import 'package:do_gym/features/share_links/data/repositories/share_content_repository.dart';
import 'package:do_gym/features/share_links/data/services/share_content_api_service.dart';

void main() {
  test('maps trainer share link into app-ready content', () async {
    late Map<String, Object?> submittedBody;
    final repository = _buildRepository((request) async {
      submittedBody = jsonDecode(request.body) as Map<String, Object?>;
      return _shareLinkResponse(targetType: 'TRAINER', title: 'Coach Maya');
    });

    final content = await repository.createTrainerShareLink(
      trainerId: 'trainer-1',
    );

    expect(submittedBody, {'targetType': 'TRAINER', 'targetId': 'trainer-1'});
    expect(content.title, 'Coach Maya');
    expect(content.publicUrl, 'https://gym.example.com/s/share-token');
  });

  test(
    'uses class and location target types supported by the backend',
    () async {
      final submittedBodies = <Map<String, Object?>>[];
      final repository = _buildRepository((request) async {
        submittedBodies.add(jsonDecode(request.body) as Map<String, Object?>);
        return _shareLinkResponse(targetType: 'GYM_CLASS', title: 'Yoga Flow');
      });

      await repository.createClassShareLink(classId: 'class-1');
      await repository.createLocationShareLink(locationId: 'location-1');

      expect(submittedBodies, [
        {'targetType': 'GYM_CLASS', 'targetId': 'class-1'},
        {'targetType': 'LOCATION', 'targetId': 'location-1'},
      ]);
    },
  );
}

RemoteShareContentRepository _buildRepository(
  Future<http.Response> Function(http.Request request) handler,
) {
  return RemoteShareContentRepository(
    apiService: ShareContentApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: MockClient(handler),
        accessTokenProvider: () async => 'member-token',
      ),
    ),
  );
}

http.Response _shareLinkResponse({
  required String targetType,
  required String title,
}) {
  return http.Response(
    jsonEncode({
      'success': true,
      'message': 'Share link is ready.',
      'shareLink': {
        'token': 'share-token',
        'publicUrl': 'https://gym.example.com/s/share-token',
        'targetType': targetType,
        'title': title,
        'description': 'Detail tersedia di aplikasi.',
        'imageUrl': null,
        'expiresAt': null,
      },
    }),
    200,
  );
}
