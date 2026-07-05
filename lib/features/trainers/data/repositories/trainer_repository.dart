import 'package:flutter/widgets.dart';

import '../../../../core/icons/app_lucide_icons.dart';
import '../dto/mobile_trainer_response_dto.dart';
import '../services/trainer_api_service.dart';

abstract interface class TrainerRepository {
  Future<List<TrainerProfile>> fetchTrainers();

  Future<TrainerProfile> fetchTrainerDetail(String trainerId);

  Future<double?> submitTrainerRating({
    required String trainerId,
    required double rating,
  });
}

class RemoteTrainerRepository implements TrainerRepository {
  const RemoteTrainerRepository({required TrainerApiService apiService})
    : _apiService = apiService;

  final TrainerApiService _apiService;

  @override
  Future<List<TrainerProfile>> fetchTrainers() async {
    final response = await _apiService.fetchTrainers();

    return response.trainers.map(_mapTrainer).toList(growable: false);
  }

  @override
  Future<TrainerProfile> fetchTrainerDetail(String trainerId) async {
    final response = await _apiService.fetchTrainerDetail(trainerId);

    return _mapTrainer(response.trainer);
  }

  @override
  Future<double?> submitTrainerRating({
    required String trainerId,
    required double rating,
  }) async {
    final response = await _apiService.submitTrainerRating(
      trainerId: trainerId,
      rating: rating,
    );

    return response.trainer.rating;
  }

  TrainerProfile _mapTrainer(MobileTrainerDto trainer) {
    final primaryLocation = _pickPrimaryLocation(trainer);
    final primaryProgram = trainer.programs.isEmpty
        ? null
        : trainer.programs.first;
    final coverImageUrl = _pickCoverImageUrl(trainer, primaryProgram);
    final gallery = _mapGallery(trainer);
    final benefits = _mapBenefits(primaryProgram);

    return TrainerProfile(
      id: trainer.id,
      name: trainer.name,
      subtitle:
          trainer.specialty ??
          primaryProgram?.subtitle ??
          primaryProgram?.name ??
          'Personal trainer',
      description:
          trainer.bio ??
          primaryProgram?.description ??
          'Trainer ini siap membantu member memahami program latihan dan progres kebugaran.',
      branch: primaryLocation?.area ?? primaryLocation?.name ?? 'Cabang',
      duration: primaryProgram == null
          ? 'Durasi menyesuaikan'
          : '${primaryProgram.durationMinutes} Menit',
      rating: trainer.rating,
      specialization:
          trainer.specialty ?? primaryProgram?.specialty ?? 'Personal training',
      location: _formatLocation(primaryLocation),
      programType: _formatProgramType(primaryProgram),
      role: trainer.specialty ?? primaryProgram?.level ?? 'Personal trainer',
      mapQuery: _formatMapQuery(primaryLocation),
      mapUrl: primaryLocation?.mapUrls.googleMaps,
      coverImageUrl: coverImageUrl,
      schedules: _mapSchedules(trainer.schedules),
      benefits: benefits,
      gallery: gallery,
      programs: trainer.programs.map(_mapProgram).toList(growable: false),
      locations: trainer.locations.map(_mapLocation).toList(growable: false),
      canRate: trainer.canRate,
    );
  }

  MobileTrainerLocationDto? _pickPrimaryLocation(MobileTrainerDto trainer) {
    if (trainer.locations.isEmpty) {
      return null;
    }

    return trainer.locations.firstWhere(
      (location) => location.isPrimary,
      orElse: () => trainer.locations.first,
    );
  }

  String _pickCoverImageUrl(
    MobileTrainerDto trainer,
    MobileTrainerProgramDto? primaryProgram,
  ) {
    return trainer.photoUrl ??
        (trainer.images.isEmpty ? null : trainer.images.first.url) ??
        primaryProgram?.coverImageUrl ??
        _fallbackTrainerImageUrl;
  }

  List<String> _mapGallery(MobileTrainerDto trainer) {
    final seenImageUrls = <String>{};
    final gallery = <String>[];

    for (final image in trainer.images) {
      final imageUrl = image.url.trim();

      if (!image.isActive ||
          imageUrl.isEmpty ||
          seenImageUrls.contains(imageUrl)) {
        continue;
      }

      seenImageUrls.add(imageUrl);
      gallery.add(imageUrl);
    }

    return gallery;
  }

  List<TrainerBenefit> _mapBenefits(MobileTrainerProgramDto? program) {
    final benefits = program?.benefits ?? const [];

    if (benefits.isEmpty) {
      return const [
        TrainerBenefit(icon: AppLucideIcons.dumbbell, label: 'Personal plan'),
        TrainerBenefit(
          icon: AppLucideIcons.badgeCheck,
          label: 'Technique check',
        ),
        TrainerBenefit(icon: AppLucideIcons.chart, label: 'Progress review'),
        TrainerBenefit(icon: AppLucideIcons.timer, label: 'Flexible session'),
      ];
    }

    return benefits
        .map(
          (benefit) => TrainerBenefit(
            icon: AppLucideIcons.resolveGymIcon(
              benefit.iconKey ?? benefit.label,
              fallback: AppLucideIcons.badgeCheck,
            ),
            label: benefit.label,
          ),
        )
        .toList(growable: false);
  }

