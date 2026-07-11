import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/bookings/data/dto/mobile_personal_training_booking_response_dto.dart';

void main() {
  test('parses mobile personal training booking contact fields', () {
    final response = MobilePersonalTrainingBookingResponseDto.fromJson({
      'success': true,
      'booking': {
        'id': 'booking-1',
        'bookingCode': 'PTB-TEST001',
        'qrPayload': 'pt_booking:PTB-TEST001',
        'source': 'MEMBERSHIP_BENEFIT',
        'status': 'SCHEDULED',
        'startsAt': '2026-06-24T09:00:00.000Z',
        'endsAt': '2026-06-24T10:00:00.000Z',
        'notes': null,
        'trainer': {
          'id': 'trainer-1',
          'name': 'Coach Maya',
          'phone': '081234567890',
          'specialty': 'Strength',
        },
        'program': {
          'id': 'program-1',
          'name': 'Strength PT',
          'durationMinutes': 60,
        },
        'location': {
          'id': 'location-1',
          'name': 'DO GYM Denpasar',
          'area': 'Denpasar',
          'address': 'Jl. Gatot Subroto',
          'whatsapp': '+628199999999',
        },
      },
    });

    expect(response.booking.trainer.phone, '081234567890');
    expect(response.booking.location?.whatsapp, '+628199999999');
  });
}
