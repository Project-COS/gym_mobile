import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/icons/app_lucide_icons.dart';
import 'package:do_gym/core/session/auth_session_cubit.dart';
import 'package:do_gym/core/session/auth_session_repository.dart';
import 'package:do_gym/features/booking/data/booking_data.dart';
import 'package:do_gym/features/lokasi/screen/branch_location_data.dart';
import 'package:do_gym/main.dart';

import 'helpers/in_memory_session_storage.dart';
import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_mobile_repositories.dart';

void main() {
  testWidgets('successful login opens home', (WidgetTester tester) async {
    _ignoreNetworkImageExceptionsDuringTest();

    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke akunmu'), findsOneWidget);

    final Finder submitButton = find.byKey(
      const ValueKey<String>('submitButton'),
    );

    ElevatedButton button = tester.widget<ElevatedButton>(submitButton);
    expect(button.onPressed, isNotNull);

    await tester.enterText(
      find.byKey(const ValueKey<String>('emailInput')),
      'member@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('passwordInput')),
      'password123',
    );
    await tester.ensureVisible(submitButton);
    await tester.pump();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang kembali'), findsOneWidget);
  });

  testWidgets('booking class flow reaches success screen', (
    WidgetTester tester,
  ) async {
    _ignoreNetworkImageExceptionsDuringTest();

    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    final Finder submitButton = find.byKey(
      const ValueKey<String>('submitButton'),
    );

    await tester.enterText(
      find.byKey(const ValueKey<String>('emailInput')),
      'member@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('passwordInput')),
      'password123',
    );
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Booking').last);
    await tester.pumpAndSettle();

    expect(find.text('Atur Jadwal Latihanmu'), findsOneWidget);

    await tester.tap(find.text('Kelas'));
    await tester.pumpAndSettle();

    final Finder firstDetailButton = find.text('Detail').first;
    await tester.ensureVisible(firstDetailButton);
    await tester.tap(firstDetailButton);
    await tester.pumpAndSettle();

    expect(find.text('Class Session'), findsOneWidget);

    final Finder detailBookingButton = find.text('Booking').first;
    await tester.ensureVisible(detailBookingButton);
    await tester.tap(detailBookingButton);
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Booking'), findsOneWidget);

    await tester.tap(find.text('Konfirmasi'));
    await tester.pumpAndSettle();

    expect(find.text('Booking Berhasil'), findsOneWidget);
  });
}

Widget _buildTestApp() {
  final repository = AuthSessionRepository(storage: InMemorySessionStorage());

  return MyApp(
    sessionCubit: AuthSessionCubit(repository: repository),
    authRepository: FakeAuthRepository(),
    locationRepository: FakeLocationRepository(
      locations: const [_testBranchLocation],
    ),
    bookingClassRepository: FakeBookingClassRepository(
      classes: const [_testGroupClassSession],
    ),
  );
}

const BranchLocation _testBranchLocation = BranchLocation(
  id: 'location-1',
  name: 'DO GYM Denpasar',
  address: 'Jl. Gatot Subroto',
  area: 'Denpasar',
  phone: '+628123',
  hours: '06:00 - 22:00',
  distance: 'Maps siap',
  capacity: 'Medium',
  access: 'Membership aktif',
  imageUrl: 'https://cdn.example/location.jpg',
  galleryImages: [
    BranchGalleryImage(
      imageUrl: 'https://cdn.example/location.jpg',
      semanticLabel: 'Foto DO GYM Denpasar',
      caption: 'Area latihan utama',
    ),
  ],
  facilities: [BranchFacility(icon: AppLucideIcons.dumbbell, name: 'Gym Area')],
  schedules: [],
  trainers: [],
  mapUrl: 'https://maps.example/location-1',
);

const GroupClassSession _testGroupClassSession = GroupClassSession(
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
  coachRole: 'Yoga Coach',
  rating: '4.8',
  mapQuery: 'DO GYM Denpasar',
  coverImageUrl: 'https://cdn.example/yoga.jpg',
  slots: [BookingSlot(day: 'Hari ini', time: '10:00')],
  tags: ['Yoga'],
  benefits: [],
  gallery: ['https://cdn.example/yoga.jpg'],
);

void _ignoreNetworkImageExceptionsDuringTest() {
  final FlutterExceptionHandler? originalOnError = FlutterError.onError;

  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception is NetworkImageLoadException) {
      return;
    }

    originalOnError?.call(details);
  };

  addTearDown(() {
    FlutterError.onError = originalOnError;
  });
}