  List<TrainerSchedule> _mapSchedules(
    List<MobileTrainerScheduleDto> schedules,
  ) {
    if (schedules.isEmpty) {
      return const [
        TrainerSchedule(label: 'Jadwal menyusul', locationName: null),
      ];
    }

    return schedules
        .map((schedule) {
          final dayLabel = _formatDay(schedule.dayOfWeek);
          final timeLabel = _formatScheduleTime(schedule);

          return TrainerSchedule(
            label: timeLabel == null ? dayLabel : '$dayLabel - $timeLabel',
            locationName: schedule.locationName,
            dayOfWeek: schedule.dayOfWeek,
            startTime: schedule.startTime,
            endTime: schedule.endTime,
            locationId: schedule.locationId,
          );
        })
        .toList(growable: false);
  }

  TrainerProgram _mapProgram(MobileTrainerProgramDto program) {
    return TrainerProgram(
      id: program.id,
      name: program.name,
      durationMinutes: program.durationMinutes,
      subtitle: program.subtitle,
      description: program.description,
      duration: '${program.durationMinutes} Menit',
      focus: program.specialty ?? program.level ?? 'Personal training',
      locationId: program.locationId,
      locationName: program.locationName,
      coverImageUrl: program.coverImageUrl,
      benefits: program.benefits
          .map((benefit) => benefit.label)
          .toList(growable: false),
    );
  }

  TrainerLocation _mapLocation(MobileTrainerLocationDto location) {
    return TrainerLocation(
      id: location.id,
      name: location.name,
      area: location.area,
      address: location.address,
      isPrimary: location.isPrimary,
      mapUrl: location.mapUrls.googleMaps,
    );
  }

  String _formatLocation(MobileTrainerLocationDto? location) {
    if (location == null) {
      return 'Cabang belum tersedia';
    }

    final parts = [
      location.name,
      location.area,
    ].whereType<String>().where((value) => value.trim().isNotEmpty);

    return parts.join(' - ');
  }

  String _formatMapQuery(MobileTrainerLocationDto? location) {
    if (location == null) {
      return 'DO GYM';
    }

    return [
      location.name,
      location.address,
      location.area,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');
  }

  String _formatProgramType(MobileTrainerProgramDto? program) {
    if (program == null) {
      return 'Personal training';
    }

    final parts = [
      program.name,
      program.level,
    ].whereType<String>().where((value) => value.trim().isNotEmpty);

    return parts.join(' - ');
  }

  String _formatDay(int? dayOfWeek) {
    if (dayOfWeek == null) {
      return 'Setiap hari';
    }

    return _dayNames[dayOfWeek] ?? 'Jadwal';
  }

  String? _formatScheduleTime(MobileTrainerScheduleDto schedule) {
    if (schedule.startTime == null && schedule.endTime == null) {
      return null;
    }

    if (schedule.startTime != null && schedule.endTime != null) {
      return '${schedule.startTime} - ${schedule.endTime}';
    }

    return schedule.startTime ?? schedule.endTime;
  }
}

class TrainerProfile {
  const TrainerProfile({
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
    required this.mapUrl,
    required this.coverImageUrl,
    required this.schedules,
    required this.benefits,
    required this.gallery,
    required this.programs,
    required this.locations,
    required this.canRate,
  });

  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String branch;
  final String duration;
  final double? rating;
  final String specialization;
  final String location;
  final String programType;
  final String role;
  final String mapQuery;
  final String? mapUrl;
  final String coverImageUrl;
  final List<TrainerSchedule> schedules;
  final List<TrainerBenefit> benefits;
  final List<String> gallery;
  final List<TrainerProgram> programs;
  final List<TrainerLocation> locations;
  final bool canRate;

  String get ratingLabel => rating?.toStringAsFixed(1) ?? 'Baru';

  String get scheduleLabel =>
      schedules.isEmpty ? 'Jadwal menyusul' : schedules.first.label;

  TrainerProfile copyWithRating(double? nextRating) {
    return TrainerProfile(
      id: id,
      name: name,
      subtitle: subtitle,
      description: description,
      branch: branch,
      duration: duration,
      rating: nextRating,
      specialization: specialization,
      location: location,
      programType: programType,
      role: role,
      mapQuery: mapQuery,
      mapUrl: mapUrl,
      coverImageUrl: coverImageUrl,
      schedules: schedules,
      benefits: benefits,
      gallery: gallery,
      programs: programs,
      locations: locations,
      canRate: canRate,
    );
  }
}

class TrainerSchedule {
  const TrainerSchedule({
    required this.label,
    required this.locationName,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.locationId,
  });

  final String label;
  final String? locationName;
  final int? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final String? locationId;
}

class TrainerBenefit {
  const TrainerBenefit({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class TrainerProgram {
  const TrainerProgram({
    required this.id,
    required this.name,
    this.durationMinutes = 60,
    required this.subtitle,
    required this.description,
    required this.duration,
    required this.focus,
    this.locationId,
    required this.locationName,
    required this.coverImageUrl,
    required this.benefits,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final String? subtitle;
  final String? description;
  final String duration;
  final String focus;
  final String? locationId;
  final String? locationName;
  final String? coverImageUrl;
  final List<String> benefits;
}

class TrainerLocation {
  const TrainerLocation({
    required this.id,
    required this.name,
    required this.area,
    required this.address,
    required this.isPrimary,
    required this.mapUrl,
  });

  final String id;
  final String name;
  final String? area;
  final String? address;
  final bool isPrimary;
  final String? mapUrl;
}

const Map<int, String> _dayNames = {
  0: 'Minggu',
  1: 'Senin',
  2: 'Selasa',
  3: 'Rabu',
  4: 'Kamis',
  5: 'Jumat',
  6: 'Sabtu',
};

const String _fallbackTrainerImageUrl =
    'https://images.unsplash.com/photo-1571019613914-85f342c6a11e?q=80&w=1200&auto=format&fit=crop';
