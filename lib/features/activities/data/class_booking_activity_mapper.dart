import '../../classes/data/repositories/booking_class_repository.dart';
import '../../../core/icons/app_lucide_icons.dart';
import 'activity_data.dart';

// Class booking history already comes from the classes feature. This mapper only
// adapts it to the shared activity card shape and preserves QR-capable detail.
ActivityHistoryItem mapClassBookingToActivityHistoryItem(
  ClassBookingHistoryItem booking, {
  bool isFeatured = false,
}) {
  return ActivityHistoryItem(
    tab: ActivityTab.classSession,
    title: booking.title,
    subtitle: 'Coach ${booking.trainerName} - ${booking.schedule}',
    status: _formatBookingStatus(booking.status),
    icon: AppLucideIcons.users,
    isFeatured: isFeatured,
    bookingDetail: ActivityBookingDetail(
      itemId: booking.id,
      typeCode: 'class',
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
        label: 'Coach',
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
    'MOBILE_APP' => 'Mobile App',
    'ADMIN' => 'Admin',
    'WALK_IN' => 'Walk In',
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
