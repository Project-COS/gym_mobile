import '../dto/member_notification_dto.dart';
import '../dto/push_device_registration_dto.dart';
import '../services/notification_api_service.dart';

class MemberNotificationInboxResult {
  const MemberNotificationInboxResult({
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
}

abstract interface class NotificationRepository {
  Future<MemberNotificationInboxResult> fetchNotifications({
    required int page,
    required int pageSize,
  });

  Future<void> registerPushDevice(PushDeviceRegistrationDto registration);

  Future<void> disablePushDevice({String? registrationToken});

  Future<void> markNotificationRead(String notificationId);

  Future<void> markAllNotificationsRead();
}

class RemoteNotificationRepository implements NotificationRepository {
  const RemoteNotificationRepository({
    required NotificationApiService apiService,
  }) : _apiService = apiService;

  final NotificationApiService _apiService;

  @override
  Future<MemberNotificationInboxResult> fetchNotifications({
    required int page,
    required int pageSize,
  }) async {
    final response = await _apiService.fetchNotifications(
      page: page,
      pageSize: pageSize,
    );

    return MemberNotificationInboxResult(
      items: response.items,
      unreadCount: response.unreadCount,
      page: response.page,
      pageSize: response.pageSize,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
    );
  }

  @override
  Future<void> registerPushDevice(PushDeviceRegistrationDto registration) {
    return _apiService.registerPushDevice(registration);
  }

  @override
  Future<void> disablePushDevice({String? registrationToken}) {
    return _apiService.disablePushDevice(registrationToken: registrationToken);
  }

  @override
  Future<void> markNotificationRead(String notificationId) {
    return _apiService.markNotificationRead(notificationId);
  }

  @override
  Future<void> markAllNotificationsRead() {
    return _apiService.markAllNotificationsRead();
  }
}
