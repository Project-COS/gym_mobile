import '../dto/login_request_dto.dart';
import '../dto/member_dto.dart';
import '../services/auth_api_service.dart';

class AuthLoginResult {
  const AuthLoginResult({
    required this.accessToken,
    required this.expiresAt,
    required this.member,
  });

  final String accessToken;
  final DateTime expiresAt;
  final MemberDto member;
}

abstract interface class AuthRepository {
  Future<AuthLoginResult> login({
    required String email,
    required String password,
    String? companyId,
  });
}

class RemoteAuthRepository implements AuthRepository {
  const RemoteAuthRepository({required AuthApiService apiService})
    : _apiService = apiService;

  final AuthApiService _apiService;

  @override
  Future<AuthLoginResult> login({
    required String email,
    required String password,
    String? companyId,
  }) async {
    final response = await _apiService.login(
      LoginRequestDto(email: email, password: password, companyId: companyId),
    );

    return AuthLoginResult(
      accessToken: response.token,
      expiresAt: response.expiresAt,
      member: response.member,
    );
  }
}
