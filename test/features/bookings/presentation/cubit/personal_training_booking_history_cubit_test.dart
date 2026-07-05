import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/network/api_exception.dart';
import 'package:do_gym/features/bookings/data/repositories/personal_training_booking_repository.dart';
import 'package:do_gym/features/bookings/presentation/cubit/personal_training_booking_history_cubit.dart';

void main() {
  test('emits success when PT booking history loads', () async {
    final repository = _FakePersonalTrainingBookingRepository(
      bookings: const [_historyItem],
    );
    final cubit = PersonalTrainingBookingHistoryCubit(repository: repository);

    await cubit.fetchBookings(
      filter: PersonalTrainingBookingHistoryFilter.history,
    );

    expect(
      cubit.state.status,
      PersonalTrainingBookingHistoryLoadStatus.success,
    );
    expect(cubit.state.filter, PersonalTrainingBookingHistoryFilter.history);
    expect(cubit.state.bookings.first.bookingCode, 'PTB-TEST001');
    expect(
      repository.submittedFilter,
      PersonalTrainingBookingHistoryFilter.history,
    );

    await cubit.close();
  });

  test('emits a user-friendly failure message', () async {
    final cubit = PersonalTrainingBookingHistoryCubit(
      repository: _FakePersonalTrainingBookingRepository(
        error: ApiException.timeout(),
      ),
    );

    await cubit.fetchBookings();

    expect(
      cubit.state.status,
      PersonalTrainingBookingHistoryLoadStatus.failure,
    );
    expect(cubit.state.errorMessage, contains('terlalu lama'));

    await cubit.close();
  });
}

class _FakePersonalTrainingBookingRepository
    implements PersonalTrainingBookingRepository {
  _FakePersonalTrainingBookingRepository({
    this.bookings = const [],
    this.error,
  });

  final List<PersonalTrainingBookingHistoryItem> bookings;
  final Object? error;
  PersonalTrainingBookingHistoryFilter? submittedFilter;

  @override
  Future<List<PersonalTrainingBookingHistoryItem>>
  fetchPersonalTrainingBookings({
    PersonalTrainingBookingHistoryFilter filter =
        PersonalTrainingBookingHistoryFilter.upcoming,
  }) async {
    submittedFilter = filter;
    final Object? error = this.error;

    if (error != null) {
      throw error;
    }

    return bookings;
  }

  @override
  Future<PersonalTrainingBookingConfirmation> createPersonalTrainingBooking({
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

const PersonalTrainingBookingHistoryItem _historyItem =
    PersonalTrainingBookingHistoryItem(
      id: 'booking-1',
      bookingCode: 'PTB-TEST001',
      qrPayload: 'pt_booking:PTB-TEST001',
      title: 'Strength PT',
      trainerName: 'Coach Maya',
      schedule: 'Rabu, 24 Jun 09:00',
      duration: '60 Menit',
      location: 'DO GYM Denpasar - Denpasar',
      status: 'COMPLETED',
      source: 'MEMBERSHIP_BENEFIT',
      canShowQr: false,
    );
