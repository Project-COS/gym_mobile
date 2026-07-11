class WhatsAppContactLink {
  const WhatsAppContactLink({required this.displayNumber, required this.uri});

  final String displayNumber;
  final Uri uri;
}

WhatsAppContactLink? buildWhatsAppContactLink(
  String? rawPhoneNumber, {
  String? message,
}) {
  final normalizedNumber = normalizeWhatsAppPhoneNumber(rawPhoneNumber);

  if (normalizedNumber == null) {
    return null;
  }

  final normalizedMessage = message?.trim();

  return WhatsAppContactLink(
    displayNumber: '+$normalizedNumber',
    uri: Uri.https(
      'wa.me',
      '/$normalizedNumber',
      normalizedMessage == null || normalizedMessage.isEmpty
          ? null
          : {'text': normalizedMessage},
    ),
  );
}

String? normalizeWhatsAppPhoneNumber(String? rawPhoneNumber) {
  if (rawPhoneNumber == null) {
    return null;
  }

  var digits = rawPhoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

  if (digits.startsWith('00')) {
    digits = digits.substring(2);
  }

  if (digits.startsWith('0')) {
    digits = '62${digits.substring(1)}';
  } else if (digits.startsWith('8')) {
    digits = '62$digits';
  }

  if (digits.length < 8 || digits.length > 15) {
    return null;
  }

  return digits;
}
