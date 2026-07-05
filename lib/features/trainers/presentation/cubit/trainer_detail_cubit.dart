import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../bookings/data/repositories/personal_training_booking_repository.dart';
import '../../data/repositories/trainer_repository.dart';

enum TrainerDetailLoadStatus { initial, loading, success, failure }

class TrainerDetailState {
  const TrainerDetailState({
    this.status = TrainerDetailLoadStatus.initial,
    this.trainer,
    this.errorMessage,
    this.isSubmittingRating = false,
    this.ratingErrorMessage,
    this.ratingSuccessMessage,
    this.isSubmittingBooking = false,
    this.bookingErrorMessage,
    this.bookingConfirmation,
  });

  const TrainerDetailState.loading({this.trainer})
    : status = TrainerDetailLoadStatus.loading,
      errorMessage = null,
      isSubmittingRating = false,
      ratingErrorMessage = null,
      ratingSuccessMessage = null,
      isSubmittingBooking = false,
      bookingErrorMessage = null,
      bookingConfirmation = null;

  const TrainerDetailState.success(
    this.trainer, {
    this.isSubmittingRating = false,
    this.ratingErrorMessage,
    this.ratingSuccessMessage,
    this.isSubmittingBooking = false,
    this.bookingErrorMessage,
    this.bookingConfirmation,
  }) : status = TrainerDetailLoadStatus.success,
       errorMessage = null;

  const TrainerDetailState.failure(this.errorMessage)
    : status = TrainerDetailLoadStatus.failure,
      trainer = null,
      isSubmittingRating = false,
      ratingErrorMessage = null,
      ratingSuccessMessage = null,
      isSubmittingBooking = false,
      bookingErrorMessage = null,
      bookingConfirmation = null;

  final TrainerDetailLoadStatus status;
  final TrainerProfile? trainer;
  final String? errorMessage;
  final bool isSubmittingRating;
  final String? ratingErrorMessage;
  final String? ratingSuccessMessage;
  final bool isSubmittingBooking;
  final String? bookingErrorMessage;
  final PersonalTrainingBookingConfirmation? bookingConfirmation;

  bool get isLoading => status == TrainerDetailLoadStatus.loading;
}

class TrainerDetailCubit extends Cubit<TrainerDetailState> {
  TrainerDetailCubit({
    required TrainerRepository repository,
    required PersonalTrainingBookingRepository bookingRepository,
    required String trainerId,
  }) : _repository = repository,
       _bookingRepository = bookingRepository,
       _trainerId = trainerId,
       super(const TrainerDetailState());

  final TrainerRepository _repository;
  final PersonalTrainingBookingRepository _bookingRepository;
  final String _trainerId;

  Future<void> fetchTrainer({bool forceRefresh = false}) async {
    if (state.isLoading && !forceRefresh) {
      return;
    }

    emit(TrainerDetailState.loading(trainer: state.trainer));

    try {
      final trainer = await _repository.fetchTrainerDetail(_trainerId);

      if (!isClosed) {
        emit(TrainerDetailState.success(trainer));
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(TrainerDetailState.failure(_mapLoadErrorMessage(error)));
      }
    }
  }

  Future<void> submitRating(double rating) async {
    final trainer = state.trainer;

    if (trainer == null) {
      return;
    }

    if (!trainer.canRate) {
      emit(
        TrainerDetailState.success(
          trainer,
          ratingErrorMessage:
              'Kamu bisa memberi rating setelah menyelesaikan sesi dengan trainer ini.',
        ),
      );
      return;
    }

    emit(TrainerDetailState.success(trainer, isSubmittingRating: true));

    try {
      final updatedRating = await _repository.submitTrainerRating(
        trainerId: trainer.id,
        rating: rating,
      );

      if (!isClosed) {
        emit(
          TrainerDetailState.success(
            trainer.copyWithRating(updatedRating),
            ratingSuccessMessage: 'Rating trainer berhasil dikirim.',
          ),
        );
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(
          TrainerDetailState.success(
            trainer,
            ratingErrorMessage: _mapRatingErrorMessage(error),
          ),
        );
      }
    }
  }

  Future<void> bookPersonalTrainingSession({
    required DateTime startsAt,
    String? programId,
    String? locationId,
  }) async {
    final trainer = state.trainer;

    if (trainer == null || state.isSubmittingBooking) {
      return;
    }

    emit(TrainerDetailState.success(trainer, isSubmittingBooking: true));

    try {
      final bookingConfirmation = await _bookingRepository
          .createPersonalTrainingBooking(
            trainerId: trainer.id,
            startsAt: startsAt,
            programId: programId,
            locationId: locationId,
          );

      if (!isClosed) {
        emit(
          TrainerDetailState.success(
            trainer,
            bookingConfirmation: bookingConfirmation,
          ),
        );
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(
          TrainerDetailState.success(
            trainer,
            bookingErrorMessage: _mapBookingErrorMessage(error),
          ),
        );
      }
    }
  }

  String _mapLoadErrorMessage(Object error) {
    if (error is! ApiException) {
      return 'Detail trainer belum bisa dimuat. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Sesi kamu sudah berakhir. Silakan masuk kembali.',
      ApiExceptionType.notFound => 'Trainer tidak ditemukan.',
      ApiExceptionType.timeout =>
        'Memuat detail trainer terlalu lama. Periksa koneksi lalu coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Data trainer belum bisa dibaca. Silakan coba kembali.',
      _ => 'Detail trainer belum bisa dimuat. Silakan coba kembali.',
    };
  }

  String _mapRatingErrorMessage(Object error) {
    if (error is! ApiException) {
      return 'Rating belum bisa dikirim. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Sesi kamu sudah berakhir. Silakan masuk kembali.',
      ApiExceptionType.forbidden =>
        'Kamu bisa memberi rating setelah menyelesaikan sesi dengan trainer ini.',
      ApiExceptionType.timeout =>
        'Mengirim rating terlalu lama. Periksa koneksi lalu coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Jawaban server belum bisa dibaca. Silakan coba kembali.',
      _ => 'Rating belum bisa dikirim. Silakan coba kembali.',
    };
  }

  String _mapBookingErrorMessage(Object error) {
    if (error is! ApiException) {
      return 'Booking belum bisa dibuat. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Sesi kamu sudah berakhir. Silakan masuk kembali.',
      ApiExceptionType.notFound =>
        'Trainer, program, atau lokasi booking tidak ditemukan.',
      ApiExceptionType.conflict =>
        'Jadwal ini sudah tidak tersedia. Pilih jadwal lain lalu coba kembali.',
      ApiExceptionType.timeout =>
        'Membuat booking terlalu lama. Periksa koneksi lalu coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Jawaban server belum bisa dibaca. Silakan coba kembali.',
      _ => 'Booking belum bisa dibuat. Silakan coba kembali.',
    };
  }
}
