import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/network/api_exception.dart';
import 'package:do_gym/features/booking/data/booking_data.dart';
import 'package:do_gym/features/classes/data/class_data.dart';
import 'package:do_gym/features/classes/data/repositories/booking_class_repository.dart';
import 'package:do_gym/features/classes/presentation/cubit/booking_class_cubit.dart';

void main() {
  test('loads class catalog for all branches', () async {
    final bookingRepository = _FakeBookingClassRepository(
      catalog: const BookingClassCatalog(
        categories: [ClassCategoryOption(id: 'category-1', label: 'Yoga')],
        sessions: [
          GroupClassSession(
            id: 'class-1:session-1',
            title: 'Yoga Flow',
            subtitle: 'Coach Maya - Hari ini 10:00',
            description: 'Low impact class',
            category: ClassCategory.yoga,
            categoryId: 'category-1',
            categoryName: 'Yoga',
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
    final cubit = BookingClassCubit(bookingClassRepository: bookingRepository);

    await cubit.fetchClassesForDate(DateTime(2026, 6, 16));

    expect(cubit.state.status, BookingClassLoadStatus.success);
    expect(cubit.state.locationName, isNull);
    expect(cubit.state.categories.map((category) => category.label), [
      'Semua',
      'Yoga',
    ]);
    expect(cubit.state.sessions.single.title, 'Yoga Flow');
    expect(bookingRepository.submittedLocationId, isNull);

    await cubit.close();
  });

  test('emits a useful message when class catalog cannot load', () async {
    final cubit = BookingClassCubit(
      bookingClassRepository: _FakeBookingClassRepository(
        error: ApiException.network(),
      ),
    );

    await cubit.fetchClassesForDate(DateTime(2026, 6, 16));

    expect(cubit.state.status, BookingClassLoadStatus.failure);
    expect(cubit.state.errorMessage, contains('Tidak dapat terhubung'));

    await cubit.close();
  });
}

class _FakeBookingClassRepository implements BookingClassRepository {
  _FakeBookingClassRepository({
    this.catalog = const BookingClassCatalog(categories: [], sessions: []),
    this.error,
  });

  final BookingClassCatalog catalog;
  final Object? error;
  String? submittedLocationId;
  String? submittedClassSessionId;

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

    submittedLocationId = locationId;
    return catalog;
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
    final catalog = await fetchClassCatalogForLocation(
      locationId: locationId,
      startsFrom: startsFrom,
      startsTo: startsTo,
    );

    return catalog.sessions;
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
