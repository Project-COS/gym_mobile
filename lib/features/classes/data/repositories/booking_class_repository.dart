import '../../../../core/icons/app_lucide_icons.dart';
import '../../../bookings/data/booking_data.dart';
import '../class_data.dart';
import '../dto/mobile_class_booking_response_dto.dart';
import '../dto/mobile_class_response_dto.dart';
import '../services/booking_class_api_service.dart';

// Repository exposes app-ready class models and hides mobile API DTO shapes.
abstract interface class BookingClassRepository {
  Future<BookingClassCatalog> fetchClassCatalog({
    String? locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  });

  Future<BookingClassCatalog> fetchClassCatalogForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  });

  Future<List<GroupClassSession>> fetchClassesForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  });

  Future<List<ClassBookingHistoryItem>> fetchClassBookings({
    ClassBookingHistoryFilter filter = ClassBookingHistoryFilter.upcoming,
  });

  Future<ClassBookingConfirmation> createClassBooking({
    required String classSessionId,
    String? notes,
  });
}

class RemoteBookingClassRepository implements BookingClassRepository {
  const RemoteBookingClassRepository({
    required BookingClassApiService apiService,
  }) : _apiService = apiService;

  final BookingClassApiService _apiService;

  @override
  Future<BookingClassCatalog> fetchClassCatalog({
    String? locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    final response = await _apiService.fetchClasses(
      locationId: locationId,
      startsFrom: startsFrom,
      startsTo: startsTo,
    );

    return _mapClassCatalog(response);
  }

  @override
  Future<BookingClassCatalog> fetchClassCatalogForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    return fetchClassCatalog(
      locationId: locationId,
      startsFrom: startsFrom,
      startsTo: startsTo,
    );
  }

  @override
  Future<List<GroupClassSession>> fetchClassesForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    final catalog = await fetchClassCatalogForLocation(
      locationId: locationId,
      startsFrom: startsFrom,
      startsTo: startsTo,
    );

