import '../dto/member_attendance_history_response_dto.dart';
import '../services/member_attendance_activity_api_service.dart';

// Repository boundary for the attendance tab. The screen and cubit should not
// depend on DTO classes from the HTTP layer.
abstract interface class MemberAttendanceActivityRepository {
  Future<MemberAttendanceHistoryPage> fetchMemberAttendanceHistory({
    MemberAttendanceHistoryFilter filter = MemberAttendanceHistoryFilter.all,
  });
}

class RemoteMemberAttendanceActivityRepository
    implements MemberAttendanceActivityRepository {
  const RemoteMemberAttendanceActivityRepository({
    required MemberAttendanceActivityApiService apiService,
  }) : _apiService = apiService;

  final MemberAttendanceActivityApiService _apiService;

  @override
  Future<MemberAttendanceHistoryPage> fetchMemberAttendanceHistory({
    MemberAttendanceHistoryFilter filter = MemberAttendanceHistoryFilter.all,
  }) async {
    // Activity history currently renders one page as a compact timeline. Keep
    // pagination metadata so the UI can still show the server total.
    final response = await _apiService.fetchAttendances(
      range: filter.queryValue,
      pageSize: 50,
    );

    return MemberAttendanceHistoryPage(
      items: response.attendances
          .map(_mapAttendanceHistoryItem)
          .toList(growable: false),
      totalItems: response.pagination.totalItems,
    );
  }

  MemberAttendanceHistoryItem _mapAttendanceHistoryItem(
    MemberAttendanceHistoryItemDto dto,
  ) {
    return MemberAttendanceHistoryItem(
      id: dto.id,
      locationName: dto.location.name,
      locationArea: dto.location.area,
      planName: dto.membership?.planName,
      checkedInAt: dto.checkedInAt,
      checkedOutAt: dto.checkedOutAt,
      status: dto.status,
      durationMinutes: dto.durationMinutes,
    );
  }
}

// Values are sent directly as the mobile API range query parameter.
enum MemberAttendanceHistoryFilter {
  all('all'),
  today('today'),
  week('week'),
  month('month');

  const MemberAttendanceHistoryFilter(this.queryValue);

  final String queryValue;
}

// App-ready attendance page used by the Cubit. It intentionally contains only
// fields the activity UI needs.
class MemberAttendanceHistoryPage {
  const MemberAttendanceHistoryPage({
    required this.items,
    required this.totalItems,
  });

  final List<MemberAttendanceHistoryItem> items;
  final int totalItems;
}

class MemberAttendanceHistoryItem {
  const MemberAttendanceHistoryItem({
    required this.id,
    required this.locationName,
    required this.locationArea,
    required this.planName,
    required this.checkedInAt,
    required this.checkedOutAt,
    required this.status,
    required this.durationMinutes,
  });

  final String id;
  final String locationName;
  final String? locationArea;
  final String? planName;
  final DateTime checkedInAt;
  final DateTime? checkedOutAt;
  final String status;
  final int? durationMinutes;

  bool get isOpen => status == 'OPEN' || checkedOutAt == null;
}
