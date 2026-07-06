// DTOs mirror the mobile locations API response. UI defaults and formatting are
// handled by the repository so malformed API payloads fail near the network layer.
class MobileLocationsResponseDto {
  const MobileLocationsResponseDto({required this.locations});

  final List<MobileLocationDto> locations;

  factory MobileLocationsResponseDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'locations response');
    final rawLocations = _readList(data, 'locations');

    return MobileLocationsResponseDto(
      locations: rawLocations
          .map(MobileLocationDto.fromJson)
          .toList(growable: false),
    );
  }
}

// One branch record from the backend, including optional media, map, and schedule data.
class MobileLocationDto {
  const MobileLocationDto({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.area,
    required this.whatsapp,
    required this.capacityLabel,
    required this.latitude,
    required this.longitude,
    required this.googlePlaceId,
    required this.mapUrls,
    required this.images,
    required this.facilities,
    required this.schedules,
  });

  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? area;
  final String? whatsapp;
  final String? capacityLabel;
  final double? latitude;
  final double? longitude;
  final String? googlePlaceId;
  final MobileLocationMapUrlsDto mapUrls;
  final List<MobileLocationImageDto> images;
  final List<MobileLocationFacilityDto> facilities;
  final List<MobileLocationScheduleDto> schedules;

  factory MobileLocationDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'location');

    return MobileLocationDto(
      id: _readRequiredString(data, 'id'),
      name: _readRequiredString(data, 'name'),
      description: _readOptionalString(data, 'description'),
      address: _readOptionalString(data, 'address'),
      area: _readOptionalString(data, 'area'),
      whatsapp: _readOptionalString(data, 'whatsapp'),
      capacityLabel: _readOptionalString(data, 'capacityLabel'),
      latitude: _readOptionalDouble(data, 'latitude'),
      longitude: _readOptionalDouble(data, 'longitude'),
      googlePlaceId: _readOptionalString(data, 'googlePlaceId'),
      mapUrls: MobileLocationMapUrlsDto.fromJson(data['mapUrls']),
      images: _readList(
        data,
        'images',
      ).map(MobileLocationImageDto.fromJson).toList(growable: false),
      facilities: _readList(
        data,
        'facilities',
      ).map(MobileLocationFacilityDto.fromJson).toList(growable: false),
      schedules: _readList(
        data,
        'schedules',
      ).map(MobileLocationScheduleDto.fromJson).toList(growable: false),
    );
  }
}

// Map URLs are optional because the app can still build a Google Maps search URL.
class MobileLocationMapUrlsDto {
  const MobileLocationMapUrlsDto({
    required this.openStreetMap,
    required this.googleMaps,
    required this.googleNavigation,
  });

  final String? openStreetMap;
  final String? googleMaps;
  final String? googleNavigation;

  factory MobileLocationMapUrlsDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'location map URLs');

    return MobileLocationMapUrlsDto(
      openStreetMap: _readOptionalString(data, 'openStreetMap'),
      googleMaps: _readOptionalString(data, 'googleMaps'),
      googleNavigation: _readOptionalString(data, 'googleNavigation'),
    );
  }
}

// Location images can be ordered or marked as primary from the admin side.
class MobileLocationImageDto {
  const MobileLocationImageDto({
    required this.url,
    required this.altText,
    required this.caption,
    required this.isPrimary,
  });

  final String url;
  final String? altText;
  final String? caption;
  final bool isPrimary;

  factory MobileLocationImageDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'location image');

    return MobileLocationImageDto(
      url: _readRequiredString(data, 'url'),
      altText: _readOptionalString(data, 'altText'),
      caption: _readOptionalString(data, 'caption'),
      isPrimary: data['isPrimary'] == true,
    );
  }
}

// Backend only sends facility names; app icons are assigned during repository mapping.
class MobileLocationFacilityDto {
  const MobileLocationFacilityDto({required this.name});

  final String name;

  factory MobileLocationFacilityDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'location facility');

    return MobileLocationFacilityDto(name: _readRequiredString(data, 'name'));
  }
}

// Operating schedule row. Null values mean the schedule is not fully configured yet.
class MobileLocationScheduleDto {
  const MobileLocationScheduleDto({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  final int? dayOfWeek;
  final String? startTime;
  final String? endTime;

  factory MobileLocationScheduleDto.fromJson(Object? json) {
    final data = _readJsonMap(json, 'location schedule');

    return MobileLocationScheduleDto(
      dayOfWeek: _readOptionalInt(data, 'dayOfWeek'),
      startTime: _readOptionalString(data, 'startTime'),
      endTime: _readOptionalString(data, 'endTime'),
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
