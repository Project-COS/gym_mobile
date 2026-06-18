import 'package:do_gym/features/booking/data/booking_data.dart';
import 'package:do_gym/features/booking/data/repositories/booking_class_repository.dart';
import 'package:do_gym/features/lokasi/data/repositories/location_repository.dart';
import 'package:do_gym/features/lokasi/screen/branch_location_data.dart';

class FakeLocationRepository implements LocationRepository {
  FakeLocationRepository({this.locations = const []});

  final List<BranchLocation> locations;

  @override
  Future<List<BranchLocation>> fetchLocations() async {
    return locations;
  }
}

class FakeBookingClassRepository implements BookingClassRepository {
  FakeBookingClassRepository({this.classes = const []});

  final List<GroupClassSession> classes;

  @override
  Future<List<GroupClassSession>> fetchClassesForLocation({
    required String locationId,
    required DateTime startsFrom,
    required DateTime startsTo,
  }) async {
    return classes;
  }
}
