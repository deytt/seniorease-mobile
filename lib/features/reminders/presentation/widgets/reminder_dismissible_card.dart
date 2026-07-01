import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/senior_modal.dart';
import 'package:mobile/core/widgets/senior_toast.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:mobile/features/reminders/presentation/widgets/reminder_card.dart';

/// Card de lembrete com swipe bidirecional integrado no mesmo contorno:
/// arrastar para a esquerda revela **Excluir** (direita) e para a direita
/// revela **Editar** (esquerda). Apenas um card aberto por vez e num único
/// lado. Tocar no corpo expande/recolhe a descrição. Lembretes concluídos não
/// podem ser editados nem excluídos (gesto desativado).
class ReminderDismissibleCard extends ConsumerStatefulWidget {
  const ReminderDismissibleCard({
    required this.reminder,
    required this.onMarkDone,
    required this.onDelete,
    this.playHint = false,
    this.highlighted = false,
    this.highlightKey,
    super.key,
  });

  final Reminder reminder;
  final VoidCallback onMarkDone;
  final Future<void> Function() onDelete;

  /// Toca a animação de dica ("peek") revelando os dois lados brevemente.
  final bool playHint;

  /// Quando `true`, o card pulsa para destacar (ex.: vindo da Home).
  final bool highlighted;

  /// Chave usada pelo ecrã para trazer este card à vista (`ensureVisible`).
  final GlobalKey? highlightKey;

  static const actionWidth = AppTheme.minTouchTarget + 8;

  @override
  ConsumerState<ReminderDismissibleCard> createState() =>
      _ReminderDismissibleCardState();
}

