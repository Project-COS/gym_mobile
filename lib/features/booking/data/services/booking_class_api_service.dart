import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/mobile_class_response_dto.dart';

class BookingClassApiService {
  const BookingClassApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MobileClassesResponseDto> fetchClassesForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.classes,
      queryParameters: {
        'locationId': locationId,
        'startsFrom': startsFrom.toUtc().toIso8601String(),
        'startsTo': startsTo.toUtc().toIso8601String(),
      },
    );

    try {
      return MobileClassesResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }
}
