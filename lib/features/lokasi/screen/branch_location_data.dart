import 'package:flutter/material.dart';

enum BranchFilter {
  all(label: 'Semua'),
  nearest(label: 'Terdekat'),
  open(label: 'Buka Sekarang'),
  twentyFourHours(label: '24 Jam');

  const BranchFilter({required this.label});

  final String label;
}

class BranchLocation {
  const BranchLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.area,
    required this.phone,
    required this.hours,
    required this.distance,
    required this.capacity,
    required this.access,
    required this.imageUrl,
    required this.facilities,
    required this.schedules,
    required this.trainers,
    this.isFeatured = false,
    this.isNearest = false,
    this.isOpen = true,
    this.isTwentyFourHours = false,
  });

  final String id;
  final String name;
  final String address;
  final String area;
  final String phone;
  final String hours;
  final String distance;
  final String capacity;
  final String access;
  final String imageUrl;
  final List<BranchFacility> facilities;
  final List<BranchSchedule> schedules;
  final List<BranchTrainer> trainers;
  final bool isFeatured;
  final bool isNearest;
  final bool isOpen;
  final bool isTwentyFourHours;

  String get mapQuery => '$name $address';

  String get dialPhoneNumber => phone.replaceAll(RegExp(r'[\s-]'), '');

  bool matchesKeyword(String keyword) {
    final String normalizedKeyword = keyword.trim().toLowerCase();

    if (normalizedKeyword.isEmpty) {
      return true;
    }

    return '$name $area $address'.toLowerCase().contains(normalizedKeyword);
  }

  bool matchesFilter(BranchFilter filter) {
    return switch (filter) {
      BranchFilter.all => true,
      BranchFilter.nearest => isNearest,
      BranchFilter.open => isOpen,
      BranchFilter.twentyFourHours => isTwentyFourHours,
    };
  }
}

class BranchFacility {
  const BranchFacility({required this.icon, required this.name});

  final IconData icon;
  final String name;
}

class BranchSchedule {
  const BranchSchedule({
    required this.time,
    required this.title,
    required this.meta,
    required this.status,
  });

  final String time;
  final String title;
  final String meta;
  final String status;

  String get timeSuffix => time == '24H' ? 'Open' : 'WITA';
}

class BranchTrainer {
  const BranchTrainer({
    required this.name,
    required this.role,
    required this.rating,
  });

  final String name;
  final String role;
  final String rating;
}

const List<BranchLocation> branchLocations = [
  BranchLocation(
    id: 'denpasar',
    name: 'DO GYM Denpasar',
    address: 'Jl. Gatot Subroto Barat No. 88, Denpasar',
    area: 'Denpasar Gatot Subroto',
    phone: '+62 812-9000-1188',
    hours: '06:00 - 22:00',
    distance: '1.8 km',
    capacity: 'Medium',
    access: 'Premium, Regular, dan Trial Pass',
    imageUrl:
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1200&auto=format&fit=crop',
    isFeatured: true,
    isNearest: true,
    facilities: [
      BranchFacility(icon: Icons.fitness_center_rounded, name: 'Weight Area'),
      BranchFacility(icon: Icons.shower_rounded, name: 'Shower Room'),
      BranchFacility(icon: Icons.local_parking_rounded, name: 'Parking Area'),
      BranchFacility(icon: Icons.groups_rounded, name: 'Class Studio'),
      BranchFacility(icon: Icons.wifi_rounded, name: 'Free WiFi'),
      BranchFacility(icon: Icons.lock_rounded, name: 'Locker'),
    ],
    schedules: [
      BranchSchedule(
        time: '18:00',
        title: 'Yoga Flow Class',
        meta: 'Studio 2 - Coach Maya',
        status: 'Open',
      ),
      BranchSchedule(
        time: '20:00',
        title: 'Open Gym Access',
        meta: 'Strength Area - Premium member',
        status: 'Ready',
      ),
    ],
    trainers: [
      BranchTrainer(
        name: 'Coach Budi',
        role: 'Strength & Muscle Gain',
        rating: '4.9',
      ),
      BranchTrainer(name: 'Coach Maya', role: 'Yoga & Mobility', rating: '4.8'),
    ],
  ),
  BranchLocation(
    id: 'renon',
    name: 'DO GYM Renon',
    address: 'Jl. Raya Puputan No. 21, Renon',
    area: 'Renon Puputan',
    phone: '+62 812-9000-2121',
    hours: '05:30 - 23:00',
    distance: '3.4 km',
    capacity: 'High',
    access: 'Premium dan Regular Membership',
    imageUrl:
        'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?q=80&w=1200&auto=format&fit=crop',
    facilities: [
      BranchFacility(icon: Icons.fitness_center_rounded, name: 'Free Weight'),
      BranchFacility(icon: Icons.groups_rounded, name: 'Class Room'),
      BranchFacility(icon: Icons.wifi_rounded, name: 'Free WiFi'),
      BranchFacility(icon: Icons.lock_rounded, name: 'Locker'),
      BranchFacility(icon: Icons.directions_bike_rounded, name: 'Cardio Zone'),
      BranchFacility(icon: Icons.favorite_rounded, name: 'Recovery Area'),
    ],
    schedules: [
      BranchSchedule(
        time: '17:30',
        title: 'Functional Training',
        meta: 'Studio 1 - Coach Raka',
        status: 'Open',
      ),
      BranchSchedule(
        time: '19:30',
        title: 'HIIT Burn Class',
        meta: 'Main Studio - Coach Wira',
        status: 'Ready',
      ),
    ],
    trainers: [
      BranchTrainer(
        name: 'Coach Raka',
        role: 'Functional Training',
        rating: '4.9',
      ),
      BranchTrainer(name: 'Coach Wira', role: 'HIIT & Fat Loss', rating: '4.7'),
    ],
  ),
  BranchLocation(
    id: 'sunset',
    name: 'DO GYM Sunset Road',
    address: 'Jl. Sunset Road No. 145, Kuta',
    area: 'Sunset Road Kuta',
    phone: '+62 812-9000-1450',
    hours: '24 Jam',
    distance: '6.2 km',
    capacity: 'Large',
    access: 'Premium Access dan All Branch Pass',
    imageUrl:
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=1200&auto=format&fit=crop',
    isTwentyFourHours: true,
    facilities: [
      BranchFacility(icon: Icons.fitness_center_rounded, name: 'Gym Area'),
      BranchFacility(
        icon: Icons.verified_user_rounded,
        name: 'Personal Trainer',
      ),
      BranchFacility(icon: Icons.local_drink_rounded, name: 'Juice Bar'),
      BranchFacility(
        icon: Icons.local_parking_rounded,
        name: 'Basement Parking',
      ),
      BranchFacility(icon: Icons.security_rounded, name: '24H Security'),
      BranchFacility(icon: Icons.shower_rounded, name: 'Shower Room'),
    ],
    schedules: [
      BranchSchedule(
        time: '24H',
        title: 'Open Gym Access',
        meta: 'Full Area - Premium member',
        status: 'Ready',
      ),
      BranchSchedule(
        time: '21:00',
        title: 'Night Strength Club',
        meta: 'Strength Zone - Coach Dika',
        status: 'Open',
      ),
    ],
    trainers: [
      BranchTrainer(
        name: 'Coach Dika',
        role: 'Powerlifting & Strength',
        rating: '4.9',
      ),
      BranchTrainer(
        name: 'Coach Ardi',
        role: 'Body Transformation',
        rating: '4.8',
      ),
    ],
  ),
];