    return catalog.sessions;
  }

  @override
  Future<List<ClassBookingHistoryItem>> fetchClassBookings({
    ClassBookingHistoryFilter filter = ClassBookingHistoryFilter.upcoming,
  }) async {
    // The mobile dashboard consumes a compact first page for each history tab.
    final response = await _apiService.fetchBookings(
      status: filter.queryValue,
      pageSize: 50,
    );

    return response.bookings
        .map(_mapClassBookingHistoryItem)
        .toList(growable: false);
  }

  @override
  Future<ClassBookingConfirmation> createClassBooking({
    required String classSessionId,
    String? notes,
  }) async {
    final response = await _apiService.createClassBooking(
      classSessionId: classSessionId,
      notes: notes,
    );

    return _mapClassBookingConfirmation(response.booking);
  }

  BookingClassCatalog _mapClassCatalog(MobileClassesResponseDto response) {
    // Flatten parent classes into card models because each card carries its
    // own available slots and display summary.
    return BookingClassCatalog(
      categories: response.categories
          .map(_mapClassCategoryOption)
          .toList(growable: false),
      sessions: response.classes
          .expand(_mapClassSessions)
          .toList(growable: false),
    );
  }

  Iterable<GroupClassSession> _mapClassSessions(MobileGymClassDto gymClass) {
    final allSlots = gymClass.sessions
        .map(_mapBookingSlot)
        .toList(growable: false);

    if (gymClass.sessions.isEmpty) {
      return const [];
    }

    // Prefer an available session for headline data so cards highlight a
    // bookable coach/location when at least one slot is open.
    final primarySession = gymClass.sessions.firstWhere(
      (session) => session.availableSlots > 0,
      orElse: () => gymClass.sessions.first,
    );
    final primarySlot = _mapBookingSlot(primarySession);
    final primaryLocation = primarySession.location;
    final primaryTrainer = primarySession.trainer;
    final categoryName = gymClass.category?.name ?? 'Class';
    final categoryId = gymClass.category?.id;
    final coverImageUrl = _pickCoverImageUrl(gymClass);

    return [
      GroupClassSession(
        id: gymClass.id,
        companyLogoUrl: gymClass.companyLogoUrl,
        title: gymClass.name,
        subtitle: _formatClassSubtitle(gymClass.sessions, primarySlot),
        description:
            gymClass.description ??
            gymClass.subtitle ??
            'Kelas tersedia untuk member aktif.',
        category: _mapClassCategory(categoryName),
        categoryId: categoryId,
        categoryName: categoryName,
        branch: _formatBranchSummary(gymClass.sessions),
        duration: '${gymClass.durationMinutes} Menit',
        slotLabel: _formatAvailableSlotSummary(gymClass.sessions),
        infoCategory: _formatInfoCategory(categoryName, gymClass.level),
        location: _formatLocationSummary(gymClass.sessions),
        contactPhoneNumber: _contactNumberForClassSession(primarySession),
        level: gymClass.level ?? 'All Level',
        coachName: _formatCoachNameSummary(gymClass.sessions),
        coachRole: _formatCoachRoleSummary(gymClass.sessions),
        rating: primaryTrainer?.rating?.toStringAsFixed(1) ?? '-',
        mapQuery: _formatMapQuery(primaryLocation),
        coverImageUrl: coverImageUrl,
        slots: allSlots,
        tags: _mapTags(gymClass, primarySession),
        benefits: _mapBenefits(gymClass.benefits),
        gallery: _mapGallery(gymClass, coverImageUrl),
        isFeatured: gymClass.sessions.any(
          (session) => session.availableSlots > 0,
        ),
      ),
    ];
  }

  ClassCategoryOption _mapClassCategoryOption(MobileClassCategoryDto category) {
    return ClassCategoryOption(id: category.id, label: category.name);
  }

  BookingSlot _mapBookingSlot(MobileClassSessionDto session) {
    final startsAt = session.startsAt.toLocal();

    // BookingSlot is shared with the bookings feature, so class-specific API
    // fields are adapted here before reaching widgets.
    return BookingSlot(
      day: _formatRelativeDay(startsAt),
      time: _formatTime(startsAt),
      sessionId: session.id,
      startsAt: session.startsAt,
      endsAt: session.endsAt,
      branch: session.location?.area ?? session.location?.name,
      location: _formatClassLocation(session.location, session.roomName),
      mapQuery: _formatMapQuery(session.location),
      contactPhoneNumber: _contactNumberForClassSession(session),
      coachName: session.trainer?.name,
      coachRole: session.trainer?.specialty,
    );
  }

  ClassBookingConfirmation _mapClassBookingConfirmation(
    MobileClassBookingDto booking,
  ) {
    final durationMinutes =
        booking.gymClass?.durationMinutes ??
        booking.endsAt.difference(booking.startsAt).inMinutes;

    return ClassBookingConfirmation(
      id: booking.id,
      bookingCode: booking.bookingCode,
      qrPayload: booking.qrPayload,
      title: booking.gymClass?.name ?? booking.className,
      schedule: _formatSchedule(booking.startsAt),
      duration: _formatDuration(durationMinutes),
      location: _formatBookingLocation(booking.location, booking.session),
    );
  }

  ClassBookingHistoryItem _mapClassBookingHistoryItem(
    MobileClassBookingDto booking,
  ) {
    final durationMinutes =
        booking.gymClass?.durationMinutes ??
        booking.endsAt.difference(booking.startsAt).inMinutes;

    return ClassBookingHistoryItem(
      id: booking.id,
      bookingCode: booking.bookingCode,
      qrPayload: booking.qrPayload,
      title: booking.gymClass?.name ?? booking.className,
      trainerName: booking.trainer.name,
      schedule: _formatSchedule(booking.startsAt),
      duration: _formatDuration(durationMinutes),
      location: _formatBookingLocation(booking.location, booking.session),
      status: booking.status,
      source: booking.source,
      // QR remains visible only while the booking can still be presented at check-in.
      canShowQr: booking.status == 'REQUESTED' || booking.status == 'SCHEDULED',
    );
  }

  String _pickCoverImageUrl(MobileGymClassDto gymClass) {
    // Prefer CMS cover image, then gallery, then a stable fallback image.
    return gymClass.coverImageUrl ??
        (gymClass.images.isEmpty
            ? _fallbackClassImageUrl
            : gymClass.images.first.url);
  }

  ClassCategory _mapClassCategory(String name) {
    // Preserve existing local styling enum while API categories remain dynamic.
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
      // Keep the detail screen informative even before benefits are configured.
      return const [
        BookingBenefit(icon: AppLucideIcons.users, label: 'Group Class'),
      ];
    }

    return benefits
        .map(
          (benefit) => BookingBenefit(
            icon: AppLucideIcons.badgeCheck,
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

    // De-dupe because the cover can also be included in the image collection.
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

  String? _contactNumberForClassSession(MobileClassSessionDto session) {
    return session.trainer?.phone ?? session.location?.whatsapp;
  }

  String _formatClassSubtitle(
    List<MobileClassSessionDto> sessions,
    BookingSlot primarySlot,
  ) {
    if (sessions.length == 1) {
      return '${primarySlot.coachName ?? 'Coach'} - ${primarySlot.label}';
    }

    return '${sessions.length} pilihan jadwal - ${_formatBranchSummary(sessions)}';
  }

  String _formatAvailableSlotSummary(List<MobileClassSessionDto> sessions) {
    final availableSlots = sessions.fold<int>(
      0,
      (total, session) => total + session.availableSlots,
    );

    if (availableSlots <= 0) {
      return 'Penuh';
    }

    return '$availableSlots Slot';
  }

  String _formatBranchSummary(List<MobileClassSessionDto> sessions) {
    final branches = _uniqueSessionValues(
      sessions,
      (session) => session.location?.area ?? session.location?.name,
    );

    if (branches.isEmpty) {
      return 'Semua Cabang';
    }

    if (branches.length == 1) {
      return branches.first;
    }

    return '${branches.length} Cabang';
  }

  String _formatLocationSummary(List<MobileClassSessionDto> sessions) {
    final locations = _uniqueSessionValues(
      sessions,
      (session) => _formatClassLocation(session.location, session.roomName),
    );

    if (locations.isEmpty) {
      return 'Lokasi akan dikonfirmasi';
    }

    if (locations.length == 1) {
      return locations.first;
    }

    return '${locations.length} lokasi tersedia';
  }

  String _formatCoachNameSummary(List<MobileClassSessionDto> sessions) {
    final coachNames = _uniqueSessionValues(
      sessions,
      (session) => session.trainer?.name,
    );

    if (coachNames.isEmpty) {
      return 'Coach DO GYM';
    }

    if (coachNames.length == 1) {
      return coachNames.first;
    }

    return 'Beragam Coach';
  }

  String _formatCoachRoleSummary(List<MobileClassSessionDto> sessions) {
    final coachRoles = _uniqueSessionValues(
      sessions,
      (session) => session.trainer?.specialty,
    );

    if (coachRoles.isEmpty || coachRoles.length > 1) {
      return 'Class Coach';
    }

    return coachRoles.first;
  }

  String _formatDuration(int durationMinutes) {
    if (durationMinutes <= 0) {
      return 'Durasi menyesuaikan';
    }

    return '$durationMinutes Menit';
  }

  String _formatSchedule(DateTime startsAt) {
    final localDate = startsAt.toLocal();
    final dayName = _dayNames[localDate.weekday % 7];
    final monthName = _monthNames[localDate.month - 1];
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$dayName, ${localDate.day} $monthName $hour:$minute';
  }

  String _formatBookingLocation(
    MobileClassBookingLocationDto? location,
    MobileClassBookingSessionDto? session,
  ) {
    if (location == null) {
      return 'Lokasi akan dikonfirmasi';
    }

    final parts = [
      location.name,
      session?.roomName ?? location.area,
    ].whereType<String>().where((value) => value.trim().isNotEmpty);

    return parts.join(' - ');
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

List<String> _uniqueSessionValues(
  List<MobileClassSessionDto> sessions,
  String? Function(MobileClassSessionDto session) selector,
) {
  // Used by summary labels so multiple sessions do not repeat the same branch,
  // room, or coach in compact card text.
  return sessions
      .map(selector)
      .whereType<String>()
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList(growable: false);
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

const String _fallbackClassImageUrl =
    'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=1200&auto=format&fit=crop';

class BookingClassCatalog {
  const BookingClassCatalog({required this.categories, required this.sessions});

  final List<ClassCategoryOption> categories;
  final List<GroupClassSession> sessions;
}

class ClassBookingConfirmation {
  const ClassBookingConfirmation({
    required this.id,
    required this.bookingCode,
    required this.qrPayload,
    required this.title,
    required this.schedule,
    required this.duration,
    required this.location,
  });

  final String id;
  final String bookingCode;
  final String qrPayload;
  final String title;
  final String schedule;
  final String duration;
  final String location;
}

enum ClassBookingHistoryFilter {
  upcoming('upcoming'),
  history('history'),
  all('all');

  const ClassBookingHistoryFilter(this.queryValue);

  // Must stay aligned with the mobile class booking history endpoint filters.
  final String queryValue;
}

class ClassBookingHistoryItem {
  const ClassBookingHistoryItem({
    required this.id,
    required this.bookingCode,
    required this.qrPayload,
    required this.title,
    required this.trainerName,
    required this.schedule,
    required this.duration,
    required this.location,
    required this.status,
    required this.source,
    required this.canShowQr,
  });

  final String id;
  final String bookingCode;
  final String qrPayload;
  final String title;
  final String trainerName;
  final String schedule;
  final String duration;
  final String location;
  final String status;
  final String source;
  final bool canShowQr;
}
