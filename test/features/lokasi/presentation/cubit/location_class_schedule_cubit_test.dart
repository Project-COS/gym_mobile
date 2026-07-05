import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/network/api_exception.dart';
import 'package:do_gym/features/booking/data/booking_data.dart';
import 'package:do_gym/features/classes/data/class_data.dart';
import 'package:do_gym/features/classes/data/repositories/booking_class_repository.dart';
import 'package:do_gym/features/lokasi/presentation/cubit/location_class_schedule_cubit.dart';

void main() {
  test('maps class sessions into branch schedules', () async {
    final cubit = LocationClassScheduleCubit(
      repository: _FakeBookingClassRepository(
        classes: const [
          GroupClassSession(
            id: 'class-1:session-1',
            title: 'Yoga Flow',
            subtitle: 'Coach Maya - Hari ini 10:00',
            description: 'Low impact class',
            category: ClassCategory.yoga,
            branch: 'Denpasar',
            duration: '60 Menit',
            slotLabel: '10 Slot',
            infoCategory: 'Yoga',
            location: 'DO GYM Denpasar - Studio 1',
            level: 'All Level',
            coachName: 'Coach Maya',
            coachRole: 'Yoga',
            rating: '4.8',
            mapQuery: 'DO GYM Denpasar',
            coverImageUrl: 'https://cdn.example/yoga.jpg',
            slots: [BookingSlot(day: 'Hari ini', time: '10:00')],
            tags: ['Yoga'],
            benefits: [],
            gallery: ['https://cdn.example/yoga.jpg'],
          ),
        ],
      ),
    );

    await cubit.fetchSchedulesForLocation('location-1');

    expect(cubit.state.status, LocationClassScheduleStatus.success);
    expect(cubit.state.schedules.first.title, 'Yoga Flow');
    expect(cubit.state.schedules.first.status, '10 Slot');

    await cubit.close();
  });

  test('emits failure when classes cannot load', () async {
    final cubit = LocationClassScheduleCubit(
      repository: _FakeBookingClassRepository(error: ApiException.network()),
    );

    await cubit.fetchSchedulesForLocation('location-1');

    expect(cubit.state.status, LocationClassScheduleStatus.failure);
    expect(cubit.state.errorMessage, contains('Tidak dapat terhubung'));

    await cubit.close();
  });
}

class _FakeBookingClassRepository implements BookingClassRepository {
  const _FakeBookingClassRepository({this.classes = const [], this.error});

  final List<GroupClassSession> classes;
  final Object? error;

  @override
  Future<BookingClassCatalog> fetchClassCatalog({
    String? locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    final Object? error = this.error;

    if (error != null) {
      throw error;
    }

    return BookingClassCatalog(
      categories: const [ClassCategoryOption.all],
      sessions: classes,
    );
  }

  @override
  Future<BookingClassCatalog> fetchClassCatalogForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    return fetchClassCatalog(
      locationId: locationId,
      startsFrom: startsFrom,
      startsTo: startsTo,
    );
  }

  @override
  Future<List<GroupClassSession>> fetchClassesForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    final Object? error = this.error;

    if (error != null) {
      throw error;
    }

    return classes;
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
