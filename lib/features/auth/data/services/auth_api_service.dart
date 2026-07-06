import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/login_request_dto.dart';
import '../dto/login_response_dto.dart';

// Auth HTTP boundary. It calls ApiClient only and leaves session persistence to
// LoginCubit/AuthSessionCubit after the repository returns a successful result.
class AuthApiService {
  const AuthApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<LoginResponseDto> login(LoginRequestDto request) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      body: request.toJson(),
      // Login must not attach a stale Bearer token.
      authenticated: false,
    );

    try {
      return LoginResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }
}
