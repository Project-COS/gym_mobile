import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/home/screen/widget/home_top_bar.dart';
import 'package:do_gym/features/notifications/presentation/cubit/notification_inbox_cubit.dart';

import '../../../../helpers/fake_mobile_repositories.dart';

void main() {
  testWidgets('notification bell opens the database-backed inbox', (
    tester,
  ) async {
    final cubit = NotificationInboxCubit(
      repository: FakeNotificationRepository(),
    );

    await tester.pumpWidget(
      BlocProvider<NotificationInboxCubit>.value(
        value: cubit,
        child: const MaterialApp(
          home: Scaffold(
            body: Padding(padding: EdgeInsets.all(20), child: HomeTopBar()),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Buka notifikasi'));
    await tester.pumpAndSettle();

    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('Belum ada notifikasi'), findsOneWidget);

    await cubit.close();
  });
}
