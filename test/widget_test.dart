import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/main.dart';

void main() {
  testWidgets('login button navigates to home', (WidgetTester tester) async {
    _ignoreNetworkImageExceptionsDuringTest();

    await tester.pumpWidget(const MyApp());

    expect(find.text('Masuk ke akunmu'), findsOneWidget);

    final Finder submitButton = find.byKey(
      const ValueKey<String>('submitButton'),
    );

    ElevatedButton button = tester.widget<ElevatedButton>(submitButton);
    expect(button.onPressed, isNotNull);

    await tester.ensureVisible(submitButton);
    await tester.pump();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang kembali'), findsOneWidget);
  });

  testWidgets('booking class flow reaches success screen', (
    WidgetTester tester,
  ) async {
    _ignoreNetworkImageExceptionsDuringTest();

    await tester.pumpWidget(const MyApp());

    final Finder submitButton = find.byKey(
      const ValueKey<String>('submitButton'),
    );

    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Booking').last);
    await tester.pumpAndSettle();

    expect(find.text('Atur Jadwal Latihanmu'), findsOneWidget);

    await tester.tap(find.text('Kelas'));
    await tester.pumpAndSettle();

    final Finder firstDetailButton = find.text('Detail').first;
    await tester.ensureVisible(firstDetailButton);
    await tester.tap(firstDetailButton);
    await tester.pumpAndSettle();

    expect(find.text('Class Session'), findsOneWidget);

    final Finder detailBookingButton = find.text('Booking').first;
    await tester.ensureVisible(detailBookingButton);
    await tester.tap(detailBookingButton);
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Booking'), findsOneWidget);

    await tester.tap(find.text('Konfirmasi'));
    await tester.pumpAndSettle();

    expect(find.text('Booking Berhasil'), findsOneWidget);
  });
}

void _ignoreNetworkImageExceptionsDuringTest() {
  final FlutterExceptionHandler? originalOnError = FlutterError.onError;

  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception is NetworkImageLoadException) {
      return;
    }

    originalOnError?.call(details);
  };

  addTearDown(() {
    FlutterError.onError = originalOnError;
  });
}
