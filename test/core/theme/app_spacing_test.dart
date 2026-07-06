import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';

void main() {
  group('AppSpacing.factor', () {
    test('compact retorna 0.75', () {
      expect(AppSpacing.factor(SpacingMode.compact), 0.75);
    });

    test('comfortable retorna 1.0', () {
      expect(AppSpacing.factor(SpacingMode.comfortable), 1.0);
    });

    test('spacious retorna 1.5', () {
      expect(AppSpacing.factor(SpacingMode.spacious), 1.5);
    });
  });
}
