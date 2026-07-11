import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/profile/data/dto/member_profile_response_dto.dart';

void main() {
  test('parses profile response with active membership', () {
    final response = MobileMemberProfileResponseDto.fromJson({
      'success': true,
      'profile': _profileJson(),
    });

    expect(response.profile.member.name, 'Andi Member');
    expect(response.profile.company.name, 'DO GYM');
    expect(
      response.profile.company.logoUrl,
      'https://cdn.example/company-logo.png',
    );
    expect(response.profile.membership?.planName, 'Premium Access');
    expect(response.profile.membership?.expiresAt.year, 2026);
  });

  test('falls back to legacy member response when profile is absent', () {
    final response = MobileMemberProfileResponseDto.fromJson({
      'success': true,
      'member': {
        'id': 'member-1',
        'memberCode': 'MEM-001',
        'name': 'Andi Member',
        'email': 'member@example.com',
        'phone': '081234567890',
        'company': {
          'id': 'company-1',
          'name': 'DO GYM',
          'logoUrl': 'https://cdn.example/company-logo.png',
        },
      },
    });

    expect(response.profile.member.memberCode, 'MEM-001');
    expect(
      response.profile.company.logoUrl,
      'https://cdn.example/company-logo.png',
    );
    expect(response.profile.membership, isNull);
  });
}

Map<String, Object?> _profileJson() {
  return {
    'member': {
      'id': 'member-1',
      'memberCode': 'MEM-001',
      'name': 'Andi Member',
      'email': 'member@example.com',
      'phone': '081234567890',
      'status': 'ACTIVE',
    },
    'company': {
      'id': 'company-1',
      'name': 'DO GYM',
      'logoUrl': 'https://cdn.example/company-logo.png',
    },
    'membership': {
      'id': 'membership-1',
      'status': 'ACTIVE',
      'planName': 'Premium Access',
      'startsAt': '2026-07-01T00:00:00.000Z',
      'expiresAt': '2026-07-25T00:00:00.000Z',
      'accessLabel': 'All locations',
    },
  };
}
