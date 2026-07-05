import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/network/api_exception.dart';
import 'package:do_gym/features/bookings/data/booking_data.dart';
import 'package:do_gym/features/classes/data/class_data.dart';
import 'package:do_gym/features/classes/data/repositories/booking_class_repository.dart';
import 'package:do_gym/features/classes/presentation/cubit/class_booking_cubit.dart';

void main() {
  test('creates class booking from selected slot session id', () async {
    final repository = _FakeBookingClassRepository();
    final cubit = ClassBookingCubit(repository: repository);

    await cubit.createClassBooking(
      slot: BookingSlot(day: 'Hari ini', time: '10:00', sessionId: 'session-1'),
    );

    expect(repository.submittedClassSessionId, 'session-1');
    expect(cubit.state.isSubmitting, isFalse);
    expect(cubit.state.confirmation?.bookingCode, 'CLB-TEST001');

    await cubit.close();
  });

  test('emits useful error when selected slot has no session id', () async {
    final cubit = ClassBookingCubit(repository: _FakeBookingClassRepository());

    await cubit.createClassBooking(
      slot: const BookingSlot(day: 'Hari ini', time: '10:00'),
    );

    expect(cubit.state.errorMessage, contains('Jadwal kelas belum lengkap'));

    await cubit.close();
  });

  test('maps API conflict into unavailable schedule message', () async {
    final cubit = ClassBookingCubit(
      repository: _FakeBookingClassRepository(
        error: const ApiException(
          type: ApiExceptionType.conflict,
          message: 'Class is full.',
          statusCode: 409,
        ),
      ),
    );

    await cubit.createClassBooking(
      slot: BookingSlot(day: 'Hari ini', time: '10:00', sessionId: 'session-1'),
    );

    expect(cubit.state.errorMessage, contains('sudah tidak tersedia'));

    await cubit.close();
  });
}

class _FakeBookingClassRepository implements BookingClassRepository {
  _FakeBookingClassRepository({this.error});

  final Object? error;
  String? submittedClassSessionId;

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
    return const [];
  }

  @override
  Future<ClassBookingConfirmation> createClassBooking({
    required String classSessionId,
    String? notes,
  }) async {
    final Object? error = this.error;

    if (error != null) {
      throw error;
    }

    submittedClassSessionId = classSessionId;
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
