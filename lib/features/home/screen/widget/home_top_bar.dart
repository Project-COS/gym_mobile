import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/colors.dart';
import '../../../notifications/presentation/cubit/notification_inbox_cubit.dart';
import '../../../notifications/presentation/screens/notification_screen.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.graphiteBlack,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.gymGold.withValues(alpha: 0.28),
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.gymGold,
                ),
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang kembali',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.silverGray,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Hi, Andre 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.metallicWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        BlocBuilder<NotificationInboxCubit, NotificationInboxState>(
          buildWhen: (previous, current) =>
              previous.unreadCount != current.unreadCount,
          builder: (context, state) => Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.graphiteBlack,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gunmetal),
            ),
            child: Badge.count(
              count: state.unreadCount,
              isLabelVisible: state.unreadCount > 0,
              backgroundColor: AppColors.gymGold,
              textColor: AppColors.blackCore,
              child: IconButton(
                tooltip: 'Buka notifikasi',
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.notifications_rounded,
                  color: AppColors.metallicWhite,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
