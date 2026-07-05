import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/icons/app_lucide_icons.dart';
import 'package:do_gym/core/session/auth_session_cubit.dart';
import 'package:do_gym/core/session/auth_session_repository.dart';
import 'package:do_gym/features/activities/data/repositories/member_attendance_activity_repository.dart';
import 'package:do_gym/features/bookings/data/booking_data.dart';
import 'package:do_gym/features/bookings/data/repositories/personal_training_booking_repository.dart';
import 'package:do_gym/features/classes/data/class_data.dart';
import 'package:do_gym/features/classes/data/repositories/booking_class_repository.dart';
import 'package:do_gym/features/locations/data/branch_location_data.dart';
import 'package:do_gym/features/trainers/data/repositories/trainer_repository.dart';
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

    expect(find.text('BOOKING CONFIRMED'), findsOneWidget);
    expect(find.text('Barcode Check-in'), findsOneWidget);
  });

  testWidgets('activity attendance tab requests member attendance history', (
    WidgetTester tester,
  ) async {
    _ignoreNetworkImageExceptionsDuringTest();

    final attendanceRepository = FakeMemberAttendanceActivityRepository(
      page: MemberAttendanceHistoryPage(
        items: [
          _createCompletedMemberAttendanceHistoryItem(),
          _createOpenMemberAttendanceHistoryItem(),
        ],
        totalItems: 2,
      ),
    );

    await tester.pumpWidget(
      _buildTestApp(memberAttendanceActivityRepository: attendanceRepository),
    );
    await tester.pumpAndSettle();

    await _signIn(tester);

    expect(attendanceRepository.submittedFilter, isNull);

    await tester.tap(find.text('Activity').last);
    await tester.pumpAndSettle();

    expect(
      attendanceRepository.submittedFilter,
      MemberAttendanceHistoryFilter.all,
    );
    expect(find.text('DO GYM Denpasar'), findsOneWidget);
    expect(find.text('DO GYM Renon'), findsOneWidget);
    expect(find.text('2 Data'), findsOneWidget);
    expect(find.text('Belum check-out'), findsOneWidget);

    await tester.tap(find.text('Hari Ini'));
    await tester.pumpAndSettle();

    expect(
      attendanceRepository.submittedFilter,
      MemberAttendanceHistoryFilter.today,
    );
  });

  testWidgets('activity PT tab requests all booking statuses', (
    WidgetTester tester,
  ) async {
    _ignoreNetworkImageExceptionsDuringTest();

    final personalTrainingBookingRepository =
        FakePersonalTrainingBookingRepository(
          historyItems: const [
            _completedPersonalTrainingBooking,
            _scheduledPersonalTrainingBooking,
          ],
        );

    await tester.pumpWidget(
      _buildTestApp(
        personalTrainingBookingRepository: personalTrainingBookingRepository,
      ),
    );
    await tester.pumpAndSettle();

    await _signIn(tester);

    expect(personalTrainingBookingRepository.submittedHistoryFilter, isNull);

    await tester.tap(find.text('Activity').last);
    await tester.pumpAndSettle();

    expect(
      personalTrainingBookingRepository.submittedHistoryFilter,
      PersonalTrainingBookingHistoryFilter.all,
    );

    await tester.tap(find.text('PT'));
    await tester.pumpAndSettle();

    expect(find.text('Strength Starter'), findsOneWidget);
    expect(find.text('Mobility Prep'), findsOneWidget);
    expect(find.text('2 Session'), findsOneWidget);

    final Finder qrBookingButton = find.text('Lihat QR booking');
    await tester.ensureVisible(qrBookingButton);
    await tester.tap(qrBookingButton);
    await tester.pumpAndSettle();

    expect(find.text('PTB-SCHEDULED'), findsWidgets);
    expect(find.text('Barcode Check-in'), findsOneWidget);
  });

  testWidgets('activity class tab requests all class booking statuses', (
    WidgetTester tester,
  ) async {
    _ignoreNetworkImageExceptionsDuringTest();

    final bookingClassRepository = FakeBookingClassRepository(
      classes: const [_testGroupClassSession],
      historyItems: const [_completedClassBooking, _scheduledClassBooking],
    );

    await tester.pumpWidget(
      _buildTestApp(bookingClassRepository: bookingClassRepository),
    );
    await tester.pumpAndSettle();

    await _signIn(tester);

    expect(bookingClassRepository.submittedHistoryFilter, isNull);

    await tester.tap(find.text('Activity').last);
    await tester.pumpAndSettle();

    expect(
      bookingClassRepository.submittedHistoryFilter,
      ClassBookingHistoryFilter.all,
    );

    await tester.tap(find.text('Kelas').last);
    await tester.pumpAndSettle();

    expect(find.text('Yoga Flow'), findsOneWidget);
    expect(find.text('Strength Class'), findsOneWidget);
    expect(find.text('2 Kelas'), findsOneWidget);

    final Finder qrBookingButton = find.text('Lihat QR booking');
    await tester.ensureVisible(qrBookingButton);
    await tester.tap(qrBookingButton);
    await tester.pumpAndSettle();

    expect(find.text('CLB-SCHEDULED'), findsWidgets);
    expect(find.text('Barcode Check-in'), findsOneWidget);
  });

  testWidgets('profile tab loads and saves profile changes', (
    WidgetTester tester,
  ) async {
    _ignoreNetworkImageExceptionsDuringTest();

    final profileRepository = FakeProfileRepository();

    await tester.pumpWidget(
      _buildTestApp(profileRepository: profileRepository),
    );
    await tester.pumpAndSettle();

    await _signIn(tester);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    expect(find.text('Andi Member'), findsOneWidget);
    expect(find.text('Premium Access'), findsOneWidget);
    expect(find.text('Semua Cabang'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_rounded));
    await tester.pumpAndSettle();

    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'Andi Updated');
    await tester.enterText(textFields.at(1), 'updated@example.com');
    await tester.enterText(textFields.at(2), '081299999999');
    final saveButton = find.text('Simpan');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(profileRepository.submittedName, 'Andi Updated');
    expect(profileRepository.submittedEmail, 'updated@example.com');
    expect(profileRepository.submittedPhone, '081299999999');
    expect(find.text('Andi Updated'), findsOneWidget);
  });
}

