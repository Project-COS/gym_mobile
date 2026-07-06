import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/trainer_repository.dart';

enum TrainerListLoadStatus { initial, loading, success, failure }

/// State daftar trainer menyimpan data lama saat refresh agar UI tidak kosong
/// mendadak ketika user menarik pull-to-refresh.
class TrainerListState {
  const TrainerListState({
    this.status = TrainerListLoadStatus.initial,
    this.trainers = const [],
    this.errorMessage,
  });

  const TrainerListState.loading({this.trainers = const []})
    : status = TrainerListLoadStatus.loading,
      errorMessage = null;

  const TrainerListState.success(this.trainers)
    : status = TrainerListLoadStatus.success,
      errorMessage = null;

  const TrainerListState.failure(this.errorMessage)
    : status = TrainerListLoadStatus.failure,
      trainers = const [];

  final TrainerListLoadStatus status;
  final List<TrainerProfile> trainers;
  final String? errorMessage;

  bool get isLoading => status == TrainerListLoadStatus.loading;
}

class TrainerListCubit extends Cubit<TrainerListState> {
  TrainerListCubit({required TrainerRepository repository})
    : _repository = repository,
      super(const TrainerListState());

  final TrainerRepository _repository;

  Future<void> fetchTrainers({bool forceRefresh = false}) async {
    if (state.isLoading && !forceRefresh) {
      return;
    }

    // Data saat ini diteruskan ke loading state untuk refresh yang lebih stabil.
    emit(TrainerListState.loading(trainers: state.trainers));

    try {
      final trainers = await _repository.fetchTrainers();

      if (!isClosed) {
        emit(TrainerListState.success(trainers));
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(TrainerListState.failure(_mapErrorMessage(error)));
      }
    }
  }

  String _mapErrorMessage(Object error) {
    // Cubit menerjemahkan ApiException menjadi copy yang aman untuk user.
    if (error is! ApiException) {
      return 'Trainer belum bisa dimuat. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Sesi kamu sudah berakhir. Silakan masuk kembali.',
      ApiExceptionType.timeout =>
        'Memuat trainer terlalu lama. Periksa koneksi lalu coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Data trainer belum bisa dibaca. Silakan coba kembali.',
      _ => 'Trainer belum bisa dimuat. Silakan coba kembali.',
    };
  }
}
