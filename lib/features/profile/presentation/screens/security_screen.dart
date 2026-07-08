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

/// Tela "Segurança": reúne as opções para proteger a conta. As funcionalidades
/// (biometria, verificação por e-mail e alterar palavra-passe) ainda não estão
/// disponíveis e aparecem com o selo "Em breve".
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
                    description:
                        'Em breve poderá entrar com a impressão digital ou o rosto, '
                        'sem precisar de escrever a palavra-passe.',
                    child: _SecurityRow(
                      icon: Icons.fingerprint,
                      label: 'Habilitar biometria',
                      onTap: _showComingSoon,
                      trailing: const _ComingSoonBadge(),
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
        color: AppColors.warningLight,
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
                color: Color(0xFF92400E),
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'A sua conta ainda não foi verificada',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF92400E),
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
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
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

/// Selo verde "Conta verificada".
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        border: Border.all(color: AppColors.success),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 14, color: AppColors.successDark),
          const SizedBox(width: 4),
          Text(
            'Verificada',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.successDark,
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
        color: AppColors.warningLight,
        border: Border.all(color: AppColors.warning),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Não verificado',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF92400E),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// Linha de opção de segurança com selo "Em breve". Segue o visual de
/// `SettingsNavRow`, mas indica que a funcionalidade ainda não está disponível.
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
                    color: AppColors.primaryLight,
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
        color: AppColors.warningLight,
        border: Border.all(color: AppColors.warning),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Em breve',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              // Âmbar escuro para garantir contraste AA sobre o fundo claro.
              color: const Color(0xFF92400E),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
