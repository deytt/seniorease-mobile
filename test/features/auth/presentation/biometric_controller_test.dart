import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/domain/repositories/biometric_repository.dart';
import 'package:mobile/features/auth/presentation/providers/biometric_provider.dart';

class MockBiometricRepository extends Mock implements BiometricRepository {}

void main() {
  late MockBiometricRepository repo;

  setUp(() {
    repo = MockBiometricRepository();
    // Resposta padrão para setEnabled — sobrescrita por teste específico.
    when(() => repo.setEnabled(value: any(named: 'value')))
        .thenAnswer((_) async {});
  });

  /// Cria um [ProviderContainer] com o repositório mock injetado.
  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        biometricRepositoryProvider.overrideWith((_) async => repo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('BiometricController', () {
    test('build() — inicializa com isAvailable e isEnabled do repositório',
        () async {
      when(() => repo.isAvailable()).thenAnswer((_) async => true);
      when(() => repo.isEnabled()).thenReturn(false);

      final container = makeContainer();
      // Aguarda o estado async resolver.
      final state = await container.read(biometricControllerProvider.future);

      expect(state.isAvailable, isTrue);
      expect(state.isEnabled, isFalse);
    });

    test('enable() — quando sucesso → estado muda para isEnabled=true',
        () async {
      when(() => repo.isAvailable()).thenAnswer((_) async => true);
      when(() => repo.isEnabled()).thenReturn(false);
      when(() => repo.authenticate(reason: any(named: 'reason')))
          .thenAnswer((_) async => true);

      final container = makeContainer();
      await container.read(biometricControllerProvider.future);

      final result =
          await container.read(biometricControllerProvider.notifier).enable();

      expect(result, isTrue);
      final newState =
          container.read(biometricControllerProvider).asData?.value;
      expect(newState?.isEnabled, isTrue);
    });

    test('disable() — quando sucesso → estado muda para isEnabled=false',
        () async {
      when(() => repo.isAvailable()).thenAnswer((_) async => true);
      when(() => repo.isEnabled()).thenReturn(true);
      when(() => repo.authenticate(reason: any(named: 'reason')))
          .thenAnswer((_) async => true);

      final container = makeContainer();
      await container.read(biometricControllerProvider.future);

      final result =
          await container.read(biometricControllerProvider.notifier).disable();

      expect(result, isTrue);
      final newState =
          container.read(biometricControllerProvider).asData?.value;
      expect(newState?.isEnabled, isFalse);
    });

    test(
        'enable() — quando isAvailable=false → estado fica AsyncError e relança',
        () async {
      when(() => repo.isAvailable()).thenAnswer((_) async => false);
      when(() => repo.isEnabled()).thenReturn(false);

      final container = makeContainer();
      await container.read(biometricControllerProvider.future);

      expect(
        () => container.read(biometricControllerProvider.notifier).enable(),
        throwsException,
      );

      // Aguarda o microtask da exceção ser processado.
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(biometricControllerProvider),
        isA<AsyncError<BiometricState>>(),
      );
    });
  });
}
