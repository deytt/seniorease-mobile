import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:showcaseview/showcaseview.dart';

/// Wrapper sobre [Showcase] que aplica os tokens do Design System SeniorEase e
/// garante consistência visual/textual + acessibilidade em todos os tutoriais.
///
/// - Fundo do tooltip em `primaryDark` com texto branco → contraste ≥ AA
///   (≈6.4:1) e estável em tema claro/escuro/alto contraste.
/// - Título e descrição herdam a escala tipográfica do tema, por isso respeitam
///   automaticamente a preferência de tamanho de letra do utilizador.
/// - O parâmetro [scope] liga o showcase ao scope nomeado da tela (essencial:
///   Home e Tarefas coexistem vivas no `IndexedStack`, logo cada tela tem o seu
///   próprio scope para não haver conflito).
class SeniorShowcase extends StatelessWidget {
  const SeniorShowcase({
    required this.showcaseKey,
    required this.scope,
    required this.title,
    required this.description,
    required this.child,
    super.key,
    this.targetBorderRadius,
    this.targetPadding = const EdgeInsets.all(8),
  });

  /// [GlobalKey] que identifica este passo no fluxo do showcase.
  final GlobalKey showcaseKey;

  /// Scope nomeado da tela (ex.: 'home', 'taskList').
  final String scope;

  final String title;
  final String description;
  final Widget child;
  final BorderRadius? targetBorderRadius;
  final EdgeInsets targetPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Showcase(
      key: showcaseKey,
      scope: scope,
      title: title,
      description: description,
      titleTextStyle: theme.textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      descTextStyle: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.white,
      ),
      tooltipBackgroundColor: AppColors.primaryDark,
      tooltipBorderRadius: BorderRadius.circular(AppTheme.borderRadius),
      tooltipPadding: const EdgeInsets.all(16),
      targetPadding: targetPadding,
      targetBorderRadius:
          targetBorderRadius ?? BorderRadius.circular(AppTheme.borderRadius),
      disableDefaultTargetGestures: true,
      child: child,
    );
  }
}
