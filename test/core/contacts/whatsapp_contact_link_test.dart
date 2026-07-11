import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/contacts/whatsapp_contact_link.dart';

void main() {
  test('normalizes Indonesian local numbers for WhatsApp links', () {
    final link = buildWhatsAppContactLink(
      '0812-3456-7890',
      message: 'Halo Coach',
    );

    expect(link?.displayNumber, '+6281234567890');
    expect(link?.uri.toString(), contains('https://wa.me/6281234567890'));
    expect(link?.uri.queryParameters['text'], 'Halo Coach');
  });

  test('keeps international numbers without plus signs', () {
    expect(normalizeWhatsAppPhoneNumber('+62 812 3456 7890'), '6281234567890');
  });

  test('rejects empty or implausible numbers', () {
    expect(buildWhatsAppContactLink(null), isNull);
    expect(buildWhatsAppContactLink('123'), isNull);
  });
}
