import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/features/guides/presentation/tutorial_catalog.dart';

void main() {
  group('kTutorials', () {
    test('inclui o tutorial de acessibilidade', () {
      expect(
        kTutorials.any((t) => t.id == TourId.accessibility),
        isTrue,
      );
    });

    test('todas as entradas têm rota não vazia e título', () {
      for (final t in kTutorials) {
        expect(t.route, isNotEmpty, reason: 'rota vazia em ${t.id}');
        expect(t.title, isNotEmpty, reason: 'título vazio em ${t.id}');
        expect(t.description, isNotEmpty, reason: 'descrição vazia em ${t.id}');
      }
    });

    test('não há TourId duplicado no catálogo', () {
      final ids = kTutorials.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });
}
