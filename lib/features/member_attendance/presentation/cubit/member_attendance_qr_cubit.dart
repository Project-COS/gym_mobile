import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/member_attendance_repository.dart';

enum MemberAttendanceQrLoadStatus { initial, loading, success, failure }

// State for creating and refreshing the member attendance QR shown in the sheet.
class MemberAttendanceQrState {
  const MemberAttendanceQrState({
    this.status = MemberAttendanceQrLoadStatus.initial,
    this.qr,
    this.errorMessage,
  });

  const MemberAttendanceQrState.loading({this.qr})
    : status = MemberAttendanceQrLoadStatus.loading,
      errorMessage = null;

  const MemberAttendanceQrState.success({required this.qr})
    : status = MemberAttendanceQrLoadStatus.success,
      errorMessage = null;

  const MemberAttendanceQrState.failure({required this.errorMessage, this.qr})
    : status = MemberAttendanceQrLoadStatus.failure;

  final MemberAttendanceQrLoadStatus status;
  final MemberAttendanceQr? qr;
  final String? errorMessage;

  bool get isLoading => status == MemberAttendanceQrLoadStatus.loading;
}

class MemberAttendanceQrCubit extends Cubit<MemberAttendanceQrState> {
  MemberAttendanceQrCubit({required MemberAttendanceRepository repository})
    : _repository = repository,
      super(const MemberAttendanceQrState());

  final MemberAttendanceRepository _repository;

  Future<void> createQr({bool forceRefresh = false}) async {
    // Block accidental duplicate requests while allowing explicit refresh taps.
    if (state.isLoading && !forceRefresh) {
      return;
    }

    // Keep the previous QR visible while a refresh request is in progress.
    emit(MemberAttendanceQrState.loading(qr: state.qr));

    try {
      final qr = await _repository.createMemberAttendanceQr();

      if (!isClosed) {
        emit(MemberAttendanceQrState.success(qr: qr));
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(
          MemberAttendanceQrState.failure(
            errorMessage: _mapErrorMessage(error),
            // Preserve the last usable QR so the member is not left with an empty sheet.
            qr: state.qr,
          ),
        );
      }
    }
  }

  String _mapErrorMessage(Object error) {
    if (error is! ApiException) {
      return 'QR member belum bisa dibuat. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Sesi kamu sudah berakhir. Silakan masuk kembali.',
      ApiExceptionType.conflict =>
        'Membership aktif diperlukan sebelum check-in ke gym.',
      ApiExceptionType.timeout =>
        'Membuat QR terlalu lama. Periksa koneksi lalu coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Data QR belum bisa dibaca. Silakan coba kembali.',
      _ => 'QR member belum bisa dibuat. Silakan coba kembali.',
    };
  }
}
