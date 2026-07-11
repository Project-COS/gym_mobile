import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/dto/push_device_registration_dto.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/services/push_notification_service.dart';

enum PushNotificationLifecycleStatus {
  idle,
  initializing,
  ready,
  permissionDenied,
  failure,
}

class PushNotificationState {
  const PushNotificationState({
    this.status = PushNotificationLifecycleStatus.idle,
    this.receivedRevision = 0,
    this.openedRevision = 0,
    this.openedData = const {},
  });

  final PushNotificationLifecycleStatus status;
  final int receivedRevision;
  final int openedRevision;
  final Map<String, String> openedData;

  PushNotificationState copyWith({
    PushNotificationLifecycleStatus? status,
    int? receivedRevision,
    int? openedRevision,
    Map<String, String>? openedData,
  }) {
    return PushNotificationState(
      status: status ?? this.status,
      receivedRevision: receivedRevision ?? this.receivedRevision,
      openedRevision: openedRevision ?? this.openedRevision,
      openedData: openedData ?? this.openedData,
    );
  }
}

class PushNotificationCubit extends Cubit<PushNotificationState> {
  PushNotificationCubit({
    required NotificationRepository repository,
    required PushNotificationService pushNotificationService,
  }) : _repository = repository,
       _pushNotificationService = pushNotificationService,
       super(const PushNotificationState());

  final NotificationRepository _repository;
  final PushNotificationService _pushNotificationService;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<PushNotificationEvent>? _foregroundSubscription;
  StreamSubscription<Map<String, String>>? _openedSubscription;
  PushAuthorizationStatus _authorizationStatus =
      PushAuthorizationStatus.notDetermined;
  String? _currentRegistrationToken;
  String? _locale;

  Future<void> startForAuthenticatedMember({required String locale}) async {
    if (state.status == PushNotificationLifecycleStatus.initializing ||
        state.status == PushNotificationLifecycleStatus.ready) {
      return;
    }

    _locale = locale;
    emit(state.copyWith(status: PushNotificationLifecycleStatus.initializing));
    await _cancelSubscriptions();

    // Subscribe before initialization so cold-start notification interactions
    // emitted by getInitialMessage are not lost.
    _foregroundSubscription = _pushNotificationService.foregroundMessages
        .listen(
          (_) => emit(
            state.copyWith(receivedRevision: state.receivedRevision + 1),
          ),
        );
    _openedSubscription = _pushNotificationService.openedNotifications.listen(
      (data) => emit(
        state.copyWith(
          openedRevision: state.openedRevision + 1,
          openedData: data,
        ),
      ),
    );

    try {
      await _pushNotificationService.initialize();
      _authorizationStatus = await _pushNotificationService.requestPermission();
      _currentRegistrationToken = await _pushNotificationService
          .getRegistrationToken();

      if (_currentRegistrationToken != null) {
        await _registerToken(_currentRegistrationToken!);
      }

      _tokenRefreshSubscription = _pushNotificationService.tokenRefreshes.listen(
        (token) async {
          _currentRegistrationToken = token;

          try {
            await _registerToken(token);
          } on Object {
            // FCM can refresh while the device is offline. A later app start or
            // refresh event will upload the latest token again.
          }
        },
      );

      if (!isClosed) {
        emit(
          state.copyWith(
            status: _authorizationStatus == PushAuthorizationStatus.denied
                ? PushNotificationLifecycleStatus.permissionDenied
                : PushNotificationLifecycleStatus.ready,
          ),
        );
      }
    } on Object {
      if (!isClosed) {
        emit(state.copyWith(status: PushNotificationLifecycleStatus.failure));
      }
    }
  }

  Future<void> stopForSignedOutMember() async {
    await _cancelSubscriptions();
    _currentRegistrationToken = null;
    _locale = null;

    if (!isClosed) {
      emit(const PushNotificationState());
    }
  }

  Future<void> disableCurrentDeviceBeforeLogout() async {
    await _repository.disablePushDevice(
      registrationToken: _currentRegistrationToken,
    );
  }

  Future<void> _registerToken(String token) {
    return _repository.registerPushDevice(
      PushDeviceRegistrationDto(
        registrationToken: token,
        platform: _pushNotificationService.currentPlatform,
        permissionStatus: _permissionStatusValue(_authorizationStatus),
        locale: _locale,
      ),
    );
  }

  String _permissionStatusValue(PushAuthorizationStatus status) {
    return switch (status) {
      PushAuthorizationStatus.notDetermined => 'not_determined',
      PushAuthorizationStatus.authorized => 'authorized',
      PushAuthorizationStatus.provisional => 'provisional',
      PushAuthorizationStatus.denied => 'denied',
    };
  }

  Future<void> _cancelSubscriptions() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _foregroundSubscription = null;
    _openedSubscription = null;
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    return super.close();
  }
}
