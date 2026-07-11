import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/icons/app_lucide_icons.dart';
import 'package:do_gym/features/trainers/data/dto/mobile_trainer_response_dto.dart';
import 'package:do_gym/features/trainers/data/repositories/trainer_repository.dart';
import 'package:do_gym/features/trainers/data/services/trainer_api_service.dart';

void main() {
  test('maps trainer DTOs into trainer profiles', () async {
    final repository = RemoteTrainerRepository(
      apiService: _FakeTrainerApiService(
        listResponse: MobileTrainersResponseDto(
          trainers: [_trainerDto(canRate: false)],
        ),
      ),
    );

    final trainers = await repository.fetchTrainers();

    expect(trainers, hasLength(1));
    expect(trainers.first.id, 'trainer-1');
    expect(trainers.first.name, 'Coach Maya');
    expect(trainers.first.subtitle, 'Strength');
    expect(trainers.first.branch, 'Denpasar');
    expect(trainers.first.duration, '60 Menit');
    expect(trainers.first.ratingLabel, '4.8');
    expect(trainers.first.whatsappNumber, '081234567890');
    expect(trainers.first.scheduleLabel, 'Senin - 08:00 - 12:00');
    expect(trainers.first.mapUrl, 'https://maps.example/location-1');
    expect(trainers.first.gallery, ['https://cdn.example/gallery.jpg']);
    expect(
      trainers.first.gallery,
      isNot(contains('https://cdn.example/trainer.jpg')),
    );
    expect(
      trainers.first.gallery,
      isNot(contains('https://cdn.example/program.jpg')),
    );
    expect(trainers.first.programs.first.name, 'Strength Builder');
    expect(trainers.first.benefits.first.label, 'Technique check');
    expect(trainers.first.benefits.first.icon, AppLucideIcons.badgeCheck);
  });

  test('maps trainer detail and submits rating', () async {
    final apiService = _FakeTrainerApiService(
      detailResponse: MobileTrainerDetailResponseDto(
        trainer: _trainerDto(canRate: true),
      ),
      ratingResponse: const MobileTrainerRatingResponseDto(
        trainer: MobileTrainerRatingDto(id: 'trainer-1', rating: 5),
      ),
    );
    final repository = RemoteTrainerRepository(apiService: apiService);

    final trainer = await repository.fetchTrainerDetail('trainer-1');
    final rating = await repository.submitTrainerRating(
      trainerId: 'trainer-1',
      rating: 5,
    );

    expect(trainer.canRate, isTrue);
    expect(apiService.detailTrainerId, 'trainer-1');
    expect(apiService.ratingTrainerId, 'trainer-1');
    expect(apiService.ratingValue, 5);
    expect(rating, 5);
  });
}

class _FakeTrainerApiService implements TrainerApiService {
  _FakeTrainerApiService({
    this.listResponse = const MobileTrainersResponseDto(trainers: []),
    MobileTrainerDetailResponseDto? detailResponse,
    MobileTrainerRatingResponseDto? ratingResponse,
  }) : detailResponse =
           detailResponse ??
           MobileTrainerDetailResponseDto(trainer: _trainerDto(canRate: false)),
       ratingResponse =
           ratingResponse ??
           const MobileTrainerRatingResponseDto(
             trainer: MobileTrainerRatingDto(id: 'trainer-1', rating: null),
           );

  final MobileTrainersResponseDto listResponse;
  final MobileTrainerDetailResponseDto detailResponse;
  final MobileTrainerRatingResponseDto ratingResponse;
  String? detailTrainerId;
  String? ratingTrainerId;
  double? ratingValue;

  @override
  Future<MobileTrainersResponseDto> fetchTrainers() async {
    return listResponse;
  }

  @override
  Future<MobileTrainerDetailResponseDto> fetchTrainerDetail(
    String trainerId,
  ) async {
    detailTrainerId = trainerId;
    return detailResponse;
  }

  @override
  Future<MobileTrainerRatingResponseDto> submitTrainerRating({
    required String trainerId,
    required double rating,
  }) async {
    ratingTrainerId = trainerId;
    ratingValue = rating;
    return ratingResponse;
  }
}

MobileTrainerDto _trainerDto({required bool canRate}) {
  return MobileTrainerDto(
    id: 'trainer-1',
    name: 'Coach Maya',
    phone: '081234567890',
    specialty: 'Strength',
    bio: 'Strength and conditioning coach.',
    photoUrl: 'https://cdn.example/trainer.jpg',
    rating: 4.8,
    defaultLocationId: 'location-1',
    defaultLocationName: 'DO GYM Denpasar',
    locations: const [
      MobileTrainerLocationDto(
        id: 'location-1',
        name: 'DO GYM Denpasar',
        area: 'Denpasar',
        address: 'Jl. Gatot Subroto',
        whatsapp: '+628199999999',
        isPrimary: true,
        sortOrder: 1,
        latitude: -8.65,
        longitude: 115.21,
        mapPlaceId: null,
        mapAddress: 'Jl. Gatot Subroto',
        mapUrls: MobileTrainerMapUrlsDto(
          openStreetMap: null,
          googleMaps: 'https://maps.example/location-1',
          googleNavigation: 'https://nav.example/location-1',
        ),
      ),
    ],
    schedules: const [
      MobileTrainerScheduleDto(
        dayOfWeek: 1,
        startTime: '08:00',
        endTime: '12:00',
        locationId: 'location-1',
        locationName: 'DO GYM Denpasar',
      ),
    ],
    images: const [
      MobileTrainerImageDto(
        url: 'https://cdn.example/gallery.jpg',
        sortOrder: 1,
        isActive: true,
      ),
    ],
    programs: const [
      MobileTrainerProgramDto(
        id: 'program-1',
        name: 'Strength Builder',
        subtitle: 'Strength basics',
        description: 'Build strength safely.',
        durationMinutes: 60,
        specialty: 'Strength',
        level: 'All Level',
        locationId: 'location-1',
        locationName: 'DO GYM Denpasar',
        coverImageUrl: 'https://cdn.example/program.jpg',
        benefits: [MobileTrainerProgramBenefitDto(label: 'Technique check')],
      ),
    ],
    canRate: canRate,
  );
}
