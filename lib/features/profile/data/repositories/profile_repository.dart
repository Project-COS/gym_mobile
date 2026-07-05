import '../dto/member_profile_response_dto.dart';
import '../dto/update_member_profile_request_dto.dart';
import '../profile_data.dart';
import '../services/profile_api_service.dart';

abstract interface class ProfileRepository {
  Future<MemberProfile> fetchProfile();

  Future<MemberProfile> updateProfile({
    required String name,
    required String email,
    required String phone,
  });
}

class RemoteProfileRepository implements ProfileRepository {
  const RemoteProfileRepository({required ProfileApiService apiService})
    : _apiService = apiService;

  final ProfileApiService _apiService;

  @override
  Future<MemberProfile> fetchProfile() async {
    final response = await _apiService.fetchProfile();
    return _mapProfile(response.profile);
  }

  @override
  Future<MemberProfile> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final response = await _apiService.updateProfile(
      UpdateMemberProfileRequestDto(name: name, email: email, phone: phone),
    );

    return _mapProfile(response.profile);
  }

  MemberProfile _mapProfile(MobileMemberProfileDto dto) {
    final membership = dto.membership;
    final hasActiveMembership = membership?.status == 'ACTIVE';

    return MemberProfile(
      id: dto.member.id,
      memberCode: dto.member.memberCode,
      name: dto.member.name,
      email: dto.member.email ?? '',
      phone: dto.member.phone ?? '',
      companyName: dto.company.name,
      badgeLabel: _formatBadgeLabel(membership?.planName),
      membershipPlanName: membership?.planName ?? 'Member Access',
      membershipStatusLabel: membership == null
          ? 'Tidak Aktif'
          : _formatMembershipStatus(membership.status),
      membershipExpiryLabel: membership == null
          ? 'Belum tersedia'
          : _formatDate(membership.expiresAt),
      accessLabel: _formatAccessLabel(membership?.accessLabel),
      hasActiveMembership: hasActiveMembership,
      membershipExpiresAt: membership?.expiresAt,
    );
  }

  String _formatBadgeLabel(String? planName) {
    final normalizedPlanName = planName?.trim();

    if (normalizedPlanName == null || normalizedPlanName.isEmpty) {
      return 'Member';
    }

    if (normalizedPlanName.toLowerCase().contains('premium')) {
      return 'Premium Member';
    }

    if (normalizedPlanName.toLowerCase().contains('member')) {
      return normalizedPlanName;
    }

    return '$normalizedPlanName Member';
  }

  String _formatMembershipStatus(String status) {
    return switch (status.toUpperCase()) {
      'ACTIVE' => 'Active',
      'PENDING' => 'Pending',
      'CANCELLED' => 'Cancelled',
      _ => status,
    };
  }

  String _formatAccessLabel(String? accessLabel) {
    final normalizedAccessLabel = accessLabel?.trim();

    if (normalizedAccessLabel == null || normalizedAccessLabel.isEmpty) {
      return 'Belum tersedia';
    }

    if (normalizedAccessLabel.toLowerCase() == 'all locations') {
      return 'Semua Cabang';
    }

    return normalizedAccessLabel;
  }

  String _formatDate(DateTime date) {
    final month = _monthNames[date.month - 1];
    return '${date.day} $month ${date.year}';
  }
}

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
