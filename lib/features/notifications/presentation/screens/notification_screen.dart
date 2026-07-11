import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/colors.dart';
import '../cubit/notification_inbox_cubit.dart';
import '../widgets/notification_list_tile.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<NotificationInboxCubit>();

      if (cubit.state.status == NotificationInboxLoadStatus.initial) {
        cubit.fetchNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackCore,
      appBar: AppBar(
        backgroundColor: AppColors.blackCore,
        foregroundColor: AppColors.metallicWhite,
        elevation: 0,
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          BlocBuilder<NotificationInboxCubit, NotificationInboxState>(
            buildWhen: (previous, current) =>
                previous.unreadCount != current.unreadCount,
            builder: (context, state) {
              return TextButton(
                onPressed: state.unreadCount > 0
                    ? context
                          .read<NotificationInboxCubit>()
                          .markAllNotificationsRead
                    : null,
                child: const Text('Tandai dibaca'),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: BlocConsumer<NotificationInboxCubit, NotificationInboxState>(
              listenWhen: (previous, current) =>
                  previous.errorMessage != current.errorMessage &&
                  current.errorMessage != null &&
                  current.items.isNotEmpty,
              listener: (context, state) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              },
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () => context
                      .read<NotificationInboxCubit>()
                      .fetchNotifications(forceRefresh: true),
                  child: _buildNotificationContent(context, state),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationContent(
    BuildContext context,
    NotificationInboxState state,
  ) {
    if (state.isInitialLoading) {
      return const CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.gymGold),
            ),
          ),
        ],
      );
    }

    if (state.items.isEmpty) {
      final isFailure = state.status == NotificationInboxLoadStatus.failure;

      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isFailure
                        ? Icons.cloud_off_rounded
                        : Icons.notifications_none_rounded,
                    size: 54,
                    color: AppColors.gymGold,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isFailure
                        ? 'Notifikasi belum dapat dimuat'
                        : 'Belum ada notifikasi',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.metallicWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFailure
                        ? state.errorMessage ??
                              'Tarik layar untuk mencoba kembali.'
                        : 'Pembaruan membership, booking, dan informasi gym akan muncul di sini.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.silverGray,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      itemCount: state.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = state.items[index];

        return NotificationListTile(
          notification: notification,
          onTap: () => context
              .read<NotificationInboxCubit>()
              .markNotificationRead(notification.id),
        );
      },
    );
  }
}
