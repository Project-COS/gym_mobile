import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/network/api_exception.dart';
import 'package:do_gym/features/classes/data/class_data.dart';
import 'package:do_gym/features/classes/data/repositories/booking_class_repository.dart';
import 'package:do_gym/features/classes/presentation/cubit/class_booking_history_cubit.dart';

void main() {
  test('loads class booking history with selected filter', () async {
    final repository = _FakeBookingClassRepository(
      historyItems: const [
        ClassBookingHistoryItem(
          id: 'class-booking-1',
          bookingCode: 'CLB-TEST001',
          qrPayload: 'class_booking:CLB-TEST001',
          title: 'Yoga Flow',
          trainerName: 'Coach Maya',
          schedule: 'Selasa, 16 Jun 18:00',
          duration: '60 Menit',
          location: 'DO GYM Denpasar - Studio 1',
          status: 'COMPLETED',
          source: 'MOBILE_APP',
          canShowQr: false,
        ),
      ],
    );
    final cubit = ClassBookingHistoryCubit(repository: repository);

    await cubit.fetchBookings(filter: ClassBookingHistoryFilter.all);

    expect(repository.submittedHistoryFilter, ClassBookingHistoryFilter.all);
    expect(cubit.state.status, ClassBookingHistoryLoadStatus.success);
    expect(cubit.state.bookings.single.bookingCode, 'CLB-TEST001');

    await cubit.close();
  });

  test('maps API errors into class history message', () async {
    final cubit = ClassBookingHistoryCubit(
      repository: _FakeBookingClassRepository(error: ApiException.network()),
    );

    await cubit.fetchBookings(filter: ClassBookingHistoryFilter.all);

    expect(cubit.state.status, ClassBookingHistoryLoadStatus.failure);
    expect(cubit.state.errorMessage, contains('Tidak dapat terhubung'));

    await cubit.close();
  });
}

class _FakeBookingClassRepository implements BookingClassRepository {
  _FakeBookingClassRepository({this.historyItems = const [], this.error});

  final List<ClassBookingHistoryItem> historyItems;
  final Object? error;
  ClassBookingHistoryFilter? submittedHistoryFilter;

  @override
  Future<BookingClassCatalog> fetchClassCatalog({
    String? locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    return const BookingClassCatalog(categories: [], sessions: []);
  }

  @override
  Future<BookingClassCatalog> fetchClassCatalogForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    return const BookingClassCatalog(categories: [], sessions: []);
  }

  @override
  Future<List<GroupClassSession>> fetchClassesForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    return const [];
  }

  @override
  Future<List<ClassBookingHistoryItem>> fetchClassBookings({
    ClassBookingHistoryFilter filter = ClassBookingHistoryFilter.upcoming,
  }) async {
    final Object? error = this.error;

    if (error != null) {
      throw error;
    }

    submittedHistoryFilter = filter;
    return historyItems;
  }

  @override
  Future<ClassBookingConfirmation> createClassBooking({
    required String classSessionId,
    String? notes,
  }) async {
    return const ClassBookingConfirmation(
      id: 'class-booking-1',
      bookingCode: 'CLB-TEST001',
      qrPayload: 'class_booking:CLB-TEST001',
      title: 'Yoga Flow',
      schedule: 'Senin, 24 Jun 09:00',
      duration: '60 Menit',
      location: 'Denpasar',
    );
  }
}
