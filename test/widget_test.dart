import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/app.dart';

void main() {
  testWidgets('exibe tela inicial do SeniorEase', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SeniorEaseApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('SeniorEase'), findsOneWidget);
    expect(find.text('Bem-vindo ao SeniorEase'), findsOneWidget);
  });
}
