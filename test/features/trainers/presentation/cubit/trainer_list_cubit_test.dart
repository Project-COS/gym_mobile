import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/network/api_exception.dart';
import 'package:do_gym/features/trainers/data/repositories/trainer_repository.dart';
import 'package:do_gym/features/trainers/presentation/cubit/trainer_list_cubit.dart';

void main() {
  test('emits success when trainers load', () async {
    final cubit = TrainerListCubit(
      repository: _FakeTrainerRepository(trainers: const [_trainerProfile]),
    );

    await cubit.fetchTrainers();

    expect(cubit.state.status, TrainerListLoadStatus.success);
    expect(cubit.state.trainers.first.name, 'Coach Maya');

    await cubit.close();
  });

  test('emits a user-friendly failure message', () async {
    final cubit = TrainerListCubit(
      repository: _FakeTrainerRepository(error: ApiException.timeout()),
    );

    await cubit.fetchTrainers();

    expect(cubit.state.status, TrainerListLoadStatus.failure);
    expect(cubit.state.errorMessage, contains('terlalu lama'));

    await cubit.close();
  });
}

class _FakeTrainerRepository implements TrainerRepository {
  const _FakeTrainerRepository({this.trainers = const [], this.error});

  final List<TrainerProfile> trainers;
  final Object? error;

  @override
  Future<List<TrainerProfile>> fetchTrainers() async {
    final Object? error = this.error;

    if (error != null) {
      throw error;
    }

    return trainers;
  }

  @override
  Future<TrainerProfile> fetchTrainerDetail(String trainerId) async {
    throw UnimplementedError();
  }

  @override
  Future<double?> submitTrainerRating({
    required String trainerId,
    required double rating,
  }) async {
    throw UnimplementedError();
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
