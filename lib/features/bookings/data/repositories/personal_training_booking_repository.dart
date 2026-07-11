import '../dto/mobile_personal_training_booking_response_dto.dart';
import '../services/personal_training_booking_api_service.dart';

// Repository boundary for PT bookings. Screens and Cubits work with these
// app-ready models instead of raw mobile API DTOs.
abstract interface class PersonalTrainingBookingRepository {
  Future<List<PersonalTrainingBookingHistoryItem>>
  fetchPersonalTrainingBookings({
    PersonalTrainingBookingHistoryFilter filter =
        PersonalTrainingBookingHistoryFilter.upcoming,
  });

  Future<PersonalTrainingBookingConfirmation> createPersonalTrainingBooking({
    required String trainerId,
    required DateTime startsAt,
    String? programId,
    String? locationId,
    String? benefitGrantId,
    String? notes,
  });
}

class RemotePersonalTrainingBookingRepository
    implements PersonalTrainingBookingRepository {
  const RemotePersonalTrainingBookingRepository({
    required PersonalTrainingBookingApiService apiService,
  }) : _apiService = apiService;

  final PersonalTrainingBookingApiService _apiService;

  @override
  Future<List<PersonalTrainingBookingHistoryItem>>
  fetchPersonalTrainingBookings({
    PersonalTrainingBookingHistoryFilter filter =
        PersonalTrainingBookingHistoryFilter.upcoming,
  }) async {
    // History screens render one compact list; keep page size high enough to
    // avoid extra pagination UI until the product needs it.
    final response = await _apiService.fetchBookings(
      status: filter.queryValue,
      pageSize: 50,
    );

    return response.bookings
        .map(_mapBookingHistoryItem)
        .toList(growable: false);
  }

  @override
  Future<PersonalTrainingBookingConfirmation> createPersonalTrainingBooking({
    required String trainerId,
    required DateTime startsAt,
    String? programId,
    String? locationId,
    String? benefitGrantId,
    String? notes,
  }) async {
    final response = await _apiService.createBooking(
      trainerId: trainerId,
      startsAt: startsAt,
      programId: programId,
      locationId: locationId,
      benefitGrantId: benefitGrantId,
      notes: notes,
    );

    return _mapBookingConfirmation(response.booking);
  }

  PersonalTrainingBookingHistoryItem _mapBookingHistoryItem(
    MobilePersonalTrainingBookingDto booking,
  ) {
    final program = booking.program;

    // Preserve backend status/source values for filtering and status badges,
    // while formatting schedule/location for direct UI use.
    return PersonalTrainingBookingHistoryItem(
      id: booking.id,
      bookingCode: booking.bookingCode,
      qrPayload: booking.qrPayload,
      title: program?.name ?? 'Personal Training',
      trainerName: booking.trainer.name,
      schedule: _formatSchedule(booking.startsAt),
      duration: _formatDuration(program?.durationMinutes, booking),
      location: _formatLocation(booking.location),
      status: booking.status,
      source: booking.source,
      canShowQr: booking.status == 'REQUESTED' || booking.status == 'SCHEDULED',
    );
  }

  PersonalTrainingBookingConfirmation _mapBookingConfirmation(
    MobilePersonalTrainingBookingDto booking,
  ) {
    final program = booking.program;

    return PersonalTrainingBookingConfirmation(
      id: booking.id,
      bookingCode: booking.bookingCode,
      qrPayload: booking.qrPayload,
      title: program?.name ?? booking.trainer.name,
      schedule: _formatSchedule(booking.startsAt),
      duration: _formatDuration(program?.durationMinutes, booking),
      location: _formatLocation(booking.location),
    );
  }

  String _formatDuration(
    int? programDurationMinutes,
    MobilePersonalTrainingBookingDto booking,
  ) {
    final durationMinutes =
        programDurationMinutes ??
        booking.endsAt.difference(booking.startsAt).inMinutes;

    // Defensive fallback for incomplete schedules or custom sessions.
    if (durationMinutes <= 0) {
      return 'Durasi menyesuaikan';
    }

    return '$durationMinutes Menit';
  }

  String _formatSchedule(DateTime startsAt) {
    final localDate = startsAt.toLocal();
    final dayName = _dayNames[localDate.weekday % 7];
    final monthName = _monthNames[localDate.month - 1];
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$dayName, ${localDate.day} $monthName $hour:$minute';
  }

  String _formatLocation(MobilePersonalTrainingBookingLocationDto? location) {
    if (location == null) {
      return 'Lokasi akan dikonfirmasi';
    }

    final parts = [
      location.name,
      location.area,
    ].whereType<String>().where((value) => value.trim().isNotEmpty);

    return parts.join(' - ');
  }
}

class PersonalTrainingBookingConfirmation {
  const PersonalTrainingBookingConfirmation({
    required this.id,
    required this.bookingCode,
    required this.qrPayload,
    required this.title,
    required this.schedule,
    required this.duration,
    required this.location,
  });

  final String id;
  final String bookingCode;
  final String qrPayload;
  final String title;
  final String schedule;
  final String duration;
  final String location;
}

// Values are sent directly as the status query parameter for the mobile API.
enum PersonalTrainingBookingHistoryFilter {
  upcoming('upcoming'),
  history('history'),
  all('all');

  const PersonalTrainingBookingHistoryFilter(this.queryValue);

  final String queryValue;
}

class PersonalTrainingBookingHistoryItem {
  const PersonalTrainingBookingHistoryItem({
    required this.id,
    required this.bookingCode,
    required this.qrPayload,
    required this.title,
    required this.trainerName,
    required this.schedule,
    required this.duration,
    required this.location,
    required this.status,
    required this.source,
    required this.canShowQr,
  });

  final String id;
  final String bookingCode;
  final String qrPayload;
  final String title;
  final String trainerName;
  final String schedule;
  final String duration;
  final String location;
  final String status;
  final String source;
  final bool canShowQr;
}

const List<String> _dayNames = [
  'Minggu',
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
];

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];
