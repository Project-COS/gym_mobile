import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/icons/app_lucide_icons.dart';
import 'package:do_gym/features/classes/data/dto/mobile_class_booking_response_dto.dart';
import 'package:do_gym/features/classes/data/dto/mobile_class_response_dto.dart';
import 'package:do_gym/features/classes/data/repositories/booking_class_repository.dart';
import 'package:do_gym/features/classes/data/services/booking_class_api_service.dart';

void main() {
  test('maps class sessions into group class sessions', () async {
    final repository = RemoteBookingClassRepository(
      apiService: _FakeBookingClassApiService(
        response: MobileClassesResponseDto(
          categories: const [
            MobileClassCategoryDto(
              id: 'category-1',
              name: 'Yoga',
              colorHex: null,
            ),
          ],
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
              ),
              images: const [],
              benefits: const [MobileClassBenefitDto(label: 'Mobility')],
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
                MobileClassSessionDto(
                  id: 'session-2',
                  status: 'SCHEDULED',
                  startsAt: DateTime.utc(2026, 6, 16, 12),
                  endsAt: DateTime.utc(2026, 6, 16, 13),
                  capacity: 10,
                  bookedCount: 2,
                  waitlistCount: 0,
                  availableSlots: 8,
                  isFull: false,
                  roomName: 'Studio 2',
                  notes: null,
                  trainer: const MobileClassTrainerDto(
                    id: 'trainer-2',
                    name: 'Coach Raka',
                    specialty: 'Strength',
                    photoUrl: null,
                    rating: 4.7,
                  ),
                  location: const MobileClassLocationDto(
                    id: 'location-2',
                    name: 'DO GYM Renon',
                    area: 'Renon',
                    address: 'Jl. Renon',
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

    final catalog = await repository.fetchClassCatalogForLocation(
      locationId: 'location-1',
      startsFrom: DateTime.utc(2026, 6, 16),
      startsTo: DateTime.utc(2026, 6, 30),
    );
    final classes = catalog.sessions;

    expect(catalog.categories.single.label, 'Yoga');
    expect(classes, hasLength(1));
    expect(classes.first.title, 'Yoga Flow');
    expect(classes.first.categoryId, 'category-1');
    expect(classes.first.categoryName, 'Yoga');
    expect(classes.first.branch, '2 Cabang');
    expect(classes.first.duration, '60 Menit');
    expect(classes.first.slotLabel, '18 Slot');
    expect(classes.first.coachName, 'Beragam Coach');
    expect(classes.first.location, '2 lokasi tersedia');
    expect(classes.first.slots, hasLength(2));
    expect(classes.first.slots.first.sessionId, 'session-1');
    expect(classes.first.slots.last.sessionId, 'session-2');
    expect(classes.first.slots.last.branch, 'Renon');
    expect(classes.first.benefits.first.label, 'Mobility');
    expect(classes.first.benefits.first.icon, AppLucideIcons.badgeCheck);
  });

  test('maps class booking response into confirmation', () async {
    final repository = RemoteBookingClassRepository(
      apiService: _FakeBookingClassApiService(
        response: MobileClassesResponseDto(
          categories: const [],
          range: MobileClassRangeDto(
            startsFrom: DateTime.utc(2026, 6, 16),
            startsTo: DateTime.utc(2026, 6, 30),
          ),
          classes: const [],
        ),
        bookingResponse: MobileClassBookingResponseDto(
          booking: MobileClassBookingDto(
            id: 'class-booking-1',
            bookingCode: 'CLB-TEST001',
            qrPayload: 'class_booking:CLB-TEST001',
            className: 'Yoga Flow',
            source: 'AD_HOC',
            status: 'SCHEDULED',
            startsAt: DateTime.utc(2026, 6, 16, 10),
            endsAt: DateTime.utc(2026, 6, 16, 11),
            notes: null,
            gymClass: const MobileClassBookingClassDto(
              id: 'class-1',
              name: 'Yoga Flow',
              durationMinutes: 60,
            ),
            session: const MobileClassBookingSessionDto(
              id: 'session-1',
              roomName: 'Studio 1',
            ),
            trainer: const MobileClassBookingTrainerDto(
              id: 'trainer-1',
              name: 'Coach Maya',
              specialty: 'Yoga',
            ),
            location: const MobileClassBookingLocationDto(
              id: 'location-1',
              name: 'DO GYM Denpasar',
              area: 'Denpasar',
              address: 'Jl. Gatot Subroto',
            ),
          ),
        ),
      ),
    );

    final confirmation = await repository.createClassBooking(
      classSessionId: 'session-1',
    );

    expect(confirmation.id, 'class-booking-1');
    expect(confirmation.bookingCode, 'CLB-TEST001');
    expect(confirmation.qrPayload, 'class_booking:CLB-TEST001');
    expect(confirmation.title, 'Yoga Flow');
    expect(confirmation.duration, '60 Menit');
    expect(confirmation.location, 'DO GYM Denpasar - Studio 1');
  });

  test('maps class booking list into history items', () async {
    final apiService = _FakeBookingClassApiService(
      response: MobileClassesResponseDto(
        categories: const [],
        range: MobileClassRangeDto(
          startsFrom: DateTime.utc(2026, 6, 16),
          startsTo: DateTime.utc(2026, 6, 30),
        ),
        classes: const [],
      ),
      bookingsResponse: MobileClassBookingsResponseDto(
        bookings: [
          MobileClassBookingDto(
            id: 'class-booking-1',
            bookingCode: 'CLB-TEST001',
            qrPayload: 'class_booking:CLB-TEST001',
            className: 'Yoga Flow',
            source: 'MOBILE_APP',
            status: 'SCHEDULED',
            startsAt: DateTime.utc(2026, 6, 16, 10),
            endsAt: DateTime.utc(2026, 6, 16, 11),
            notes: null,
            gymClass: const MobileClassBookingClassDto(
              id: 'class-1',
              name: 'Yoga Flow',
              durationMinutes: 60,
            ),
            session: const MobileClassBookingSessionDto(
              id: 'session-1',
              roomName: 'Studio 1',
            ),
            trainer: const MobileClassBookingTrainerDto(
              id: 'trainer-1',
              name: 'Coach Maya',
              specialty: 'Yoga',
            ),
            location: const MobileClassBookingLocationDto(
              id: 'location-1',
              name: 'DO GYM Denpasar',
              area: 'Denpasar',
              address: 'Jl. Gatot Subroto',
            ),
          ),
        ],
        pagination: const MobileClassBookingPaginationDto(
          page: 1,
          pageSize: 50,
          totalItems: 1,
          totalPages: 1,
        ),
      ),
    );
    final repository = RemoteBookingClassRepository(apiService: apiService);

    final items = await repository.fetchClassBookings(
      filter: ClassBookingHistoryFilter.all,
    );

    expect(apiService.submittedBookingStatus, 'all');
    expect(apiService.submittedBookingPageSize, 50);
    expect(items.single.id, 'class-booking-1');
    expect(items.single.bookingCode, 'CLB-TEST001');
    expect(items.single.title, 'Yoga Flow');
    expect(items.single.trainerName, 'Coach Maya');
    expect(items.single.duration, '60 Menit');
    expect(items.single.location, 'DO GYM Denpasar - Studio 1');
    expect(items.single.canShowQr, isTrue);
  });
}

class _FakeBookingClassApiService implements BookingClassApiService {
  _FakeBookingClassApiService({
    required this.response,
    this.bookingResponse,
    this.bookingsResponse,
  });

  final MobileClassesResponseDto response;
  final MobileClassBookingResponseDto? bookingResponse;
  final MobileClassBookingsResponseDto? bookingsResponse;
  String? submittedBookingStatus;
  int? submittedBookingPage;
  int? submittedBookingPageSize;

  @override
  Future<MobileClassesResponseDto> fetchClasses({
    String? locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    return response;
  }

  @override
  Future<MobileClassesResponseDto> fetchClassesForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    return fetchClasses(
      locationId: locationId,
      startsFrom: startsFrom,
      startsTo: startsTo,
    );
  }

  @override
  Future<MobileClassBookingsResponseDto> fetchBookings({
    required String status,
    int page = 1,
    int pageSize = 20,
  }) async {
    submittedBookingStatus = status;
    submittedBookingPage = page;
    submittedBookingPageSize = pageSize;

    return bookingsResponse ??
        const MobileClassBookingsResponseDto(
          bookings: [],
          pagination: MobileClassBookingPaginationDto(
            page: 1,
            pageSize: 20,
            totalItems: 0,
            totalPages: 0,
          ),
        );
  }

  @override
  Future<MobileClassBookingResponseDto> createClassBooking({
    required String classSessionId,
    String? notes,
  }) async {
    return bookingResponse ??
        MobileClassBookingResponseDto(
          booking: MobileClassBookingDto(
            id: 'class-booking-1',
            bookingCode: 'CLB-TEST001',
            qrPayload: 'class_booking:CLB-TEST001',
            className: 'Yoga Flow',
            source: 'AD_HOC',
            status: 'SCHEDULED',
            startsAt: DateTime.utc(2026, 6, 16, 10),
            endsAt: DateTime.utc(2026, 6, 16, 11),
            notes: null,
            gymClass: const MobileClassBookingClassDto(
              id: 'class-1',
              name: 'Yoga Flow',
              durationMinutes: 60,
            ),
            session: const MobileClassBookingSessionDto(
              id: 'session-1',
              roomName: 'Studio 1',
            ),
            trainer: const MobileClassBookingTrainerDto(
              id: 'trainer-1',
              name: 'Coach Maya',
              specialty: 'Yoga',
            ),
            location: const MobileClassBookingLocationDto(
              id: 'location-1',
              name: 'DO GYM Denpasar',
              area: 'Denpasar',
              address: 'Jl. Gatot Subroto',
            ),
          ),
        );
  }
}
