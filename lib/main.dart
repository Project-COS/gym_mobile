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
import 'features/booking/data/repositories/booking_class_repository.dart';
import 'features/booking/data/services/booking_class_api_service.dart';
import 'features/home/screen/home_screen.dart';
import 'features/lokasi/data/repositories/location_repository.dart';
import 'features/lokasi/data/services/location_api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final sessionRepository = AuthSessionRepository(
    storage: const SecureSessionStorage(),
  );
  final sessionCubit = AuthSessionCubit(repository: sessionRepository);
  final apiClient = ApiClient(
    baseUri: AppConfig.apiBaseUri,
    accessTokenProvider: () async {
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

  runApp(
    MyApp(
      sessionCubit: sessionCubit,
      authRepository: authRepository,
      locationRepository: locationRepository,
      bookingClassRepository: bookingClassRepository,
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
  });

  final AuthSessionCubit sessionCubit;
  final AuthRepository authRepository;
  final LocationRepository locationRepository;
  final BookingClassRepository bookingClassRepository;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.sessionCubit.bootstrap();
  }

  @override
  void didUpdateWidget(covariant MyApp oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sessionCubit != widget.sessionCubit) {
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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: widget.authRepository),
        RepositoryProvider<LocationRepository>.value(
          value: widget.locationRepository,
        ),
        RepositoryProvider<BookingClassRepository>.value(
          value: widget.bookingClassRepository,
        ),
      ],
      child: BlocProvider<AuthSessionCubit>.value(
        value: widget.sessionCubit,
        child: MaterialApp(
          title: 'DO GYM',
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
