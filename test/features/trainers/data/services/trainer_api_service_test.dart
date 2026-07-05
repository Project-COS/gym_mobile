import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:do_gym/core/network/api_client.dart';
import 'package:do_gym/features/trainers/data/services/trainer_api_service.dart';

void main() {
  test('fetches trainers through the authenticated mobile endpoint', () async {
    late http.Request capturedRequest;
    final httpClient = MockClient((request) async {
      capturedRequest = request;

      return http.Response(
        jsonEncode({'success': true, 'trainers': <Object>[]}),
        200,
      );
    });
    final service = TrainerApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: httpClient,
        accessTokenProvider: () async => 'member-token',
      ),
    );

    final response = await service.fetchTrainers();

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/api/mobile/trainers');
    expect(capturedRequest.headers['authorization'], 'Bearer member-token');
    expect(response.trainers, isEmpty);
  });

  test('fetches trainer detail by id', () async {
    late http.Request capturedRequest;
    final httpClient = MockClient((request) async {
      capturedRequest = request;

      return http.Response(
        jsonEncode({'success': true, 'trainer': _trainerJson(canRate: true)}),
        200,
      );
    });
    final service = TrainerApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: httpClient,
        accessTokenProvider: () async => 'member-token',
      ),
    );

    final response = await service.fetchTrainerDetail('trainer-1');

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/api/mobile/trainers/trainer-1');
    expect(response.trainer.canRate, isTrue);
  });

  test('submits trainer rating through the rating endpoint', () async {
    late http.Request capturedRequest;
    final httpClient = MockClient((request) async {
      capturedRequest = request;

      return http.Response(
        jsonEncode({
          'success': true,
          'trainer': {'id': 'trainer-1', 'rating': 5},
        }),
        200,
      );
    });
    final service = TrainerApiService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://gym.example.com/api/mobile/'),
        client: httpClient,
        accessTokenProvider: () async => 'member-token',
      ),
    );

    final response = await service.submitTrainerRating(
      trainerId: 'trainer-1',
      rating: 5,
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/api/mobile/trainers/trainer-1/rating');
    expect(
      capturedRequest.headers['content-type'],
      'application/json; charset=UTF-8',
    );
    expect(jsonDecode(capturedRequest.body), {'rating': 5.0});
    expect(response.trainer.rating, 5);
  });
}

Map<String, Object?> _trainerJson({required bool canRate}) {
  return {
    'id': 'trainer-1',
    'name': 'Coach Maya',
    'specialty': null,
    'bio': null,
    'photoUrl': null,
    'rating': null,
    'defaultLocationId': null,
    'defaultLocationName': null,
    'locations': <Object>[],
    'schedules': <Object>[],
    'images': <Object>[],
    'programs': <Object>[],
    'canRate': canRate,
  };
}
