import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/classes/data/dto/mobile_class_response_dto.dart';

void main() {
  test('parses mobile classes response', () {
    final response = MobileClassesResponseDto.fromJson({
      'success': true,
      'categories': [
        {
          'id': 'category-1',
          'name': 'Yoga',
          'colorHex': null,
          'iconKey': 'yoga',
        },
      ],
      'classes': [
        {
          'id': 'class-1',
          'name': 'Yoga Flow',
          'subtitle': 'Morning flow',
          'description': 'Low impact class',
          'level': 'All Level',
          'durationMinutes': 60,
          'defaultCapacity': 12,
          'coverImageUrl': 'https://cdn.example/yoga.jpg',
          'category': {
            'id': 'category-1',
            'name': 'Yoga',
            'colorHex': null,
            'iconKey': 'yoga',
          },
          'images': [
            {'url': 'https://cdn.example/gallery.jpg'},
          ],
          'benefits': [
            {'label': 'Mobility', 'iconKey': 'mobility'},
          ],
          'sessions': [
            {
              'id': 'session-1',
              'status': 'SCHEDULED',
              'startsAt': '2026-06-16T10:00:00.000Z',
              'endsAt': '2026-06-16T11:00:00.000Z',
              'capacity': 12,
              'bookedCount': 2,
              'waitlistCount': 0,
              'availableSlots': 10,
              'isFull': false,
              'roomName': 'Studio 1',
              'notes': null,
              'trainer': {
                'id': 'trainer-1',
                'name': 'Coach Maya',
                'specialty': 'Yoga',
                'photoUrl': null,
                'rating': 4.8,
              },
              'location': {
                'id': 'location-1',
                'name': 'DO GYM Denpasar',
                'area': 'Denpasar',
                'address': 'Jl. Gatot Subroto',
                'latitude': -8.65,
                'longitude': 115.21,
                'mapPlaceId': 'place-1',
              },
            },
          ],
        },
      ],
      'range': {
        'startsFrom': '2026-06-16T00:00:00.000Z',
        'startsTo': '2026-06-30T00:00:00.000Z',
      },
    });

    expect(response.categories.first.name, 'Yoga');
    expect(response.classes.first.sessions.first.availableSlots, 10);
    expect(response.classes.first.sessions.first.trainer?.name, 'Coach Maya');
    expect(
      response.classes.first.sessions.first.location?.googlePlaceId,
      'place-1',
    );
    expect(response.range.startsTo.year, 2026);
  });

  test('rejects invalid class session dates', () {
    expect(
      () => MobileClassesResponseDto.fromJson({
        'categories': <Object>[],
        'classes': <Object>[],
        'range': {'startsFrom': 'invalid', 'startsTo': '2026-06-30'},
      }),
      throwsFormatException,
    );
  });
}
