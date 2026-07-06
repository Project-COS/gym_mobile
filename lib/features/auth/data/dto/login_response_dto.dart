import 'member_dto.dart';

// Strict parser for a successful login response. Invalid shapes become
// FormatException so AuthApiService can convert them into ApiException.
class LoginResponseDto {
  const LoginResponseDto({
    required this.token,
    required this.expiresAt,
    required this.member,
  });

  factory LoginResponseDto.fromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const FormatException('Login response must be a JSON object.');
    }

    if (json['success'] != true) {
      throw const FormatException('Login response was not successful.');
    }

    final token = json['token'];
    final expiresAtValue = json['expiresAt'];

    if (token is! String || token.trim().isEmpty) {
      throw const FormatException('Login token is missing.');
    }

    if (expiresAtValue is! String) {
      throw const FormatException('Session expiry is missing.');
    }

    final expiresAt = DateTime.tryParse(expiresAtValue);

    if (expiresAt == null) {
      throw const FormatException('Session expiry is invalid.');
    }

    return LoginResponseDto(
      token: token.trim(),
      // Store session expiry in UTC to match the core session model.
      expiresAt: expiresAt.toUtc(),
      member: MemberDto.fromJson(json['member']),
    );
  }

  final String token;
  final DateTime expiresAt;
  final MemberDto member;
}
