import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/session/auth_session_cubit.dart';
import 'package:do_gym/core/session/auth_session_repository.dart';
import 'package:do_gym/main.dart';

import 'helpers/in_memory_session_storage.dart';
import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_mobile_repositories.dart';

void main() {
  testWidgets('restores an active session and opens home', (tester) async {
    final storage = InMemorySessionStorage();
    final repository = AuthSessionRepository(storage: storage);
    await repository.saveSession(
      accessToken: 'member-token',
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    );

    await tester.pumpWidget(
      MyApp(
        sessionCubit: AuthSessionCubit(repository: repository),
        authRepository: FakeAuthRepository(),
        locationRepository: FakeLocationRepository(),
        bookingClassRepository: FakeBookingClassRepository(),
        personalTrainingBookingRepository:
            FakePersonalTrainingBookingRepository(),
        trainerRepository: FakeTrainerRepository(),
        memberAttendanceRepository: FakeMemberAttendanceRepository(),
        memberAttendanceActivityRepository:
            FakeMemberAttendanceActivityRepository(),
        profileRepository: FakeProfileRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang kembali'), findsOneWidget);
    expect(find.text('Masuk ke akunmu'), findsNothing);
  });
}
