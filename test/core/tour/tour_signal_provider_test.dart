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

  // TourSession foi removido no ADR-021: o guard de sessão era redundante face
  // ao mecanismo de persistência por TourId (SharedPreferences 'offered').
}
