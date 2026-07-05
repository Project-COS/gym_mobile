import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/member_profile_response_dto.dart';
import '../dto/update_member_profile_request_dto.dart';

class ProfileApiService {
  const ProfileApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MobileMemberProfileResponseDto> fetchProfile() async {
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
