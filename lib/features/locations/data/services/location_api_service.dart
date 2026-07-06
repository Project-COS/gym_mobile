import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/mobile_location_response_dto.dart';

// Thin HTTP boundary for the mobile branch location endpoint.
class LocationApiService {
  const LocationApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MobileLocationsResponseDto> fetchLocations() async {
    final response = await _apiClient.get(ApiEndpoints.locations);

    try {
      return MobileLocationsResponseDto.fromJson(response);
    } on FormatException catch (error) {
      // Keep invalid payload handling consistent with the shared ApiClient flow.
      throw ApiException.invalidResponse(cause: error);
    }
  }
}
