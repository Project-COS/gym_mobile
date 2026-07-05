import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/mobile_personal_training_booking_response_dto.dart';

class PersonalTrainingBookingApiService {
  const PersonalTrainingBookingApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MobilePersonalTrainingBookingsResponseDto> fetchBookings({
    required String status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.personalTrainingBookings,
      queryParameters: {
        'status': status,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    try {
      return MobilePersonalTrainingBookingsResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  Future<MobilePersonalTrainingBookingResponseDto> createBooking({
    required String trainerId,
    required DateTime startsAt,
    String? programId,
    String? locationId,
    String? benefitGrantId,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.personalTrainingBookings,
      body: {
        'trainerId': trainerId,
        'startsAt': startsAt.toUtc().toIso8601String(),
        if (programId != null) 'programId': programId,
        if (locationId != null) 'locationId': locationId,
        if (benefitGrantId != null) 'benefitGrantId': benefitGrantId,
        if (notes != null) 'notes': notes,
      },
    );

    try {
      return MobilePersonalTrainingBookingResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }
}
