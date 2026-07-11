import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/trainers/data/dto/mobile_trainer_response_dto.dart';

void main() {
  test('parses mobile trainer list response', () {
    final response = MobileTrainersResponseDto.fromJson({
      'success': true,
      'trainers': [
        {
          'id': 'trainer-1',
          'name': 'Coach Maya',
          'phone': '081234567890',
          'specialty': 'Strength',
          'bio': 'Strength and conditioning coach.',
          'photoUrl': 'https://cdn.example/trainer.jpg',
          'rating': '4.8',
          'defaultLocationId': 'location-1',
          'defaultLocationName': 'DO GYM Denpasar',
          'locations': [
            {
              'id': 'location-1',
              'name': 'DO GYM Denpasar',
              'area': 'Denpasar',
              'address': 'Jl. Gatot Subroto',
              'whatsapp': '+6281234567890',
              'isPrimary': true,
              'sortOrder': 1,
              'latitude': -8.65,
              'longitude': 115.21,
              'mapPlaceId': null,
              'mapAddress': 'Jl. Gatot Subroto',
              'mapUrls': {
                'openStreetMap': null,
                'googleMaps': 'https://maps.example/location-1',
                'googleNavigation': 'https://nav.example/location-1',
              },
            },
          ],
          'schedules': [
            {
              'dayOfWeek': 1,
              'startTime': '08:00',
              'endTime': '12:00',
              'locationId': 'location-1',
              'locationName': 'DO GYM Denpasar',
            },
          ],
          'images': [
            {
              'url': 'https://cdn.example/gallery.jpg',
              'sortOrder': 1,
              'isActive': true,
            },
          ],
          'programs': [
            {
              'id': 'program-1',
              'name': 'Strength Builder',
              'subtitle': 'Strength basics',
              'description': 'Build strength safely.',
              'durationMinutes': 60,
              'specialty': 'Strength',
              'level': 'All Level',
              'locationId': 'location-1',
              'locationName': 'DO GYM Denpasar',
              'coverImageUrl': 'https://cdn.example/program.jpg',
              'benefits': [
                {'label': 'Technique check'},
              ],
            },
          ],
        },
      ],
    });

    expect(response.trainers, hasLength(1));
    expect(response.trainers.first.name, 'Coach Maya');
    expect(response.trainers.first.phone, '081234567890');
    expect(response.trainers.first.rating, 4.8);
    expect(response.trainers.first.locations.first.whatsapp, '+6281234567890');
    expect(
      response.trainers.first.locations.first.mapUrls.googleMaps,
      'https://maps.example/location-1',
    );
    expect(response.trainers.first.schedules.first.dayOfWeek, 1);
    expect(
      response.trainers.first.programs.first.benefits.first.label,
      'Technique check',
    );
    expect(response.trainers.first.canRate, isFalse);
  });

  test('parses mobile trainer detail response with rating permission', () {
    final response = MobileTrainerDetailResponseDto.fromJson({
      'success': true,
      'trainer': {
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
        'canRate': true,
      },
    });

    expect(response.trainer.id, 'trainer-1');
    expect(response.trainer.canRate, isTrue);
  });

  test('rejects invalid trainer locations', () {
    expect(
      () => MobileTrainersResponseDto.fromJson({
        'trainers': [
          {
            'id': 'trainer-1',
            'name': 'Coach Maya',
            'locations': 'invalid',
            'schedules': <Object>[],
            'images': <Object>[],
            'programs': <Object>[],
          },
        ],
      }),
      throwsFormatException,
    );
  });
}
