import 'package:flutter/material.dart';
import 'package:mobile/core/preferences/user_preferences.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Card de seleção da antecedência de notificação push.
/// Visualmente alinhado ao [SpacingModeCard]: botões custom com
/// [AnimatedContainer] e [Semantics].
class NotificationOffsetCard extends StatelessWidget {
  const NotificationOffsetCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final NotificationOffset value;
  final ValueChanged<NotificationOffset> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !enabled,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: NotificationOffset.values
                    .map(
                      (offset) => _OffsetChip(
                        offset: offset,
                        selected: value == offset,
                        onTap: () => onChanged(offset),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OffsetChip extends StatelessWidget {
  const _OffsetChip({
    required this.offset,
    required this.selected,
    required this.onTap,
  });

  final NotificationOffset offset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.15)
        : theme.colorScheme.surface;
    final border = selected ? AppColors.primary : theme.colorScheme.outline;
    final labelColor =
        selected ? theme.colorScheme.primary : theme.colorScheme.onSurface;

    return Semantics(
      button: true,
      selected: selected,
      label: offset.label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            offset.label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: labelColor,
            ),
          ),
        ),
      ),
    );
  }
}
