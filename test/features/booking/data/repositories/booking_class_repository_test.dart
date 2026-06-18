import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/booking/data/dto/mobile_class_response_dto.dart';
import 'package:do_gym/features/booking/data/repositories/booking_class_repository.dart';
import 'package:do_gym/features/booking/data/services/booking_class_api_service.dart';

void main() {
  test('maps class sessions into group class sessions', () async {
    final repository = RemoteBookingClassRepository(
      apiService: _FakeBookingClassApiService(
        response: MobileClassesResponseDto(
          categories: const [],
          range: MobileClassRangeDto(
            startsFrom: DateTime.utc(2026, 6, 16),
            startsTo: DateTime.utc(2026, 6, 30),
          ),
          classes: [
            MobileGymClassDto(
              id: 'class-1',
              name: 'Yoga Flow',
              subtitle: 'Morning flow',
              description: 'Low impact class',
              level: 'All Level',
              durationMinutes: 60,
              defaultCapacity: 12,
              coverImageUrl: 'https://cdn.example/yoga.jpg',
              category: const MobileClassCategoryDto(
                id: 'category-1',
                name: 'Yoga',
                colorHex: null,
                iconKey: 'yoga',
              ),
              images: const [],
              benefits: const [
                MobileClassBenefitDto(label: 'Mobility', iconKey: 'mobility'),
              ],
              sessions: [
                MobileClassSessionDto(
                  id: 'session-1',
                  status: 'SCHEDULED',
                  startsAt: DateTime.utc(2026, 6, 16, 10),
                  endsAt: DateTime.utc(2026, 6, 16, 11),
                  capacity: 12,
                  bookedCount: 2,
                  waitlistCount: 0,
                  availableSlots: 10,
                  isFull: false,
                  roomName: 'Studio 1',
                  notes: null,
                  trainer: const MobileClassTrainerDto(
                    id: 'trainer-1',
                    name: 'Coach Maya',
                    specialty: 'Yoga',
                    photoUrl: null,
                    rating: 4.8,
                  ),
                  location: const MobileClassLocationDto(
                    id: 'location-1',
                    name: 'DO GYM Denpasar',
                    area: 'Denpasar',
                    address: 'Jl. Gatot Subroto',
                    latitude: null,
                    longitude: null,
                    googlePlaceId: null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final classes = await repository.fetchClassesForLocation(
      locationId: 'location-1',
      startsFrom: DateTime.utc(2026, 6, 16),
      startsTo: DateTime.utc(2026, 6, 30),
    );

    expect(classes, hasLength(1));
    expect(classes.first.title, 'Yoga Flow');
    expect(classes.first.duration, '60 Menit');
    expect(classes.first.slotLabel, '10 Slot');
    expect(classes.first.coachName, 'Coach Maya');
    expect(classes.first.benefits.first.label, 'Mobility');
  });
}

class _FakeBookingClassApiService implements BookingClassApiService {
  const _FakeBookingClassApiService({required this.response});

  final MobileClassesResponseDto response;

  @override
  Future<MobileClassesResponseDto> fetchClassesForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    return response;
  }
}
