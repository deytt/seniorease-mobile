import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/feedback/senior_feedback.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/senior_system_ui.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_modal.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/profile/presentation/providers/profile_provider.dart';
import 'package:mobile/features/profile/presentation/widgets/settings_nav_row.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with TourHost<SettingsScreen> {
  static const String _scope = 'settings';

  // Alvos do tutorial guiado (na ordem de exibição; o 1.º está no topo).
  final _navShowcaseKey = GlobalKey();
  final _helpShowcaseKey = GlobalKey();
  final _signOutShowcaseKey = GlobalKey();

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.settings;

  @override
  List<GlobalKey> get tourKeys =>
      [_navShowcaseKey, _helpShowcaseKey, _signOutShowcaseKey];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).asData?.value;
    final profile = ref.watch(profileProvider).asData?.value;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SeniorSystemUi.headerOverlay,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            _ProfileBanner(
              name: profile?.name.isNotEmpty == true
                  ? profile!.name
                  : (user?.name ?? ''),
              email: profile?.email.isNotEmpty == true
                  ? profile!.email
                  : (user?.email ?? ''),
              phone: profile?.hasPhone == true ? profile!.phone : null,
              photoUrl: profile?.hasPhoto == true ? profile!.photoUrl : null,
              onHelp: startTour,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    // Card de navegação
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: SeniorShowcase(
                        showcaseKey: _navShowcaseKey,
                        scope: _scope,
                        title: 'Atalhos das definições',
                        description:
                            'Aqui abre a acessibilidade, os guias do aplicativo e a página Sobre.',
                        child: _NavCard(
                          securityAlert: user != null && !user.emailVerified,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Card "Precisa de Ajuda?"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: SeniorShowcase(
                        showcaseKey: _helpShowcaseKey,
                        scope: _scope,
                        title: 'Precisa de ajuda?',
                        description:
                            'Tem sempre o nosso telefone de apoio à mão, a qualquer hora.',
                        child: _HelpCard(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Botão "Sair da Conta"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: SeniorShowcase(
                        showcaseKey: _signOutShowcaseKey,
                        scope: _scope,
                        title: 'Sair da conta',
                        description:
                            'Quando quiser sair, toque aqui. Pedimos sempre confirmação antes.',
                        child: SeniorButton(
                          label: 'Sair da Conta',
                          variant: SeniorButtonVariant.destructive,
                          icon: Icons.logout,
                          onPressed: _confirmSignOut,
                        ),
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

  Future<void> _confirmSignOut() async {
    await SeniorFeedback.medium(ref);
    if (!mounted) return;
    final confirmed = await showSeniorConfirmDialog(
      context: context,
      title: 'Sair da conta',
      message: 'Tem certeza de que deseja sair da conta SeniorEase?',
      confirmLabel: 'Sim, sair',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );
    if (confirmed == true && mounted) {
      await ref.read(authControllerProvider.notifier).signOut();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }
}

// ------------------------------------------------------------------ Profile Banner

class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner({
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.onHelp,
  });

  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final VoidCallback? onHelp;

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
              // Título + botão de ajuda (à direita)
              Row(
                children: [
                  const SizedBox(width: 44),
                  Expanded(
                    child: Text(
                      'Configurações',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: onHelp != null
                        ? _HeaderHelpButton(onTap: onHelp!)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Avatar — foto de perfil quando existir, senão as iniciais
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
                  image: photoUrl != null && photoUrl!.trim().isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoUrl != null && photoUrl!.trim().isNotEmpty
                    ? null
                    : Center(
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
                name.isNotEmpty ? name : 'Usuário',
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
              if (phone != null && phone!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      phone!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão de ajuda em versão clara, para o header gradiente das Definições.
class _HeaderHelpButton extends ConsumerWidget {
  const _HeaderHelpButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: 'Ver como funciona esta tela',
      child: GestureDetector(
        onTap: () {
          SeniorFeedback.light(ref);
          onTap();
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.help_outline, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Nav Card

class _NavCard extends StatelessWidget {
  const _NavCard({this.securityAlert = false});

  final bool securityAlert;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SettingsNavRow(
            icon: Icons.person_outline,
            label: 'Perfil',
            onTap: () => context.push(AppRoutes.profile),
          ),
          SettingsNavRow(
            icon: Icons.security_outlined,
            label: 'Segurança',
            showAlert: securityAlert,
            onTap: () => context.push(AppRoutes.security),
          ),
          SettingsNavRow(
            icon: Icons.notifications_outlined,
            label: 'Preferências de Notificação',
            onTap: () {},
          ),
          SettingsNavRow(
            icon: Icons.accessibility_new_outlined,
            label: 'Preferências de Acessibilidade',
            onTap: () => context.push(AppRoutes.accessibility),
          ),
          SettingsNavRow(
            icon: Icons.menu_book_outlined,
            label: 'Guias do aplicativo',
            onTap: () => context.push(AppRoutes.guides),
          ),
          SettingsNavRow(
            icon: Icons.info_outline,
            label: 'Sobre',
            onTap: () => context.push(AppRoutes.about),
            showDivider: false,
          ),
        ],
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
