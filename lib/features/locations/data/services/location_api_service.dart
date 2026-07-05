import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/mobile_location_response_dto.dart';

class LocationApiService {
  const LocationApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MobileLocationsResponseDto> fetchLocations() async {
    final response = await _apiClient.get(ApiEndpoints.locations);

    try {
      return MobileLocationsResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }
}
