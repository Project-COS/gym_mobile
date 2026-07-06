import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/member_attendance_qr_response_dto.dart';

// Thin HTTP boundary for creating the member attendance QR.
class MemberAttendanceApiService {
  const MemberAttendanceApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MemberAttendanceQrResponseDto> createMemberAttendanceQr() async {
    // The backend decides the QR payload and expiry; mobile only requests a new token.
    final response = await _apiClient.post(ApiEndpoints.memberAttendanceQr);

    try {
      return MemberAttendanceQrResponseDto.fromJson(response);
    } on FormatException catch (error) {
      // Keep invalid payload handling consistent with the shared ApiClient flow.
      throw ApiException.invalidResponse(cause: error);
    }
  }
}
