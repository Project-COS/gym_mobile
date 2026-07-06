import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/member_attendance_activity_repository.dart';

enum MemberAttendanceActivityLoadStatus { initial, loading, success, failure }

// State is scoped to the attendance tab. PT and class activity reuse their own
// booking history cubits from their owning features.
class MemberAttendanceActivityState {
  const MemberAttendanceActivityState({
    this.status = MemberAttendanceActivityLoadStatus.initial,
    this.filter = MemberAttendanceHistoryFilter.all,
    this.items = const [],
    this.totalItems = 0,
    this.errorMessage,
  });

  const MemberAttendanceActivityState.loading({
    required this.filter,
    this.items = const [],
    this.totalItems = 0,
  }) : status = MemberAttendanceActivityLoadStatus.loading,
       errorMessage = null;

  const MemberAttendanceActivityState.success({
    required this.filter,
    required this.items,
    required this.totalItems,
  }) : status = MemberAttendanceActivityLoadStatus.success,
       errorMessage = null;

  const MemberAttendanceActivityState.failure({
    required this.filter,
    required this.errorMessage,
    this.items = const [],
    this.totalItems = 0,
  }) : status = MemberAttendanceActivityLoadStatus.failure;

  final MemberAttendanceActivityLoadStatus status;
  final MemberAttendanceHistoryFilter filter;
  final List<MemberAttendanceHistoryItem> items;
  final int totalItems;
  final String? errorMessage;

  bool get isLoading => status == MemberAttendanceActivityLoadStatus.loading;
}

class MemberAttendanceActivityCubit
    extends Cubit<MemberAttendanceActivityState> {
  MemberAttendanceActivityCubit({
    required MemberAttendanceActivityRepository repository,
  }) : _repository = repository,
       super(const MemberAttendanceActivityState());

  final MemberAttendanceActivityRepository _repository;

  Future<void> fetchAttendances({
    MemberAttendanceHistoryFilter? filter,
    bool forceRefresh = false,
  }) async {
    final nextFilter = filter ?? state.filter;

    // Prevent duplicate requests from repeated rebuilds, but allow explicit
    // pull-to-refresh to restart the request.
    if (state.isLoading && !forceRefresh) {
      return;
    }

    emit(
      MemberAttendanceActivityState.loading(
        filter: nextFilter,
        // Keep the current timeline visible while refreshing the same filter.
        items: state.filter == nextFilter ? state.items : const [],
        totalItems: state.filter == nextFilter ? state.totalItems : 0,
      ),
    );

    try {
      final page = await _repository.fetchMemberAttendanceHistory(
        filter: nextFilter,
      );

      if (!isClosed) {
        emit(
          MemberAttendanceActivityState.success(
            filter: nextFilter,
            items: page.items,
            totalItems: page.totalItems,
          ),
        );
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(
          MemberAttendanceActivityState.failure(
            filter: nextFilter,
            errorMessage: _mapErrorMessage(error),
            // A failed refresh should not blank an already-loaded list.
            items: state.filter == nextFilter ? state.items : const [],
            totalItems: state.filter == nextFilter ? state.totalItems : 0,
          ),
        );
      }
    }
  }

  String _mapErrorMessage(Object error) {
    if (error is! ApiException) {
      return 'Riwayat kedatangan belum bisa dimuat. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Sesi kamu sudah berakhir. Silakan masuk kembali.',
      ApiExceptionType.timeout =>
        'Memuat riwayat kedatangan terlalu lama. Periksa koneksi lalu coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Data riwayat kedatangan belum bisa dibaca. Silakan coba kembali.',
      _ => 'Riwayat kedatangan belum bisa dimuat. Silakan coba kembali.',
    };
  }
}
