import 'package:flutter/material.dart';

import 'activity_data.dart';
import 'repositories/member_attendance_activity_repository.dart';

ActivityHistoryItem mapMemberAttendanceToActivityHistoryItem(
  MemberAttendanceHistoryItem attendance, {
  bool isFeatured = false,
}) {
  return ActivityHistoryItem(
    tab: ActivityTab.attendance,
    title: attendance.locationName,
    subtitle: '${_formatDate(attendance.checkedInAt)} - Check-in member',
    status: attendance.isOpen ? 'Berlangsung' : 'Hadir',
    icon: Icons.door_front_door_rounded,
    isFeatured: isFeatured,
    metas: [
      ActivityHistoryMeta(
        icon: Icons.location_on_rounded,
        label: 'Branch',
        value: attendance.locationArea ?? attendance.locationName,
      ),
      ActivityHistoryMeta(
        icon: Icons.login_rounded,
        label: 'Check-in',
        value: _formatTime(attendance.checkedInAt),
      ),
      ActivityHistoryMeta(
        icon: Icons.logout_rounded,
        label: 'Check-out',
        value: attendance.checkedOutAt == null
            ? 'Belum check-out'
            : _formatTime(attendance.checkedOutAt!),
      ),
      ActivityHistoryMeta(
        icon: Icons.timer_rounded,
        label: 'Durasi',
        value: attendance.durationMinutes == null
            ? 'Berlangsung'
            : _formatDuration(attendance.durationMinutes!),
      ),
    ],
  );
}

String _formatDate(DateTime dateTime) {
  final localDate = dateTime.toLocal();
  final monthName = _monthNames[localDate.month - 1];

  return '${localDate.day} $monthName ${localDate.year}';
}

String _formatTime(DateTime dateTime) {
  final localDate = dateTime.toLocal();
  final hour = localDate.hour.toString().padLeft(2, '0');
  final minute = localDate.minute.toString().padLeft(2, '0');

  return '$hour:$minute';
}

String _formatDuration(int durationMinutes) {
  final hours = durationMinutes ~/ 60;
  final minutes = durationMinutes % 60;

  if (hours <= 0) {
    return '${minutes}m';
  }

  if (minutes == 0) {
    return '${hours}j';
  }

  return '${hours}j ${minutes}m';
}

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];
