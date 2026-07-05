import 'package:do_gym/features/activities/data/repositories/member_attendance_activity_repository.dart';
import 'package:do_gym/features/classes/data/repositories/booking_class_repository.dart';
import 'package:do_gym/features/bookings/data/repositories/personal_training_booking_repository.dart';
import 'package:do_gym/features/classes/data/class_data.dart';
import 'package:do_gym/features/locations/data/repositories/location_repository.dart';
import 'package:do_gym/features/locations/data/branch_location_data.dart';
import 'package:do_gym/features/member_attendance/data/repositories/member_attendance_repository.dart';
import 'package:do_gym/features/profile/data/profile_data.dart';
import 'package:do_gym/features/profile/data/repositories/profile_repository.dart';
import 'package:do_gym/features/trainers/data/repositories/trainer_repository.dart';

class FakeLocationRepository implements LocationRepository {
  FakeLocationRepository({this.locations = const []});

  final List<BranchLocation> locations;

  @override
  Future<List<BranchLocation>> fetchLocations() async {
    return locations;
  }
}

class FakeBookingClassRepository implements BookingClassRepository {
  FakeBookingClassRepository({
    this.classes = const [],
    this.categories = const [ClassCategoryOption.all],
    this.historyItems = const [],
    ClassBookingConfirmation? confirmation,
  }) : confirmation =
           confirmation ??
           const ClassBookingConfirmation(
             id: 'class-booking-1',
             bookingCode: 'CLB-TEST001',
             qrPayload: 'class_booking:CLB-TEST001',
             title: 'Yoga Flow',
             schedule: 'Senin, 24 Jun 09:00',
             duration: '60 Menit',
             location: 'Denpasar',
           );

  final List<GroupClassSession> classes;
  final List<ClassCategoryOption> categories;
  final List<ClassBookingHistoryItem> historyItems;
  final ClassBookingConfirmation confirmation;
  String? submittedClassSessionId;
  String? submittedLocationId;
  ClassBookingHistoryFilter? submittedHistoryFilter;

  @override
  Future<BookingClassCatalog> fetchClassCatalog({
    String? locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    submittedLocationId = locationId;
    return BookingClassCatalog(categories: categories, sessions: classes);
  }

  @override
  Future<BookingClassCatalog> fetchClassCatalogForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    return fetchClassCatalog(
      locationId: locationId,
      startsFrom: startsFrom,
      startsTo: startsTo,
    );
  }

  @override
  Future<List<GroupClassSession>> fetchClassesForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    return classes;
  }

  @override
  Future<List<ClassBookingHistoryItem>> fetchClassBookings({
    ClassBookingHistoryFilter filter = ClassBookingHistoryFilter.upcoming,
  }) async {
    submittedHistoryFilter = filter;
    return historyItems;
  }

  @override
  Future<ClassBookingConfirmation> createClassBooking({
    required String classSessionId,
    String? notes,
  }) async {
    submittedClassSessionId = classSessionId;
    return confirmation;
  }
}

class FakePersonalTrainingBookingRepository
    implements PersonalTrainingBookingRepository {
  FakePersonalTrainingBookingRepository({
    PersonalTrainingBookingConfirmation? confirmation,
    this.historyItems = const [],
  }) : confirmation =
           confirmation ??
           const PersonalTrainingBookingConfirmation(
             id: 'booking-1',
             bookingCode: 'PTB-TEST001',
             qrPayload: 'pt_booking:PTB-TEST001',
             title: 'Personal Training',
             schedule: 'Senin, 24 Jun 09:00',
             duration: '60 Menit',
             location: 'Denpasar',
           );

  final PersonalTrainingBookingConfirmation confirmation;
  final List<PersonalTrainingBookingHistoryItem> historyItems;
  DateTime? submittedStartsAt;
  PersonalTrainingBookingHistoryFilter? submittedHistoryFilter;

  @override
  Future<List<PersonalTrainingBookingHistoryItem>>
  fetchPersonalTrainingBookings({
    PersonalTrainingBookingHistoryFilter filter =
        PersonalTrainingBookingHistoryFilter.upcoming,
  }) async {
    submittedHistoryFilter = filter;
    return historyItems;
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
    submittedStartsAt = startsAt;
    return confirmation;
  }
}

