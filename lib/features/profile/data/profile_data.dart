// App-ready member profile model consumed by profile display and edit screens.
class MemberProfile {
  const MemberProfile({
    required this.id,
    required this.memberCode,
    required this.name,
    required this.email,
    required this.phone,
    required this.companyName,
    required this.badgeLabel,
    required this.membershipPlanName,
    required this.membershipStatusLabel,
    required this.membershipExpiryLabel,
    required this.accessLabel,
    required this.hasActiveMembership,
    this.membershipExpiresAt,
  });

  final String id;
  final String memberCode;
  final String name;
  final String email;
  final String phone;
  final String companyName;
  final String badgeLabel;
  final String membershipPlanName;
  final String membershipStatusLabel;
  final String membershipExpiryLabel;
  final String accessLabel;
  final bool hasActiveMembership;
  final DateTime? membershipExpiresAt;
}
