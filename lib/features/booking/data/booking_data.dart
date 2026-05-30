import 'package:flutter/material.dart';

enum BookingTab {
  personalTrainer(label: 'PT Session', icon: Icons.person_add_alt_1_rounded),
  classSession(label: 'Kelas', icon: Icons.groups_rounded);

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
    required this.label,
    required this.number,
    required this.dayName,
  });

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

const List<BookingDateOption> bookingDateOptions = [
  BookingDateOption(label: 'Hari ini', number: '25', dayName: 'Min'),
  BookingDateOption(label: 'Besok', number: '26', dayName: 'Sen'),
  BookingDateOption(label: 'Selasa', number: '27', dayName: 'Sel'),
  BookingDateOption(label: 'Rabu', number: '28', dayName: 'Rab'),
  BookingDateOption(label: 'Kamis', number: '29', dayName: 'Kam'),
  BookingDateOption(label: 'Jumat', number: '30', dayName: 'Jum'),
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
    icon: Icons.person_add_alt_1_rounded,
    slots: [
      BookingSlot(day: 'Hari ini', time: '17:00'),
      BookingSlot(day: 'Hari ini', time: '18:30'),
      BookingSlot(day: 'Besok', time: '07:00'),
      BookingSlot(day: 'Jumat', time: '18:00'),
    ],
    benefits: [
      BookingBenefit(
        icon: Icons.fitness_center_rounded,
        label: 'Program Strength',
      ),
      BookingBenefit(icon: Icons.fact_check_rounded, label: 'Form Check'),
      BookingBenefit(
        icon: Icons.show_chart_rounded,
        label: 'Progress Tracking',
      ),
      BookingBenefit(icon: Icons.verified_rounded, label: 'Private Session'),
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
    icon: Icons.fitness_center_rounded,
    slots: [
      BookingSlot(day: 'Hari ini', time: '19:00'),
      BookingSlot(day: 'Besok', time: '06:30'),
      BookingSlot(day: 'Sabtu', time: '10:00'),
      BookingSlot(day: 'Sabtu', time: '16:00'),
    ],
    benefits: [
      BookingBenefit(
        icon: Icons.local_fire_department_rounded,
        label: 'Fat Loss Focus',
      ),
      BookingBenefit(icon: Icons.show_chart_rounded, label: 'Conditioning'),
      BookingBenefit(icon: Icons.timer_rounded, label: '45 Menit Efektif'),
      BookingBenefit(icon: Icons.verified_rounded, label: 'Movement Check'),
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
    icon: Icons.favorite_rounded,
    slots: [
      BookingSlot(day: 'Besok', time: '08:00'),
      BookingSlot(day: 'Besok', time: '12:30'),
      BookingSlot(day: 'Jumat', time: '18:00'),
      BookingSlot(day: 'Minggu', time: '09:30'),
    ],
    benefits: [
      BookingBenefit(icon: Icons.favorite_rounded, label: 'Mobility Flow'),
      BookingBenefit(icon: Icons.verified_user_rounded, label: 'Posture Check'),
      BookingBenefit(icon: Icons.show_chart_rounded, label: 'Recovery Drill'),
      BookingBenefit(icon: Icons.verified_rounded, label: 'Low Impact'),
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
    icon: Icons.show_chart_rounded,
    slots: [
      BookingSlot(day: 'Jumat', time: '20:00'),
      BookingSlot(day: 'Sabtu', time: '11:00'),
      BookingSlot(day: 'Minggu', time: '09:00'),
      BookingSlot(day: 'Minggu', time: '15:00'),
    ],
    benefits: [
      BookingBenefit(
        icon: Icons.fitness_center_rounded,
        label: 'Heavy Lift Program',
      ),
      BookingBenefit(icon: Icons.fact_check_rounded, label: 'Technique Review'),
      BookingBenefit(icon: Icons.timer_rounded, label: '75 Menit'),
      BookingBenefit(icon: Icons.verified_user_rounded, label: 'Safety First'),
    ],
    gallery: [
      'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1571019613914-85f342c6a11e?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1599058917212-d750089bc07e?q=80&w=1200&auto=format&fit=crop',
    ],
  ),
];

const List<GroupClassSession> groupClassSessions = [
  GroupClassSession(
    id: 'pilates-core-flow',
    title: 'Pilates Core Flow',
    subtitle: 'Coach Maya • Hari ini 18:00',
    description:
        'Kelas untuk meningkatkan kekuatan core, stabilitas, dan kontrol gerak dengan pendekatan low impact yang nyaman.',
    category: ClassCategory.pilates,
    branch: 'Denpasar',
    duration: '50 Menit',
    slotLabel: '8 Slot',
    infoCategory: 'Pilates • Beginner Friendly',
    location: 'DO GYM Denpasar • Mat Area',
    level: 'All Level • Low Impact',
    coachName: 'Coach Maya',
    coachRole: 'Pilates & Mobility Specialist',
    rating: '4.8',
    mapQuery: 'DO GYM Denpasar',
    coverImageUrl:
        'https://media.istockphoto.com/id/1181682650/photo/pretty-patient-sitting-on-the-blue-mat-in-the-gym-and-training-with-the-ball.webp?a=1&b=1&s=612x612&w=0&k=20&c=H3bNhMpSuqa0Loxl0g2SWoTgHtrT-1rgUzpdtekqvpQ=',
    slots: [
      BookingSlot(day: 'Hari ini', time: '18:00'),
      BookingSlot(day: 'Besok', time: '08:00'),
      BookingSlot(day: 'Rabu', time: '18:00'),
      BookingSlot(day: 'Jumat', time: '17:30'),
    ],
    tags: ['Beginner Friendly', 'Mat Area', 'Low Impact'],
    benefits: [
      BookingBenefit(icon: Icons.auto_awesome_rounded, label: 'Core Control'),
      BookingBenefit(icon: Icons.favorite_rounded, label: 'Low Impact'),
      BookingBenefit(icon: Icons.groups_rounded, label: 'Group Class'),
      BookingBenefit(icon: Icons.verified_rounded, label: 'Beginner Friendly'),
    ],
    gallery: [
      'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1518310383802-640c2de311b2?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1599058917212-d750089bc07e?q=80&w=1200&auto=format&fit=crop',
    ],
    isFeatured: true,
  ),
  GroupClassSession(
    id: 'zumba-energy',
    title: 'Zumba Energy',
    subtitle: 'Coach Lita • Hari ini 19:30',
    description:
        'Kelas cardio dance penuh energi untuk membakar kalori, menjaga mood, dan membuat sesi latihan terasa fun.',
    category: ClassCategory.zumba,
    branch: 'Renon',
    duration: '45 Menit',
    slotLabel: '12 Slot',
    infoCategory: 'Zumba • Cardio Dance',
    location: 'DO GYM Renon • Studio 1',
    level: 'All Level • High Energy',
    coachName: 'Coach Lita',
    coachRole: 'Dance Cardio Coach',
    rating: '4.8',
    mapQuery: 'DO GYM Renon',
    coverImageUrl:
        'https://images.unsplash.com/photo-1524594152303-9fd13543fe6e?q=80&w=1200&auto=format&fit=crop',
    slots: [
      BookingSlot(day: 'Hari ini', time: '19:30'),
      BookingSlot(day: 'Besok', time: '18:30'),
      BookingSlot(day: 'Kamis', time: '19:30'),
      BookingSlot(day: 'Sabtu', time: '16:00'),
    ],
    tags: ['Cardio Dance', 'High Energy', 'All Level'],
    benefits: [
      BookingBenefit(icon: Icons.music_note_rounded, label: 'Cardio Dance'),
      BookingBenefit(
        icon: Icons.local_fire_department_rounded,
        label: 'Burn Calories',
      ),
      BookingBenefit(icon: Icons.groups_rounded, label: 'All Level'),
      BookingBenefit(icon: Icons.auto_awesome_rounded, label: 'High Energy'),
    ],
    gallery: [
      'https://images.unsplash.com/photo-1524594152303-9fd13543fe6e?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1571019613914-85f342c6a11e?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1599058917212-d750089bc07e?q=80&w=1200&auto=format&fit=crop',
    ],
  ),
  GroupClassSession(
    id: 'hiit-burn-class',
    title: 'HIIT Burn Class',
    subtitle: 'Coach Raka • Besok 07:00',
    description:
        'Kelas interval intens untuk membakar kalori, melatih endurance, dan meningkatkan kebugaran tubuh secara cepat.',
    category: ClassCategory.hiit,
    branch: 'Sunset Road',
    duration: '40 Menit',
    slotLabel: '5 Slot',
    infoCategory: 'HIIT • Fat Burn',
    location: 'DO GYM Sunset Road • Conditioning Area',
    level: 'Intermediate • High Intensity',
    coachName: 'Coach Raka',
    coachRole: 'HIIT & Fat Loss Coach',
    rating: '4.8',
    mapQuery: 'DO GYM Sunset Road Kuta',
    coverImageUrl:
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=1200&auto=format&fit=crop',
    slots: [
      BookingSlot(day: 'Besok', time: '07:00'),
      BookingSlot(day: 'Besok', time: '19:00'),
      BookingSlot(day: 'Jumat', time: '06:30'),
      BookingSlot(day: 'Sabtu', time: '08:30'),
    ],
    tags: ['Fat Burn', 'High Intensity', 'Strength'],
    benefits: [
      BookingBenefit(
        icon: Icons.local_fire_department_rounded,
        label: 'Fat Burn',
      ),
      BookingBenefit(icon: Icons.show_chart_rounded, label: 'High Intensity'),
      BookingBenefit(icon: Icons.timer_rounded, label: '40 Menit'),
      BookingBenefit(
        icon: Icons.fitness_center_rounded,
        label: 'Strength Combo',
      ),
    ],
    gallery: [
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1599058917212-d750089bc07e?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1571019613914-85f342c6a11e?q=80&w=1200&auto=format&fit=crop',
    ],
  ),
  GroupClassSession(
    id: 'yoga-flow',
    title: 'Yoga Flow',
    subtitle: 'Coach Ayu • Jumat 18:00',
    description:
        'Kelas untuk fleksibilitas, kontrol napas, relaksasi, dan recovery tubuh dengan alur gerakan yang nyaman.',
    category: ClassCategory.yoga,
    branch: 'Denpasar',
    duration: '60 Menit',
    slotLabel: '10 Slot',
    infoCategory: 'Yoga • Recovery',
    location: 'DO GYM Denpasar • Studio 2',
    level: 'All Level • Relaxing Session',
    coachName: 'Coach Ayu',
    coachRole: 'Yoga & Breathwork Coach',
    rating: '4.9',
    mapQuery: 'DO GYM Denpasar',
    coverImageUrl:
        'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=1200&auto=format&fit=crop',
    slots: [
      BookingSlot(day: 'Jumat', time: '18:00'),
      BookingSlot(day: 'Sabtu', time: '07:30'),
      BookingSlot(day: 'Minggu', time: '08:00'),
      BookingSlot(day: 'Senin', time: '18:00'),
    ],
    tags: ['Flexibility', 'Relax', 'All Level'],
    benefits: [
      BookingBenefit(icon: Icons.eco_rounded, label: 'Flexibility'),
      BookingBenefit(icon: Icons.favorite_rounded, label: 'Recovery'),
      BookingBenefit(icon: Icons.show_chart_rounded, label: 'Mobility'),
      BookingBenefit(icon: Icons.verified_user_rounded, label: 'All Level'),
    ],
    gallery: [
      'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1518310383802-640c2de311b2?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1506629905607-d9bb5b8fe0d0?q=80&w=1200&auto=format&fit=crop',
    ],
  ),
];
