import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/core/tour/tour_signal_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  group('TourSignal', () {
    test('estado inicial é null', () {
      expect(container.read(tourSignalProvider), isNull);
    });

    test('request define o sinal e clear limpa-o', () {
      final notifier = container.read(tourSignalProvider.notifier);

      notifier.request(TourId.createTask);
      expect(container.read(tourSignalProvider), TourId.createTask);

      notifier.clear();
      expect(container.read(tourSignalProvider), isNull);
    });
  });

  group('TourSession', () {
    test('começa sem oferta automática', () {
      expect(container.read(tourSessionProvider), isFalse);
      expect(container.read(tourSessionProvider.notifier).hasAutoOffered,
          isFalse);
    });

    test('markAutoOffered marca a sessão', () {
      container.read(tourSessionProvider.notifier).markAutoOffered();
      expect(container.read(tourSessionProvider), isTrue);
      expect(
          container.read(tourSessionProvider.notifier).hasAutoOffered, isTrue);
    });
  });
}
