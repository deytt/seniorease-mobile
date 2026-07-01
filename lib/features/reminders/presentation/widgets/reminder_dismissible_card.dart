import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/senior_modal.dart';
import 'package:mobile/core/widgets/senior_toast.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:mobile/features/reminders/presentation/widgets/reminder_card.dart';

/// Card com swipe parcial integrado — a faixa de excluir fica dentro do mesmo
/// contorno do card (Figma). Apenas um card pode estar aberto por vez.
class ReminderDismissibleCard extends ConsumerStatefulWidget {
  const ReminderDismissibleCard({
    required this.reminder,
    required this.onMarkDone,
    required this.onDelete,
    super.key,
  });

  final Reminder reminder;
  final VoidCallback onMarkDone;
  final Future<void> Function() onDelete;

  static const actionWidth = AppTheme.minTouchTarget + 8;

  @override
  ConsumerState<ReminderDismissibleCard> createState() =>
      _ReminderDismissibleCardState();
}

class _ReminderDismissibleCardState
    extends ConsumerState<ReminderDismissibleCard> {
  /// Offset usado apenas durante o gesto ativo de arrastar.
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  void didUpdateWidget(covariant ReminderDismissibleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reminder.id != widget.reminder.id) {
      _resetLocalDrag();
    }
  }

  void _resetLocalDrag() {
    _dragOffset = 0;
    _isDragging = false;
  }

  void _closeSwipe() {
    ref.read(openReminderSwipeIdProvider.notifier).close();
    setState(_resetLocalDrag);
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    ref.read(openReminderSwipeIdProvider.notifier).close();
    setState(() {
      _isDragging = true;
      _dragOffset = 0;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_dragOffset - details.delta.dx)
          .clamp(0.0, ReminderDismissibleCard.actionWidth);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final open = _dragOffset > ReminderDismissibleCard.actionWidth / 2;
    setState(_resetLocalDrag);
    if (open) {
      ref.read(openReminderSwipeIdProvider.notifier).open(widget.reminder.id);
    } else {
      ref.read(openReminderSwipeIdProvider.notifier).closeIf(widget.reminder.id);
    }
  }

  Future<void> _handleDeleteTap() async {
    final openId = ref.read(openReminderSwipeIdProvider);
    if (openId != widget.reminder.id && !_isDragging) return;

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

    // Qualquer resultado que não seja confirmação explícita fecha o swipe.
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

  double _effectiveOffset(String? openId) {
    if (_isDragging) return _dragOffset;
    if (openId == widget.reminder.id) {
      return ReminderDismissibleCard.actionWidth;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final openId = ref.watch(openReminderSwipeIdProvider);

    ref.listen<String?>(openReminderSwipeIdProvider, (previous, next) {
      if (next != widget.reminder.id && mounted) {
        setState(_resetLocalDrag);
      }
    });

    final theme = Theme.of(context);
    final isDone = widget.reminder.isDone;
    final offset = _effectiveOffset(openId);
    final revealDelete = offset > 0;

    return Semantics(
      container: true,
      label: widget.reminder.title,
      child: Opacity(
        opacity: isDone ? 0.7 : 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (revealDelete)
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  width: ReminderDismissibleCard.actionWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: Semantics(
                      button: true,
                      label: 'Excluir lembrete',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleDeleteTap,
                          child: const Center(
                            child: Icon(
                              Icons.delete_outline,
                              color: AppColors.danger,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(-offset, 0),
                child: GestureDetector(
                  onHorizontalDragStart: _onHorizontalDragStart,
                  onHorizontalDragUpdate: _onHorizontalDragUpdate,
                  onHorizontalDragEnd: _onHorizontalDragEnd,
                  child: DecoratedBox(
                    decoration: ReminderCard.shellDecoration(
                      context,
                      isDone: isDone,
                    ),
                    child: ReminderCard(
                      reminder: widget.reminder,
                      onMarkDone: widget.onMarkDone,
                      showShell: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
