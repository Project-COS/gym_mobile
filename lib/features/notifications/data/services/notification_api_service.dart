import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/member_notification_list_response_dto.dart';
import '../dto/push_device_registration_dto.dart';

class NotificationApiService {
  const NotificationApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MemberNotificationListResponseDto> fetchNotifications({
    required int page,
    required int pageSize,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.notifications,
      queryParameters: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    try {
      return MemberNotificationListResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  Future<void> registerPushDevice(PushDeviceRegistrationDto registration) {
    return _apiClient
        .post(
          ApiEndpoints.notificationPushRegistrations,
          body: registration.toJson(),
        )
        .then((_) {});
  }

  Future<void> disablePushDevice({String? registrationToken}) {
    return _apiClient
        .delete(
          ApiEndpoints.notificationPushRegistrations,
          body: {'registrationToken': registrationToken},
        )
        .then((_) {});
  }

  Future<void> markNotificationRead(String notificationId) {
    return _apiClient
        .patch(ApiEndpoints.readNotification(notificationId))
        .then((_) {});
  }

  Future<void> markAllNotificationsRead() {
    return _apiClient.patch(ApiEndpoints.readAllNotifications).then((_) {});
  }
}
