import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../bookings/data/booking_data.dart';
import '../../data/repositories/booking_class_repository.dart';

class ClassBookingState {
  const ClassBookingState({
    this.isSubmitting = false,
    this.errorMessage,
    this.confirmation,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final ClassBookingConfirmation? confirmation;
}

class ClassBookingCubit extends Cubit<ClassBookingState> {
  ClassBookingCubit({required BookingClassRepository repository})
    : _repository = repository,
      super(const ClassBookingState());

  final BookingClassRepository _repository;

  Future<void> createClassBooking({required BookingSlot slot}) async {
    if (state.isSubmitting) {
      return;
    }

    final sessionId = slot.sessionId;

    if (sessionId == null || sessionId.trim().isEmpty) {
      emit(
        const ClassBookingState(
          errorMessage:
              'Jadwal kelas belum lengkap. Muat ulang kelas lalu coba kembali.',
        ),
      );
      return;
    }

    emit(const ClassBookingState(isSubmitting: true));

    try {
      final confirmation = await _repository.createClassBooking(
        classSessionId: sessionId,
      );

      if (!isClosed) {
        emit(ClassBookingState(confirmation: confirmation));
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(ClassBookingState(errorMessage: _mapBookingErrorMessage(error)));
      }
    }
  }

  String _mapBookingErrorMessage(Object error) {
    if (error is! ApiException) {
      return 'Booking kelas belum bisa dibuat. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Sesi kamu sudah berakhir. Silakan masuk kembali.',
      ApiExceptionType.notFound =>
        'Jadwal kelas tidak ditemukan. Pilih jadwal lain lalu coba kembali.',
      ApiExceptionType.conflict =>
        'Jadwal kelas ini sudah tidak tersedia. Pilih jadwal lain lalu coba kembali.',
      ApiExceptionType.timeout =>
        'Membuat booking terlalu lama. Periksa koneksi lalu coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Jawaban server belum bisa dibaca. Silakan coba kembali.',
      _ => 'Booking kelas belum bisa dibuat. Silakan coba kembali.',
    };
  }
}
