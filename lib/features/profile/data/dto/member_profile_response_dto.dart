import '../../../auth/data/dto/member_dto.dart';

// DTOs mirror the mobile current-member response. Display labels are mapped in
// the repository so parsing stays focused on API shape and validation.
class MobileMemberProfileResponseDto {
  const MobileMemberProfileResponseDto({required this.profile});

  factory MobileMemberProfileResponseDto.fromJson(Object? json) {
    final data = _requireJsonObject(json, 'profile response');

    if (data['success'] != true) {
      throw const FormatException('Profile response was not successful.');
    }

    final profileJson = data['profile'];

    if (profileJson != null) {
      return MobileMemberProfileResponseDto(
        profile: MobileMemberProfileDto.fromJson(profileJson),
      );
    }

    // Some auth/session responses still return a legacy member object. Keep
    // this fallback so the profile screen can render during backend transitions.
    final legacyMember = MemberDto.fromJson(data['member']);

    return MobileMemberProfileResponseDto(
      profile: MobileMemberProfileDto(
        member: MobileMemberProfileMemberDto(
          id: legacyMember.id,
          memberCode: legacyMember.memberCode,
          name: legacyMember.name,
          email: legacyMember.email,
          phone: legacyMember.phone,
          status: 'ACTIVE',
        ),
        company: MobileMemberProfileCompanyDto(
          id: legacyMember.company.id,
          name: legacyMember.company.name,
        ),
        membership: null,
      ),
    );
  }

  final MobileMemberProfileDto profile;
}

// Normalized profile object expected by the current mobile profile endpoint.
class MobileMemberProfileDto {
  const MobileMemberProfileDto({
    required this.member,
    required this.company,
    required this.membership,
  });

  factory MobileMemberProfileDto.fromJson(Object? json) {
    final data = _requireJsonObject(json, 'profile');

    return MobileMemberProfileDto(
      member: MobileMemberProfileMemberDto.fromJson(data['member']),
      company: MobileMemberProfileCompanyDto.fromJson(data['company']),
      membership: data['membership'] == null
          ? null
          : MobileMemberProfileMembershipDto.fromJson(data['membership']),
    );
  }

  final MobileMemberProfileMemberDto member;
  final MobileMemberProfileCompanyDto company;
  final MobileMemberProfileMembershipDto? membership;
}

// Member identity can be edited only through the explicit update endpoint.
class MobileMemberProfileMemberDto {
  const MobileMemberProfileMemberDto({
    required this.id,
    required this.memberCode,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
  });

  factory MobileMemberProfileMemberDto.fromJson(Object? json) {
    final data = _requireJsonObject(json, 'profile.member');

    return MobileMemberProfileMemberDto(
      id: _requireString(data, 'id', 'profile.member.id'),
      memberCode: _requireString(
        data,
        'memberCode',
        'profile.member.memberCode',
      ),
      name: _requireString(data, 'name', 'profile.member.name'),
      email: _optionalString(data, 'email', 'profile.member.email'),
      phone: _optionalString(data, 'phone', 'profile.member.phone'),
      status:
          _optionalString(data, 'status', 'profile.member.status') ?? 'ACTIVE',
    );
  }

  final String id;
  final String memberCode;
  final String name;
  final String? email;
  final String? phone;
  final String status;
}

class MobileMemberProfileCompanyDto {
  const MobileMemberProfileCompanyDto({required this.id, required this.name});

  factory MobileMemberProfileCompanyDto.fromJson(Object? json) {
    final data = _requireJsonObject(json, 'profile.company');

    return MobileMemberProfileCompanyDto(
      id: _requireString(data, 'id', 'profile.company.id'),
      name: _requireString(data, 'name', 'profile.company.name'),
    );
  }

  final String id;
  final String name;
}

// Active membership is optional because a member may exist without a valid plan.
class MobileMemberProfileMembershipDto {
  const MobileMemberProfileMembershipDto({
    required this.id,
    required this.status,
    required this.planName,
    required this.startsAt,
    required this.expiresAt,
    required this.accessLabel,
  });

  factory MobileMemberProfileMembershipDto.fromJson(Object? json) {
    final data = _requireJsonObject(json, 'profile.membership');
    final startsAt = _requireDateTime(
      data,
      'startsAt',
      'profile.membership.startsAt',
    );
    final expiresAt = _requireDateTime(
      data,
      'expiresAt',
      'profile.membership.expiresAt',
    );

    return MobileMemberProfileMembershipDto(
      id: _requireString(data, 'id', 'profile.membership.id'),
      status: _requireString(data, 'status', 'profile.membership.status'),
      planName: _requireString(data, 'planName', 'profile.membership.planName'),
      startsAt: startsAt,
      expiresAt: expiresAt,
      accessLabel:
          _optionalString(
            data,
            'accessLabel',
            'profile.membership.accessLabel',
          ) ??
          'All locations',
    );
  }

  final String id;
  final String status;
  final String planName;
  final DateTime startsAt;
  final DateTime expiresAt;
  final String accessLabel;
}

Map<String, Object?> _requireJsonObject(Object? value, String fieldName) {
  if (value is! Map<String, Object?>) {
    throw FormatException('$fieldName must be a JSON object.');
  }

  return value;
}

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

DateTime _requireDateTime(
  Map<String, Object?> data,
  String key,
  String fieldName,
) {
  final value = _requireString(data, key, fieldName);
  final dateTime = DateTime.tryParse(value);

  if (dateTime == null) {
    throw FormatException('$fieldName must be a valid date time.');
  }

  // Profile dates are shown to the member, so normalize before repository mapping.
  return dateTime.toLocal();
}
