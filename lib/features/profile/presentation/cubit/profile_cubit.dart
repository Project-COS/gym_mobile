import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/profile_data.dart';
import '../../data/repositories/profile_repository.dart';

enum ProfileLoadStatus { initial, loading, success, updating, failure }

class ProfileState {
  const ProfileState({
    this.status = ProfileLoadStatus.initial,
    this.profile,
    this.errorMessage,
    this.formErrorMessage,
  });

  final ProfileLoadStatus status;
  final MemberProfile? profile;
  final String? errorMessage;
  final String? formErrorMessage;

  bool get isLoading => status == ProfileLoadStatus.loading;
  bool get isUpdating => status == ProfileLoadStatus.updating;

  ProfileState copyWith({
    ProfileLoadStatus? status,
    Object? profile = _unchanged,
    Object? errorMessage = _unchanged,
    Object? formErrorMessage = _unchanged,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: identical(profile, _unchanged)
          ? this.profile
          : profile as MemberProfile?,
      errorMessage: identical(errorMessage, _unchanged)
          ? this.errorMessage
          : errorMessage as String?,
      formErrorMessage: identical(formErrorMessage, _unchanged)
          ? this.formErrorMessage
          : formErrorMessage as String?,
    );
  }
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required ProfileRepository repository})
    : _repository = repository,
      super(const ProfileState());

  final ProfileRepository _repository;

  Future<void> fetchProfile({bool forceRefresh = false}) async {
    if ((state.isLoading || state.isUpdating) && !forceRefresh) {
      return;
    }

    if (state.status == ProfileLoadStatus.success && !forceRefresh) {
      return;
    }

    emit(
      state.copyWith(
        status: ProfileLoadStatus.loading,
        errorMessage: null,
        formErrorMessage: null,
      ),
    );

    try {
      final profile = await _repository.fetchProfile();

      if (!isClosed) {
        emit(ProfileState(status: ProfileLoadStatus.success, profile: profile));
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: ProfileLoadStatus.failure,
            errorMessage: _mapFetchErrorMessage(error),
          ),
        );
      }
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPhone = phone.trim();
    final validationMessage = _validateProfileInput(
      name: normalizedName,
      email: normalizedEmail,
      phone: normalizedPhone,
    );

    if (validationMessage != null) {
      emit(
        state.copyWith(formErrorMessage: validationMessage, errorMessage: null),
      );
      return false;
    }

    emit(
      state.copyWith(
        status: ProfileLoadStatus.updating,
        errorMessage: null,
        formErrorMessage: null,
      ),
    );

    try {
      final profile = await _repository.updateProfile(
        name: normalizedName,
        email: normalizedEmail,
        phone: normalizedPhone,
      );

      if (!isClosed) {
        emit(ProfileState(status: ProfileLoadStatus.success, profile: profile));
      }

      return true;
    } on Object catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: ProfileLoadStatus.success,
            errorMessage: _mapUpdateErrorMessage(error),
            formErrorMessage: _mapUpdateErrorMessage(error),
          ),
        );
      }

      return false;
    }
  }

  String? _validateProfileInput({
    required String name,
    required String email,
    required String phone,
  }) {
    if (name.length < 2) {
      return 'Nama minimal 2 karakter.';
    }

    if (!_emailPattern.hasMatch(email)) {
      return 'Masukkan email yang valid.';
    }

    final digitCount = RegExp(r'\d').allMatches(phone).length;

    if (digitCount < 10) {
      return 'Nomor telepon minimal 10 digit.';
    }

    return null;
  }

  String _mapFetchErrorMessage(Object error) {
    if (error is! ApiException) {
      return 'Profile belum bisa dimuat. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Sesi kamu sudah berakhir. Silakan masuk kembali.',
      ApiExceptionType.timeout =>
        'Memuat profile terlalu lama. Periksa koneksi lalu coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Data profile belum bisa dibaca. Silakan coba kembali.',
      _ => 'Profile belum bisa dimuat. Silakan coba kembali.',
    };
  }

  String _mapUpdateErrorMessage(Object error) {
    if (error is! ApiException) {
      return 'Profile belum bisa disimpan. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.conflict => 'Email sudah digunakan member lain.',
      ApiExceptionType.badRequest ||
      ApiExceptionType.validation => error.message,
      ApiExceptionType.unauthorized =>
        'Sesi kamu sudah berakhir. Silakan masuk kembali.',
      ApiExceptionType.timeout =>
        'Menyimpan profile terlalu lama. Periksa koneksi lalu coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Data profile terbaru belum bisa dibaca. Silakan coba kembali.',
      _ => 'Profile belum bisa disimpan. Silakan coba kembali.',
    };
  }
}

const Object _unchanged = Object();
final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
