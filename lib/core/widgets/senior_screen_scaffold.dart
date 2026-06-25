import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/senior_screen_header.dart';

class SeniorScreenScaffold extends StatelessWidget {
  const SeniorScreenScaffold({
    required this.title,
    required this.body,
    super.key,
    this.subtitle,
    this.showBackButton = true,
    this.backIcon = Icons.arrow_back,
    this.onBack,
    this.trailing,
    this.backgroundColor = AppColors.slate50,
  });

  final String title;
  final String? subtitle;
  final bool showBackButton;
  final IconData backIcon;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Widget body;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SeniorScreenHeader(
            title: title,
            subtitle: subtitle,
            showBackButton: showBackButton,
            backIcon: backIcon,
            onBack: onBack,
            trailing: trailing,
          ),
          Expanded(
            child: ColoredBox(
              color: backgroundColor,
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
