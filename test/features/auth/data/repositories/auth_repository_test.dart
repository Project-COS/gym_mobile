import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/auth/data/dto/login_request_dto.dart';
import 'package:do_gym/features/auth/data/dto/login_response_dto.dart';
import 'package:do_gym/features/auth/data/dto/member_dto.dart';
import 'package:do_gym/features/auth/data/repositories/auth_repository.dart';
import 'package:do_gym/features/auth/data/services/auth_api_service.dart';

void main() {
  test('maps the service response to an auth login result', () async {
    final service = _FakeAuthApiService();
    final repository = RemoteAuthRepository(apiService: service);

    final result = await repository.login(
      email: 'member@example.com',
      password: 'password123',
    );

    expect(service.lastRequest?.email, 'member@example.com');
    expect(service.lastRequest?.password, 'password123');
    expect(result.accessToken, 'member-token');
    expect(result.member.name, 'Member Test');
  });
}

class _FakeAuthApiService implements AuthApiService {
  LoginRequestDto? lastRequest;

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    lastRequest = request;

    return LoginResponseDto(
      token: 'member-token',
      expiresAt: DateTime.utc(2026, 6, 13, 12),
      member: const MemberDto(
        id: 'member-1',
        memberCode: 'MEM-001',
        name: 'Member Test',
        email: 'member@example.com',
        phone: null,
        company: MemberCompanyDto(id: 'company-1', name: 'DO GYM'),
      ),
    );
  }
}
