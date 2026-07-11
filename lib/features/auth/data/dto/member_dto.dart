// Minimal company context returned with a member login. It lets the app know
// which gym tenant the authenticated member belongs to.
class MemberCompanyDto {
  const MemberCompanyDto({required this.id, required this.name, this.logoUrl});

  factory MemberCompanyDto.fromJson(Object? json) {
    final data = _requireJsonObject(json, 'member.company');

    return MemberCompanyDto(
      id: _requireString(data, 'id', 'member.company.id'),
      name: _requireString(data, 'name', 'member.company.name'),
      logoUrl: _optionalString(data, 'logoUrl', 'member.company.logoUrl'),
    );
  }

  final String id;
  final String name;
  final String? logoUrl;
}

// Member identity returned by login. Keep this DTO limited to API response data;
// richer profile presentation belongs to the profile feature.
class MemberDto {
  const MemberDto({
    required this.id,
    required this.memberCode,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
  });

  factory MemberDto.fromJson(Object? json) {
    final data = _requireJsonObject(json, 'member');

    return MemberDto(
      id: _requireString(data, 'id', 'member.id'),
      memberCode: _requireString(data, 'memberCode', 'member.memberCode'),
      name: _requireString(data, 'name', 'member.name'),
      email: _optionalString(data, 'email', 'member.email'),
      phone: _optionalString(data, 'phone', 'member.phone'),
      company: MemberCompanyDto.fromJson(data['company']),
    );
  }

  final String id;
  final String memberCode;
  final String name;
  final String? email;
  final String? phone;
  final MemberCompanyDto company;
}

Map<String, Object?> _requireJsonObject(Object? value, String fieldName) {
  if (value is! Map<String, Object?>) {
    throw FormatException('$fieldName must be a JSON object.');
  }

  return value;
}

// These helpers intentionally validate fields strictly so bad backend contracts
// fail at the DTO boundary instead of leaking nulls into the UI.
String _requireString(Map<String, Object?> data, String key, String fieldName) {
  final value = data[key];

  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$fieldName must be a non-empty string.');
  }

  return value.trim();
}

String? _optionalString(
  Map<String, Object?> data,
  String key,
  String fieldName,
) {
  final value = data[key];

  if (value == null) {
    return null;
  }

  if (value is! String) {
    throw FormatException('$fieldName must be a string or null.');
  }

  final normalizedValue = value.trim();
  return normalizedValue.isEmpty ? null : normalizedValue;
}