Widget _buildTestApp({
  FakeBookingClassRepository? bookingClassRepository,
  FakePersonalTrainingBookingRepository? personalTrainingBookingRepository,
  FakeMemberAttendanceActivityRepository? memberAttendanceActivityRepository,
  FakeProfileRepository? profileRepository,
}) {
  final repository = AuthSessionRepository(storage: InMemorySessionStorage());

  return MyApp(
    sessionCubit: AuthSessionCubit(repository: repository),
    authRepository: FakeAuthRepository(),
    locationRepository: FakeLocationRepository(
      locations: const [_testBranchLocation],
    ),
    bookingClassRepository:
        bookingClassRepository ??
        FakeBookingClassRepository(classes: const [_testGroupClassSession]),
    personalTrainingBookingRepository:
        personalTrainingBookingRepository ??
        FakePersonalTrainingBookingRepository(),
    trainerRepository: FakeTrainerRepository(
      trainers: const [_testTrainerProfile],
    ),
    memberAttendanceRepository: FakeMemberAttendanceRepository(),
    memberAttendanceActivityRepository:
        memberAttendanceActivityRepository ??
        FakeMemberAttendanceActivityRepository(),
    profileRepository: profileRepository ?? FakeProfileRepository(),
  );
}

Future<void> _signIn(WidgetTester tester) async {
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
  slots: [BookingSlot(day: 'Hari ini', time: '10:00', sessionId: 'session-1')],
  tags: ['Yoga'],
  benefits: [],
  gallery: ['https://cdn.example/yoga.jpg'],
);

