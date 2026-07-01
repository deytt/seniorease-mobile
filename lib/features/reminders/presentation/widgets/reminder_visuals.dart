import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';

/// Ícone e cores por categoria de lembrete.
({IconData icon, Color color, Color bg}) reminderCategoryStyle(
  ReminderCategory category,
) =>
    switch (category) {
      ReminderCategory.medication => (
          icon: Icons.medication_outlined,
          color: AppColors.danger,
          bg: AppColors.danger.withValues(alpha: 0.13),
        ),
      ReminderCategory.appointment => (
          icon: Icons.event_outlined,
          color: AppColors.secondary,
          bg: AppColors.secondary.withValues(alpha: 0.13),
        ),
      ReminderCategory.hydration => (
          icon: Icons.water_drop_outlined,
          color: AppColors.primary,
          bg: AppColors.primary.withValues(alpha: 0.13),
        ),
      ReminderCategory.meal => (
          icon: Icons.restaurant_outlined,
          color: AppColors.warning,
          bg: AppColors.warning.withValues(alpha: 0.13),
        ),
      ReminderCategory.bills => (
          icon: Icons.receipt_long_outlined,
          color: AppColors.success,
          bg: AppColors.success.withValues(alpha: 0.13),
        ),
    };

/// Formata a hora para o bloco lateral do card (12h, ex.: 6:00).
String formatReminderTime(DateTime dt) {
  final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final min = dt.minute.toString().padLeft(2, '0');
  return '$hour12:$min';
}

/// Período AM/PM (Figma `15:7912`).
String formatReminderPeriod(DateTime dt) => dt.hour < 12 ? 'AM' : 'PM';
