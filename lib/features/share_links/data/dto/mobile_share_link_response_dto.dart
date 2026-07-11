class MobileShareLinkResponseDto {
  const MobileShareLinkResponseDto({required this.shareLink});

  final MobileShareLinkDto shareLink;

  factory MobileShareLinkResponseDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'share link response');

    return MobileShareLinkResponseDto(
      shareLink: MobileShareLinkDto.fromJson(data['shareLink']),
    );
  }
}

class MobileShareLinkDto {
  const MobileShareLinkDto({
    required this.token,
    required this.publicUrl,
    required this.targetType,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.expiresAt,
  });

  final String token;
  final String publicUrl;
  final String targetType;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime? expiresAt;

  factory MobileShareLinkDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'shareLink');
    final expiresAt = _readOptionalString(data, 'expiresAt');

    return MobileShareLinkDto(
      token: _readRequiredString(data, 'token'),
      publicUrl: _readRequiredString(data, 'publicUrl'),
      targetType: _readRequiredString(data, 'targetType'),
      title: _readRequiredString(data, 'title'),
      description: _readRequiredString(data, 'description'),
      imageUrl: _readOptionalString(data, 'imageUrl'),
      expiresAt: expiresAt == null ? null : DateTime.parse(expiresAt),
    );
  }
}

Map<String, Object?> _readJsonMap(Object? value, String label) {
  if (value is Map<String, Object?>) {
    return value;
  }

  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  throw FormatException('Invalid $label payload.');
}

String _readRequiredString(Map<String, Object?> data, String key) {
  final value = data[key];

  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }

  throw FormatException('Missing $key in share link payload.');
}

String? _readOptionalString(Map<String, Object?> data, String key) {
  final value = data[key];

  if (value == null) {
    return null;
  }

  if (value is String) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  throw FormatException('Invalid $key in share link payload.');
}
