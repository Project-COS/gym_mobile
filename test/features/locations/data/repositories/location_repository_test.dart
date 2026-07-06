import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/icons/app_lucide_icons.dart';
import 'package:do_gym/features/locations/data/dto/mobile_location_response_dto.dart';
import 'package:do_gym/features/locations/data/repositories/location_repository.dart';
import 'package:do_gym/features/locations/data/services/location_api_service.dart';

void main() {
  test('maps location DTOs into branch locations', () async {
    final repository = RemoteLocationRepository(
      apiService: _FakeLocationApiService(
        response: MobileLocationsResponseDto(
          locations: [
            MobileLocationDto(
              id: 'location-1',
              name: 'DO GYM Denpasar',
              description: null,
              address: 'Jl. Gatot Subroto',
              area: 'Denpasar',
              whatsapp: '+628123',
              capacityLabel: 'Medium',
              latitude: -8.65,
              longitude: 115.21,
              googlePlaceId: null,
              mapUrls: const MobileLocationMapUrlsDto(
                openStreetMap: null,
                googleMaps: 'https://maps.example/location-1',
                googleNavigation: 'https://nav.example/location-1',
              ),
              images: const [
                MobileLocationImageDto(
                  url: 'https://cdn.example/location.jpg',
                  altText: 'Main training area',
                  caption: 'Area latihan utama',
                  isPrimary: true,
                ),
                MobileLocationImageDto(
                  url: 'https://cdn.example/location-lobby.jpg',
                  altText: null,
                  caption: 'Lobby member',
                  isPrimary: false,
                ),
              ],
              facilities: const [
                MobileLocationFacilityDto(name: 'Shower Room'),
              ],
              schedules: const [
                MobileLocationScheduleDto(
                  dayOfWeek: 1,
                  startTime: '06:00',
                  endTime: '22:00',
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final locations = await repository.fetchLocations();

    expect(locations, hasLength(1));
    expect(locations.first.name, 'DO GYM Denpasar');
    expect(locations.first.hours, '06:00 - 22:00');
    expect(locations.first.mapUrl, 'https://nav.example/location-1');
    expect(locations.first.imageUrl, 'https://cdn.example/location.jpg');
    expect(locations.first.galleryImages, hasLength(2));
    expect(locations.first.galleryImages.first.caption, 'Area latihan utama');
    expect(
      locations.first.galleryImages.last.imageUrl,
      'https://cdn.example/location-lobby.jpg',
    );
    expect(locations.first.facilities.first.name, 'Shower Room');
    expect(locations.first.facilities.first.icon, AppLucideIcons.dumbbell);
  });
}

class _FakeLocationApiService implements LocationApiService {
  const _FakeLocationApiService({required this.response});

  final MobileLocationsResponseDto response;

  @override
  Future<MobileLocationsResponseDto> fetchLocations() async {
    return response;
  }
}
