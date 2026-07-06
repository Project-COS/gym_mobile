import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/mobile_class_booking_response_dto.dart';
import '../dto/mobile_class_response_dto.dart';

// Thin HTTP boundary for class catalog, class booking history, and create booking.
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
        // Send UTC range boundaries so the backend receives an unambiguous day window.
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
        // The repository owns valid status values via ClassBookingHistoryFilter.
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
        // Backend books a concrete session, not the parent class.
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
