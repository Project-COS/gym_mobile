import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/activities/data/activity_data.dart';
import 'package:do_gym/features/activities/data/personal_training_activity_mapper.dart';
import 'package:do_gym/features/bookings/data/repositories/personal_training_booking_repository.dart';

void main() {
  test('maps API-backed PT booking history into activity history item', () {
    const booking = PersonalTrainingBookingHistoryItem(
      id: 'booking-1',
      bookingCode: 'PTB-TEST001',
      qrPayload: 'pt_booking:PTB-TEST001',
      title: 'Strength PT',
      trainerName: 'Coach Maya',
      schedule: 'Rabu, 24 Jun 09:00',
      duration: '60 Menit',
      location: 'DO GYM Denpasar - Denpasar',
      status: 'COMPLETED',
      source: 'MEMBERSHIP_BENEFIT',
      canShowQr: false,
    );

    final item = mapPersonalTrainingBookingToActivityHistoryItem(
      booking,
      isFeatured: true,
    );

    expect(item.tab, ActivityTab.personalTrainer);
    expect(item.title, 'Strength PT');
    expect(item.subtitle, contains('Coach Maya'));
    expect(item.status, 'Selesai');
    expect(item.isFeatured, isTrue);
    expect(item.bookingDetail?.itemId, 'booking-1');
    expect(item.bookingDetail?.typeCode, 'pt');
    expect(item.bookingDetail?.title, 'Strength PT');
    expect(item.bookingDetail?.schedule, 'Rabu, 24 Jun 09:00');
    expect(item.bookingDetail?.duration, '60 Menit');
    expect(item.bookingDetail?.location, 'DO GYM Denpasar - Denpasar');
    expect(item.bookingDetail?.bookingCode, 'PTB-TEST001');
    expect(item.bookingDetail?.source, 'Membership Benefit');
    expect(item.bookingDetail?.qrPayload, 'pt_booking:PTB-TEST001');
    expect(item.bookingDetail?.canShowQr, isFalse);
    expect(item.metas.map((meta) => meta.value), contains('60 Menit'));
    expect(
      item.metas.map((meta) => meta.value),
      contains('DO GYM Denpasar - Denpasar'),
    );
  });
}
