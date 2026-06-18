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
      'email': email.trim().toLowerCase(),
      'password': password,
      if (companyId case final companyId?) 'companyId': companyId,
      if (deviceId case final deviceId?) 'deviceId': deviceId,
      if (deviceName case final deviceName?) 'deviceName': deviceName,
      if (platform case final platform?) 'platform': platform,
    };
  }
}