class FakeTrainerRepository implements TrainerRepository {
  FakeTrainerRepository({
    this.trainers = const [],
    TrainerProfile? detailTrainer,
  }) : detailTrainer =
           detailTrainer ?? (trainers.isEmpty ? null : trainers.first);

  final List<TrainerProfile> trainers;
  final TrainerProfile? detailTrainer;
  double? submittedRating;

  @override
  Future<List<TrainerProfile>> fetchTrainers() async {
    return trainers;
  }

  @override
  Future<TrainerProfile> fetchTrainerDetail(String trainerId) async {
    final trainer = detailTrainer;

    if (trainer != null) {
      return trainer;
    }

    return trainers.firstWhere((item) => item.id == trainerId);
  }

  @override
  Future<double?> submitTrainerRating({
    required String trainerId,
    required double rating,
  }) async {
    submittedRating = rating;
    return rating;
  }
}

class FakeMemberAttendanceRepository implements MemberAttendanceRepository {
  FakeMemberAttendanceRepository({MemberAttendanceQr? qr, this.error})
    : qr = qr ?? _createDefaultMemberAttendanceQr();

  final MemberAttendanceQr qr;
  final Object? error;

  @override
  Future<MemberAttendanceQr> createMemberAttendanceQr() async {
    final Object? error = this.error;

    if (error != null) {
      throw error;
    }

    return qr;
  }
}

class FakeMemberAttendanceActivityRepository
    implements MemberAttendanceActivityRepository {
  FakeMemberAttendanceActivityRepository({
    this.page = const MemberAttendanceHistoryPage(items: [], totalItems: 0),
    this.error,
  });

  final MemberAttendanceHistoryPage page;
  final Object? error;
  MemberAttendanceHistoryFilter? submittedFilter;

  @override
  Future<MemberAttendanceHistoryPage> fetchMemberAttendanceHistory({
    MemberAttendanceHistoryFilter filter = MemberAttendanceHistoryFilter.all,
  }) async {
    submittedFilter = filter;
    final Object? error = this.error;

    if (error != null) {
      throw error;
    }

    return page;
  }
}

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({MemberProfile? profile, this.error})
    : profile = profile ?? _createDefaultMemberProfile();

  MemberProfile profile;
  final Object? error;
  String? submittedName;
  String? submittedEmail;
  String? submittedPhone;

  @override
  Future<MemberProfile> fetchProfile() async {
    final Object? error = this.error;

    if (error != null) {
      throw error;
    }

    return profile;
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
    submittedEmail = email;
    submittedPhone = phone;
    profile = MemberProfile(
      id: profile.id,
      memberCode: profile.memberCode,
      name: name,
      email: email,
      phone: phone,
      companyName: profile.companyName,
      badgeLabel: profile.badgeLabel,
      membershipPlanName: profile.membershipPlanName,
      membershipStatusLabel: profile.membershipStatusLabel,
      membershipExpiryLabel: profile.membershipExpiryLabel,
      accessLabel: profile.accessLabel,
      hasActiveMembership: profile.hasActiveMembership,
      membershipExpiresAt: profile.membershipExpiresAt,
    );

    return profile;
  }
}

MemberAttendanceQr _createDefaultMemberAttendanceQr() {
  final expiresAt = DateTime.now().add(const Duration(minutes: 2));
  final expiryHour = expiresAt.hour.toString().padLeft(2, '0');
  final expiryMinute = expiresAt.minute.toString().padLeft(2, '0');

  return MemberAttendanceQr(
    qrPayload: 'member_checkin:MEMBER-QR',
    expiresAt: expiresAt,
    memberName: 'Andi Member',
    memberCode: 'MEM-001',
    planName: 'Premium Access',
    membershipExpiresAt: DateTime(2026, 7, 25),
    membershipExpiryLabel: '25 Jul 2026',
    qrExpiryLabel: '$expiryHour:$expiryMinute',
  );
}

MemberProfile _createDefaultMemberProfile() {
  return const MemberProfile(
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
    membershipExpiresAt: null,
  );
}
