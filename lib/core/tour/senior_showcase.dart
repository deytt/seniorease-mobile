import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:showcaseview/showcaseview.dart';

/// Wrapper sobre [Showcase] que aplica os tokens do Design System SeniorEase e
/// garante consistência visual/textual + acessibilidade em todos os tutoriais.
///
/// Usa um balão **personalizado** ([Showcase.withWidget]) para colocar um botão
/// de fechar (X) no canto superior direito, alinhado com o título — sinalizando
/// claramente "sair do guia", como num cartão. Os botões Anterior/Próximo são
/// geridos pelo [TourHost] e aparecem por baixo do balão.
///
/// - Fundo do balão em `primaryDark` com texto branco → contraste ≥ AA.
/// - Título e descrição herdam a escala tipográfica do tema, respeitando a
///   preferência de tamanho de letra do utilizador.
/// - Área de toque do X ≥ 44×44px (acessibilidade).
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
    return Showcase.withWidget(
      key: showcaseKey,
      scope: scope,
      container: _SeniorTooltip(
        scope: scope,
        title: title,
        description: description,
      ),
      targetPadding: targetPadding,
      targetBorderRadius:
          targetBorderRadius ?? BorderRadius.circular(AppTheme.borderRadius),
      disableDefaultTargetGestures: true,
      child: child,
    );
  }
}

/// Conteúdo do balão: título + botão X (à direita) e descrição por baixo.
class _SeniorTooltip extends StatelessWidget {
  const _SeniorTooltip({
    required this.scope,
    required this.title,
    required this.description,
  });

  final String scope;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = MediaQuery.sizeOf(context).width * 0.82;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, right: 4),
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _CloseTourButton(
                  onTap: () => ShowcaseView.getNamed(scope).dismiss(),
                ),
              ],
            ),
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Botão "X" para sair do guia. Área de toque ≥ 44×44px.
class _CloseTourButton extends StatelessWidget {
  const _CloseTourButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sair do guia',
      child: Material(
        color: Colors.white.withValues(alpha: 0.16),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.close, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
