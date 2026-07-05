class MemberAttendanceQrResponseDto {
  const MemberAttendanceQrResponseDto({required this.data});

  final MemberAttendanceQrDataDto data;

  factory MemberAttendanceQrResponseDto.fromJson(Object? json) {
    final response = _readMap(json);

    return MemberAttendanceQrResponseDto(
      data: MemberAttendanceQrDataDto.fromJson(response['data']),
    );
  }
}

class MemberAttendanceQrDataDto {
  const MemberAttendanceQrDataDto({
    required this.qrPayload,
    required this.expiresAt,
    required this.member,
    required this.activeMembership,
  });

  final String qrPayload;
  final DateTime expiresAt;
  final MemberAttendanceMemberDto member;
  final MemberAttendanceMembershipDto activeMembership;

  factory MemberAttendanceQrDataDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MemberAttendanceQrDataDto(
      qrPayload: _readRequiredString(data, 'qrPayload'),
      expiresAt: _readRequiredDate(data, 'expiresAt'),
      member: MemberAttendanceMemberDto.fromJson(data['member']),
      activeMembership: MemberAttendanceMembershipDto.fromJson(
        data['activeMembership'],
      ),
    );
  }
}

class MemberAttendanceMemberDto {
  const MemberAttendanceMemberDto({
    required this.id,
    required this.memberCode,
    required this.name,
    required this.email,
    required this.phone,
  });

  final String id;
  final String memberCode;
  final String name;
  final String? email;
  final String? phone;

  factory MemberAttendanceMemberDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MemberAttendanceMemberDto(
      id: _readRequiredString(data, 'id'),
      memberCode: _readRequiredString(data, 'memberCode'),
      name: _readRequiredString(data, 'name'),
      email: _readOptionalString(data, 'email'),
      phone: _readOptionalString(data, 'phone'),
    );
  }
}

class MemberAttendanceMembershipDto {
  const MemberAttendanceMembershipDto({
    required this.id,
    required this.planName,
    required this.startsAt,
    required this.expiresAt,
  });

  final String id;
  final String planName;
  final DateTime startsAt;
  final DateTime expiresAt;

  factory MemberAttendanceMembershipDto.fromJson(Object? json) {
    final data = _readMap(json);

    return MemberAttendanceMembershipDto(
      id: _readRequiredString(data, 'id'),
      planName: _readRequiredString(data, 'planName'),
      startsAt: _readRequiredDate(data, 'startsAt'),
      expiresAt: _readRequiredDate(data, 'expiresAt'),
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

DateTime _readRequiredDate(Map<String, Object?> data, String key) {
  final value = _readRequiredString(data, key);
  final date = DateTime.tryParse(value);

  if (date == null) {
    throw FormatException('Expected $key to be an ISO date.');
  }

  return date.toLocal();
}
