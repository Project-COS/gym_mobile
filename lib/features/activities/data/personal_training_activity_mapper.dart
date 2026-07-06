import '../../bookings/data/repositories/personal_training_booking_repository.dart';
import '../../../core/icons/app_lucide_icons.dart';
import 'activity_data.dart';

// PT booking history keeps its source/status terminology in the bookings
// feature. This mapper translates that record into member-facing activity copy.
ActivityHistoryItem mapPersonalTrainingBookingToActivityHistoryItem(
  PersonalTrainingBookingHistoryItem booking, {
  bool isFeatured = false,
}) {
  return ActivityHistoryItem(
    tab: ActivityTab.personalTrainer,
    title: booking.title,
    subtitle: 'Coach ${booking.trainerName} - ${booking.schedule}',
    status: _formatBookingStatus(booking.status),
    icon: AppLucideIcons.userPlus,
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
        icon: AppLucideIcons.calendar,
        label: 'Jadwal',
        value: booking.schedule,
      ),
      ActivityHistoryMeta(
        icon: AppLucideIcons.timer,
        label: 'Durasi',
        value: booking.duration,
      ),
      ActivityHistoryMeta(
        icon: AppLucideIcons.person,
        label: 'Trainer',
        value: booking.trainerName,
      ),
      ActivityHistoryMeta(
        icon: AppLucideIcons.mapPin,
        label: 'Cabang',
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
