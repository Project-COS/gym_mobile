import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/branch_location_data.dart';
import '../../data/repositories/location_repository.dart';

enum LocationLoadStatus { initial, loading, success, failure }

// State for the API-backed branch list.
class LocationState {
  const LocationState({
    this.status = LocationLoadStatus.initial,
    this.locations = const [],
    this.errorMessage,
  });

  const LocationState.loading()
    : status = LocationLoadStatus.loading,
      locations = const [],
      errorMessage = null;

  const LocationState.success(this.locations)
    : status = LocationLoadStatus.success,
      errorMessage = null;

  const LocationState.failure(this.errorMessage)
    : status = LocationLoadStatus.failure,
      locations = const [];

  final LocationLoadStatus status;
  final List<BranchLocation> locations;
  final String? errorMessage;

  bool get isLoading => status == LocationLoadStatus.loading;
}

class LocationCubit extends Cubit<LocationState> {
  LocationCubit({required LocationRepository repository})
    : _repository = repository,
      super(const LocationState());

  final LocationRepository _repository;

  Future<void> fetchLocations() async {
    // Prevent duplicate requests from repeated tab rebuilds.
    if (state.isLoading) {
      return;
    }

    emit(const LocationState.loading());

    try {
      final locations = await _repository.fetchLocations();

      if (!isClosed) {
        emit(LocationState.success(locations));
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(LocationState.failure(_mapErrorMessage(error)));
      }
    }
  }

  String _mapErrorMessage(Object error) {
    if (error is! ApiException) {
      return 'Lokasi belum bisa dimuat. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Sesi kamu sudah berakhir. Silakan masuk kembali.',
      ApiExceptionType.timeout =>
        'Memuat lokasi terlalu lama. Periksa koneksi lalu coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Data lokasi belum bisa dibaca. Silakan coba kembali.',
      _ => 'Lokasi belum bisa dimuat. Silakan coba kembali.',
    };
  }
}
