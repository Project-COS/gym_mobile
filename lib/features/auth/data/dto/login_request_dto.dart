// DTO for POST /api/mobile/auth/login. Keep this class close to the API payload
// shape; repository and Cubit logic should not add fields directly.
class LoginRequestDto {
  const LoginRequestDto({
    required this.email,
    required this.password,
    this.companyId,
    this.deviceId,
    this.deviceName,
    this.platform,
  });

  final String email;
  final String password;
  final String? companyId;
  final String? deviceId;
  final String? deviceName;
  final String? platform;

  Map<String, Object?> toJson() {
    return {
      // The backend treats email as the member identity, so normalize casing
      // before sending it over the network.
      'email': email.trim().toLowerCase(),
      'password': password,
      // Optional device and company fields are omitted when absent so the API
      // can apply its own defaults and conflict handling.
      if (companyId case final companyId?) 'companyId': companyId,
      if (deviceId case final deviceId?) 'deviceId': deviceId,
      if (deviceName case final deviceName?) 'deviceName': deviceName,
      if (platform case final platform?) 'platform': platform,
    };
  }
}
