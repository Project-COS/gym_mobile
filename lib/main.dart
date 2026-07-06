import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/colors.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/session/auth_session_cubit.dart';
import 'core/session/auth_session_repository.dart';
import 'core/session/secure_session_storage.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/services/auth_api_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/activities/data/repositories/member_attendance_activity_repository.dart';
import 'features/activities/data/services/member_attendance_activity_api_service.dart';
import 'features/bookings/data/repositories/personal_training_booking_repository.dart';
import 'features/bookings/data/services/personal_training_booking_api_service.dart';
import 'features/classes/data/repositories/booking_class_repository.dart';
import 'features/classes/data/services/booking_class_api_service.dart';
import 'features/home/screen/home_screen.dart';
import 'features/locations/data/repositories/location_repository.dart';
import 'features/locations/data/services/location_api_service.dart';
import 'features/member_attendance/data/repositories/member_attendance_repository.dart';
import 'features/member_attendance/data/services/member_attendance_api_service.dart';
import 'features/profile/data/repositories/profile_repository.dart';
import 'features/profile/data/services/profile_api_service.dart';
import 'features/trainers/data/repositories/trainer_repository.dart';
import 'features/trainers/data/services/trainer_api_service.dart';

void main() {
  // Secure storage uses platform channels, so initialize Flutter bindings before
  // constructing session dependencies.
  WidgetsFlutterBinding.ensureInitialized();

  // Keep long-lived app dependencies at the root so feature screens receive the
  // same repositories through providers instead of creating their own clients.
  final sessionRepository = AuthSessionRepository(
    storage: const SecureSessionStorage(),
  );
  final sessionCubit = AuthSessionCubit(repository: sessionRepository);
  final apiClient = ApiClient(
    baseUri: AppConfig.apiBaseUri,
    accessTokenProvider: () async {
      // Prefer the in-memory token after bootstrap, then fall back to secure
      // storage for requests made before the session cubit has emitted state.
      return sessionCubit.accessToken ??
          await sessionRepository.readAccessToken();
    },
  );
  final authRepository = RemoteAuthRepository(
    apiService: AuthApiService(apiClient: apiClient),
  );
  final locationRepository = RemoteLocationRepository(
    apiService: LocationApiService(apiClient: apiClient),
  );
  final bookingClassRepository = RemoteBookingClassRepository(
    apiService: BookingClassApiService(apiClient: apiClient),
  );
  final personalTrainingBookingRepository =
      RemotePersonalTrainingBookingRepository(
        apiService: PersonalTrainingBookingApiService(apiClient: apiClient),
      );
  final trainerRepository = RemoteTrainerRepository(
    apiService: TrainerApiService(apiClient: apiClient),
  );
  final memberAttendanceRepository = RemoteMemberAttendanceRepository(
    apiService: MemberAttendanceApiService(apiClient: apiClient),
  );
  final memberAttendanceActivityRepository =
      RemoteMemberAttendanceActivityRepository(
        apiService: MemberAttendanceActivityApiService(apiClient: apiClient),
      );
  final profileRepository = RemoteProfileRepository(
    apiService: ProfileApiService(apiClient: apiClient),
  );

  runApp(
    MyApp(
      sessionCubit: sessionCubit,
      authRepository: authRepository,
      locationRepository: locationRepository,
      bookingClassRepository: bookingClassRepository,
      personalTrainingBookingRepository: personalTrainingBookingRepository,
      trainerRepository: trainerRepository,
      memberAttendanceRepository: memberAttendanceRepository,
      memberAttendanceActivityRepository: memberAttendanceActivityRepository,
      profileRepository: profileRepository,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.sessionCubit,
    required this.authRepository,
    required this.locationRepository,
    required this.bookingClassRepository,
    required this.personalTrainingBookingRepository,
    required this.trainerRepository,
    required this.memberAttendanceRepository,
    required this.memberAttendanceActivityRepository,
    required this.profileRepository,
  });

  final AuthSessionCubit sessionCubit;
  final AuthRepository authRepository;
  final LocationRepository locationRepository;
  final BookingClassRepository bookingClassRepository;
  final PersonalTrainingBookingRepository personalTrainingBookingRepository;
  final TrainerRepository trainerRepository;
  final MemberAttendanceRepository memberAttendanceRepository;
  final MemberAttendanceActivityRepository memberAttendanceActivityRepository;
  final ProfileRepository profileRepository;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Restore any persisted session before deciding whether to show Home or Login.
    widget.sessionCubit.bootstrap();
  }

  @override
  void didUpdateWidget(covariant MyApp oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sessionCubit != widget.sessionCubit) {
      // If tests or a parent rebuild replace the root cubit, close the old one
      // and bootstrap the replacement so listeners stay aligned with the session.
      oldWidget.sessionCubit.close();
      widget.sessionCubit.bootstrap();
    }
  }

  @override
  void dispose() {
    widget.sessionCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // RepositoryProvider.value is used because these repositories are created in
    // main() and owned by the root app, not by the provider widgets themselves.
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: widget.authRepository),
        RepositoryProvider<LocationRepository>.value(
          value: widget.locationRepository,
        ),
        RepositoryProvider<BookingClassRepository>.value(
          value: widget.bookingClassRepository,
        ),
        RepositoryProvider<PersonalTrainingBookingRepository>.value(
          value: widget.personalTrainingBookingRepository,
        ),
        RepositoryProvider<TrainerRepository>.value(
          value: widget.trainerRepository,
        ),
        RepositoryProvider<MemberAttendanceRepository>.value(
          value: widget.memberAttendanceRepository,
        ),
        RepositoryProvider<MemberAttendanceActivityRepository>.value(
          value: widget.memberAttendanceActivityRepository,
        ),
        RepositoryProvider<ProfileRepository>.value(
          value: widget.profileRepository,
        ),
      ],
      child: BlocProvider<AuthSessionCubit>.value(
        value: widget.sessionCubit,
        child: MaterialApp(
          title: 'GYM APP',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD9A52E),
              brightness: Brightness.dark,
            ),
          ),
          home: BlocBuilder<AuthSessionCubit, AuthSessionState>(
            builder: (context, state) {
              // The root screen is driven only by session state; feature screens
              // handle their own loading and error states after authentication.
              return switch (state.status) {
                AuthSessionStatus.initializing =>
                  const _SessionBootstrapScreen(),
                AuthSessionStatus.authenticated => const HomeScreen(),
                AuthSessionStatus.unauthenticated => const LoginScreen(),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _SessionBootstrapScreen extends StatelessWidget {
  const _SessionBootstrapScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Center(child: CircularProgressIndicator(color: AppColors.gymGold)),
    );
  }
}
