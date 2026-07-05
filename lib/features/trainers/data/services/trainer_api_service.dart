import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/mobile_trainer_response_dto.dart';

class TrainerApiService {
  const TrainerApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<MobileTrainersResponseDto> fetchTrainers() async {
    final response = await _apiClient.get(ApiEndpoints.trainers);

    try {
      return MobileTrainersResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  Future<MobileTrainerDetailResponseDto> fetchTrainerDetail(
    String trainerId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.trainerDetail(trainerId),
    );

    try {
      return MobileTrainerDetailResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  Future<MobileTrainerRatingResponseDto> submitTrainerRating({
    required String trainerId,
    required double rating,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.trainerRating(trainerId),
      body: {'rating': rating},
    );

    try {
      return MobileTrainerRatingResponseDto.fromJson(response);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }
}
