import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:do_gym/core/network/api_client.dart';
import 'package:do_gym/features/profile/data/dto/update_member_profile_request_dto.dart';
import 'package:do_gym/features/profile/data/services/profile_api_service.dart';

void main() {
  test('fetches profile from authenticated current member endpoint', () async {
    late http.Request capturedRequest;
    final httpClient = MockClient((request) async {
      capturedRequest = request;

      return http.Response(
        jsonEncode({'success': true, 'profile': _profileJson()}),
        200,
      );
    });
    final service = ProfileApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: httpClient,
        accessTokenProvider: () async => 'member-token',
      ),
    );

    final response = await service.fetchProfile();

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/api/mobile/me');
    expect(capturedRequest.headers['authorization'], 'Bearer member-token');
    expect(response.profile.member.name, 'Andi Member');
  });

  test('updates profile with PATCH request body', () async {
    late http.Request capturedRequest;
    final httpClient = MockClient((request) async {
      capturedRequest = request;

      return http.Response(
        jsonEncode({'success': true, 'profile': _profileJson()}),
        200,
      );
    });
    final service = ProfileApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: httpClient,
        accessTokenProvider: () async => 'member-token',
      ),
    );

    await service.updateProfile(
      const UpdateMemberProfileRequestDto(
        name: 'Andi Member',
        email: 'member@example.com',
        phone: '081234567890',
      ),
    );

    expect(capturedRequest.method, 'PATCH');
    expect(capturedRequest.url.path, '/api/mobile/me');
    expect(jsonDecode(capturedRequest.body), {
      'name': 'Andi Member',
      'email': 'member@example.com',
      'phone': '081234567890',
    });
  });
}

Map<String, Object?> _profileJson() {
  return {
    'member': {
      'id': 'member-1',
      'memberCode': 'MEM-001',
      'name': 'Andi Member',
      'email': 'member@example.com',
      'phone': '081234567890',
      'status': 'ACTIVE',
    },
    'company': {'id': 'company-1', 'name': 'DO GYM'},
    'membership': {
      'id': 'membership-1',
      'status': 'ACTIVE',
      'planName': 'Premium Access',
      'startsAt': '2026-07-01T00:00:00.000Z',
      'expiresAt': '2026-07-25T00:00:00.000Z',
      'accessLabel': 'All locations',
    },
  };
}
