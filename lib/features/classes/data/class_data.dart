import '../../booking/data/booking_data.dart';

enum ClassCategory {
  all(label: 'Semua'),
  pilates(label: 'Pilates'),
  zumba(label: 'Zumba'),
  yoga(label: 'Yoga'),
  hiit(label: 'HIIT');

  const ClassCategory({required this.label});

  final String label;
}

class ClassCategoryOption {
  const ClassCategoryOption({required this.id, required this.label});

  final String? id;
  final String label;

  bool get isAll => id == null;

  static const all = ClassCategoryOption(id: null, label: 'Semua');
}

class GroupClassSession {
  const GroupClassSession({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    this.categoryId,
    this.categoryName = 'Kelas',
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
  final String? categoryId;
  final String categoryName;
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
