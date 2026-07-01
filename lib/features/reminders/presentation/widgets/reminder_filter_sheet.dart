import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_filter.dart';

/// Bottom sheet de filtros para a lista de lembretes.
///
/// Recebe o [initialFilter] activo e devolve o novo [ReminderFilter] via
/// [onApply]. O estado local do sheet não afecta a lista até o utilizador tocar
/// em "Aplicar".
class ReminderFilterSheet extends StatefulWidget {
  const ReminderFilterSheet({
    required this.initialFilter,
    required this.onApply,
    super.key,
  });

  final ReminderFilter initialFilter;
  final ValueChanged<ReminderFilter> onApply;

  static Future<void> show(
    BuildContext context, {
    required ReminderFilter initialFilter,
    required ValueChanged<ReminderFilter> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReminderFilterSheet(
        initialFilter: initialFilter,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ReminderFilterSheet> createState() => _ReminderFilterSheetState();
}

class _ReminderFilterSheetState extends State<ReminderFilterSheet> {
  late ReminderFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  void _toggleToday() {
    HapticFeedback.selectionClick();
    setState(() => _filter = _filter.copyWith(isToday: !_filter.isToday));
  }

  void _toggleCategory(ReminderCategory cat) {
    HapticFeedback.selectionClick();
    setState(() {
      _filter = _filter.copyWith(
        category: _filter.category == cat ? null : cat,
      );
    });
  }

  void _clear() {
    HapticFeedback.lightImpact();
    setState(() => _filter = ReminderFilter.empty);
  }

  void _apply() {
    HapticFeedback.lightImpact();
    widget.onApply(_filter);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Filtrar Lembretes',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (!_filter.isEmpty)
                  TextButton(
                    onPressed: _clear,
                    child: Text(
                      'Limpar',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, thickness: 1, color: AppColors.slate200),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel(label: 'Data'),
                const SizedBox(height: AppSpacing.sm),
                _FilterToggleTile(
                  icon: Icons.today_rounded,
                  label: 'Lembretes de Hoje',
                  subtitle: 'Mostrar apenas lembretes agendados para hoje',
                  selected: _filter.isToday,
                  onTap: _toggleToday,
                ),
                const SizedBox(height: AppSpacing.lg),
                const _SectionLabel(label: 'Categoria'),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: ReminderCategory.values
                      .map(
                        (cat) => _FilterChip(
                          label: cat.label,
                          selected: _filter.category == cat,
                          onTap: () => _toggleCategory(cat),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.slate200),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md + bottomPadding,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    label: 'Cancelar',
                    variant: _SheetButtonVariant.outline,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: _SheetButton(
                    label: _filter.isEmpty
                        ? 'Mostrar Tudo'
                        : 'Aplicar Filtros',
                    variant: _SheetButtonVariant.primary,
                    onTap: _apply,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets internos
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        color: AppColors.slate500,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _FilterToggleTile extends StatelessWidget {
  const _FilterToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? '$label, ativo' : label,
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.slate200,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.slate500,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? '$label, seleccionado' : label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.slate300,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.slate600,
            ),
          ),
        ),
      ),
    );
  }
}

enum _SheetButtonVariant { primary, outline }

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.variant,
    required this.onTap,
  });

  final String label;
  final _SheetButtonVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrimary = variant == _SheetButtonVariant.primary;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: isPrimary ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          child: Container(
            height: 50,
            decoration: isPrimary
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(color: AppColors.slate300, width: 1.5),
                  ),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.white : AppColors.slate600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
