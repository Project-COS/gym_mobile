import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/booking_class_repository.dart';

enum ClassBookingHistoryLoadStatus { initial, loading, success, failure }

// State for class booking history tabs: Requested, History, and All.
class ClassBookingHistoryState {
  const ClassBookingHistoryState({
    this.status = ClassBookingHistoryLoadStatus.initial,
    this.filter = ClassBookingHistoryFilter.upcoming,
    this.bookings = const [],
    this.errorMessage,
  });

  const ClassBookingHistoryState.loading({
    required this.filter,
    this.bookings = const [],
  }) : status = ClassBookingHistoryLoadStatus.loading,
       errorMessage = null;

  const ClassBookingHistoryState.success({
    required this.filter,
    required this.bookings,
  }) : status = ClassBookingHistoryLoadStatus.success,
       errorMessage = null;

  const ClassBookingHistoryState.failure({
    required this.filter,
    required this.errorMessage,
    this.bookings = const [],
  }) : status = ClassBookingHistoryLoadStatus.failure;

  final ClassBookingHistoryLoadStatus status;
  final ClassBookingHistoryFilter filter;
  final List<ClassBookingHistoryItem> bookings;
  final String? errorMessage;

  bool get isLoading => status == ClassBookingHistoryLoadStatus.loading;
}

class ClassBookingHistoryCubit extends Cubit<ClassBookingHistoryState> {
  ClassBookingHistoryCubit({required BookingClassRepository repository})
    : _repository = repository,
      super(const ClassBookingHistoryState());

  final BookingClassRepository _repository;

  Future<void> fetchBookings({
    ClassBookingHistoryFilter? filter,
    bool forceRefresh = false,
  }) async {
    final nextFilter = filter ?? state.filter;

    // Let manual refresh bypass this guard while blocking accidental duplicate loads.
    if (state.isLoading && !forceRefresh) {
      return;
    }

    emit(
      ClassBookingHistoryState.loading(
        filter: nextFilter,
        // Preserve the current list when refreshing the same tab to avoid UI flicker.
        bookings: state.filter == nextFilter ? state.bookings : const [],
      ),
    );

    try {
      final bookings = await _repository.fetchClassBookings(filter: nextFilter);

      if (!isClosed) {
        emit(
          ClassBookingHistoryState.success(
            filter: nextFilter,
            bookings: bookings,
          ),
        );
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(
          ClassBookingHistoryState.failure(
            filter: nextFilter,
            errorMessage: _mapErrorMessage(error),
          ),
        );
      }
    }
  }

  String _mapErrorMessage(Object error) {
    if (error is! ApiException) {
      return 'Riwayat kelas belum bisa dimuat. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Sesi kamu sudah berakhir. Silakan masuk kembali.',
      ApiExceptionType.timeout =>
        'Memuat riwayat kelas terlalu lama. Periksa koneksi lalu coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Data riwayat kelas belum bisa dibaca. Silakan coba kembali.',
      _ => 'Riwayat kelas belum bisa dimuat. Silakan coba kembali.',
    };
  }
}
