import 'package:do_gym/features/auth/data/dto/member_dto.dart';
import 'package:do_gym/features/auth/data/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthLoginResult? result, this.error})
    : result = result ?? successfulLoginResult();

  final AuthLoginResult result;
  final Object? error;

  int loginCount = 0;
  String? lastEmail;
  String? lastPassword;
  String? lastCompanyId;

  @override
  Future<AuthLoginResult> login({
    required String email,
    required String password,
    String? companyId,
  }) async {
    loginCount += 1;
    lastEmail = email;
    lastPassword = password;
    lastCompanyId = companyId;

    final loginError = error;

    if (loginError != null) {
      throw loginError;
    }

    return result;
  }
}

AuthLoginResult successfulLoginResult() {
  return AuthLoginResult(
    accessToken: 'member-token',
    expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
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
