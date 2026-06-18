import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:do_gym/core/network/api_client.dart';
import 'package:do_gym/features/lokasi/data/services/location_api_service.dart';

void main() {
  test('fetches locations with Bearer authorization', () async {
    late http.Request capturedRequest;
    final httpClient = MockClient((request) async {
      capturedRequest = request;

      return http.Response(
        jsonEncode({'success': true, 'locations': <Object>[]}),
        200,
      );
    });
    final service = LocationApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: httpClient,
        accessTokenProvider: () async => 'member-token',
      ),
    );

    final response = await service.fetchLocations();

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/api/mobile/locations');
    expect(capturedRequest.headers['authorization'], 'Bearer member-token');
    expect(response.locations, isEmpty);
  });
}
