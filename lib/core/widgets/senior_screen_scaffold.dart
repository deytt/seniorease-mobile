import 'package:flutter/material.dart';
import 'package:mobile/core/widgets/senior_screen_header.dart';

class SeniorScreenScaffold extends StatelessWidget {
  const SeniorScreenScaffold({
    required this.title,
    required this.body,
    super.key,
    this.subtitle,
    this.subtitleWidget,
    this.showBackButton = true,
    this.backIcon = Icons.arrow_back,
    this.onBack,
    this.trailing,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final bool showBackButton;
  final IconData backIcon;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Widget body;

  /// Cor de fundo do scaffold. Quando nulo, usa
  /// [ThemeData.scaffoldBackgroundColor] (correto em dark/light mode).
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SeniorScreenHeader(
            title: title,
            subtitle: subtitle,
            subtitleWidget: subtitleWidget,
            showBackButton: showBackButton,
            backIcon: backIcon,
            onBack: onBack,
            trailing: trailing,
          ),
          Expanded(
            child: ColoredBox(
              color: bg,
              child: SafeArea(
                top: false,
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
