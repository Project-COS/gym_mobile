import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/mobile_class_booking_response_dto.dart';
import '../dto/mobile_class_response_dto.dart';

class BookingClassApiService {
  const BookingClassApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MobileClassesResponseDto> fetchClasses({
    String? locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    final normalizedLocationId = locationId?.trim();
    final response = await _apiClient.get(
      ApiEndpoints.classes,
      queryParameters: {
        if (normalizedLocationId != null && normalizedLocationId.isNotEmpty)
          'locationId': normalizedLocationId,
        'startsFrom': startsFrom.toUtc().toIso8601String(),
        'startsTo': startsTo.toUtc().toIso8601String(),
      },
    );

    try {
      return MobileClassesResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  Future<MobileClassesResponseDto> fetchClassesForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) {
    return fetchClasses(
      locationId: locationId,
      startsFrom: startsFrom,
      startsTo: startsTo,
    );
  }

  Future<MobileClassBookingsResponseDto> fetchBookings({
    required String status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.classBookings,
      queryParameters: {
        'status': status,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    try {
      return MobileClassBookingsResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  Future<MobileClassBookingResponseDto> createClassBooking({
    required String classSessionId,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.classBookings,
      body: {
        'classSessionId': classSessionId,
        if (notes != null) 'notes': notes,
      },
    );

    try {
      return MobileClassBookingResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }
}
