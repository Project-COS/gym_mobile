import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_session.dart';
import 'auth_session_repository.dart';

enum AuthSessionStatus { initializing, authenticated, unauthenticated }

class AuthSessionState {
  const AuthSessionState({required this.status, this.session});

  const AuthSessionState.initializing()
    : status = AuthSessionStatus.initializing,
      session = null;

  const AuthSessionState.authenticated(AuthSession activeSession)
    : status = AuthSessionStatus.authenticated,
      session = activeSession;

  const AuthSessionState.unauthenticated()
    : status = AuthSessionStatus.unauthenticated,
      session = null;

  final AuthSessionStatus status;
  final AuthSession? session;

  String? get accessToken => session?.accessToken;
}

class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit({required AuthSessionRepository repository})
    : _repository = repository,
      super(const AuthSessionState.initializing());

  final AuthSessionRepository _repository;

  AuthSessionStatus get status => state.status;
  AuthSession? get session => state.session;
  String? get accessToken => state.accessToken;

  Future<void> bootstrap() async {
    emit(const AuthSessionState.initializing());

    AuthSession? restoredSession;

    try {
      restoredSession = await _repository.restoreSession();
    } on Object {
      restoredSession = null;
    }

    if (isClosed) {
      return;
    }

    emit(
      restoredSession == null
          ? const AuthSessionState.unauthenticated()
          : AuthSessionState.authenticated(restoredSession),
    );
  }

  Future<void> saveSession({
    required String accessToken,
    required DateTime expiresAt,
  }) {
    return startSession(
      accessToken: accessToken,
      expiresAt: expiresAt,
      persist: true,
    );
  }

  Future<void> startSession({
    required String accessToken,
    required DateTime expiresAt,
    required bool persist,
  }) async {
    final session = AuthSession(accessToken: accessToken, expiresAt: expiresAt);

    if (persist) {
      await _repository.saveSession(
        accessToken: session.accessToken,
        expiresAt: session.expiresAt,
      );
    } else {
      await _repository.clearSession();
    }

    emit(AuthSessionState.authenticated(session));
  }

  Future<void> clearSession() async {
    await _repository.clearSession();
    emit(const AuthSessionState.unauthenticated());
  }
}
