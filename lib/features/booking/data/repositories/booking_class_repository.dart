import '../../../../core/icons/app_lucide_icons.dart';
import '../booking_data.dart';
import '../dto/mobile_class_response_dto.dart';
import '../services/booking_class_api_service.dart';

abstract interface class BookingClassRepository {
  Future<List<GroupClassSession>> fetchClassesForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  });
}

class RemoteBookingClassRepository implements BookingClassRepository {
  const RemoteBookingClassRepository({
    required BookingClassApiService apiService,
  }) : _apiService = apiService;

  final BookingClassApiService _apiService;

  @override
  Future<List<GroupClassSession>> fetchClassesForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    final response = await _apiService.fetchClassesForLocation(
      locationId: locationId,
      startsFrom: startsFrom,
      startsTo: startsTo,
    );

    return response.classes.expand(_mapClassSessions).toList(growable: false);
  }

  Iterable<GroupClassSession> _mapClassSessions(MobileGymClassDto gymClass) {
    final allSlots = gymClass.sessions
        .map(_mapBookingSlot)
        .toList(growable: false);

    return gymClass.sessions.map((session) {
      final selectedSlot = _mapBookingSlot(session);
      final slots = [
        selectedSlot,
        ...allSlots.where((slot) => slot.label != selectedSlot.label),
      ];
      final location = session.location;
      final trainer = session.trainer;
      final categoryName = gymClass.category?.name ?? 'Class';
      final coverImageUrl = _pickCoverImageUrl(gymClass);

      return GroupClassSession(
        id: '${gymClass.id}:${session.id}',
        title: gymClass.name,
        subtitle: '${trainer?.name ?? 'Coach'} - ${selectedSlot.label}',
        description:
            gymClass.description ??
            gymClass.subtitle ??
            'Kelas tersedia untuk member aktif.',
        category: _mapClassCategory(categoryName),
        branch: location?.area ?? location?.name ?? 'Cabang',
        duration: '${gymClass.durationMinutes} Menit',
        slotLabel: session.isFull ? 'Penuh' : '${session.availableSlots} Slot',
        infoCategory: _formatInfoCategory(categoryName, gymClass.level),
        location: _formatClassLocation(location, session.roomName),
        level: gymClass.level ?? 'All Level',
        coachName: trainer?.name ?? 'Coach DO GYM',
        coachRole: trainer?.specialty ?? 'Class Coach',
        rating: trainer?.rating?.toStringAsFixed(1) ?? '-',
        mapQuery: _formatMapQuery(location),
        coverImageUrl: coverImageUrl,
        slots: slots.isEmpty ? [selectedSlot] : slots,
        tags: _mapTags(gymClass, session),
        benefits: _mapBenefits(gymClass.benefits),
        gallery: _mapGallery(gymClass, coverImageUrl),
        isFeatured: session.availableSlots > 0,
      );
    });
  }

  BookingSlot _mapBookingSlot(MobileClassSessionDto session) {
    final startsAt = session.startsAt.toLocal();

    return BookingSlot(
      day: _formatRelativeDay(startsAt),
      time: _formatTime(startsAt),
    );
  }

  String _pickCoverImageUrl(MobileGymClassDto gymClass) {
    return gymClass.coverImageUrl ??
        (gymClass.images.isEmpty
            ? _fallbackClassImageUrl
            : gymClass.images.first.url);
  }

  ClassCategory _mapClassCategory(String name) {
    final normalizedName = name.toLowerCase();

    if (normalizedName.contains('pilates')) {
      return ClassCategory.pilates;
    }
    if (normalizedName.contains('zumba')) {
      return ClassCategory.zumba;
    }
    if (normalizedName.contains('yoga')) {
      return ClassCategory.yoga;
    }
    if (normalizedName.contains('hiit')) {
      return ClassCategory.hiit;
    }

    return ClassCategory.all;
  }

  List<BookingBenefit> _mapBenefits(List<MobileClassBenefitDto> benefits) {
    if (benefits.isEmpty) {
      return const [
        BookingBenefit(icon: AppLucideIcons.users, label: 'Group Class'),
      ];
    }

    return benefits
        .map(
          (benefit) => BookingBenefit(
            icon: AppLucideIcons.resolveGymIcon(
              benefit.iconKey ?? benefit.label,
              fallback: AppLucideIcons.badgeCheck,
            ),
            label: benefit.label,
          ),
        )
        .toList(growable: false);
  }

  List<String> _mapTags(
    MobileGymClassDto gymClass,
    MobileClassSessionDto session,
  ) {
    final tags = <String>[
      if (gymClass.category?.name != null) gymClass.category!.name,
      if (gymClass.level != null) gymClass.level!,
      if (session.roomName != null) session.roomName!,
    ];

    if (tags.isEmpty) {
      return const ['Group Class'];
    }

    return tags.take(3).toList(growable: false);
  }

  List<String> _mapGallery(MobileGymClassDto gymClass, String coverImageUrl) {
    final gallery = [
      coverImageUrl,
      ...gymClass.images.map((image) => image.url),
    ];

    return gallery.toSet().toList(growable: false);
  }

  String _formatInfoCategory(String categoryName, String? level) {
    if (level == null) {
      return categoryName;
    }

    return '$categoryName - $level';
  }

  String _formatClassLocation(
    MobileClassLocationDto? location,
    String? roomName,
  ) {
    final locationName = location?.name ?? 'DO GYM';

    if (roomName == null) {
      return locationName;
    }

    return '$locationName - $roomName';
  }

  String _formatMapQuery(MobileClassLocationDto? location) {
    if (location == null) {
      return 'DO GYM';
    }

    return [location.name, location.address].whereType<String>().join(' ');
  }

  String _formatRelativeDay(DateTime date) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final differenceInDays = dateOnly.difference(todayOnly).inDays;

    if (differenceInDays == 0) {
      return 'Hari ini';
    }
    if (differenceInDays == 1) {
      return 'Besok';
    }

    return _dayNames[date.weekday % 7];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}

const List<String> _dayNames = [
  'Minggu',
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
];

const String _fallbackClassImageUrl =
    'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=1200&auto=format&fit=crop';
