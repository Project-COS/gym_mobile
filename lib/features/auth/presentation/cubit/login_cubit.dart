import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/session/auth_session_cubit.dart';
import '../../data/repositories/auth_repository.dart';

enum LoginSubmissionStatus { idle, submitting, success, failure }

class LoginState {
  const LoginState({
    this.status = LoginSubmissionStatus.idle,
    this.errorMessage,
  });

  const LoginState.submitting()
    : status = LoginSubmissionStatus.submitting,
      errorMessage = null;

  const LoginState.success()
    : status = LoginSubmissionStatus.success,
      errorMessage = null;

  const LoginState.failure(String message)
    : status = LoginSubmissionStatus.failure,
      errorMessage = message;

  final LoginSubmissionStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == LoginSubmissionStatus.submitting;
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required AuthRepository authRepository,
    required AuthSessionCubit sessionCubit,
  }) : _authRepository = authRepository,
       _sessionCubit = sessionCubit,
       super(const LoginState());

  final AuthRepository _authRepository;
  final AuthSessionCubit _sessionCubit;

  Future<bool> submit({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (state.isSubmitting) {
      return false;
    }

    final validationMessage = _validate(email: email, password: password);

    if (validationMessage != null) {
      emit(LoginState.failure(validationMessage));
      return false;
    }

    emit(const LoginState.submitting());

    try {
      final result = await _authRepository.login(
        email: email.trim(),
        password: password,
      );

      await _sessionCubit.startSession(
        accessToken: result.accessToken,
        expiresAt: result.expiresAt,
        persist: rememberMe,
      );

      if (!isClosed) {
        emit(const LoginState.success());
      }
      return true;
    } on Object catch (error) {
      if (!isClosed) {
        emit(LoginState.failure(_mapErrorMessage(error)));
      }
      return false;
    }
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }

    emit(const LoginState());
  }

  String? _validate({required String email, required String password}) {
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      return 'Email wajib diisi.';
    }

    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailPattern.hasMatch(normalizedEmail)) {
      return 'Masukkan alamat email yang valid.';
    }

    if (password.isEmpty) {
      return 'Password wajib diisi.';
    }

    return null;
  }

  String _mapErrorMessage(Object error) {
    if (error is! ApiException) {
      return 'Terjadi kesalahan. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.unauthorized => 'Email atau password salah.',
      ApiExceptionType.conflict =>
        'Akun ini terdaftar di lebih dari satu gym. Pemilihan gym diperlukan sebelum masuk.',
      ApiExceptionType.timeout =>
        'Koneksi ke server terlalu lama. Silakan coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Respons server tidak valid. Silakan coba kembali.',
      _ => error.message,
    };
  }
}
