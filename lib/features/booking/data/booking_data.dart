import 'package:flutter/material.dart';

import '../../../core/icons/app_lucide_icons.dart';

enum BookingTab {
  personalTrainer(label: 'PT Session', icon: AppLucideIcons.userPlus),
  classSession(label: 'Kelas', icon: AppLucideIcons.users);

  const BookingTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

enum ClassCategory {
  all(label: 'Semua'),
  pilates(label: 'Pilates'),
  zumba(label: 'Zumba'),
  yoga(label: 'Yoga'),
  hiit(label: 'HIIT');

  const ClassCategory({required this.label});

  final String label;
}

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
  const BookingSlot({required this.day, required this.time});

  final String day;
  final String time;

  String get label => '$day • $time';
}

class BookingBenefit {
  const BookingBenefit({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class PersonalTrainerSession {
  const PersonalTrainerSession({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.branch,
    required this.duration,
    required this.rating,
    required this.specialization,
    required this.location,
    required this.programType,
    required this.role,
    required this.mapQuery,
    required this.coverImageUrl,
    required this.icon,
    required this.slots,
    required this.benefits,
    required this.gallery,
    this.isFeatured = false,
  });

  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String branch;
  final String duration;
  final String rating;
  final String specialization;
  final String location;
  final String programType;
  final String role;
  final String mapQuery;
  final String coverImageUrl;
  final IconData icon;
  final List<BookingSlot> slots;
  final List<BookingBenefit> benefits;
  final List<String> gallery;
  final bool isFeatured;

  String get schedule => slots.first.label;
}

class GroupClassSession {
  const GroupClassSession({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.branch,
    required this.duration,
    required this.slotLabel,
    required this.infoCategory,
    required this.location,
    required this.level,
    required this.coachName,
    required this.coachRole,
    required this.rating,
    required this.mapQuery,
    required this.coverImageUrl,
    required this.slots,
    required this.tags,
    required this.benefits,
    required this.gallery,
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final ClassCategory category;
  final String branch;
  final String duration;
  final String slotLabel;
  final String infoCategory;
  final String location;
  final String level;
  final String coachName;
  final String coachRole;
  final String rating;
  final String mapQuery;
  final String coverImageUrl;
  final List<BookingSlot> slots;
  final List<String> tags;
  final List<BookingBenefit> benefits;
  final List<String> gallery;
  final bool isFeatured;

  String get schedule => slots.first.label;
}

List<BookingDateOption> buildUpcomingBookingDateOptions({
  DateTime? today,
  int dayCount = 6,
}) {
  final DateTime baseDate = today ?? DateTime.now();
  final DateTime normalizedBaseDate = DateTime(
    baseDate.year,
    baseDate.month,
    baseDate.day,
  );

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

const List<PersonalTrainerSession> personalTrainerSessions = [
  PersonalTrainerSession(
    id: 'coach-budi',
    name: 'Coach Budi Santoso',
    subtitle: 'Strength Training • Muscle Building',
    description:
        'Program latihan personal untuk membantu peningkatan massa otot, teknik latihan, dan progres kebugaran yang terukur.',
    branch: 'Denpasar',
    duration: '60 Menit',
    rating: '4.9',
    specialization: 'Strength Training • Muscle Building',
    location: 'DO GYM Denpasar • Strength Area',
    programType: '1-on-1 Coaching • Progress Monitoring',
    role: 'Strength & Muscle Building Specialist',
    mapQuery: 'DO GYM Denpasar',
    coverImageUrl:
        'https://images.unsplash.com/photo-1571019613914-85f342c6a11e?q=80&w=1200&auto=format&fit=crop',
    icon: AppLucideIcons.userPlus,
    slots: [
      BookingSlot(day: 'Hari ini', time: '17:00'),
      BookingSlot(day: 'Hari ini', time: '18:30'),
      BookingSlot(day: 'Besok', time: '07:00'),
      BookingSlot(day: 'Jumat', time: '18:00'),
    ],
    benefits: [
      BookingBenefit(icon: AppLucideIcons.dumbbell, label: 'Program Strength'),
      BookingBenefit(icon: AppLucideIcons.badgeCheck, label: 'Form Check'),
      BookingBenefit(icon: AppLucideIcons.chart, label: 'Progress Tracking'),
      BookingBenefit(icon: AppLucideIcons.badgeCheck, label: 'Private Session'),
    ],
    gallery: [
      'https://images.unsplash.com/photo-1571019613914-85f342c6a11e?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1599058917212-d750089bc07e?q=80&w=1200&auto=format&fit=crop',
    ],
    isFeatured: true,
  ),
  PersonalTrainerSession(
    id: 'coach-raka',
    name: 'Coach Raka Pratama',
    subtitle: 'Fat Loss • Functional Training',
    description:
        'Sesi personal untuk fat loss dan functional training dengan fokus stamina, movement quality, dan conditioning.',
    branch: 'Renon',
    duration: '45 Menit',
    rating: '4.8',
    specialization: 'Fat Loss • Functional Training',
    location: 'DO GYM Renon • Functional Zone',
    programType: 'Functional Movement • Conditioning Plan',
    role: 'Fat Loss & Functional Training',
    mapQuery: 'DO GYM Renon',
    coverImageUrl:
        'https://images.unsplash.com/photo-1599058917212-d750089bc07e?q=80&w=1200&auto=format&fit=crop',
    icon: AppLucideIcons.dumbbell,
    slots: [
      BookingSlot(day: 'Hari ini', time: '19:00'),
      BookingSlot(day: 'Besok', time: '06:30'),
      BookingSlot(day: 'Sabtu', time: '10:00'),
      BookingSlot(day: 'Sabtu', time: '16:00'),
    ],
    benefits: [
      BookingBenefit(icon: AppLucideIcons.flame, label: 'Fat Loss Focus'),
      BookingBenefit(icon: AppLucideIcons.chart, label: 'Conditioning'),
      BookingBenefit(icon: AppLucideIcons.timer, label: '45 Menit Efektif'),
      BookingBenefit(icon: AppLucideIcons.badgeCheck, label: 'Movement Check'),
    ],
    gallery: [
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1599058917212-d750089bc07e?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1571019613914-85f342c6a11e?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1200&auto=format&fit=crop',
    ],
  ),
  PersonalTrainerSession(
    id: 'coach-maya',
    name: 'Coach Maya Sari',
    subtitle: 'Mobility • Posture Correction',
    description:
        'Sesi personal untuk mobility, posture correction, dan recovery agar tubuh lebih stabil, fleksibel, dan nyaman bergerak.',
    branch: 'Sunset Road',
    duration: '60 Menit',
    rating: '4.7',
    specialization: 'Mobility • Posture Correction',
    location: 'DO GYM Sunset Road • Recovery Area',
    programType: 'Mobility Drill • Posture Improvement',
    role: 'Mobility & Posture Correction',
    mapQuery: 'DO GYM Sunset Road Kuta',
    coverImageUrl:
        'https://images.unsplash.com/photo-1518310383802-640c2de311b2?q=80&w=1200&auto=format&fit=crop',
    icon: AppLucideIcons.heart,
    slots: [
      BookingSlot(day: 'Besok', time: '08:00'),
      BookingSlot(day: 'Besok', time: '12:30'),
      BookingSlot(day: 'Jumat', time: '18:00'),
      BookingSlot(day: 'Minggu', time: '09:30'),
    ],
    benefits: [
      BookingBenefit(icon: AppLucideIcons.heart, label: 'Mobility Flow'),
      BookingBenefit(icon: AppLucideIcons.security, label: 'Posture Check'),
      BookingBenefit(icon: AppLucideIcons.chart, label: 'Recovery Drill'),
      BookingBenefit(icon: AppLucideIcons.badgeCheck, label: 'Low Impact'),
    ],
    gallery: [
      'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1518310383802-640c2de311b2?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=1200&auto=format&fit=crop',
    ],
  ),
  PersonalTrainerSession(
    id: 'coach-dika',
    name: 'Coach Dika Aditya',
    subtitle: 'Powerlifting • Strength Program',
    description:
        'Sesi personal powerlifting dan strength program untuk meningkatkan performa angkatan dan kualitas teknik secara aman.',
    branch: 'Sunset Road',
    duration: '75 Menit',
    rating: '4.9',
    specialization: 'Powerlifting • Strength Program',
    location: 'DO GYM Sunset Road • Strength Platform',
    programType: 'Strength Progression • Heavy Lift Review',
    role: 'Powerlifting & Strength Specialist',
    mapQuery: 'DO GYM Sunset Road Kuta',
    coverImageUrl:
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=1200&auto=format&fit=crop',
    icon: AppLucideIcons.chart,
    slots: [
      BookingSlot(day: 'Jumat', time: '20:00'),
      BookingSlot(day: 'Sabtu', time: '11:00'),
      BookingSlot(day: 'Minggu', time: '09:00'),
      BookingSlot(day: 'Minggu', time: '15:00'),
    ],
    benefits: [
      BookingBenefit(
        icon: AppLucideIcons.dumbbell,
        label: 'Heavy Lift Program',
      ),
      BookingBenefit(
        icon: AppLucideIcons.badgeCheck,
        label: 'Technique Review',
      ),
      BookingBenefit(icon: AppLucideIcons.timer, label: '75 Menit'),
      BookingBenefit(icon: AppLucideIcons.security, label: 'Safety First'),
    ],
    gallery: [
      'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1571019613914-85f342c6a11e?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1599058917212-d750089bc07e?q=80&w=1200&auto=format&fit=crop',
    ],
  ),
];
