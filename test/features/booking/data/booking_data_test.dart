import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/features/booking/data/booking_data.dart';

void main() {
  group('buildUpcomingBookingDateOptions', () {
    test('normalizes the base date to the start of the calendar day', () {
      final options = buildUpcomingBookingDateOptions(
        today: DateTime(2026, 7, 5, 23, 45),
        dayCount: 2,
      );

      expect(options.first.date, DateTime(2026, 7, 5));
      expect(options.first.label, 'Hari ini');
      expect(options.last.date, DateTime(2026, 7, 6));
      expect(options.last.label, 'Besok');
    });
  });

  group('findBookingDateOptionIndexForDate', () {
    test('keeps a selected future date after the date strip refreshes', () {
      final refreshedOptions = buildUpcomingBookingDateOptions(
        today: DateTime(2026, 7, 5),
        dayCount: 4,
      );

      final selectedIndex = findBookingDateOptionIndexForDate(
        refreshedOptions,
        DateTime(2026, 7, 6, 18),
      );

      expect(selectedIndex, 1);
    });

    test('falls back to today when the previous selected date is stale', () {
      final refreshedOptions = buildUpcomingBookingDateOptions(
        today: DateTime(2026, 7, 5),
        dayCount: 4,
      );

      final selectedIndex = findBookingDateOptionIndexForDate(
        refreshedOptions,
        DateTime(2026, 7, 4, 18),
      );

      expect(selectedIndex, 0);
    });
  });
}
