import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/personal_training_booking_repository.dart';

enum PersonalTrainingBookingHistoryLoadStatus {
  initial,
  loading,
  success,
  failure,
}

// State for PT booking history only. Class booking history uses the classes
// feature Cubit so each booking type keeps ownership of its own API contract.
class PersonalTrainingBookingHistoryState {
  const PersonalTrainingBookingHistoryState({
    this.status = PersonalTrainingBookingHistoryLoadStatus.initial,
    this.filter = PersonalTrainingBookingHistoryFilter.upcoming,
    this.bookings = const [],
    this.errorMessage,
  });

  const PersonalTrainingBookingHistoryState.loading({
    required this.filter,
    this.bookings = const [],
  }) : status = PersonalTrainingBookingHistoryLoadStatus.loading,
       errorMessage = null;

  const PersonalTrainingBookingHistoryState.success({
    required this.filter,
    required this.bookings,
  }) : status = PersonalTrainingBookingHistoryLoadStatus.success,
       errorMessage = null;

  const PersonalTrainingBookingHistoryState.failure({
    required this.filter,
    required this.errorMessage,
    this.bookings = const [],
  }) : status = PersonalTrainingBookingHistoryLoadStatus.failure;

  final PersonalTrainingBookingHistoryLoadStatus status;
  final PersonalTrainingBookingHistoryFilter filter;
  final List<PersonalTrainingBookingHistoryItem> bookings;
  final String? errorMessage;

  bool get isLoading =>
      status == PersonalTrainingBookingHistoryLoadStatus.loading;
}

class PersonalTrainingBookingHistoryCubit
    extends Cubit<PersonalTrainingBookingHistoryState> {
  PersonalTrainingBookingHistoryCubit({
    required PersonalTrainingBookingRepository repository,
  }) : _repository = repository,
       super(const PersonalTrainingBookingHistoryState());

  final PersonalTrainingBookingRepository _repository;

  Future<void> fetchBookings({
    PersonalTrainingBookingHistoryFilter? filter,
    bool forceRefresh = false,
  }) async {
    final nextFilter = filter ?? state.filter;

    // Prevent duplicate fetches from rebuilds, while still allowing explicit
    // pull-to-refresh to restart the request.
    if (state.isLoading && !forceRefresh) {
      return;
    }

    emit(
      PersonalTrainingBookingHistoryState.loading(
        filter: nextFilter,
        // Keep the existing list visible when refreshing the same filter.
        bookings: state.filter == nextFilter ? state.bookings : const [],
      ),
    );

    try {
      final bookings = await _repository.fetchPersonalTrainingBookings(
        filter: nextFilter,
      );

      if (!isClosed) {
        emit(
          PersonalTrainingBookingHistoryState.success(
            filter: nextFilter,
            bookings: bookings,
          ),
        );
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(
          PersonalTrainingBookingHistoryState.failure(
            filter: nextFilter,
            errorMessage: _mapErrorMessage(error),
          ),
        );
      }
    }
  }

  String _mapErrorMessage(Object error) {
    // Keep network details out of user-facing copy.
    if (error is! ApiException) {
      return 'Riwayat booking belum bisa dimuat. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Sesi kamu sudah berakhir. Silakan masuk kembali.',
      ApiExceptionType.timeout =>
        'Memuat riwayat booking terlalu lama. Periksa koneksi lalu coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Data riwayat booking belum bisa dibaca. Silakan coba kembali.',
      _ => 'Riwayat booking belum bisa dimuat. Silakan coba kembali.',
    };
  }
}
