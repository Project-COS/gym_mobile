import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/dto/member_notification_dto.dart';
import '../../data/repositories/notification_repository.dart';

enum NotificationInboxLoadStatus { initial, loading, success, failure }

class NotificationInboxState {
  const NotificationInboxState({
    this.status = NotificationInboxLoadStatus.initial,
    this.items = const [],
    this.unreadCount = 0,
    this.totalItems = 0,
    this.errorMessage,
  });

  final NotificationInboxLoadStatus status;
  final List<MemberNotificationDto> items;
  final int unreadCount;
  final int totalItems;
  final String? errorMessage;

  bool get isInitialLoading =>
      status == NotificationInboxLoadStatus.loading && items.isEmpty;

  NotificationInboxState copyWith({
    NotificationInboxLoadStatus? status,
    List<MemberNotificationDto>? items,
    int? unreadCount,
    int? totalItems,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationInboxState(
      status: status ?? this.status,
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      totalItems: totalItems ?? this.totalItems,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class NotificationInboxCubit extends Cubit<NotificationInboxState> {
  NotificationInboxCubit({required NotificationRepository repository})
    : _repository = repository,
      super(const NotificationInboxState());

  static const int _pageSize = 50;
  final NotificationRepository _repository;

  Future<void> fetchNotifications({bool forceRefresh = false}) async {
    if (state.status == NotificationInboxLoadStatus.loading && !forceRefresh) {
      return;
    }

    emit(
      state.copyWith(
        status: NotificationInboxLoadStatus.loading,
        clearError: true,
      ),
    );

    try {
      final result = await _repository.fetchNotifications(
        page: 1,
        pageSize: _pageSize,
      );

      if (!isClosed) {
        emit(
          NotificationInboxState(
            status: NotificationInboxLoadStatus.success,
            items: result.items,
            unreadCount: result.unreadCount,
            totalItems: result.totalItems,
          ),
        );
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: NotificationInboxLoadStatus.failure,
            errorMessage: _mapNotificationError(error),
          ),
        );
      }
    }
  }

  Future<void> markNotificationRead(String notificationId) async {
    final notification = state.items
        .where((item) => item.id == notificationId)
        .firstOrNull;

    if (notification == null || notification.isRead) {
      return;
    }

    try {
      await _repository.markNotificationRead(notificationId);
      final now = DateTime.now();

      if (!isClosed) {
        emit(
          state.copyWith(
            items: state.items
                .map(
                  (item) =>
                      item.id == notificationId ? item.markRead(now) : item,
                )
                .toList(growable: false),
            unreadCount: (state.unreadCount - 1).clamp(0, state.unreadCount),
            clearError: true,
          ),
        );
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: _mapNotificationError(error)));
      }
    }
  }

  Future<void> markAllNotificationsRead() async {
    if (state.unreadCount == 0) {
      return;
    }

    try {
      await _repository.markAllNotificationsRead();
      final now = DateTime.now();

      if (!isClosed) {
        emit(
          state.copyWith(
            items: state.items
                .map((item) => item.isRead ? item : item.markRead(now))
                .toList(growable: false),
            unreadCount: 0,
            clearError: true,
          ),
        );
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: _mapNotificationError(error)));
      }
    }
  }

  void clearForSignedOutMember() {
    emit(const NotificationInboxState());
  }

  String _mapNotificationError(Object error) {
    if (error is ApiException) {
      return switch (error.type) {
        ApiExceptionType.unauthorized =>
          'Sesi kamu sudah berakhir. Silakan masuk kembali.',
        ApiExceptionType.timeout =>
          'Memuat notifikasi terlalu lama. Silakan coba kembali.',
        ApiExceptionType.network =>
          'Tidak dapat terhubung. Periksa koneksi internet kamu.',
        _ => 'Notifikasi belum bisa dimuat. Silakan coba kembali.',
      };
    }

    return 'Notifikasi belum bisa dimuat. Silakan coba kembali.';
  }
}
