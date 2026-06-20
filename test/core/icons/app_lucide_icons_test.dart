import 'package:flutter_test/flutter_test.dart';

import 'package:do_gym/core/icons/app_lucide_icons.dart';

void main() {
  group('AppLucideIcons', () {
    test('maps dashboard icon keys and legacy labels to Lucide icons', () {
      expect(
        AppLucideIcons.resolveGymIcon('fitness_center'),
        AppLucideIcons.dumbbell,
      );
      expect(AppLucideIcons.resolveGymIcon('mapPin'), AppLucideIcons.mapPin);
      expect(AppLucideIcons.resolveGymIcon('free WiFi'), AppLucideIcons.wifi);
      expect(AppLucideIcons.resolveGymIcon('HIIT'), AppLucideIcons.flame);
      expect(AppLucideIcons.resolveGymIcon('mobility'), AppLucideIcons.heart);
    });

    test('uses the provided fallback for unknown icon keys', () {
      expect(
        AppLucideIcons.resolveGymIcon(
          'unknown-dashboard-icon',
          fallback: AppLucideIcons.badgeCheck,
        ),
        AppLucideIcons.badgeCheck,
      );
    });
  });
}
