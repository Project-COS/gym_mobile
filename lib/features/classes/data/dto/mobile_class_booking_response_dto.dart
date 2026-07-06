// Response after creating a single class booking.
class MobileClassBookingResponseDto {
  const MobileClassBookingResponseDto({required this.booking});

  final MobileClassBookingDto booking;

  factory MobileClassBookingResponseDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MobileClassBookingResponseDto(
      booking: MobileClassBookingDto.fromJson(data['booking']),
    );
  }
}

// Paginated response for Requested, History, and All class booking tabs.
class MobileClassBookingsResponseDto {
  const MobileClassBookingsResponseDto({
    required this.bookings,
    required this.pagination,
  });

  final List<MobileClassBookingDto> bookings;
  final MobileClassBookingPaginationDto pagination;

  factory MobileClassBookingsResponseDto.fromJson(Object? json) {
    final data = _readMap(json);
    final bookingsValue = data['bookings'];

    if (bookingsValue is! List) {
      throw const FormatException('Expected bookings to be a list.');
    }

    return MobileClassBookingsResponseDto(
      bookings: bookingsValue
          .map(MobileClassBookingDto.fromJson)
          .toList(growable: false),
      pagination: MobileClassBookingPaginationDto.fromJson(data['pagination']),
    );
  }
}

// Pagination is parsed even when the current UI only consumes the items.
class MobileClassBookingPaginationDto {
  const MobileClassBookingPaginationDto({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  factory MobileClassBookingPaginationDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MobileClassBookingPaginationDto(
      page: _readRequiredInt(data, 'page'),
      pageSize: _readRequiredInt(data, 'pageSize'),
      totalItems: _readRequiredInt(data, 'totalItems'),
      totalPages: _readRequiredInt(data, 'totalPages'),
    );
  }
}

// Booking DTO keeps both QR data and relational display data returned by API.
class MobileClassBookingDto {
  const MobileClassBookingDto({
    required this.id,
    required this.bookingCode,
    required this.qrPayload,
    required this.className,
    required this.source,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.notes,
    required this.gymClass,
    required this.session,
    required this.trainer,
    required this.location,
  });

  final String id;
  final String bookingCode;
  final String qrPayload;
  final String className;
  final String source;
  final String status;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? notes;
  final MobileClassBookingClassDto? gymClass;
  final MobileClassBookingSessionDto? session;
  final MobileClassBookingTrainerDto trainer;
  final MobileClassBookingLocationDto? location;

  factory MobileClassBookingDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MobileClassBookingDto(
      id: _readRequiredString(data, 'id'),
      bookingCode: _readRequiredString(data, 'bookingCode'),
      qrPayload: _readRequiredString(data, 'qrPayload'),
      className: _readRequiredString(data, 'className'),
      source: _readRequiredString(data, 'source'),
      status: _readRequiredString(data, 'status'),
      startsAt: _readRequiredDate(data, 'startsAt'),
      endsAt: _readRequiredDate(data, 'endsAt'),
      notes: _readOptionalString(data, 'notes'),
      gymClass: data['class'] == null
          ? null
          : MobileClassBookingClassDto.fromJson(data['class']),
      session: data['session'] == null
          ? null
          : MobileClassBookingSessionDto.fromJson(data['session']),
      trainer: MobileClassBookingTrainerDto.fromJson(data['trainer']),
      location: data['location'] == null
          ? null
          : MobileClassBookingLocationDto.fromJson(data['location']),
    );
  }
}

class MobileClassBookingClassDto {
  const MobileClassBookingClassDto({
    required this.id,
    required this.name,
    required this.durationMinutes,
  });

  final String id;
  final String name;
  final int durationMinutes;

  factory MobileClassBookingClassDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MobileClassBookingClassDto(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'name'),
      durationMinutes: _readRequiredInt(data, 'durationMinutes'),
    );
  }
}

class MobileClassBookingSessionDto {
  const MobileClassBookingSessionDto({
    required this.id,
    required this.roomName,
  });

  final String id;
  final String? roomName;

  factory MobileClassBookingSessionDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MobileClassBookingSessionDto(
      id: _readRequiredString(data, 'id'),
      roomName: _readOptionalString(data, 'roomName'),
    );
  }
}

class MobileClassBookingTrainerDto {
  const MobileClassBookingTrainerDto({
    required this.id,
    required this.name,
    required this.specialty,
  });

  final String id;
  final String name;
  final String? specialty;

  factory MobileClassBookingTrainerDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MobileClassBookingTrainerDto(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'name'),
      specialty: _readOptionalString(data, 'specialty'),
    );
  }
}

class MobileClassBookingLocationDto {
  const MobileClassBookingLocationDto({
    required this.id,
    required this.name,
    required this.area,
    required this.address,
  });

  final String id;
  final String name;
  final String? area;
  final String? address;

  factory MobileClassBookingLocationDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MobileClassBookingLocationDto(
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

  // Booking history is user-facing, so normalize timestamps before formatting.
  return date.toLocal();
}
