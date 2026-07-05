import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/class_data.dart';
import '../../data/repositories/booking_class_repository.dart';

enum BookingClassLoadStatus { initial, loading, success, failure }

class BookingClassState {
  const BookingClassState({
    this.status = BookingClassLoadStatus.initial,
    this.sessions = const [],
    this.categories = const [ClassCategoryOption.all],
    this.locationName,
    this.errorMessage,
  });

  const BookingClassState.loading({
    this.sessions = const [],
    this.categories = const [ClassCategoryOption.all],
    this.locationName,
  }) : status = BookingClassLoadStatus.loading,
       errorMessage = null;

  const BookingClassState.success({
    required this.sessions,
    required this.categories,
    required this.locationName,
  }) : status = BookingClassLoadStatus.success,
       errorMessage = null;

  const BookingClassState.failure(this.errorMessage)
    : status = BookingClassLoadStatus.failure,
      sessions = const [],
      categories = const [ClassCategoryOption.all],
      locationName = null;

  final BookingClassLoadStatus status;
  final List<GroupClassSession> sessions;
  final List<ClassCategoryOption> categories;
  final String? locationName;
  final String? errorMessage;

  bool get isLoading => status == BookingClassLoadStatus.loading;
}

class BookingClassCubit extends Cubit<BookingClassState> {
  BookingClassCubit({required BookingClassRepository bookingClassRepository})
    : _bookingClassRepository = bookingClassRepository,
      super(const BookingClassState());

  final BookingClassRepository _bookingClassRepository;

  Future<void> fetchClassesForDate(
    DateTime selectedDate, {
    bool forceRefresh = false,
  }) async {
    if (state.isLoading && !forceRefresh) {
      return;
    }

    emit(
      BookingClassState.loading(
        sessions: state.sessions,
        categories: state.categories,
        locationName: state.locationName,
      ),
    );

    try {
      final startsFrom = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      final startsTo = startsFrom.add(const Duration(days: 1));
      final catalog = await _bookingClassRepository.fetchClassCatalog(
        startsFrom: startsFrom,
        startsTo: startsTo,
      );

      if (!isClosed) {
        emit(
          BookingClassState.success(
            sessions: catalog.sessions,
            categories: [ClassCategoryOption.all, ...catalog.categories],
            locationName: null,
          ),
        );
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(BookingClassState.failure(_mapErrorMessage(error)));
      }
    }
  }

  String _mapErrorMessage(Object error) {
    if (error is! ApiException) {
      return 'Kelas belum bisa dimuat. Silakan coba kembali.';
    }

    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Sesi kamu sudah berakhir. Silakan masuk kembali.',
      ApiExceptionType.timeout =>
        'Memuat kelas terlalu lama. Periksa koneksi lalu coba kembali.',
      ApiExceptionType.network =>
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      ApiExceptionType.invalidResponse =>
        'Data kelas belum bisa dibaca. Silakan coba kembali.',
      _ => 'Kelas belum bisa dimuat. Silakan coba kembali.',
    };
  }
}
