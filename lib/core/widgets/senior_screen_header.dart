import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/feedback/senior_feedback.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/theme/senior_system_ui.dart';

class SeniorScreenHeader extends StatelessWidget {
  const SeniorScreenHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.subtitleWidget,
    this.showBackButton = true,
    this.backIcon = Icons.arrow_back,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;

  /// Widget exibido abaixo da linha do título, dentro do header.
  /// Alternativa ao [subtitle] textual — use para badges, chips ou conteúdo
  /// estruturado. Se ambos forem fornecidos, [subtitleWidget] tem precedência.
  final Widget? subtitleWidget;
  final bool showBackButton;

  /// Ícone do botão de retroceder (ex: [Icons.close] para ecrãs de criação).
  final IconData backIcon;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SeniorSystemUi.headerOverlay,
      child: ColoredBox(
        color: theme.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                MediaQuery.paddingOf(context).top + 12,
                AppSpacing.md,
                subtitle != null ? AppSpacing.sm : 17,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showBackButton) ...[
                    _BackButton(
                      icon: backIcon,
                      onPressed:
                          onBack ?? () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailing != null) ...[trailing!],
                ],
              ),
            ),
            if (subtitleWidget != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: subtitleWidget!,
              )
            else if (subtitle != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const Divider(height: 1, thickness: 1, color: AppColors.slate200),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends ConsumerWidget {
  const _BackButton({required this.onPressed, this.icon = Icons.arrow_back});

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: icon == Icons.close ? 'Fechar' : 'Voltar',
      child: GestureDetector(
        onTap: () {
          SeniorFeedback.light(ref);
          onPressed();
        },
        child: Container(
          width: AppTheme.minTouchTarget,
          height: AppTheme.minTouchTarget,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            size: AppTheme.backButtonIconSize,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
