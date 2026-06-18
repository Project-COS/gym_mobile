import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/auth/data/dto/login_response_dto.dart';

void main() {
  group('LoginResponseDto', () {
    test('parses the mobile login response', () {
      final response = LoginResponseDto.fromJson({
        'success': true,
        'token': 'member-token',
        'expiresAt': '2026-06-13T12:00:00.000Z',
        'member': {
          'id': 'member-1',
          'memberCode': 'MEM-001',
          'name': 'Member Test',
          'email': 'member@example.com',
          'phone': null,
          'company': {'id': 'company-1', 'name': 'DO GYM'},
        },
      });

      expect(response.token, 'member-token');
      expect(response.expiresAt, DateTime.utc(2026, 6, 13, 12));
      expect(response.member.memberCode, 'MEM-001');
      expect(response.member.company.name, 'DO GYM');
    });

    test('rejects a successful response without a token', () {
      expect(
        () => LoginResponseDto.fromJson({
          'success': true,
          'expiresAt': '2026-06-13T12:00:00.000Z',
          'member': <String, Object?>{},
        }),
        throwsFormatException,
      );
    });
  });
}
