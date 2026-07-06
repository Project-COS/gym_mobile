// DTOs mirror the mobile personal training booking API response. Keep parsing
// strict here so repositories receive trusted, typed booking data.
class MobilePersonalTrainingBookingResponseDto {
  const MobilePersonalTrainingBookingResponseDto({required this.booking});

  final MobilePersonalTrainingBookingDto booking;

  factory MobilePersonalTrainingBookingResponseDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MobilePersonalTrainingBookingResponseDto(
      booking: MobilePersonalTrainingBookingDto.fromJson(data['booking']),
    );
  }
}

class MobilePersonalTrainingBookingsResponseDto {
  const MobilePersonalTrainingBookingsResponseDto({
    required this.bookings,
    required this.pagination,
  });

  final List<MobilePersonalTrainingBookingDto> bookings;
  final MobilePersonalTrainingBookingPaginationDto pagination;

  factory MobilePersonalTrainingBookingsResponseDto.fromJson(Object? json) {
    final data = _readMap(json);
    final bookingsValue = data['bookings'];

    if (bookingsValue is! List) {
      throw const FormatException('Expected bookings to be a list.');
    }

    return MobilePersonalTrainingBookingsResponseDto(
      bookings: bookingsValue
          .map(MobilePersonalTrainingBookingDto.fromJson)
          .toList(growable: false),
      pagination: MobilePersonalTrainingBookingPaginationDto.fromJson(
        data['pagination'],
      ),
    );
  }
}

class MobilePersonalTrainingBookingPaginationDto {
  const MobilePersonalTrainingBookingPaginationDto({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  factory MobilePersonalTrainingBookingPaginationDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MobilePersonalTrainingBookingPaginationDto(
      page: _readRequiredInt(data, 'page'),
      pageSize: _readRequiredInt(data, 'pageSize'),
      totalItems: _readRequiredInt(data, 'totalItems'),
      totalPages: _readRequiredInt(data, 'totalPages'),
    );
  }
}

class MobilePersonalTrainingBookingDto {
  const MobilePersonalTrainingBookingDto({
    required this.id,
    required this.bookingCode,
    required this.qrPayload,
    required this.source,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.notes,
    required this.trainer,
    required this.program,
    required this.location,
  });

  final String id;
  final String bookingCode;
  final String qrPayload;
  final String source;
  final String status;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? notes;
  final MobilePersonalTrainingBookingTrainerDto trainer;
  final MobilePersonalTrainingBookingProgramDto? program;
  final MobilePersonalTrainingBookingLocationDto? location;

  factory MobilePersonalTrainingBookingDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MobilePersonalTrainingBookingDto(
      id: _readRequiredString(data, 'id'),
      bookingCode: _readRequiredString(data, 'bookingCode'),
      qrPayload: _readRequiredString(data, 'qrPayload'),
      source: _readRequiredString(data, 'source'),
      status: _readRequiredString(data, 'status'),
      startsAt: _readRequiredDate(data, 'startsAt'),
      endsAt: _readRequiredDate(data, 'endsAt'),
      notes: _readOptionalString(data, 'notes'),
      trainer: MobilePersonalTrainingBookingTrainerDto.fromJson(
        data['trainer'],
      ),
      program: data['program'] == null
          ? null
          : MobilePersonalTrainingBookingProgramDto.fromJson(data['program']),
      location: data['location'] == null
          ? null
          : MobilePersonalTrainingBookingLocationDto.fromJson(data['location']),
    );
  }
}

class MobilePersonalTrainingBookingTrainerDto {
  const MobilePersonalTrainingBookingTrainerDto({
    required this.id,
    required this.name,
    required this.specialty,
  });

  final String id;
  final String name;
  final String? specialty;

  factory MobilePersonalTrainingBookingTrainerDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MobilePersonalTrainingBookingTrainerDto(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'name'),
      specialty: _readOptionalString(data, 'specialty'),
    );
  }
}

class MobilePersonalTrainingBookingProgramDto {
  const MobilePersonalTrainingBookingProgramDto({
    required this.id,
    required this.name,
    required this.durationMinutes,
  });

  final String id;
  final String name;
  final int durationMinutes;

  factory MobilePersonalTrainingBookingProgramDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MobilePersonalTrainingBookingProgramDto(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'name'),
      durationMinutes: _readRequiredInt(data, 'durationMinutes'),
    );
  }
}

class MobilePersonalTrainingBookingLocationDto {
  const MobilePersonalTrainingBookingLocationDto({
    required this.id,
    required this.name,
    required this.area,
    required this.address,
  });

  final String id;
  final String name;
  final String? area;
  final String? address;

  factory MobilePersonalTrainingBookingLocationDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MobilePersonalTrainingBookingLocationDto(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'name'),
      area: _readOptionalString(data, 'area'),
      address: _readOptionalString(data, 'address'),
    );
  }
}

Map<String, Object?> _readMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }

  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  throw const FormatException('Expected an object.');
}

String _readRequiredString(Map<String, Object?> data, String key) {
  final value = data[key];

  if (value is String && value.trim().isNotEmpty) {
    return value;
  }

  throw FormatException('Expected $key to be a non-empty string.');
}

String? _readOptionalString(Map<String, Object?> data, String key) {
  final value = data[key];

  if (value == null) {
    return null;
  }

  if (value is String) {
    final normalized = value.trim();

    return normalized.isEmpty ? null : normalized;
  }

  throw FormatException('Expected $key to be a string.');
}

int _readRequiredInt(Map<String, Object?> data, String key) {
  final value = data[key];

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  throw FormatException('Expected $key to be a number.');
}

DateTime _readRequiredDate(Map<String, Object?> data, String key) {
  final value = _readRequiredString(data, key);
  final date = DateTime.tryParse(value);

  if (date == null) {
    throw FormatException('Expected $key to be an ISO date.');
  }

  // Booking schedules are displayed in the member's device timezone.
  return date.toLocal();
}
