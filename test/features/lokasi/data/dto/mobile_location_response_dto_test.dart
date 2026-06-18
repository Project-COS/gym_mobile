import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/lokasi/data/dto/mobile_location_response_dto.dart';

void main() {
  test('parses mobile locations response', () {
    final response = MobileLocationsResponseDto.fromJson({
      'success': true,
      'locations': [
        {
          'id': 'location-1',
          'name': 'DO GYM Denpasar',
          'description': null,
          'address': 'Jl. Gatot Subroto',
          'area': 'Denpasar',
          'whatsapp': '+628123',
          'capacityLabel': 'Medium',
          'latitude': -8.65,
          'longitude': 115.21,
          'googlePlaceId': 'place-1',
          'mapUrls': {
            'openStreetMap': 'https://osm.example/location-1',
            'googleMaps': 'https://maps.example/location-1',
            'googleNavigation': 'https://nav.example/location-1',
          },
          'images': [
            {
              'url': 'https://cdn.example/location.jpg',
              'altText': 'Branch',
              'caption': null,
              'isPrimary': true,
            },
          ],
          'facilities': [
            {'name': 'Shower Room', 'iconKey': 'shower'},
          ],
          'schedules': [
            {'dayOfWeek': 1, 'startTime': '06:00', 'endTime': '22:00'},
          ],
        },
      ],
    });

    expect(response.locations, hasLength(1));
    expect(response.locations.first.name, 'DO GYM Denpasar');
    expect(response.locations.first.images.first.isPrimary, isTrue);
    expect(response.locations.first.facilities.first.iconKey, 'shower');
    expect(response.locations.first.mapUrls.googleNavigation, contains('nav'));
  });

  test('rejects invalid location data', () {
    expect(
      () => MobileLocationsResponseDto.fromJson({
        'success': true,
        'locations': [
          {'name': 'Missing id'},
        ],
      }),
      throwsFormatException,
    );
  });
}
