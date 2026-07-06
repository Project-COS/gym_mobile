import '../../../../core/icons/app_lucide_icons.dart';
import '../branch_location_data.dart';
import '../dto/mobile_location_response_dto.dart';
import '../services/location_api_service.dart';

// Repository converts API DTOs into app-ready branch models for presentation.
abstract interface class LocationRepository {
  Future<List<BranchLocation>> fetchLocations();
}

class RemoteLocationRepository implements LocationRepository {
  RemoteLocationRepository({
    required LocationApiService apiService,
    DateTime Function()? now,
  }) : _apiService = apiService,
       _now = now ?? DateTime.now;

  final LocationApiService _apiService;
  final DateTime Function() _now;

  @override
  Future<List<BranchLocation>> fetchLocations() async {
    final response = await _apiService.fetchLocations();

    // Widgets consume BranchLocation only; DTO details should not leak upward.
    return response.locations.map(_mapLocation).toList(growable: false);
  }

  BranchLocation _mapLocation(MobileLocationDto location) {
    final schedules = _mapSchedules(location.schedules);
    final openingStatus = _resolveOpeningStatus(location.schedules, _now());

    // Provide user-facing defaults so partially configured branches still render.
    return BranchLocation(
      id: location.id,
      name: location.name,
      address: location.address ?? 'Alamat belum tersedia',
      area: location.area ?? 'Area belum tersedia',
      phone: location.whatsapp ?? '-',
      hours: _formatOperatingHours(location.schedules),
      distance: _formatDistance(location),
      capacity: location.capacityLabel ?? 'Umum',
      access: 'Membership aktif',
      imageUrl: _pickPrimaryImageUrl(location.images),
      galleryImages: _mapGalleryImages(location),
      facilities: _mapFacilities(location.facilities),
      schedules: schedules,
      trainers: const [],
      mapUrl: location.mapUrls.googleNavigation ?? location.mapUrls.googleMaps,
      isFeatured: location.images.any((image) => image.isPrimary),
      isNearest: false,
      hasKnownOpenStatus: openingStatus.isKnown,
      isOpen: openingStatus.isOpen,
      isTwentyFourHours: _isTwentyFourHours(location.schedules),
    );
  }

  String _pickPrimaryImageUrl(List<MobileLocationImageDto> images) {
    if (images.isEmpty) {
      return _fallbackLocationImageUrl;
    }

    // Admin-selected primary image wins; otherwise use the first media item.
    for (final image in images) {
      if (image.isPrimary) {
        return image.url;
      }
    }

    return images.first.url;
  }

  List<BranchGalleryImage> _mapGalleryImages(MobileLocationDto location) {
    final seenImageUrls = <String>{};
    final galleryImages = <BranchGalleryImage>[];

    for (final image in location.images) {
      final imageUrl = image.url.trim();

      // De-dupe because the primary image can also appear in the gallery list.
      if (imageUrl.isEmpty || seenImageUrls.contains(imageUrl)) {
        continue;
      }

      seenImageUrls.add(imageUrl);
      galleryImages.add(
        BranchGalleryImage(
          imageUrl: imageUrl,
          caption: image.caption,
          semanticLabel:
              image.altText ?? image.caption ?? 'Foto ${location.name}',
        ),
      );
    }

    return galleryImages;
  }

  List<BranchFacility> _mapFacilities(
    List<MobileLocationFacilityDto> facilities,
  ) {
    if (facilities.isEmpty) {
      // Keep the facilities section meaningful before admin data is configured.
      return const [
        BranchFacility(icon: AppLucideIcons.dumbbell, name: 'Gym Area'),
      ];
    }

    return facilities
        .map(
          (facility) => BranchFacility(
            icon: AppLucideIcons.dumbbell,
            name: facility.name,
          ),
        )
        .toList(growable: false);
  }

  List<BranchSchedule> _mapSchedules(
    List<MobileLocationScheduleDto> schedules,
  ) {
    if (schedules.isEmpty) {
      // Fallback schedule keeps detail UI populated without implying exact hours.
      return const [
        BranchSchedule(
          time: 'Ready',
          title: 'Open Gym Access',
          meta: 'Jam operasional belum tersedia',
          status: 'Jadwal',
        ),
      ];
    }

    return schedules
        // The location detail preview shows a short operating-hours summary.
        .take(3)
        .map(
          (schedule) => BranchSchedule(
            time: _formatScheduleStartTime(schedule),
            title: _formatScheduleDay(schedule.dayOfWeek),
            meta: _formatScheduleMeta(schedule),
            status: 'Jadwal',
          ),
        )
        .toList(growable: false);
  }

