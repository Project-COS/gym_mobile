import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../classes/data/class_data.dart';
import '../../../classes/data/repositories/booking_class_repository.dart';
import '../../screen/branch_location_data.dart';

enum LocationClassScheduleStatus { initial, loading, success, failure }

class LocationClassScheduleState {
  const LocationClassScheduleState({
    this.status = LocationClassScheduleStatus.initial,
    this.schedules = const [],
    this.errorMessage,
  });

  const LocationClassScheduleState.loading()
    : status = LocationClassScheduleStatus.loading,
      schedules = const [],
      errorMessage = null;

  const LocationClassScheduleState.success(this.schedules)
    : status = LocationClassScheduleStatus.success,
      errorMessage = null;

  const LocationClassScheduleState.failure(this.errorMessage)
    : status = LocationClassScheduleStatus.failure,
      schedules = const [];

  final LocationClassScheduleStatus status;
  final List<BranchSchedule> schedules;
  final String? errorMessage;

  bool get isLoading => status == LocationClassScheduleStatus.loading;
}

class LocationClassScheduleCubit extends Cubit<LocationClassScheduleState> {
  LocationClassScheduleCubit({required BookingClassRepository repository})
    : _repository = repository,
      super(const LocationClassScheduleState());

  final BookingClassRepository _repository;

  Future<void> fetchSchedulesForLocation(String locationId) async {
    if (state.isLoading) {
      return;
    }

    emit(const LocationClassScheduleState.loading());

    final now = DateTime.now();
    final startsFrom = DateTime(now.year, now.month, now.day);
    final startsTo = startsFrom.add(const Duration(days: 14));

    try {
      final classes = await _repository.fetchClassesForLocation(
        locationId: locationId,
        startsFrom: startsFrom,
        startsTo: startsTo,
      );
      final schedules = classes
          .take(5)
          .map(_mapClassSessionToBranchSchedule)
          .toList(growable: false);

      if (!isClosed) {
        emit(LocationClassScheduleState.success(schedules));
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(LocationClassScheduleState.failure(_mapErrorMessage(error)));
      }
    }
  }

  BranchSchedule _mapClassSessionToBranchSchedule(GroupClassSession session) {
    final slot = session.slots.first;

    return BranchSchedule(
      time: slot.time,
      title: session.title,
      meta: '${session.location} - ${session.coachName}',
      status: session.slotLabel,
    );
  }

  String _mapErrorMessage(Object error) {
    if (error is! ApiException) {
      return 'Jadwal kelas belum bisa dimuat. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Sesi kamu sudah berakhir. Silakan masuk kembali.',
      ApiExceptionType.timeout =>
        'Memuat jadwal terlalu lama. Periksa koneksi lalu coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Data jadwal belum bisa dibaca. Silakan coba kembali.',
      _ => 'Jadwal kelas belum bisa dimuat. Silakan coba kembali.',
    };
  }
}