const TrainerProfile _testTrainerProfile = TrainerProfile(
  id: 'trainer-1',
  name: 'Coach Maya',
  subtitle: 'Strength coach',
  description: 'Membantu progres latihan member.',
  branch: 'Denpasar',
  duration: '60 Menit',
  rating: 4.8,
  specialization: 'Strength',
  location: 'DO GYM Denpasar - Denpasar',
  programType: 'Strength - All Level',
  role: 'Strength coach',
  mapQuery: 'DO GYM Denpasar',
  mapUrl: 'https://maps.example/location-1',
  coverImageUrl: 'https://cdn.example/trainer.jpg',
  schedules: [
    TrainerSchedule(label: 'Senin - 08:00 - 12:00', locationName: 'Denpasar'),
  ],
  benefits: [
    TrainerBenefit(icon: AppLucideIcons.dumbbell, label: 'Personal plan'),
  ],
  gallery: ['https://cdn.example/trainer.jpg'],
  programs: [
    TrainerProgram(
      id: 'program-1',
      name: 'Strength',
      subtitle: 'Personal strength',
      description: 'Program kekuatan personal',
      duration: '60 Menit',
      focus: 'Strength',
      locationName: 'DO GYM Denpasar',
      coverImageUrl: 'https://cdn.example/program.jpg',
      benefits: ['Personal plan'],
    ),
  ],
  locations: [
    TrainerLocation(
      id: 'location-1',
      name: 'DO GYM Denpasar',
      area: 'Denpasar',
      address: 'Jl. Gatot Subroto',
      isPrimary: true,
      mapUrl: 'https://maps.example/location-1',
    ),
  ],
  canRate: true,
);

const PersonalTrainingBookingHistoryItem _completedPersonalTrainingBooking =
    PersonalTrainingBookingHistoryItem(
      id: 'booking-completed',
      bookingCode: 'PTB-COMPLETED',
      qrPayload: 'pt_booking:PTB-COMPLETED',
      title: 'Strength Starter',
      trainerName: 'Coach Maya',
      schedule: 'Minggu, 28 Jun 06:00',
      duration: '60 Menit',
      location: 'DO GYM Denpasar - Denpasar',
      status: 'COMPLETED',
      source: 'AD_HOC',
      canShowQr: false,
    );

const PersonalTrainingBookingHistoryItem _scheduledPersonalTrainingBooking =
    PersonalTrainingBookingHistoryItem(
      id: 'booking-scheduled',
      bookingCode: 'PTB-SCHEDULED',
      qrPayload: 'pt_booking:PTB-SCHEDULED',
      title: 'Mobility Prep',
      trainerName: 'Coach Maya',
      schedule: 'Minggu, 28 Jun 07:00',
      duration: '60 Menit',
      location: 'DO GYM Denpasar - Denpasar',
      status: 'SCHEDULED',
      source: 'AD_HOC',
      canShowQr: true,
    );

const ClassBookingHistoryItem _completedClassBooking = ClassBookingHistoryItem(
  id: 'class-booking-completed',
  bookingCode: 'CLB-COMPLETED',
  qrPayload: 'class_booking:CLB-COMPLETED',
  title: 'Yoga Flow',
  trainerName: 'Coach Maya',
  schedule: 'Minggu, 28 Jun 08:00',
  duration: '60 Menit',
  location: 'DO GYM Denpasar - Studio 1',
  status: 'COMPLETED',
  source: 'MOBILE_APP',
  canShowQr: false,
);

const ClassBookingHistoryItem _scheduledClassBooking = ClassBookingHistoryItem(
  id: 'class-booking-scheduled',
  bookingCode: 'CLB-SCHEDULED',
  qrPayload: 'class_booking:CLB-SCHEDULED',
  title: 'Strength Class',
  trainerName: 'Coach Maya',
  schedule: 'Minggu, 28 Jun 09:00',
  duration: '60 Menit',
  location: 'DO GYM Denpasar - Studio 2',
  status: 'SCHEDULED',
  source: 'MOBILE_APP',
  canShowQr: true,
);

MemberAttendanceHistoryItem _createCompletedMemberAttendanceHistoryItem() {
  return MemberAttendanceHistoryItem(
    id: 'attendance-completed',
    locationName: 'DO GYM Denpasar',
    locationArea: 'Denpasar',
    planName: 'Premium Access',
    checkedInAt: DateTime(2026, 7, 5, 8, 0),
    checkedOutAt: DateTime(2026, 7, 5, 9, 15),
    status: 'COMPLETED',
    durationMinutes: 75,
  );
}

MemberAttendanceHistoryItem _createOpenMemberAttendanceHistoryItem() {
  return MemberAttendanceHistoryItem(
    id: 'attendance-open',
    locationName: 'DO GYM Renon',
    locationArea: 'Renon',
    planName: 'Premium Access',
    checkedInAt: DateTime(2026, 7, 5, 10, 0),
    checkedOutAt: null,
    status: 'OPEN',
    durationMinutes: null,
  );
}

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
