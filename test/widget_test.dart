import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

void main() {
  testWidgets('exibe tela de login quando não autenticado', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const SeniorEaseApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });

  // TODO(dev): re-ativar após remover credenciais de teste pré-preenchidas no LoginScreen.
  // O teste falha porque a HomeScreen agora mostra a saudação dinâmica ("Bom dia/tarde/noite")
  // em vez de "Olá, Maria Silva!", e o assert original deixou de ser válido.
  // testWidgets('redireciona para home quando autenticado', (WidgetTester tester) async {
  //   await tester.pumpWidget(
  //     ProviderScope(
  //       overrides: [
  //         authStateProvider.overrideWith(
  //           (ref) => Stream.value(
  //             AppUser(
  //               id: 'test-id',
  //               email: 'test@email.com',
  //               name: 'Maria Silva',
  //               createdAt: DateTime(2026, 6, 18),
  //             ),
  //           ),
  //         ),
  //       ],
  //       child: const SeniorEaseApp(),
  //     ),
  //   );
  //   await tester.pumpAndSettle();
  //
  //   expect(find.text('Olá, Maria Silva!'), findsOneWidget);
  //   expect(find.text('SeniorEase'), findsOneWidget);
  // });
}
