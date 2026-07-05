import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/network/api_exception.dart';
import 'package:do_gym/features/profile/data/profile_data.dart';
import 'package:do_gym/features/profile/data/repositories/profile_repository.dart';
import 'package:do_gym/features/profile/presentation/cubit/profile_cubit.dart';

void main() {
  test('loads profile', () async {
    final cubit = ProfileCubit(repository: _FakeProfileRepository());

    await cubit.fetchProfile();

    expect(cubit.state.status, ProfileLoadStatus.success);
    expect(cubit.state.profile?.memberCode, 'MEM-001');

    await cubit.close();
  });

  test('validates update input before calling repository', () async {
    final repository = _FakeProfileRepository();
    final cubit = ProfileCubit(repository: repository);

    final success = await cubit.updateProfile(
      name: 'A',
      email: 'bad-email',
      phone: '08123',
    );

    expect(success, isFalse);
    expect(repository.submittedName, isNull);
    expect(cubit.state.formErrorMessage, 'Nama minimal 2 karakter.');

    await cubit.close();
  });

  test('maps conflict update errors into user message', () async {
    final cubit = ProfileCubit(
      repository: _FakeProfileRepository(
        error: const ApiException(
          type: ApiExceptionType.conflict,
          message: 'Duplicate email.',
          statusCode: 409,
        ),
      ),
    );

    final success = await cubit.updateProfile(
      name: 'Andi Member',
      email: 'member@example.com',
      phone: '081234567890',
    );

    expect(success, isFalse);
    expect(cubit.state.formErrorMessage, 'Email sudah digunakan member lain.');

    await cubit.close();
  });
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.error});

  final Object? error;
  String? submittedName;

  @override
  Future<MemberProfile> fetchProfile() async {
    final Object? error = this.error;

    if (error != null) {
      throw error;
    }

    return _profile;
  }

  @override
  Future<MemberProfile> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final Object? error = this.error;

    if (error != null) {
      throw error;
    }

    submittedName = name;
    return _profile;
  }
}

const MemberProfile _profile = MemberProfile(
  id: 'member-1',
  memberCode: 'MEM-001',
  name: 'Andi Member',
  email: 'member@example.com',
  phone: '081234567890',
  companyName: 'DO GYM',
  badgeLabel: 'Premium Member',
  membershipPlanName: 'Premium Access',
  membershipStatusLabel: 'Active',
  membershipExpiryLabel: '25 Jul 2026',
  accessLabel: 'Semua Cabang',
  hasActiveMembership: true,
);
