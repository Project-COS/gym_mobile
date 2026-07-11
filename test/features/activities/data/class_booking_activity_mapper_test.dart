import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/activities/data/activity_data.dart';
import 'package:do_gym/features/activities/data/class_booking_activity_mapper.dart';
import 'package:do_gym/features/classes/data/repositories/booking_class_repository.dart';

void main() {
  test('maps API-backed class booking history into activity history item', () {
    const booking = ClassBookingHistoryItem(
      id: 'class-booking-1',
      bookingCode: 'CLB-TEST001',
      qrPayload: 'class_booking:CLB-TEST001',
      title: 'Yoga Flow',
      trainerName: 'Coach Maya',
      schedule: 'Selasa, 16 Jun 18:00',
      duration: '60 Menit',
      location: 'DO GYM Denpasar - Studio 1',
      status: 'COMPLETED',
      source: 'CUSTOM_SESSION',
      canShowQr: false,
    );

    final item = mapClassBookingToActivityHistoryItem(
      booking,
      isFeatured: true,
    );

    expect(item.tab, ActivityTab.classSession);
    expect(item.title, 'Yoga Flow');
    expect(item.subtitle, contains('Coach Maya'));
    expect(item.status, 'Selesai');
    expect(item.icon, ActivityTab.classSession.icon);
    expect(item.isFeatured, isTrue);
    expect(item.bookingDetail?.itemId, 'class-booking-1');
    expect(item.bookingDetail?.typeCode, 'class');
    expect(item.bookingDetail?.bookingCode, 'CLB-TEST001');
    expect(item.bookingDetail?.source, 'Custom session');
    expect(item.bookingDetail?.qrPayload, 'class_booking:CLB-TEST001');
    expect(item.bookingDetail?.canShowQr, isFalse);
    expect(item.metas.map((meta) => meta.value), contains('60 Menit'));
    expect(
      item.metas.map((meta) => meta.value),
      contains('DO GYM Denpasar - Studio 1'),
    );
  });
}
