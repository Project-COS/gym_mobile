class MobileClassesResponseDto {
  const MobileClassesResponseDto({
    required this.categories,
    required this.classes,
    required this.range,
  });

  final List<MobileClassCategoryDto> categories;
  final List<MobileGymClassDto> classes;
  final MobileClassRangeDto range;

  factory MobileClassesResponseDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'classes response');

    return MobileClassesResponseDto(
      categories: _readList(
        data,
        'categories',
      ).map(MobileClassCategoryDto.fromJson).toList(growable: false),
      classes: _readList(
        data,
        'classes',
      ).map(MobileGymClassDto.fromJson).toList(growable: false),
      range: MobileClassRangeDto.fromJson(data['range']),
    );
  }
}

class MobileClassRangeDto {
  const MobileClassRangeDto({required this.startsFrom, required this.startsTo});

  final DateTime startsFrom;
  final DateTime startsTo;

  factory MobileClassRangeDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'class range');

    return MobileClassRangeDto(
      startsFrom: _readRequiredDateTime(data, 'startsFrom'),
      startsTo: _readRequiredDateTime(data, 'startsTo'),
    );
  }
}

class MobileClassCategoryDto {
  const MobileClassCategoryDto({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.iconKey,
  });

  final String id;
  final String name;
  final String? colorHex;
  final String? iconKey;

  factory MobileClassCategoryDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'class category');

    return MobileClassCategoryDto(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'name'),
      colorHex: _readOptionalString(data, 'colorHex'),
      iconKey: _readOptionalString(data, 'iconKey'),
    );
  }
}

class MobileGymClassDto {
  const MobileGymClassDto({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.level,
    required this.durationMinutes,
    required this.defaultCapacity,
    required this.coverImageUrl,
    required this.category,
    required this.images,
    required this.benefits,
    required this.sessions,
  });

  final String id;
  final String name;
  final String? subtitle;
  final String? description;
  final String? level;
  final int durationMinutes;
  final int? defaultCapacity;
  final String? coverImageUrl;
  final MobileClassCategoryDto? category;
  final List<MobileClassImageDto> images;
  final List<MobileClassBenefitDto> benefits;
  final List<MobileClassSessionDto> sessions;

  factory MobileGymClassDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'gym class');

    return MobileGymClassDto(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'name'),
      subtitle: _readOptionalString(data, 'subtitle'),
      description: _readOptionalString(data, 'description'),
      level: _readOptionalString(data, 'level'),
      durationMinutes: _readRequiredInt(data, 'durationMinutes'),
      defaultCapacity: _readOptionalInt(data, 'defaultCapacity'),
      coverImageUrl: _readOptionalString(data, 'coverImageUrl'),
      category: data['category'] == null
          ? null
          : MobileClassCategoryDto.fromJson(data['category']),
      images: _readList(
        data,
        'images',
      ).map(MobileClassImageDto.fromJson).toList(growable: false),
      benefits: _readList(
        data,
        'benefits',
      ).map(MobileClassBenefitDto.fromJson).toList(growable: false),
      sessions: _readList(
        data,
        'sessions',
      ).map(MobileClassSessionDto.fromJson).toList(growable: false),
    );
  }
}

class MobileClassImageDto {
  const MobileClassImageDto({required this.url});

  final String url;

  factory MobileClassImageDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'class image');

    return MobileClassImageDto(url: _readRequiredString(data, 'url'));
  }
}

class MobileClassBenefitDto {
  const MobileClassBenefitDto({required this.label, required this.iconKey});

  final String label;
  final String? iconKey;

  factory MobileClassBenefitDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'class benefit');

    return MobileClassBenefitDto(
      label: _readRequiredString(data, 'label'),
      iconKey: _readOptionalString(data, 'iconKey'),
    );
  }
}

class MobileClassSessionDto {
  const MobileClassSessionDto({
    required this.id,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.capacity,
    required this.bookedCount,
    required this.waitlistCount,
    required this.availableSlots,
    required this.isFull,
    required this.roomName,
    required this.notes,
    required this.trainer,
    required this.location,
  });

  final String id;
  final String status;
  final DateTime startsAt;
  final DateTime endsAt;
  final int capacity;
  final int bookedCount;
  final int waitlistCount;
  final int availableSlots;
  final bool isFull;
  final String? roomName;
  final String? notes;
  final MobileClassTrainerDto? trainer;
  final MobileClassLocationDto? location;

  factory MobileClassSessionDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'class session');

    return MobileClassSessionDto(
      id: _readRequiredString(data, 'id'),
      status: _readRequiredString(data, 'status'),
      startsAt: _readRequiredDateTime(data, 'startsAt'),
      endsAt: _readRequiredDateTime(data, 'endsAt'),
      capacity: _readRequiredInt(data, 'capacity'),
      bookedCount: _readRequiredInt(data, 'bookedCount'),
      waitlistCount: _readRequiredInt(data, 'waitlistCount'),
      availableSlots: _readRequiredInt(data, 'availableSlots'),
      isFull: data['isFull'] == true,
      roomName: _readOptionalString(data, 'roomName'),
      notes: _readOptionalString(data, 'notes'),
      trainer: data['trainer'] == null
          ? null
          : MobileClassTrainerDto.fromJson(data['trainer']),
      location: data['location'] == null
          ? null
          : MobileClassLocationDto.fromJson(data['location']),
    );
  }
}

class MobileClassTrainerDto {
  const MobileClassTrainerDto({
    required this.id,
    required this.name,
    required this.specialty,
    required this.photoUrl,
    required this.rating,
  });

  final String id;
  final String name;
  final String? specialty;
  final String? photoUrl;
  final double? rating;

  factory MobileClassTrainerDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'class trainer');

    return MobileClassTrainerDto(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'name'),
      specialty: _readOptionalString(data, 'specialty'),
      photoUrl: _readOptionalString(data, 'photoUrl'),
      rating: _readOptionalDouble(data, 'rating'),
    );
  }
}

class MobileClassLocationDto {
  const MobileClassLocationDto({
    required this.id,
    required this.name,
    required this.area,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.googlePlaceId,
  });

  final String id;
  final String name;
  final String? area;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? googlePlaceId;

  factory MobileClassLocationDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'class location');

    return MobileClassLocationDto(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'name'),
      area: _readOptionalString(data, 'area'),
      address: _readOptionalString(data, 'address'),
      latitude: _readOptionalDouble(data, 'latitude'),
      longitude: _readOptionalDouble(data, 'longitude'),
      googlePlaceId: _readOptionalString(data, 'googlePlaceId'),
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

int _readRequiredInt(Map<String, Object?> data, String key) {
  final value = data[key];

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

DateTime _readRequiredDateTime(Map<String, Object?> data, String key) {
  final value = data[key];

  if (value is! String) {
    throw FormatException('Invalid $key data.');
  }

  final parsed = DateTime.tryParse(value);

  if (parsed == null) {
    throw FormatException('Invalid $key data.');
  }

  return parsed;
}
