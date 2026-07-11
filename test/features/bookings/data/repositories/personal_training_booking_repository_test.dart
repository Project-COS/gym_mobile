import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/bookings/data/dto/mobile_personal_training_booking_response_dto.dart';
import 'package:do_gym/features/bookings/data/repositories/personal_training_booking_repository.dart';
import 'package:do_gym/features/bookings/data/services/personal_training_booking_api_service.dart';

void main() {
  test('maps PT booking response into history items', () async {
    final apiService = _FakePersonalTrainingBookingApiService(
      bookingsResponse: MobilePersonalTrainingBookingsResponseDto(
        pagination: const MobilePersonalTrainingBookingPaginationDto(
          page: 1,
          pageSize: 50,
          totalItems: 1,
          totalPages: 1,
        ),
        bookings: [
          MobilePersonalTrainingBookingDto(
            id: 'booking-1',
            bookingCode: 'PTB-TEST001',
            qrPayload: 'pt_booking:PTB-TEST001',
            source: 'MEMBERSHIP_BENEFIT',
            status: 'SCHEDULED',
            startsAt: DateTime.utc(2026, 6, 24, 9),
            endsAt: DateTime.utc(2026, 6, 24, 10),
            notes: null,
            trainer: const MobilePersonalTrainingBookingTrainerDto(
              id: 'trainer-1',
              name: 'Coach Maya',
              phone: '081234567890',
              specialty: 'Strength',
            ),
            program: const MobilePersonalTrainingBookingProgramDto(
              id: 'program-1',
              name: 'Strength PT',
              durationMinutes: 60,
            ),
            location: const MobilePersonalTrainingBookingLocationDto(
              id: 'location-1',
              name: 'DO GYM Denpasar',
              area: 'Denpasar',
              address: 'Jl. Gatot Subroto',
              whatsapp: '+628199999999',
            ),
          ),
        ],
      ),
    );
    final repository = RemotePersonalTrainingBookingRepository(
      apiService: apiService,
    );

    final bookings = await repository.fetchPersonalTrainingBookings(
      filter: PersonalTrainingBookingHistoryFilter.upcoming,
    );

    expect(apiService.submittedStatus, 'upcoming');
    expect(bookings, hasLength(1));
    expect(bookings.first.title, 'Strength PT');
    expect(bookings.first.trainerName, 'Coach Maya');
    expect(bookings.first.duration, '60 Menit');
    expect(bookings.first.canShowQr, isTrue);
  });
}

class _FakePersonalTrainingBookingApiService
    implements PersonalTrainingBookingApiService {
  _FakePersonalTrainingBookingApiService({required this.bookingsResponse});

  final MobilePersonalTrainingBookingsResponseDto bookingsResponse;
  String? submittedStatus;

  @override
  Future<MobilePersonalTrainingBookingsResponseDto> fetchBookings({
    required String status,
    int page = 1,
    int pageSize = 20,
  }) async {
    submittedStatus = status;
    return bookingsResponse;
  }

  @override
  Future<MobilePersonalTrainingBookingResponseDto> createBooking({
    required String trainerId,
    required DateTime startsAt,
    String? programId,
    String? locationId,
    String? benefitGrantId,
    String? notes,
  }) {
    throw UnimplementedError();
  }
}
