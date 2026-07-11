class MemberNotificationDto {
  const MemberNotificationDto({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.readAt,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, Object?> data;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;

  factory MemberNotificationDto.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Notification item must be an object.');
    }

    final id = _requiredString(json, 'id');
    final type = _requiredString(json, 'type');
    final title = _requiredString(json, 'title');
    final body = _requiredString(json, 'body');
    final createdAt = DateTime.tryParse(_requiredString(json, 'createdAt'));
    final rawReadAt = json['readAt'];
    final readAt = rawReadAt == null
        ? null
        : DateTime.tryParse(rawReadAt is String ? rawReadAt : '');

    if (createdAt == null || (rawReadAt != null && readAt == null)) {
      throw const FormatException('Notification dates are not valid.');
    }

    final rawData = json['data'];

    return MemberNotificationDto(
      id: id,
      type: type,
      title: title,
      body: body,
      data: rawData is Map<String, dynamic>
          ? Map<String, Object?>.from(rawData)
          : const {},
      readAt: readAt,
      createdAt: createdAt,
    );
  }

  MemberNotificationDto markRead(DateTime timestamp) {
    return MemberNotificationDto(
      id: id,
      type: type,
      title: title,
      body: body,
      data: data,
      readAt: readAt ?? timestamp,
      createdAt: createdAt,
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Notification $key is required.');
  }

  return value.trim();
}
