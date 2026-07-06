import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/member_profile_response_dto.dart';
import '../dto/update_member_profile_request_dto.dart';

// Thin HTTP boundary for reading and updating the authenticated member profile.
class ProfileApiService {
  const ProfileApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MobileMemberProfileResponseDto> fetchProfile() async {
    // ApiClient injects the Bearer token from the root session provider.
    final response = await _apiClient.get(ApiEndpoints.currentMember);

    try {
      return MobileMemberProfileResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  Future<MobileMemberProfileResponseDto> updateProfile(
    UpdateMemberProfileRequestDto request,
  ) async {
    // The backend returns the latest profile after update, so repository can
    // refresh UI state from the response directly.
    final response = await _apiClient.patch(
      ApiEndpoints.currentMember,
      body: request.toJson(),
    );

    try {
      return MobileMemberProfileResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }
}
