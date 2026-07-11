import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/classes/data/dto/mobile_class_booking_response_dto.dart';

void main() {
  test('parses mobile class booking response', () {
    final response = MobileClassBookingResponseDto.fromJson({
      'success': true,
      'booking': {
        'id': 'class-booking-1',
        'bookingCode': 'CLB-TEST001',
        'qrPayload': 'class_booking:CLB-TEST001',
        'className': 'Yoga Flow',
        'source': 'CUSTOM_SESSION',
        'status': 'SCHEDULED',
        'startsAt': '2026-06-16T10:00:00.000Z',
        'endsAt': '2026-06-16T11:00:00.000Z',
        'notes': null,
        'class': {'id': 'class-1', 'name': 'Yoga Flow', 'durationMinutes': 60},
        'session': {'id': 'session-1', 'roomName': 'Studio 1'},
        'trainer': {
          'id': 'trainer-1',
          'name': 'Coach Maya',
          'phone': '081234567890',
          'specialty': 'Yoga',
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

    expect(response.booking.id, 'class-booking-1');
    expect(response.booking.bookingCode, 'CLB-TEST001');
    expect(response.booking.gymClass?.name, 'Yoga Flow');
    expect(response.booking.trainer.phone, '081234567890');
    expect(response.booking.session?.roomName, 'Studio 1');
    expect(response.booking.location?.area, 'Denpasar');
    expect(response.booking.location?.whatsapp, '+628199999999');
  });

  test('parses mobile class bookings list response', () {
    final response = MobileClassBookingsResponseDto.fromJson({
      'success': true,
      'bookings': [
        {
          'id': 'class-booking-1',
          'bookingCode': 'CLB-TEST001',
          'qrPayload': 'class_booking:CLB-TEST001',
          'className': 'Yoga Flow',
          'source': 'CUSTOM_SESSION',
          'status': 'COMPLETED',
          'startsAt': '2026-06-16T10:00:00.000Z',
          'endsAt': '2026-06-16T11:00:00.000Z',
          'notes': null,
          'class': {
            'id': 'class-1',
            'name': 'Yoga Flow',
            'durationMinutes': 60,
          },
          'session': {'id': 'session-1', 'roomName': 'Studio 1'},
          'trainer': {
            'id': 'trainer-1',
            'name': 'Coach Maya',
            'phone': null,
            'specialty': 'Yoga',
          },
          'location': {
            'id': 'location-1',
            'name': 'DO GYM Denpasar',
            'area': 'Denpasar',
            'address': 'Jl. Gatot Subroto',
            'whatsapp': '+628199999999',
          },
        },
      ],
      'pagination': {
        'page': 1,
        'pageSize': 20,
        'totalItems': 1,
        'totalPages': 1,
      },
    });

    expect(response.bookings, hasLength(1));
    expect(response.bookings.single.bookingCode, 'CLB-TEST001');
    expect(response.bookings.single.status, 'COMPLETED');
    expect(response.pagination.totalItems, 1);
  });

  test('rejects invalid class booking response dates', () {
    expect(
      () => MobileClassBookingResponseDto.fromJson({
        'booking': {
          'id': 'class-booking-1',
          'bookingCode': 'CLB-TEST001',
          'qrPayload': 'class_booking:CLB-TEST001',
          'className': 'Yoga Flow',
          'source': 'CUSTOM_SESSION',
          'status': 'SCHEDULED',
          'startsAt': 'invalid',
          'endsAt': '2026-06-16T11:00:00.000Z',
          'notes': null,
          'class': null,
          'session': null,
          'trainer': {
            'id': 'trainer-1',
            'name': 'Coach Maya',
            'specialty': null,
          },
          'location': null,
        },
      }),
      throwsFormatException,
    );
  });
}
