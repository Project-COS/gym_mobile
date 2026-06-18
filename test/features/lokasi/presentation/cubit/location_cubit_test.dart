import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/network/api_exception.dart';
import 'package:do_gym/features/lokasi/data/repositories/location_repository.dart';
import 'package:do_gym/features/lokasi/presentation/cubit/location_cubit.dart';
import 'package:do_gym/features/lokasi/screen/branch_location_data.dart';

void main() {
  test('emits success when locations load', () async {
    final cubit = LocationCubit(
      repository: _FakeLocationRepository(
        locations: const [
          BranchLocation(
            id: 'location-1',
            name: 'DO GYM Denpasar',
            address: 'Jl. Gatot Subroto',
            area: 'Denpasar',
            phone: '+628123',
            hours: '06:00 - 22:00',
            distance: 'Maps siap',
            capacity: 'Medium',
            access: 'Membership aktif',
            imageUrl: 'https://cdn.example/location.jpg',
            facilities: [],
            schedules: [],
            trainers: [],
          ),
        ],
      ),
    );

    await cubit.fetchLocations();

    expect(cubit.state.status, LocationLoadStatus.success);
    expect(cubit.state.locations.first.name, 'DO GYM Denpasar');

    await cubit.close();
  });

  test('emits a user-friendly failure message', () async {
    final cubit = LocationCubit(
      repository: _FakeLocationRepository(error: ApiException.timeout()),
    );

    await cubit.fetchLocations();

    expect(cubit.state.status, LocationLoadStatus.failure);
    expect(cubit.state.errorMessage, contains('terlalu lama'));

    await cubit.close();
  });
}

class _FakeLocationRepository implements LocationRepository {
  const _FakeLocationRepository({this.locations = const [], this.error});

  final List<BranchLocation> locations;
  final Object? error;

  @override
  Future<List<BranchLocation>> fetchLocations() async {
    final Object? error = this.error;

    if (error != null) {
      throw error;
    }

    return locations;
  }
}
