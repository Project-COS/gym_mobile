import 'package:flutter/material.dart';

import '../../../../core/colors.dart';
import '../../data/dto/member_notification_dto.dart';

class NotificationListTile extends StatelessWidget {
  const NotificationListTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final MemberNotificationDto notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.isRead
          ? AppColors.graphiteBlack
          : AppColors.gymGold.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.gunmetal
                  : AppColors.gymGold.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.gymGold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: AppColors.gymGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(
                              color: AppColors.metallicWhite,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(width: 8),
                          const Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: CircleAvatar(
                              radius: 4,
                              backgroundColor: AppColors.gymGold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        color: AppColors.silverGray,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatNotificationTime(notification.createdAt),
                      style: TextStyle(
                        color: AppColors.silverGray.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNotificationTime(DateTime timestamp) {
    final localTimestamp = timestamp.toLocal();
    final difference = DateTime.now().difference(localTimestamp);

    if (!difference.isNegative && difference.inMinutes < 1) {
      return 'Baru saja';
    }

    if (!difference.isNegative && difference.inHours < 1) {
      return '${difference.inMinutes} menit lalu';
    }

    if (!difference.isNegative && difference.inDays < 1) {
      return '${difference.inHours} jam lalu';
    }

    if (!difference.isNegative && difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    }

    return '${localTimestamp.day.toString().padLeft(2, '0')}/'
        '${localTimestamp.month.toString().padLeft(2, '0')}/'
        '${localTimestamp.year}';
  }
}
