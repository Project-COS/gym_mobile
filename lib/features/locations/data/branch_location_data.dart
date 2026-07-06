import 'package:flutter/material.dart';

// Local filter options used by the location list UI.
enum BranchFilter {
  all(label: 'Semua'),
  nearest(label: 'Terdekat'),
  open(label: 'Buka Sekarang'),
  twentyFourHours(label: '24 Jam');

  const BranchFilter({required this.label});

  final String label;
}

// App-ready branch model consumed by both list and detail screens.
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
    required this.galleryImages,
    required this.facilities,
    required this.schedules,
    required this.trainers,
    this.mapUrl,
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
  final List<BranchGalleryImage> galleryImages;
  final List<BranchFacility> facilities;
  final List<BranchSchedule> schedules;
  final List<BranchTrainer> trainers;
  final String? mapUrl;
  final bool isFeatured;
  final bool isNearest;
  final bool isOpen;
  final bool isTwentyFourHours;

  // Used when opening maps if the API does not provide a direct map URL.
  String get mapQuery => '$name $address';

  // Keep the display phone untouched while preparing a tel: URI friendly value.
  String get dialPhoneNumber => phone.replaceAll(RegExp(r'[\s-]'), '');

  // Search stays local because the current mobile endpoint already returns all branches.
  bool matchesKeyword(String keyword) {
    final String normalizedKeyword = keyword.trim().toLowerCase();

    if (normalizedKeyword.isEmpty) {
      return true;
    }

    return '$name $area $address'.toLowerCase().contains(normalizedKeyword);
  }

  // Filter flags come from repository mapping until backend exposes richer availability.
  bool matchesFilter(BranchFilter filter) {
    return switch (filter) {
      BranchFilter.all => true,
      BranchFilter.nearest => isNearest,
      BranchFilter.open => isOpen,
      BranchFilter.twentyFourHours => isTwentyFourHours,
    };
  }
}

// Gallery metadata keeps accessibility text separate from visible captions.
class BranchGalleryImage {
  const BranchGalleryImage({
    required this.imageUrl,
    required this.semanticLabel,
    this.caption,
  });

  final String imageUrl;
  final String semanticLabel;
  final String? caption;
}

// Icon is app-owned so backend facilities do not need to carry dynamic icons.
class BranchFacility {
  const BranchFacility({required this.icon, required this.name});

  final IconData icon;
  final String name;
}

// Shared schedule row model for operating hours and location class previews.
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

  // 24-hour schedule uses a compact visual suffix in schedule cards.
  String get timeSuffix => time == '24H' ? 'Open' : 'WITA';
}

// Placeholder-ready trainer display model for future location trainer data.
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
