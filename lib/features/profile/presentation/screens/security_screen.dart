import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/feedback/senior_feedback.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_help_button.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_screen_scaffold.dart';
import 'package:mobile/core/widgets/senior_toast.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/providers/biometric_provider.dart';

/// Tela "Segurança": reúne as opções para proteger a conta.
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen>
    with TourHost<SecurityScreen> {
  static const String _scope = 'security';

  // Alvos do tutorial guiado (na ordem de exibição; o 1.º está no topo).
  final _biometricShowcaseKey = GlobalKey();
  final _verifyShowcaseKey = GlobalKey();
  final _passwordShowcaseKey = GlobalKey();

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.security;

  @override
  List<GlobalKey> get tourKeys =>
      [_biometricShowcaseKey, _verifyShowcaseKey, _passwordShowcaseKey];

  // Envio do e-mail de verificação em curso.
  bool _sending = false;
  // Verificação ("Já confirmei") em curso.
  bool _checking = false;
  // Mostra o painel de ajuda depois de o utilizador iniciar a verificação.
  bool _verificationStarted = false;

  void _showComingSoon() {
    SeniorFeedback.light(ref);
    showSeniorToast(
      context,
      title: 'Em breve',
      message: 'Esta opção estará disponível numa próxima atualização.',
    );
  }

  Future<void> _toggleBiometric({required bool currentlyEnabled}) async {
    await SeniorFeedback.light(ref);

    try {
      final controller = ref.read(biometricControllerProvider.notifier);
      final confirmed = currentlyEnabled
          ? await controller.disable()
          : await controller.enable();

      if (!mounted) return;

      if (confirmed) {
        showSeniorToast(
          context,
          title: currentlyEnabled ? 'Biometria desativada' : 'Biometria ativada',
          message: currentlyEnabled
              ? 'O desbloqueio biométrico foi desativado.'
              : 'Pode agora entrar com a impressão digital ou o rosto.',
          variant: SeniorToastVariant.success,
        );
      }
    } on Exception catch (error) {
      if (!mounted) return;
      showSeniorToast(
        context,
        title: 'Não foi possível alterar',
        message: error.toString().replaceFirst('Exception: ', ''),
        variant: SeniorToastVariant.danger,
      );
    }
  }

  Future<void> _startVerification() async {
    await SeniorFeedback.light(ref);
    setState(() {
      _sending = true;
      _verificationStarted = true;
    });
    try {
      await ref.read(authControllerProvider.notifier).sendEmailVerification();
      if (!mounted) return;
      showSeniorToast(
        context,
        title: 'E-mail enviado',
        message: 'Abra a mensagem que enviámos e toque no link para confirmar.',
        variant: SeniorToastVariant.success,
      );
    } catch (error) {
      if (!mounted) return;
      showSeniorToast(
        context,
        title: 'Não foi possível enviar',
        message: error.toString().replaceFirst('Exception: ', ''),
        variant: SeniorToastVariant.danger,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _confirmVerification() async {
    await SeniorFeedback.light(ref);
    setState(() => _checking = true);
    try {
      final verified =
          await ref.read(authControllerProvider.notifier).refreshEmailVerification();
      if (!mounted) return;
      if (verified) {
        showSeniorToast(
          context,
          title: 'Conta verificada',
          message: 'Obrigado! A sua conta está confirmada.',
          variant: SeniorToastVariant.success,
        );
      } else {
        showSeniorToast(
          context,
          title: 'Ainda não confirmado',
          message:
              'Não encontrámos a confirmação. Abra o link no e-mail e tente novamente.',
          variant: SeniorToastVariant.warning,
        );
      }
    } catch (error) {
      if (!mounted) return;
      showSeniorToast(
        context,
        title: 'Não foi possível verificar',
        message: error.toString().replaceFirst('Exception: ', ''),
        variant: SeniorToastVariant.danger,
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerified =
        ref.watch(authStateProvider).asData?.value?.emailVerified ?? false;

    final biometricAsync = ref.watch(biometricControllerProvider);
    final biometricState = biometricAsync.asData?.value;
    final isBiometricLoading = biometricAsync.isLoading;

    return SeniorScreenScaffold(
      title: 'Segurança',
      subtitle: 'Proteja a sua conta',
      backIcon: Icons.chevron_left,
      onBack: () => Navigator.of(context).pop(),
      trailing: TourHelpButton(onPressed: startTour, tourId: tourId),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SeniorShowcase(
                    showcaseKey: _biometricShowcaseKey,
                    scope: _scope,
                    title: 'Desbloqueio com biometria',
                    description: biometricState?.isAvailable == true
                        ? 'Ative para entrar com a impressão digital ou o rosto, '
                            'sem precisar de escrever a palavra-passe.'
                        : 'Permite entrar com a impressão digital ou o rosto. '
                            'Disponível em dispositivos com sensor biométrico.',
                    child: _SecurityRow(
                      icon: Icons.fingerprint,
                      label: biometricState?.isEnabled == true
                          ? 'Desativar biometria'
                          : 'Habilitar biometria',
                      onTap: isBiometricLoading || biometricState?.isAvailable != true
                          ? (biometricState?.isAvailable != true
                              ? _showBiometricUnavailable
                              : null)
                          : () => _toggleBiometric(
                                currentlyEnabled: biometricState!.isEnabled,
                              ),
                      trailing: _BiometricTrailing(
                        isLoading: isBiometricLoading,
                        isAvailable: biometricState?.isAvailable ?? false,
                        isEnabled: biometricState?.isEnabled ?? false,
                      ),
                    ),
                  ),
                  SeniorShowcase(
                    showcaseKey: _verifyShowcaseKey,
                    scope: _scope,
                    title: 'Verificar a conta',
                    description:
                        'Confirme o seu e-mail para manter a conta mais segura.',
                    child: _SecurityRow(
                      icon: Icons.mark_email_read_outlined,
                      label: 'Verificar conta',
                      onTap: isVerified || _sending ? null : _startVerification,
                      trailing: isVerified
                          ? const _VerifiedBadge()
                          : const _NotVerifiedBadge(),
                    ),
                  ),
                  SeniorShowcase(
                    showcaseKey: _passwordShowcaseKey,
                    scope: _scope,
                    title: 'Alterar a palavra-passe',
                    description:
                        'Em breve poderá definir uma nova palavra-passe sempre que '
                        'quiser.',
                    child: _SecurityRow(
                      icon: Icons.lock_outline,
                      label: 'Alterar senha',
                      onTap: _showComingSoon,
                      showDivider: false,
                      trailing: const _ComingSoonBadge(),
                    ),
                  ),
                ],
              ),
            ),
            if (!isVerified) ...[
              const SizedBox(height: AppSpacing.md),
              _VerificationPanel(
                started: _verificationStarted,
                sending: _sending,
                checking: _checking,
                onSend: _startVerification,
                onConfirm: _confirmVerification,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              isVerified
                  ? 'A sua conta está protegida. Em breve teremos mais opções de segurança.'
                  : 'Confirmar o e-mail ajuda a manter a sua conta protegida.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.slate500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBiometricUnavailable() {
    SeniorFeedback.light(ref);
    showSeniorToast(
      context,
      title: 'Biometria não disponível',
      message:
          'O seu dispositivo não tem sensor biométrico configurado. '
          'Active nas definições do sistema.',
      variant: SeniorToastVariant.warning,
    );
  }
}

/// Painel de ajuda para a verificação de e-mail. Antes de iniciar, mostra um
/// convite a enviar o e-mail; depois de enviado, explica os próximos passos e
/// oferece o botão "Já confirmei o meu e-mail".
class _VerificationPanel extends StatelessWidget {
  const _VerificationPanel({
    required this.started,
    required this.sending,
    required this.checking,
    required this.onSend,
    required this.onConfirm,
  });

  final bool started;
  final bool sending;
  final bool checking;
  final VoidCallback onSend;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                color: AppColors.warning,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'A sua conta ainda não foi verificada',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            started
                ? 'Enviámos um link para o seu e-mail. Abra a mensagem, toque no '
                    'link para confirmar e depois volte aqui e toque em '
                    '"Já confirmei o meu e-mail".'
                : 'Vamos enviar um link para o seu e-mail. Basta abrir a mensagem '
                    'e tocar no link para confirmar a sua conta.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!started)
            SeniorButton(
              label: 'Enviar e-mail de verificação',
              icon: Icons.mail_outline,
              isLoading: sending,
              onPressed: sending ? null : onSend,
            )
          else ...[
            SeniorButton(
              label: 'Já confirmei o meu e-mail',
              icon: Icons.check_circle_outline,
              isLoading: checking,
              onPressed: checking ? null : onConfirm,
            ),
            const SizedBox(height: AppSpacing.sm),
            SeniorButton(
              label: 'Reenviar e-mail',
              variant: SeniorButtonVariant.outline,
              size: SeniorButtonSize.medium,
              icon: Icons.refresh,
              onPressed: sending ? null : onSend,
            ),
          ],
        ],
      ),
    );
  }
}

/// Trailing da linha de biometria: mostra loading, ou um dos três selos
/// (indisponível / ativo / inativo).
class _BiometricTrailing extends StatelessWidget {
  const _BiometricTrailing({
    required this.isLoading,
    required this.isAvailable,
    required this.isEnabled,
  });

  final bool isLoading;
  final bool isAvailable;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (!isAvailable) return const _ComingSoonBadge();
    if (isEnabled) return const _BiometricActiveBadge();
    return const _BiometricInactiveBadge();
  }
}

/// Selo verde "Ativo".
class _BiometricActiveBadge extends StatelessWidget {
  const _BiometricActiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 14, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            'Ativo',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Selo cinzento "Inativo".
class _BiometricInactiveBadge extends StatelessWidget {
  const _BiometricInactiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.slate200.withValues(alpha: 0.6),
        border: Border.all(color: AppColors.slate300),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Inativo',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.slate500,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// Selo verde "Conta verificada".
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 14, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            'Verificada',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Selo âmbar "Não verificado".
class _NotVerifiedBadge extends StatelessWidget {
  const _NotVerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Não verificado',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// Linha de opção de segurança. Segue o visual de `SettingsNavRow`.
class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.trailing,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 4,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                trailing,
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: AppSpacing.md + 44 + AppSpacing.md,
            endIndent: AppSpacing.md,
            color: theme.colorScheme.outline,
          ),
      ],
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Em breve',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
