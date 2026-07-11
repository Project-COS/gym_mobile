import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/mobile_share_link_response_dto.dart';

// HTTP boundary for member-created public share links.
class ShareContentApiService {
  const ShareContentApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MobileShareLinkResponseDto> createShareLink({
    required String targetType,
    required String targetId,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.shareLinks,
      body: {'targetType': targetType, 'targetId': targetId},
    );

    try {
      return MobileShareLinkResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }
}
