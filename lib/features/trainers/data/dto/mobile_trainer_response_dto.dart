class MobileTrainersResponseDto {
  const MobileTrainersResponseDto({required this.trainers});

  final List<MobileTrainerDto> trainers;

  factory MobileTrainersResponseDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'trainers response');
    final rawTrainers = _readList(data, 'trainers');

    return MobileTrainersResponseDto(
      trainers: rawTrainers
          .map(MobileTrainerDto.fromJson)
          .toList(growable: false),
    );
  }
}

class MobileTrainerDetailResponseDto {
  const MobileTrainerDetailResponseDto({required this.trainer});

  final MobileTrainerDto trainer;

  factory MobileTrainerDetailResponseDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'trainer detail response');

    return MobileTrainerDetailResponseDto(
      trainer: MobileTrainerDto.fromJson(data['trainer']),
    );
  }
}

class MobileTrainerRatingResponseDto {
  const MobileTrainerRatingResponseDto({required this.trainer});

  final MobileTrainerRatingDto trainer;

  factory MobileTrainerRatingResponseDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'trainer rating response');

    return MobileTrainerRatingResponseDto(
      trainer: MobileTrainerRatingDto.fromJson(data['trainer']),
    );
  }
}

class MobileTrainerRatingDto {
  const MobileTrainerRatingDto({required this.id, required this.rating});

  final String id;
  final double? rating;

  factory MobileTrainerRatingDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'trainer rating');

    return MobileTrainerRatingDto(
      id: _readRequiredString(data, 'id'),
      rating: _readOptionalDouble(data, 'rating'),
    );
  }
}

class MobileTrainerDto {
  const MobileTrainerDto({
    required this.id,
    required this.name,
    required this.specialty,
    required this.bio,
    required this.photoUrl,
    required this.rating,
    required this.defaultLocationId,
    required this.defaultLocationName,
    required this.locations,
    required this.schedules,
    required this.images,
    required this.programs,
    required this.canRate,
  });

  final String id;
  final String name;
  final String? specialty;
  final String? bio;
  final String? photoUrl;
  final double? rating;
  final String? defaultLocationId;
  final String? defaultLocationName;
  final List<MobileTrainerLocationDto> locations;
  final List<MobileTrainerScheduleDto> schedules;
  final List<MobileTrainerImageDto> images;
  final List<MobileTrainerProgramDto> programs;
  final bool canRate;

  factory MobileTrainerDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'trainer');

    return MobileTrainerDto(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'name'),
      specialty: _readOptionalString(data, 'specialty'),
      bio: _readOptionalString(data, 'bio'),
      photoUrl: _readOptionalString(data, 'photoUrl'),
      rating: _readOptionalDouble(data, 'rating'),
      defaultLocationId: _readOptionalString(data, 'defaultLocationId'),
      defaultLocationName: _readOptionalString(data, 'defaultLocationName'),
      locations: _readList(
        data,
        'locations',
      ).map(MobileTrainerLocationDto.fromJson).toList(growable: false),
      schedules: _readList(
        data,
        'schedules',
      ).map(MobileTrainerScheduleDto.fromJson).toList(growable: false),
      images: _readList(
        data,
        'images',
      ).map(MobileTrainerImageDto.fromJson).toList(growable: false),
      programs: _readList(
        data,
        'programs',
      ).map(MobileTrainerProgramDto.fromJson).toList(growable: false),
      canRate: data['canRate'] == true,
    );
  }
}

class MobileTrainerLocationDto {
  const MobileTrainerLocationDto({
    required this.id,
    required this.name,
    required this.area,
    required this.address,
    required this.isPrimary,
    required this.sortOrder,
    required this.latitude,
    required this.longitude,
    required this.mapPlaceId,
    required this.mapAddress,
    required this.mapUrls,
  });

  final String id;
  final String name;
  final String? area;
  final String? address;
  final bool isPrimary;
  final int sortOrder;
  final double? latitude;
  final double? longitude;
  final String? mapPlaceId;
  final String? mapAddress;
  final MobileTrainerMapUrlsDto mapUrls;

  factory MobileTrainerLocationDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'trainer location');

    return MobileTrainerLocationDto(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'name'),
      area: _readOptionalString(data, 'area'),
      address: _readOptionalString(data, 'address'),
      isPrimary: data['isPrimary'] == true,
      sortOrder: _readInt(data, 'sortOrder', fallback: 0),
      latitude: _readOptionalDouble(data, 'latitude'),
      longitude: _readOptionalDouble(data, 'longitude'),
      mapPlaceId: _readOptionalString(data, 'mapPlaceId'),
      mapAddress: _readOptionalString(data, 'mapAddress'),
      mapUrls: MobileTrainerMapUrlsDto.fromJson(data['mapUrls']),
    );
  }
}

