class PushDeviceRegistrationDto {
  const PushDeviceRegistrationDto({
    required this.registrationToken,
    required this.platform,
    required this.permissionStatus,
    this.firebaseInstallationId,
    this.deviceId,
    this.deviceName,
    this.appVersion,
    this.locale,
  });

  final String registrationToken;
  final String platform;
  final String permissionStatus;
  final String? firebaseInstallationId;
  final String? deviceId;
  final String? deviceName;
  final String? appVersion;
  final String? locale;

  Map<String, Object?> toJson() {
    return {
      'registrationToken': registrationToken,
      'platform': platform,
      'permissionStatus': permissionStatus,
      'firebaseInstallationId': firebaseInstallationId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'appVersion': appVersion,
      'locale': locale,
    };
  }
}
