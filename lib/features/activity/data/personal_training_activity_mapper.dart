import 'package:flutter/material.dart';

import '../../booking/data/repositories/personal_training_booking_repository.dart';
import 'activity_data.dart';

ActivityHistoryItem mapPersonalTrainingBookingToActivityHistoryItem(
  PersonalTrainingBookingHistoryItem booking, {
  bool isFeatured = false,
}) {
  return ActivityHistoryItem(
    tab: ActivityTab.personalTrainer,
    title: booking.title,
    subtitle: 'Coach ${booking.trainerName} - ${booking.schedule}',
    status: _formatBookingStatus(booking.status),
    icon: Icons.how_to_reg_rounded,
    isFeatured: isFeatured,
    bookingDetail: ActivityBookingDetail(
      itemId: booking.id,
      typeCode: 'pt',
      title: booking.title,
      schedule: booking.schedule,
      duration: booking.duration,
      location: booking.location,
      bookingCode: booking.bookingCode,
      source: _formatBookingSource(booking.source),
      qrPayload: booking.qrPayload,
      canShowQr: booking.canShowQr,
    ),
    metas: [
      ActivityHistoryMeta(
        icon: Icons.calendar_month_rounded,
        label: 'Jadwal',
        value: booking.schedule,
      ),
      ActivityHistoryMeta(
        icon: Icons.timer_rounded,
        label: 'Durasi',
        value: booking.duration,
      ),
      ActivityHistoryMeta(
        icon: Icons.person_rounded,
        label: 'Trainer',
        value: booking.trainerName,
      ),
      ActivityHistoryMeta(
        icon: Icons.location_on_rounded,
        label: 'Branch',
        value: booking.location,
      ),
    ],
  );
}

String _formatBookingSource(String source) {
  return switch (source) {
    'MEMBERSHIP_BENEFIT' => 'Membership Benefit',
    'AD_HOC' => 'Ad Hoc',
    'MANUAL' => 'Manual',
    'TRIAL' => 'Trial',
    _ => source,
  };
}

String _formatBookingStatus(String status) {
  return switch (status) {
    'REQUESTED' => 'Menunggu',
    'SCHEDULED' => 'Aktif',
    'COMPLETED' => 'Selesai',
    'CANCELLED' => 'Batal',
    'NO_SHOW' => 'Tidak Hadir',
    _ => status,
  };
}
