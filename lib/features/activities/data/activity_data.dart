import 'package:flutter/material.dart';

enum ActivityTab {
  attendance(
    label: 'Hadir',
    sectionTitle: 'Riwayat Kedatangan',
    countLabel: '0 Data',
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

const Map<ActivityTab, List<String>> activityFilters = {
  ActivityTab.attendance: ['Semua', 'Hari Ini', 'Minggu Ini', 'Bulan Ini'],
  ActivityTab.personalTrainer: ['Semua', 'Selesai'],
  ActivityTab.classSession: ['Semua', 'Selesai'],
};

const List<ActivityHistoryItem> activityHistoryItems = [];
