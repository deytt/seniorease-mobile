import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/senior_system_ui.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_modal.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/profile/presentation/widgets/settings_nav_row.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SeniorSystemUi.headerOverlay,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            _ProfileBanner(
              name: user?.name ?? '',
              email: user?.email ?? '',
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    // Card de navegação
                    _NavCard(),
                    const SizedBox(height: AppSpacing.md),
                    // Card "Precisa de Ajuda?"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: _HelpCard(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Botão "Sair da Conta"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: SeniorButton(
                        label: 'Sair da Conta',
                        variant: SeniorButtonVariant.destructive,
                        icon: Icons.logout,
                        onPressed: () => _confirmSignOut(context, ref),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showSeniorConfirmDialog(
      context: context,
      title: 'Sair da conta',
      message: 'Tens a certeza que queres sair da conta SeniorEase?',
      confirmLabel: 'Sim, sair',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      await ref.read(authControllerProvider.notifier).signOut();
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    }
  }
}

// ------------------------------------------------------------------ Profile Banner

class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner({required this.name, required this.email});

  final String name;
  final String email;

  String get _initials {
    final parts = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          child: Column(
            children: [
              // Título
              Text(
                'Definições',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                name.isNotEmpty ? name : 'Utilizador',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Nav Card

class _NavCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Builder(
              builder: (ctx) => SettingsNavRow(
                icon: Icons.person_outline,
                label: 'Informação Pessoal',
                onTap: () {},
              ),
            ),
            Builder(
              builder: (ctx) => SettingsNavRow(
                icon: Icons.notifications_outlined,
                label: 'Preferências de Notificação',
                onTap: () {},
              ),
            ),
            Builder(
              builder: (ctx) => SettingsNavRow(
                icon: Icons.accessibility_new_outlined,
                label: 'Preferências de Acessibilidade',
                onTap: () => context.push(AppRoutes.accessibility),
              ),
            ),
            Builder(
              builder: (ctx) => SettingsNavRow(
                icon: Icons.people_outline,
                label: 'Membros da Família',
                onTap: () {},
              ),
            ),
            SettingsNavRow(
              icon: Icons.lock_outline,
              label: 'Segurança',
              onTap: () {},
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Help Card

class _HelpCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star_border_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Precisa de Ajuda?',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ligue para a nossa equipa de suporte a qualquer hora — estamos aqui para si.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryDark.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.phone,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '1-800-SENIOR',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
