import '../../../../core/icons/app_lucide_icons.dart';
import '../branch_location_data.dart';
import '../dto/mobile_location_response_dto.dart';
import '../services/location_api_service.dart';

abstract interface class LocationRepository {
  Future<List<BranchLocation>> fetchLocations();
}

class RemoteLocationRepository implements LocationRepository {
  const RemoteLocationRepository({required LocationApiService apiService})
    : _apiService = apiService;

  final LocationApiService _apiService;

  @override
  Future<List<BranchLocation>> fetchLocations() async {
    final response = await _apiService.fetchLocations();

    return response.locations.map(_mapLocation).toList(growable: false);
  }

  BranchLocation _mapLocation(MobileLocationDto location) {
    final schedules = _mapSchedules(location.schedules);

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
      isOpen: true,
      isTwentyFourHours: _isTwentyFourHours(location.schedules),
    );
  }

  String _pickPrimaryImageUrl(List<MobileLocationImageDto> images) {
    if (images.isEmpty) {
      return _fallbackLocationImageUrl;
    }

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
      return const [
        BranchFacility(icon: AppLucideIcons.dumbbell, name: 'Gym Area'),
      ];
    }

    return facilities
        .map(
          (facility) => BranchFacility(
            icon: AppLucideIcons.resolveGymIcon(
              facility.iconKey ?? facility.name,
            ),
            name: facility.name,
          ),
        )
        .toList(growable: false);
  }

  List<BranchSchedule> _mapSchedules(
    List<MobileLocationScheduleDto> schedules,
  ) {
    if (schedules.isEmpty) {
      return const [
        BranchSchedule(
          time: 'Ready',
          title: 'Open Gym Access',
          meta: 'Jam operasional belum tersedia',
          status: 'Open',
        ),
      ];
    }

    return schedules
        .take(3)
        .map(
          (schedule) => BranchSchedule(
            time: _formatScheduleStartTime(schedule),
            title: _formatScheduleDay(schedule.dayOfWeek),
            meta: _formatScheduleMeta(schedule),
            status: 'Open',
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
      final startTime = schedule.startTime?.trim();
      final endTime = schedule.endTime?.trim();

      return startTime == '00:00' && (endTime == '23:59' || endTime == '24:00');
    });
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
      return '24H';
    }

    return schedule.startTime ?? 'Open';
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
      return 'Open gym access';
    }

    return '$startTime - $endTime WITA';
  }
}

const String _fallbackLocationImageUrl =
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1200&auto=format&fit=crop';
