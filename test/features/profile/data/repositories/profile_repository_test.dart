import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/profile/data/dto/member_profile_response_dto.dart';
import 'package:do_gym/features/profile/data/dto/update_member_profile_request_dto.dart';
import 'package:do_gym/features/profile/data/repositories/profile_repository.dart';
import 'package:do_gym/features/profile/data/services/profile_api_service.dart';

void main() {
  test('maps profile DTO into display data', () async {
    final repository = RemoteProfileRepository(
      apiService: _FakeProfileApiService(
        response: MobileMemberProfileResponseDto.fromJson({
          'success': true,
          'profile': _profileJson(),
        }),
      ),
    );

    final profile = await repository.fetchProfile();

    expect(profile.name, 'Andi Member');
    expect(profile.badgeLabel, 'Premium Member');
    expect(profile.membershipStatusLabel, 'Active');
    expect(profile.membershipExpiryLabel, '25 Jul 2026');
    expect(profile.accessLabel, 'Semua Cabang');
  });
}

class _FakeProfileApiService implements ProfileApiService {
  _FakeProfileApiService({required this.response});

  final MobileMemberProfileResponseDto response;

  @override
  Future<MobileMemberProfileResponseDto> fetchProfile() async {
    return response;
  }

  @override
  Future<MobileMemberProfileResponseDto> updateProfile(
    UpdateMemberProfileRequestDto request,
  ) async {
    return response;
  }
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
    'company': {'id': 'company-1', 'name': 'DO GYM'},
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