  String _formatOperatingHours(List<MobileLocationScheduleDto> schedules) {
    if (schedules.isEmpty) {
      return 'Jam belum tersedia';
    }

    if (_isTwentyFourHours(schedules)) {
      return '24 Jam';
    }

    final firstSchedule = schedules.first;
    final startTime = firstSchedule.startTime;
    final endTime = firstSchedule.endTime;

    if (startTime == null || endTime == null) {
      return 'Jam tersedia';
    }

    return '$startTime - $endTime';
  }

  bool _isTwentyFourHours(List<MobileLocationScheduleDto> schedules) {
    return schedules.any((schedule) {
      final startTime = _parseTimeMinutes(schedule.startTime);
      final endTime = _parseTimeMinutes(schedule.endTime);

      return startTime == 0 && (endTime == 1439 || endTime == 1440);
    });
  }

  _OpeningStatus _resolveOpeningStatus(
    List<MobileLocationScheduleDto> schedules,
    DateTime now,
  ) {
    if (schedules.isEmpty) {
      return const _OpeningStatus.unknown();
    }

    final nowMinutes = (now.hour * 60) + now.minute;
    final today = now.weekday % 7;
    final yesterday = (today + 6) % 7;
    var hasConfiguredSchedule = false;

    for (final schedule in schedules) {
      final startMinutes = _parseTimeMinutes(schedule.startTime);
      final endMinutes = _parseTimeMinutes(schedule.endTime);

      if (startMinutes == null || endMinutes == null) {
        continue;
      }

      hasConfiguredSchedule = true;

      final dayOfWeek = schedule.dayOfWeek;
      final appliesEveryDay = dayOfWeek == null;
      final appliesToday = appliesEveryDay || dayOfWeek == today;
      final appliesFromYesterday = !appliesEveryDay && dayOfWeek == yesterday;

      if (startMinutes == 0 &&
          (endMinutes == 0 || endMinutes == 1439 || endMinutes == 1440) &&
          appliesToday) {
        return const _OpeningStatus.open();
      }

      if (endMinutes > startMinutes) {
        if (appliesToday &&
            nowMinutes >= startMinutes &&
            nowMinutes < endMinutes) {
          return const _OpeningStatus.open();
        }
        continue;
      }

      if (endMinutes < startMinutes) {
        if (appliesToday && nowMinutes >= startMinutes) {
          return const _OpeningStatus.open();
        }

        if ((appliesEveryDay || appliesFromYesterday) &&
            nowMinutes < endMinutes) {
          return const _OpeningStatus.open();
        }
      }
    }

    if (!hasConfiguredSchedule) {
      return const _OpeningStatus.unknown();
    }

    return const _OpeningStatus.closed();
  }

  int? _parseTimeMinutes(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    final parts = normalized.split(':');

    if (parts.length < 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 24 ||
        minute < 0 ||
        minute > 59 ||
        (hour == 24 && minute != 0)) {
      return null;
    }

    return (hour * 60) + minute;
  }

  String _formatDistance(MobileLocationDto location) {
    if (location.latitude == null || location.longitude == null) {
      return 'Maps';
    }

    return 'Maps siap';
  }

  String _formatScheduleStartTime(MobileLocationScheduleDto schedule) {
    if (schedule.startTime == null && schedule.endTime == null) {
      return 'Ready';
    }

    if (schedule.startTime == '00:00' &&
        (schedule.endTime == '23:59' || schedule.endTime == '24:00')) {
      // Compact label used by BranchSchedule.timeSuffix.
      return '24H';
    }

    return schedule.startTime ?? 'Ready';
  }

  String _formatScheduleDay(int? dayOfWeek) {
    return switch (dayOfWeek) {
      0 => 'Minggu',
      1 => 'Senin',
      2 => 'Selasa',
      3 => 'Rabu',
      4 => 'Kamis',
      5 => 'Jumat',
      6 => 'Sabtu',
      _ => 'Jam Operasional',
    };
  }

  String _formatScheduleMeta(MobileLocationScheduleDto schedule) {
    final startTime = schedule.startTime;
    final endTime = schedule.endTime;

    if (startTime == null || endTime == null) {
      return 'Akses open gym';
    }

    return '$startTime - $endTime WITA';
  }
}

const String _fallbackLocationImageUrl =
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1200&auto=format&fit=crop';

class _OpeningStatus {
  const _OpeningStatus._({required this.isKnown, required this.isOpen});

  const _OpeningStatus.open() : this._(isKnown: true, isOpen: true);

  const _OpeningStatus.closed() : this._(isKnown: true, isOpen: false);

  const _OpeningStatus.unknown() : this._(isKnown: false, isOpen: false);

  final bool isKnown;
  final bool isOpen;
}
