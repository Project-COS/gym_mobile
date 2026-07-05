import '../dto/member_attendance_history_response_dto.dart';
import '../services/member_attendance_activity_api_service.dart';

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

enum MemberAttendanceHistoryFilter {
  all('all'),
  today('today'),
  week('week'),
  month('month');

  const MemberAttendanceHistoryFilter(this.queryValue);

  final String queryValue;
}

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
