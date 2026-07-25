import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/preferences/preferences_state.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/senior_button.dart';

void main() {
  // ---------------------------------------------------------------------------
  // largeTouchTargetsProvider
  // ---------------------------------------------------------------------------

  group('largeTouchTargetsProvider', () {
    test('valor padrão é false (sem side-effects antes do override)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(largeTouchTargetsProvider), isFalse);
    });

    test('override com true é lido correctamente', () {
      final container = ProviderContainer(
        overrides: [largeTouchTargetsProvider.overrideWithValue(true)],
      );
      addTearDown(container.dispose);

      expect(container.read(largeTouchTargetsProvider), isTrue);
    });

    test('override com false mantém o comportamento padrão', () {
      final container = ProviderContainer(
        overrides: [largeTouchTargetsProvider.overrideWithValue(false)],
      );
      addTearDown(container.dispose);

      expect(container.read(largeTouchTargetsProvider), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // SeniorButton.resolveHeight — lógica pura, sem widget
  // ---------------------------------------------------------------------------

  group('SeniorButton.resolveHeight', () {
    group('largeTouchTargets=false (comportamento padrão)', () {
      test('size large → buttonHeight (56 px)', () {
        expect(
          SeniorButton.resolveHeight(SeniorButtonSize.large, false),
          AppTheme.buttonHeight,
        );
      });

      test('size medium → minTouchTarget (48 px)', () {
        expect(
          SeniorButton.resolveHeight(SeniorButtonSize.medium, false),
          AppTheme.minTouchTarget,
        );
      });
    });

    group('largeTouchTargets=true', () {
      test('size large → minTouchTargetLarge (64 px)', () {
        expect(
          SeniorButton.resolveHeight(SeniorButtonSize.large, true),
          AppTheme.minTouchTargetLarge,
        );
      });

      test('size medium → minTouchTargetLarge (64 px)', () {
        expect(
          SeniorButton.resolveHeight(SeniorButtonSize.medium, true),
          AppTheme.minTouchTargetLarge,
        );
      });

      test('minTouchTargetLarge é maior que buttonHeight', () {
        expect(AppTheme.minTouchTargetLarge, greaterThan(AppTheme.buttonHeight));
      });

      test('minTouchTargetLarge é maior que minTouchTarget', () {
        expect(
          AppTheme.minTouchTargetLarge,
          greaterThan(AppTheme.minTouchTarget),
        );
      });
    });
  });
}