class _ReminderDismissibleCardState
    extends ConsumerState<ReminderDismissibleCard>
    with TickerProviderStateMixin {
  /// Offset assinado usado durante o gesto: positivo revela Excluir (direita),
  /// negativo revela Editar (esquerda).
  double _dragOffset = 0;
  bool _isDragging = false;

  late final AnimationController _hintController;
  late final Animation<double> _hintAnim;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..addListener(() => setState(() {}));

    const double peek = ReminderDismissibleCard.actionWidth * 0.62;
    _hintAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 12),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: peek).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: peek, end: 0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 18,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 8),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -peek).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -peek, end: 0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 18,
      ),
    ]).animate(_hintController);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    if (widget.playHint && !widget.reminder.isDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _hintController.forward();
      });
    }
    if (widget.highlighted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ReminderDismissibleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reminder.id != widget.reminder.id) {
      _resetLocalDrag();
    }
    if (widget.highlighted && !oldWidget.highlighted) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.highlighted && oldWidget.highlighted) {
      _pulseController
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _hintController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _resetLocalDrag() {
    _dragOffset = 0;
    _isDragging = false;
  }

  void _closeSwipe() {
    ref.read(openReminderSwipeProvider.notifier).close();
    setState(_resetLocalDrag);
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_hintController.isAnimating) _hintController.stop();
    ref.read(openReminderSwipeProvider.notifier).close();
    setState(() {
      _isDragging = true;
      _dragOffset = 0;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_dragOffset - details.delta.dx).clamp(
        -ReminderDismissibleCard.actionWidth,
        ReminderDismissibleCard.actionWidth,
      );
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final threshold = ReminderDismissibleCard.actionWidth / 2;
    final offset = _dragOffset;
    setState(_resetLocalDrag);

    final notifier = ref.read(openReminderSwipeProvider.notifier);
    if (offset > threshold) {
      notifier.open(widget.reminder.id, ReminderSwipeSide.delete);
    } else if (offset < -threshold) {
      notifier.open(widget.reminder.id, ReminderSwipeSide.edit);
    } else {
      notifier.closeIf(widget.reminder.id);
    }
  }

  void _handleTap() {
    // Com um swipe aberto, o toque fecha-o em vez de expandir.
    final open = ref.read(openReminderSwipeProvider);
    if (open?.id == widget.reminder.id) {
      _closeSwipe();
      return;
    }
    HapticFeedback.selectionClick();
    ref.read(expandedReminderIdProvider.notifier).toggle(widget.reminder.id);
  }

  Future<void> _handleDeleteTap() async {
    final open = ref.read(openReminderSwipeProvider);
    if (open?.id != widget.reminder.id && !_isDragging) return;

    HapticFeedback.mediumImpact();
    final confirmed = await showSeniorConfirmDialog(
      context: context,
      title: 'Excluir lembrete?',
      message:
          'Tem certeza de que deseja excluir este lembrete? Essa ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );

    if (!mounted) return;

    if (confirmed != true) {
      _closeSwipe();
      return;
    }

    _closeSwipe();
    await widget.onDelete();
    if (!mounted) return;

    showSeniorToast(
      context,
      title: 'Lembrete excluído',
      message: 'O lembrete foi removido.',
      variant: SeniorToastVariant.info,
    );
  }

  void _handleEditTap() {
    final open = ref.read(openReminderSwipeProvider);
    if (open?.id != widget.reminder.id && !_isDragging) return;

    HapticFeedback.lightImpact();
    _closeSwipe();
    context.push(
      AppRoutes.editReminder(widget.reminder.id),
      extra: widget.reminder,
    );
  }

  double _effectiveOffset(ReminderSwipe? open) {
    if (_isDragging) return _dragOffset;
    if (_hintController.isAnimating) return _hintAnim.value;
    if (open?.id == widget.reminder.id) {
      return open!.side == ReminderSwipeSide.delete
          ? ReminderDismissibleCard.actionWidth
          : -ReminderDismissibleCard.actionWidth;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final open = ref.watch(openReminderSwipeProvider);
    final expanded =
        ref.watch(expandedReminderIdProvider) == widget.reminder.id;

    ref.listen<ReminderSwipe?>(openReminderSwipeProvider, (previous, next) {
      if (next?.id != widget.reminder.id && mounted) {
        setState(_resetLocalDrag);
      }
    });

    final theme = Theme.of(context);
    final isDone = widget.reminder.isDone;
    final offset = _effectiveOffset(open);
    final revealDelete = offset > 0.5;
    final revealEdit = offset < -0.5;

    return KeyedSubtree(
      key: widget.highlightKey,
      child: Semantics(
        container: true,
        label: widget.reminder.title,
        child: Opacity(
          opacity: isDone ? 0.7 : 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                if (revealEdit)
                  _ActionStrip(
                    alignment: Alignment.centerLeft,
                    icon: Icons.edit_outlined,
                    color: AppColors.primary,
                    background: AppColors.primaryLight,
                    borderColor: theme.colorScheme.outline,
                    semanticLabel: 'Editar lembrete',
                    onTap: _handleEditTap,
                  ),
                if (revealDelete)
                  _ActionStrip(
                    alignment: Alignment.centerRight,
                    icon: Icons.delete_outline,
                    color: AppColors.danger,
                    background: AppColors.dangerLight,
                    borderColor: theme.colorScheme.outline,
                    semanticLabel: 'Excluir lembrete',
                    onTap: _handleDeleteTap,
                  ),
                Transform.translate(
                  offset: Offset(-offset, 0),
                  child: GestureDetector(
                    onTap: _handleTap,
                    onHorizontalDragStart:
                        isDone ? null : _onHorizontalDragStart,
                    onHorizontalDragUpdate:
                        isDone ? null : _onHorizontalDragUpdate,
                    onHorizontalDragEnd: isDone ? null : _onHorizontalDragEnd,
                    child: DecoratedBox(
                      decoration: ReminderCard.shellDecoration(
                        context,
                        isDone: isDone,
                      ),
                      child: ReminderCard(
                        reminder: widget.reminder,
                        onMarkDone: widget.onMarkDone,
                        showShell: false,
                        expanded: expanded,
                      ),
                    ),
                  ),
                ),
                // Pulso de destaque (não intercepta toques).
                if (widget.highlighted)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) => DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withValues(
                                alpha: 0.35 + 0.45 * _pulseController.value,
                              ),
                              width: 2.5,
                            ),
                            color: AppColors.primary.withValues(
                              alpha: 0.06 * _pulseController.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Faixa de ação (Editar/Excluir) revelada pelo swipe, dentro do contorno.
class _ActionStrip extends StatelessWidget {
  const _ActionStrip({
    required this.alignment,
    required this.icon,
    required this.color,
    required this.background,
    required this.borderColor,
    required this.semanticLabel,
    required this.onTap,
  });

  final Alignment alignment;
  final IconData icon;
  final Color color;
  final Color background;
  final Color borderColor;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: alignment == Alignment.centerLeft ? 0 : null,
      right: alignment == Alignment.centerRight ? 0 : null,
      width: ReminderDismissibleCard.actionWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Semantics(
          button: true,
          label: semanticLabel,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Center(child: Icon(icon, color: color, size: 20)),
            ),
          ),
        ),
      ),
    );
  }
}
