import '../services/share_content_api_service.dart';

abstract interface class ShareContentRepository {
  Future<ShareContent> createTrainerShareLink({required String trainerId});

  Future<ShareContent> createClassShareLink({required String classId});

  Future<ShareContent> createLocationShareLink({required String locationId});
}

class RemoteShareContentRepository implements ShareContentRepository {
  const RemoteShareContentRepository({
    required ShareContentApiService apiService,
  }) : _apiService = apiService;

  final ShareContentApiService _apiService;

  @override
  Future<ShareContent> createTrainerShareLink({required String trainerId}) {
    return _createShareLink(targetType: 'TRAINER', targetId: trainerId);
  }

  @override
  Future<ShareContent> createClassShareLink({required String classId}) {
    return _createShareLink(targetType: 'GYM_CLASS', targetId: classId);
  }

  @override
  Future<ShareContent> createLocationShareLink({required String locationId}) {
    return _createShareLink(targetType: 'LOCATION', targetId: locationId);
  }

  Future<ShareContent> _createShareLink({
    required String targetType,
    required String targetId,
  }) async {
    final response = await _apiService.createShareLink(
      targetType: targetType,
      targetId: targetId,
    );
    final shareLink = response.shareLink;

    return ShareContent(
      title: shareLink.title,
      description: shareLink.description,
      publicUrl: shareLink.publicUrl,
    );
  }
}

class ShareContent {
  const ShareContent({
    required this.title,
    required this.description,
    required this.publicUrl,
  });

  final String title;
  final String description;
  final String publicUrl;
}
