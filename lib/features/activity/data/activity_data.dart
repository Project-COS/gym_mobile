import 'package:flutter/material.dart';

enum ActivityTab {
  attendance(
    label: 'Hadir',
    sectionTitle: 'Riwayat Kedatangan',
    countLabel: '12 Data',
    icon: Icons.door_front_door_rounded,
  ),
  personalTrainer(
    label: 'PT',
    sectionTitle: 'Riwayat PT',
    countLabel: '0 Session',
    icon: Icons.how_to_reg_rounded,
  ),
  classSession(
    label: 'Kelas',
    sectionTitle: 'Riwayat Kelas',
    countLabel: '0 Kelas',
    icon: Icons.groups_rounded,
  );

  const ActivityTab({
    required this.label,
    required this.sectionTitle,
    required this.countLabel,
    required this.icon,
  });

  final String label;
  final String sectionTitle;
  final String countLabel;
  final IconData icon;
}

class ActivitySummaryStat {
  const ActivitySummaryStat({required this.value, required this.label});

  final String value;
  final String label;
}

class ActivityHistoryMeta {
  const ActivityHistoryMeta({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class ActivityBookingDetail {
  const ActivityBookingDetail({
    required this.itemId,
    required this.typeCode,
    required this.title,
    required this.schedule,
    required this.duration,
    required this.location,
    required this.bookingCode,
    required this.source,
    required this.qrPayload,
    required this.canShowQr,
  });

  final String itemId;
  final String typeCode;
  final String title;
  final String schedule;
  final String duration;
  final String location;
  final String bookingCode;
  final String source;
  final String qrPayload;
  final bool canShowQr;
}

class ActivityHistoryItem {
  const ActivityHistoryItem({
    required this.tab,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
    required this.metas,
    this.isFeatured = false,
    this.bookingDetail,
  });

  final ActivityTab tab;
  final String title;
  final String subtitle;
  final String status;
  final IconData icon;
  final List<ActivityHistoryMeta> metas;
  final bool isFeatured;
  final ActivityBookingDetail? bookingDetail;
}

const List<ActivitySummaryStat> activitySummaryStats = [
  ActivitySummaryStat(value: '12', label: 'Kedatangan'),
  ActivitySummaryStat(value: '-', label: 'PT Session'),
  ActivitySummaryStat(value: '-', label: 'Kelas'),
];

const Map<ActivityTab, List<String>> activityFilters = {
  ActivityTab.attendance: ['Semua', 'Hari Ini', 'Minggu Ini', 'Bulan Ini'],
  ActivityTab.personalTrainer: ['Semua', 'Selesai'],
  ActivityTab.classSession: ['Semua', 'Selesai'],
};

const List<ActivityHistoryItem> activityHistoryItems = [
  ActivityHistoryItem(
    tab: ActivityTab.attendance,
    title: 'DO GYM Denpasar',
    subtitle: '25 Jan 2026 - Check-in member',
    status: 'Hadir',
    icon: Icons.door_front_door_rounded,
    isFeatured: true,
    metas: [
      ActivityHistoryMeta(
        icon: Icons.location_on_rounded,
        label: 'Branch',
        value: 'Denpasar',
      ),
      ActivityHistoryMeta(
        icon: Icons.login_rounded,
        label: 'Check-in',
        value: '16:48',
      ),
      ActivityHistoryMeta(
        icon: Icons.logout_rounded,
        label: 'Check-out',
        value: '18:20',
      ),
      ActivityHistoryMeta(
        icon: Icons.timer_rounded,
        label: 'Durasi',
        value: '1j 32m',
      ),
    ],
  ),
  ActivityHistoryItem(
    tab: ActivityTab.attendance,
    title: 'DO GYM Renon',
    subtitle: '24 Jan 2026 - Check-in member',
    status: 'Hadir',
    icon: Icons.door_front_door_rounded,
    metas: [
      ActivityHistoryMeta(
        icon: Icons.location_on_rounded,
        label: 'Branch',
        value: 'Renon',
      ),
      ActivityHistoryMeta(
        icon: Icons.login_rounded,
        label: 'Check-in',
        value: '07:12',
      ),
      ActivityHistoryMeta(
        icon: Icons.logout_rounded,
        label: 'Check-out',
        value: '08:36',
      ),
      ActivityHistoryMeta(
        icon: Icons.timer_rounded,
        label: 'Durasi',
        value: '1j 24m',
      ),
    ],
  ),
  ActivityHistoryItem(
    tab: ActivityTab.attendance,
    title: 'DO GYM Sunset Road',
    subtitle: '22 Jan 2026 - Check-in member',
    status: 'Hadir',
    icon: Icons.door_front_door_rounded,
    metas: [
      ActivityHistoryMeta(
        icon: Icons.location_on_rounded,
        label: 'Branch',
        value: 'Sunset Road',
      ),
      ActivityHistoryMeta(
        icon: Icons.login_rounded,
        label: 'Check-in',
        value: '18:05',
      ),
      ActivityHistoryMeta(
        icon: Icons.logout_rounded,
        label: 'Check-out',
        value: '19:30',
      ),
      ActivityHistoryMeta(
        icon: Icons.timer_rounded,
        label: 'Durasi',
        value: '1j 25m',
      ),
    ],
  ),
  ActivityHistoryItem(
    tab: ActivityTab.classSession,
    title: 'Pilates Core Flow',
    subtitle: 'Coach Maya - 24 Jan 2026',
    status: 'Selesai',
    icon: Icons.auto_awesome_rounded,
    isFeatured: true,
    metas: [
      ActivityHistoryMeta(
        icon: Icons.calendar_month_rounded,
        label: 'Tanggal',
        value: '24 Jan',
      ),
      ActivityHistoryMeta(
        icon: Icons.schedule_rounded,
        label: 'Jam',
        value: '18:00',
      ),
      ActivityHistoryMeta(
        icon: Icons.person_rounded,
        label: 'Coach',
        value: 'Maya',
      ),
      ActivityHistoryMeta(
        icon: Icons.location_on_rounded,
        label: 'Branch',
        value: 'Denpasar',
      ),
    ],
  ),
  ActivityHistoryItem(
    tab: ActivityTab.classSession,
    title: 'Zumba Energy',
    subtitle: 'Coach Lita - 23 Jan 2026',
    status: 'Selesai',
    icon: Icons.music_note_rounded,
    metas: [
      ActivityHistoryMeta(
        icon: Icons.calendar_month_rounded,
        label: 'Tanggal',
        value: '23 Jan',
      ),
      ActivityHistoryMeta(
        icon: Icons.schedule_rounded,
        label: 'Jam',
        value: '19:30',
      ),
      ActivityHistoryMeta(
        icon: Icons.person_rounded,
        label: 'Coach',
        value: 'Lita',
      ),
      ActivityHistoryMeta(
        icon: Icons.location_on_rounded,
        label: 'Branch',
        value: 'Renon',
      ),
    ],
  ),
  ActivityHistoryItem(
    tab: ActivityTab.classSession,
    title: 'Yoga Flow',
    subtitle: 'Coach Ayu - 20 Jan 2026',
    status: 'Selesai',
    icon: Icons.eco_rounded,
    metas: [
      ActivityHistoryMeta(
        icon: Icons.calendar_month_rounded,
        label: 'Tanggal',
        value: '20 Jan',
      ),
      ActivityHistoryMeta(
        icon: Icons.schedule_rounded,
        label: 'Jam',
        value: '18:00',
      ),
      ActivityHistoryMeta(
        icon: Icons.person_rounded,
        label: 'Coach',
        value: 'Ayu',
      ),
      ActivityHistoryMeta(
        icon: Icons.location_on_rounded,
        label: 'Branch',
        value: 'Denpasar',
      ),
    ],
  ),
];
