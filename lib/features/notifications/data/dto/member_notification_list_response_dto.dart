import 'member_notification_dto.dart';

class MemberNotificationListResponseDto {
  const MemberNotificationListResponseDto({
    required this.items,
    required this.unreadCount,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final List<MemberNotificationDto> items;
  final int unreadCount;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  factory MemberNotificationListResponseDto.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Notification response must be an object.');
    }

    final rawItems = json['items'];
    final pagination = json['pagination'];

    if (rawItems is! List || pagination is! Map<String, dynamic>) {
      throw const FormatException('Notification response is incomplete.');
    }

    return MemberNotificationListResponseDto(
      items: rawItems
          .map(MemberNotificationDto.fromJson)
          .toList(growable: false),
      unreadCount: _requiredNonNegativeInteger(json, 'unreadCount'),
      page: _requiredPositiveInteger(pagination, 'page'),
      pageSize: _requiredPositiveInteger(pagination, 'pageSize'),
      totalItems: _requiredNonNegativeInteger(pagination, 'totalItems'),
      totalPages: _requiredPositiveInteger(pagination, 'totalPages'),
    );
  }
}

int _requiredPositiveInteger(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is! int || value < 1) {
    throw FormatException('Notification pagination $key is not valid.');
  }

  return value;
}

int _requiredNonNegativeInteger(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is! int || value < 0) {
    throw FormatException('Notification $key is not valid.');
  }

  return value;
}