class MobileTrainerMapUrlsDto {
  const MobileTrainerMapUrlsDto({
    required this.openStreetMap,
    required this.googleMaps,
    required this.googleNavigation,
  });

  final String? openStreetMap;
  final String? googleMaps;
  final String? googleNavigation;

  factory MobileTrainerMapUrlsDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'trainer map URLs');

    return MobileTrainerMapUrlsDto(
      openStreetMap: _readOptionalString(data, 'openStreetMap'),
      googleMaps: _readOptionalString(data, 'googleMaps'),
      googleNavigation: _readOptionalString(data, 'googleNavigation'),
    );
  }
}

class MobileTrainerScheduleDto {
  const MobileTrainerScheduleDto({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.locationId,
    required this.locationName,
  });

  final int? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final String? locationId;
  final String? locationName;

  factory MobileTrainerScheduleDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'trainer schedule');

    return MobileTrainerScheduleDto(
      dayOfWeek: _readOptionalInt(data, 'dayOfWeek'),
      startTime: _readOptionalString(data, 'startTime'),
      endTime: _readOptionalString(data, 'endTime'),
      locationId: _readOptionalString(data, 'locationId'),
      locationName: _readOptionalString(data, 'locationName'),
    );
  }
}

class MobileTrainerImageDto {
  const MobileTrainerImageDto({
    required this.url,
    required this.sortOrder,
    required this.isActive,
  });

  final String url;
  final int sortOrder;
  final bool isActive;

  factory MobileTrainerImageDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'trainer image');

    return MobileTrainerImageDto(
      url: _readRequiredString(data, 'url'),
      sortOrder: _readInt(data, 'sortOrder', fallback: 0),
      isActive: data['isActive'] != false,
    );
  }
}

class MobileTrainerProgramDto {
  const MobileTrainerProgramDto({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.durationMinutes,
    required this.specialty,
    required this.level,
    required this.locationId,
    required this.locationName,
    required this.coverImageUrl,
    required this.benefits,
  });

  final String id;
  final String name;
  final String? subtitle;
  final String? description;
  final int durationMinutes;
  final String? specialty;
  final String? level;
  final String? locationId;
  final String? locationName;
  final String? coverImageUrl;
  final List<MobileTrainerProgramBenefitDto> benefits;

  factory MobileTrainerProgramDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'trainer program');

    return MobileTrainerProgramDto(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'name'),
      subtitle: _readOptionalString(data, 'subtitle'),
      description: _readOptionalString(data, 'description'),
      durationMinutes: _readInt(data, 'durationMinutes', fallback: 60),
      specialty: _readOptionalString(data, 'specialty'),
      level: _readOptionalString(data, 'level'),
      locationId: _readOptionalString(data, 'locationId'),
      locationName: _readOptionalString(data, 'locationName'),
      coverImageUrl: _readOptionalString(data, 'coverImageUrl'),
      benefits: _readList(
        data,
        'benefits',
      ).map(MobileTrainerProgramBenefitDto.fromJson).toList(growable: false),
    );
  }
}

class MobileTrainerProgramBenefitDto {
  const MobileTrainerProgramBenefitDto({
    required this.label,
    required this.iconKey,
  });

  final String label;
  final String? iconKey;

  factory MobileTrainerProgramBenefitDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'trainer program benefit');

    return MobileTrainerProgramBenefitDto(
      label: _readRequiredString(data, 'label'),
      iconKey: _readOptionalString(data, 'iconKey'),
    );
  }
}

Map<String, Object?> _readJsonMap(Object? json, String label) {
  if (json is Map<String, Object?>) {
    return json;
  }

  if (json is Map) {
    return json.map((key, value) => MapEntry(key.toString(), value));
  }

  throw FormatException('Invalid $label data.');
}

List<Object?> _readList(Map<String, Object?> data, String key) {
  final value = data[key];

  if (value is List) {
    return value.cast<Object?>();
  }

  throw FormatException('Invalid $key data.');
}

String _readRequiredString(Map<String, Object?> data, String key) {
  final value = data[key];

  if (value is String && value.trim().isNotEmpty) {
    return value;
  }

  throw FormatException('Invalid $key data.');
}

String? _readOptionalString(Map<String, Object?> data, String key) {
  final value = data[key];

  if (value == null) {
    return null;
  }

  if (value is String) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  throw FormatException('Invalid $key data.');
}

double? _readOptionalDouble(Map<String, Object?> data, String key) {
  final value = data[key];

  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value);
  }

  throw FormatException('Invalid $key data.');
}

int _readInt(Map<String, Object?> data, String key, {required int fallback}) {
  final value = data[key];

  if (value == null) {
    return fallback;
  }

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  throw FormatException('Invalid $key data.');
}

int? _readOptionalInt(Map<String, Object?> data, String key) {
  final value = data[key];

  if (value == null) {
    return null;
  }

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  throw FormatException('Invalid $key data.');
}
