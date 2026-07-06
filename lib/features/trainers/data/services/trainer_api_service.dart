import '../../../../core/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dto/mobile_trainer_response_dto.dart';

/// Batas HTTP untuk fitur trainer.
///
/// Service hanya memanggil endpoint melalui ApiClient dan mengubah payload
/// valid menjadi DTO. Mapping ke model aplikasi tetap menjadi tanggung jawab
/// repository.
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

  /// Mengirim rating trainer setelah backend mengizinkan member memberi nilai.
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
