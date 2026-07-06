import '../services/member_attendance_api_service.dart';

// Repository exposes app-ready QR data and hides the API DTO shape.
abstract interface class MemberAttendanceRepository {
  Future<MemberAttendanceQr> createMemberAttendanceQr();
}

class RemoteMemberAttendanceRepository implements MemberAttendanceRepository {
  const RemoteMemberAttendanceRepository({
    required MemberAttendanceApiService apiService,
  }) : _apiService = apiService;

  final MemberAttendanceApiService _apiService;

  @override
  Future<MemberAttendanceQr> createMemberAttendanceQr() async {
    final response = await _apiService.createMemberAttendanceQr();
    final data = response.data;

    // Prepare labels here so the QR sheet stays focused on rendering state.
    return MemberAttendanceQr(
      qrPayload: data.qrPayload,
      expiresAt: data.expiresAt,
      memberName: data.member.name,
      memberCode: data.member.memberCode,
      planName: data.activeMembership.planName,
      membershipExpiresAt: data.activeMembership.expiresAt,
      membershipExpiryLabel: _formatDate(data.activeMembership.expiresAt),
      qrExpiryLabel: _formatTime(data.expiresAt),
    );
  }

  String _formatDate(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    final monthName = _monthNames[localDate.month - 1];

    return '${localDate.day} $monthName ${localDate.year}';
  }

  String _formatTime(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}

// App-ready model for the short-lived member attendance barcode.
class MemberAttendanceQr {
  const MemberAttendanceQr({
    required this.qrPayload,
    required this.expiresAt,
    required this.memberName,
    required this.memberCode,
    required this.planName,
    required this.membershipExpiresAt,
    required this.membershipExpiryLabel,
    required this.qrExpiryLabel,
  });

  final String qrPayload;
  final DateTime expiresAt;
  final String memberName;
  final String memberCode;
  final String planName;
  final DateTime membershipExpiresAt;
  final String membershipExpiryLabel;
  final String qrExpiryLabel;

  // UI can use this when deciding whether a stale QR should be refreshed.
  bool get isExpired => !expiresAt.isAfter(DateTime.now());
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
