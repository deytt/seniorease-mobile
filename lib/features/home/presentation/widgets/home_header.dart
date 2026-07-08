import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/feedback/senior_feedback.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
import 'package:mobile/core/tour/tour_attention_wrapper.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/notifications/presentation/providers/notification_history_provider.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/presentation/providers/tasks_provider.dart';

/// Header gradiente com saudação dinâmica, nome do utilizador e botão SOS.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    super.key,
    this.tourScope,
    this.nextActivityShowcaseKey,
    this.onHelp,
    this.tourId,
  });

  /// Quando fornecidos, o cartão "Próxima atividade" torna-se alvo do tutorial
  /// guiado e é mostrado um botão de ajuda no header.
  final String? tourScope;
  final GlobalKey? nextActivityShowcaseKey;
  final VoidCallback? onHelp;

  /// Identificador do tour da tela inicial — controla se o tooltip é exibido.
  final TourId? tourId;

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia ☀️';
    if (hour < 18) return 'Boa tarde 🌤️';
    return 'Boa noite 🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).asData?.value;
    final firstName = user?.name.split(' ').firstOrNull ?? 'Usuário';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.paddingOf(context).top + AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expanded garante que textos longos não colidam com o SOS button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFBEDBFF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$firstName!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (onHelp != null) ...[
                _HeaderHelpButton(onTap: onHelp!, tourId: tourId),
                const SizedBox(width: AppSpacing.sm),
              ],
              _NotificationBell(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildNextActivity(ref),
        ],
      ),
    );
  }

  Widget _buildNextActivity(WidgetRef ref) {
    final card = _NextActivityCard(nextTask: ref.watch(nextPendingTaskProvider));
    if (tourScope == null || nextActivityShowcaseKey == null) return card;
    return SeniorShowcase(
      showcaseKey: nextActivityShowcaseKey!,
      scope: tourScope!,
      title: 'A sua próxima atividade',
      description:
          'Aqui aparece sempre a próxima tarefa. Toque em "Iniciar" para começar com ajuda passo a passo.',
      child: card,
    );
  }
}

/// Botão de ajuda em versão clara, para o header gradiente da Tela Inicial.
class _HeaderHelpButton extends ConsumerWidget {
  const _HeaderHelpButton({required this.onTap, this.tourId});

  final VoidCallback onTap;
  final TourId? tourId;

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
        child: TourAttentionWrapper(
          tourId: tourId,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                const Icon(Icons.help_outline, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Notification Bell

/// Botão sininho que navega para o histórico de notificações push.
/// Exibe um badge vermelho com a contagem de notificações recebidas hoje.
/// Ao abrir a Home, balança por 5 segundos para chamar a atenção do usuário.
class _NotificationBell extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<_NotificationBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bellCtrl;
  late final Animation<double> _shakeAnim;
  Timer? _stopTimer;

  static const _kBellDuration = Duration(seconds: 5);
  static const _kBellCycle = Duration(milliseconds: 450);

  @override
  void initState() {
    super.initState();
    _bellCtrl = AnimationController(vsync: this, duration: _kBellCycle);

    // Swing: centre → left → right → centre, giving a ringing bell feel.
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -0.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.1, end: 0.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.1, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
    ]).animate(_bellCtrl);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bellCtrl.repeat();
      _stopTimer = Timer(_kBellDuration, _stop);
    });
  }

  void _stop() {
    if (!mounted) return;
    _bellCtrl.stop();
    _bellCtrl.animateTo(0, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _bellCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayCount = ref.watch(todayNotificationCountProvider);
    final hasBadge = todayCount > 0;

    return Semantics(
      button: true,
      label: hasBadge
          ? 'Notificações — $todayCount nova${todayCount > 1 ? 's' : ''} hoje'
          : 'Ver notificações',
      child: GestureDetector(
        onTap: () {
          SeniorFeedback.light(ref);
          context.push(AppRoutes.notifications);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: AnimatedBuilder(
                animation: _shakeAnim,
                builder: (context, child) => Transform.rotate(
                  angle: _shakeAnim.value,
                  child: child,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            if (hasBadge)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 18, minHeight: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: todayCount < 10
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    borderRadius:
                        todayCount >= 10 ? BorderRadius.circular(9) : null,
                    border: Border.all(
                      color: AppColors.primaryDark,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      todayCount > 99 ? '99+' : '$todayCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Next Activity Card

class _NextActivityCard extends ConsumerWidget {
  const _NextActivityCard({required this.nextTask});

  final Task? nextTask;

  String _formatDueDate(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final isTomorrow = dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day + 1;

    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final time = '$hour:$min';

    if (isToday) return '$time · Hoje';
    if (isTomorrow) return '$time · Amanhã';

    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$time · $day/$month';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasTask = nextTask != null;

    final title = hasTask ? nextTask!.title : 'Nenhuma atividade agendada';
    final subtitle = hasTask
        ? (nextTask!.dueDate != null
            ? _formatDueDate(nextTask!.dueDate!)
            : 'Toque para iniciar')
        : 'Cria uma tarefa para começar';
    final buttonLabel = hasTask ? 'Iniciar →' : 'Criar →';
    final semanticCardLabel = hasTask
        ? 'Próxima atividade: $title. Toque em Iniciar para começar.'
        : 'Sem atividade agendada. Toque em Criar para adicionar uma tarefa.';
    final semanticButtonLabel =
        hasTask ? 'Iniciar tarefa: $title' : 'Criar nova tarefa';

    return Semantics(
      label: semanticCardLabel,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRÓXIMA ATIVIDADE',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFBEDBFF),
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        hasTask ? Icons.schedule : Icons.add_circle_outline,
                        size: 12,
                        color: const Color(0xFFDBEAFE),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Semantics(
              button: true,
              label: semanticButtonLabel,
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () {
                  SeniorFeedback.light(ref);
                  if (hasTask) {
                    context.push(AppRoutes.guidedTask(nextTask!.id));
                  } else {
                    context.push(AppRoutes.createTask);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    buttonLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
