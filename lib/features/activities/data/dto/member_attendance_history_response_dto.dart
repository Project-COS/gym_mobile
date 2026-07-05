class MemberAttendanceHistoryResponseDto {
  const MemberAttendanceHistoryResponseDto({
    required this.attendances,
    required this.pagination,
  });

  final List<MemberAttendanceHistoryItemDto> attendances;
  final MemberAttendanceHistoryPaginationDto pagination;

  factory MemberAttendanceHistoryResponseDto.fromJson(Object? json) {
    final response = _readMap(json);

    if (response['success'] != true) {
      throw const FormatException('Attendance response was not successful.');
    }

    final attendances = response['attendances'];

    if (attendances is! List) {
      throw const FormatException('Attendances must be a list.');
    }

    return MemberAttendanceHistoryResponseDto(
      attendances: attendances
          .map(MemberAttendanceHistoryItemDto.fromJson)
          .toList(growable: false),
      pagination: MemberAttendanceHistoryPaginationDto.fromJson(
        response['pagination'],
      ),
    );
  }
}

class MemberAttendanceHistoryItemDto {
  const MemberAttendanceHistoryItemDto({
    required this.id,
    required this.location,
    required this.membership,
    required this.checkedInAt,
    required this.checkedOutAt,
    required this.checkInMethod,
    required this.checkOutMethod,
    required this.status,
    required this.durationMinutes,
  });

  final String id;
  final MemberAttendanceHistoryLocationDto location;
  final MemberAttendanceHistoryMembershipDto? membership;
  final DateTime checkedInAt;
  final DateTime? checkedOutAt;
  final String checkInMethod;
  final String? checkOutMethod;
  final String status;
  final int? durationMinutes;

  factory MemberAttendanceHistoryItemDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MemberAttendanceHistoryItemDto(
      id: _readRequiredString(data, 'id'),
      location: MemberAttendanceHistoryLocationDto.fromJson(data['location']),
      membership: data['membership'] == null
          ? null
          : MemberAttendanceHistoryMembershipDto.fromJson(data['membership']),
      checkedInAt: _readRequiredDate(data, 'checkedInAt'),
      checkedOutAt: _readOptionalDate(data, 'checkedOutAt'),
      checkInMethod: _readRequiredString(data, 'checkInMethod'),
      checkOutMethod: _readOptionalString(data, 'checkOutMethod'),
      status: _readRequiredString(data, 'status'),
      durationMinutes: _readOptionalInt(data, 'durationMinutes'),
    );
  }
}

class MemberAttendanceHistoryLocationDto {
  const MemberAttendanceHistoryLocationDto({
    required this.id,
    required this.name,
    required this.area,
  });

  final String id;
  final String name;
  final String? area;

  factory MemberAttendanceHistoryLocationDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MemberAttendanceHistoryLocationDto(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'name'),
      area: _readOptionalString(data, 'area'),
    );
  }
}

class MemberAttendanceHistoryMembershipDto {
  const MemberAttendanceHistoryMembershipDto({
    required this.id,
    required this.planName,
    required this.startsAt,
    required this.expiresAt,
  });

  final String id;
  final String planName;
  final DateTime startsAt;
  final DateTime expiresAt;

  factory MemberAttendanceHistoryMembershipDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MemberAttendanceHistoryMembershipDto(
      id: _readRequiredString(data, 'id'),
      planName: _readRequiredString(data, 'planName'),
      startsAt: _readRequiredDate(data, 'startsAt'),
      expiresAt: _readRequiredDate(data, 'expiresAt'),
    );
  }
}

class MemberAttendanceHistoryPaginationDto {
  const MemberAttendanceHistoryPaginationDto({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  factory MemberAttendanceHistoryPaginationDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MemberAttendanceHistoryPaginationDto(
      page: _readRequiredInt(data, 'page'),
      pageSize: _readRequiredInt(data, 'pageSize'),
      totalItems: _readRequiredInt(data, 'totalItems'),
      totalPages: _readRequiredInt(data, 'totalPages'),
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
    return value.trim();
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

  throw FormatException('Expected $key to be an integer.');
}

int? _readOptionalInt(Map<String, Object?> data, String key) {
  final value = data[key];

  if (value == null) {
    return null;
  }

  if (value is int) {
    return value;
  }

  throw FormatException('Expected $key to be an integer.');
}

DateTime _readRequiredDate(Map<String, Object?> data, String key) {
  final value = _readRequiredString(data, key);
  final date = DateTime.tryParse(value);

  if (date == null) {
    throw FormatException('Expected $key to be an ISO date.');
  }

  return date.toLocal();
}

DateTime? _readOptionalDate(Map<String, Object?> data, String key) {
  final value = _readOptionalString(data, key);

  if (value == null) {
    return null;
  }

  final date = DateTime.tryParse(value);

  if (date == null) {
    throw FormatException('Expected $key to be an ISO date.');
  }

  return date.toLocal();
}
