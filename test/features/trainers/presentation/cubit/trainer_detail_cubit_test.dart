import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/network/api_exception.dart';
import 'package:do_gym/features/booking/data/repositories/personal_training_booking_repository.dart';
import 'package:do_gym/features/trainers/data/repositories/trainer_repository.dart';
import 'package:do_gym/features/trainers/presentation/cubit/trainer_detail_cubit.dart';

void main() {
  test('emits success when trainer detail loads', () async {
    final cubit = TrainerDetailCubit(
      repository: _FakeTrainerRepository(detailTrainer: _trainerProfile),
      bookingRepository: _FakePersonalTrainingBookingRepository(),
      trainerId: 'trainer-1',
    );

    await cubit.fetchTrainer();

    expect(cubit.state.status, TrainerDetailLoadStatus.success);
    expect(cubit.state.trainer?.name, 'Coach Maya');

    await cubit.close();
  });

  test('updates trainer rating after successful submit', () async {
    final repository = _FakeTrainerRepository(
      detailTrainer: _trainerProfile,
      submittedRating: 5,
    );
    final cubit = TrainerDetailCubit(
      repository: repository,
      bookingRepository: _FakePersonalTrainingBookingRepository(),
      trainerId: 'trainer-1',
    );

    await cubit.fetchTrainer();
    await cubit.submitRating(5);

    expect(repository.ratingTrainerId, 'trainer-1');
    expect(repository.ratingValue, 5);
    expect(cubit.state.trainer?.rating, 5);
    expect(cubit.state.ratingSuccessMessage, contains('berhasil'));

    await cubit.close();
  });

  test('does not submit rating when member cannot rate trainer', () async {
    final repository = _FakeTrainerRepository(
      detailTrainer: _trainerProfile.copyWithRating(4.8).copyWithCanRate(false),
      submittedRating: 5,
    );
    final cubit = TrainerDetailCubit(
      repository: repository,
      bookingRepository: _FakePersonalTrainingBookingRepository(),
      trainerId: 'trainer-1',
    );

    await cubit.fetchTrainer();
    await cubit.submitRating(5);

    expect(repository.ratingTrainerId, isNull);
    expect(cubit.state.ratingErrorMessage, contains('menyelesaikan sesi'));

    await cubit.close();
  });

  test('keeps trainer detail visible when rating submit fails', () async {
    final cubit = TrainerDetailCubit(
      repository: _FakeTrainerRepository(
        detailTrainer: _trainerProfile,
        ratingError: const ApiException(
          type: ApiExceptionType.forbidden,
          message: 'Forbidden',
          statusCode: 403,
        ),
      ),
      bookingRepository: _FakePersonalTrainingBookingRepository(),
      trainerId: 'trainer-1',
    );

    await cubit.fetchTrainer();
    await cubit.submitRating(5);

    expect(cubit.state.status, TrainerDetailLoadStatus.success);
    expect(cubit.state.trainer?.name, 'Coach Maya');
    expect(cubit.state.ratingErrorMessage, contains('menyelesaikan sesi'));

    await cubit.close();
  });

  test('emits a user-friendly failure message', () async {
    final cubit = TrainerDetailCubit(
      repository: _FakeTrainerRepository(loadError: ApiException.timeout()),
      bookingRepository: _FakePersonalTrainingBookingRepository(),
      trainerId: 'trainer-1',
    );

    await cubit.fetchTrainer();

    expect(cubit.state.status, TrainerDetailLoadStatus.failure);
    expect(cubit.state.errorMessage, contains('terlalu lama'));

    await cubit.close();
  });

  test('stores booking confirmation after successful booking', () async {
    final bookingRepository = _FakePersonalTrainingBookingRepository();
    final cubit = TrainerDetailCubit(
      repository: _FakeTrainerRepository(detailTrainer: _trainerProfile),
      bookingRepository: bookingRepository,
      trainerId: 'trainer-1',
    );

    final startsAt = DateTime(2026, 6, 24, 9);

    await cubit.fetchTrainer();
    await cubit.bookPersonalTrainingSession(startsAt: startsAt);

    expect(bookingRepository.submittedTrainerId, 'trainer-1');
    expect(bookingRepository.submittedStartsAt, startsAt);
    expect(cubit.state.bookingConfirmation?.bookingCode, 'PTB-TEST001');

    await cubit.close();
  });
}

class _FakeTrainerRepository implements TrainerRepository {
  _FakeTrainerRepository({
    this.detailTrainer,
    this.loadError,
    this.ratingError,
    this.submittedRating,
  });

  final TrainerProfile? detailTrainer;
  final Object? loadError;
  final Object? ratingError;
  final double? submittedRating;
  String? ratingTrainerId;
  double? ratingValue;

  @override
  Future<List<TrainerProfile>> fetchTrainers() async {
    return const [];
  }

  @override
  Future<TrainerProfile> fetchTrainerDetail(String trainerId) async {
    final Object? error = loadError;

    if (error != null) {
      throw error;
    }

    return detailTrainer ?? _trainerProfile;
  }

  @override
  Future<double?> submitTrainerRating({
    required String trainerId,
    required double rating,
  }) async {
    final Object? error = ratingError;

    if (error != null) {
      throw error;
    }

    ratingTrainerId = trainerId;
    ratingValue = rating;
    return submittedRating ?? rating;
  }
}

class _FakePersonalTrainingBookingRepository
    implements PersonalTrainingBookingRepository {
  String? submittedTrainerId;
  DateTime? submittedStartsAt;

  @override
  Future<List<PersonalTrainingBookingHistoryItem>>
  fetchPersonalTrainingBookings({
    PersonalTrainingBookingHistoryFilter filter =
        PersonalTrainingBookingHistoryFilter.upcoming,
  }) async {
    return const [];
  }

  @override
  Future<PersonalTrainingBookingConfirmation> createPersonalTrainingBooking({
    required String trainerId,
    required DateTime startsAt,
    String? programId,
    String? locationId,
    String? benefitGrantId,
    String? notes,
  }) async {
    submittedTrainerId = trainerId;
    submittedStartsAt = startsAt;

    return const PersonalTrainingBookingConfirmation(
      id: 'booking-1',
      bookingCode: 'PTB-TEST001',
      qrPayload: 'pt_booking:PTB-TEST001',
      title: 'Personal Training',
      schedule: 'Rabu, 24 Jun 09:00',
      duration: '60 Menit',
      location: 'Denpasar',
    );
  }
}

extension on TrainerProfile {
  TrainerProfile copyWithCanRate(bool canRate) {
    return TrainerProfile(
      id: id,
      name: name,
      subtitle: subtitle,
      description: description,
      branch: branch,
      duration: duration,
      rating: rating,
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

const TrainerProfile _trainerProfile = TrainerProfile(
  id: 'trainer-1',
  name: 'Coach Maya',
  subtitle: 'Strength coach',
  description: 'Membantu progres latihan member.',
  branch: 'Denpasar',
  duration: '60 Menit',
  rating: 4.8,
  specialization: 'Strength',
  location: 'DO GYM Denpasar - Denpasar',
  programType: 'Strength - All Level',
  role: 'Strength coach',
  mapQuery: 'DO GYM Denpasar',
  mapUrl: 'https://maps.example/location-1',
  coverImageUrl: 'https://cdn.example/trainer.jpg',
  schedules: [],
  benefits: [],
  gallery: [],
  programs: [],
  locations: [],
  canRate: true,
);
