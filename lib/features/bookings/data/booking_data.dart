import 'package:flutter/material.dart';

import '../../../core/icons/app_lucide_icons.dart';

// Booking tabs centralize labels and icons used by the main booking screen.
enum BookingTab {
  personalTrainer(label: 'Sesi PT', icon: AppLucideIcons.userPlus),
  classSession(label: 'Kelas', icon: AppLucideIcons.users);

  const BookingTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

// Date strip option used by class bookings. Dates are normalized to calendar
// days so the selection survives refreshes and midnight rollover.
class BookingDateOption {
  const BookingDateOption({
    required this.date,
    required this.label,
    required this.number,
    required this.dayName,
  });

  final DateTime date;
  final String label;
  final String number;
  final String dayName;
}

class BookingSlot {
  const BookingSlot({
    required this.day,
    required this.time,
    this.sessionId,
    this.startsAt,
    this.endsAt,
    this.branch,
    this.location,
    this.mapQuery,
    this.contactPhoneNumber,
    this.coachName,
    this.coachRole,
  });

  final String day;
  final String time;
  final String? sessionId;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? branch;
  final String? location;
  final String? mapQuery;
  final String? contactPhoneNumber;
  final String? coachName;
  final String? coachRole;

  String get label => '$day - $time';
}

// Shared benefit presentation model used by booking cards that need compact
// icon+label rows.
class BookingBenefit {
  const BookingBenefit({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

List<BookingDateOption> buildUpcomingBookingDateOptions({
  DateTime? today,
  int dayCount = 6,
}) {
  final DateTime baseDate = today ?? DateTime.now();
  final DateTime normalizedBaseDate = normalizeBookingCalendarDate(baseDate);

  // Always build from the start of the selected day to avoid time-of-day drift
  // when the app stays open across midnight.
  return List<BookingDateOption>.generate(dayCount, (index) {
    final DateTime date = normalizedBaseDate.add(Duration(days: index));

    return BookingDateOption(
      date: date,
      label: switch (index) {
        0 => 'Hari ini',
        1 => 'Besok',
        _ => _fullDayNames[date.weekday % 7],
      },
      number: date.day.toString().padLeft(2, '0'),
      dayName: _shortDayNames[date.weekday % 7],
    );
  }, growable: false);
}

DateTime normalizeBookingCalendarDate(DateTime date) {
  // Local calendar dates are enough for the date strip; class API queries do
  // their own UTC conversion in the classes feature.
  return DateTime(date.year, date.month, date.day);
}

bool isSameBookingCalendarDate(DateTime firstDate, DateTime secondDate) {
  return firstDate.year == secondDate.year &&
      firstDate.month == secondDate.month &&
      firstDate.day == secondDate.day;
}

int findBookingDateOptionIndexForDate(
  List<BookingDateOption> options,
  DateTime selectedDate, {
  int fallbackIndex = 0,
}) {
  final normalizedSelectedDate = normalizeBookingCalendarDate(selectedDate);
  final matchingIndex = options.indexWhere(
    (option) => isSameBookingCalendarDate(option.date, normalizedSelectedDate),
  );

  if (matchingIndex >= 0) {
    return matchingIndex;
  }

  if (fallbackIndex >= 0 && fallbackIndex < options.length) {
    return fallbackIndex;
  }

  return 0;
}

String formatBookingMonthLabel(DateTime date) {
  return '${_monthNames[date.month - 1]} ${date.year}';
}

const List<String> _fullDayNames = [
  'Minggu',
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
];

const List<String> _shortDayNames = [
  'Min',
  'Sen',
  'Sel',
  'Rab',
  'Kam',
  'Jum',
  'Sab',
];

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
