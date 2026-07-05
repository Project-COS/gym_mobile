import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/member_attendance_history_response_dto.dart';

class MemberAttendanceActivityApiService {
  const MemberAttendanceActivityApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MemberAttendanceHistoryResponseDto> fetchAttendances({
    required String range,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.memberAttendances,
      queryParameters: {
        'range': range,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    try {
      return MemberAttendanceHistoryResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }
}
