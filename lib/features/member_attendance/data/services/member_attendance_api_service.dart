import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/member_attendance_qr_response_dto.dart';

class MemberAttendanceApiService {
  const MemberAttendanceApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MemberAttendanceQrResponseDto> createMemberAttendanceQr() async {
    final response = await _apiClient.post(ApiEndpoints.memberAttendanceQr);

    try {
      return MemberAttendanceQrResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }
}
