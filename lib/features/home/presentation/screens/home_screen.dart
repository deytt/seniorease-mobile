import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_screen_scaffold.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;

    return SeniorScreenScaffold(
      title: 'SeniorEase',
      showBackButton: false,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.accessibility_new,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                user != null ? 'Olá, ${user.name}!' : 'Bem-vindo ao SeniorEase',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Plataforma de inclusão digital para idosos.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              SeniorButton(
                label: 'Definições de Acessibilidade',
                icon: Icons.accessibility_new,
                onPressed: () => context.push(AppRoutes.accessibility),
              ),
              const SizedBox(height: AppSpacing.sm),
              SeniorButton(
                label: 'Sair da conta',
                variant: SeniorButtonVariant.secondary,
                icon: Icons.logout,
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
