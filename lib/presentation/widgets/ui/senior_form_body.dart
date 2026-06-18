import 'package:flutter/material.dart';

/// Corpo de formulário que preenche a altura disponível e rola quando necessário.
class SeniorFormBody extends StatelessWidget {
  const SeniorFormBody({
    required this.child,
    super.key,
    this.centerVertically = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.bottomPadding = 32,
  });

  final Widget child;
  final bool centerVertically;
  final EdgeInsets padding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: padding.copyWith(bottom: bottomPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: centerVertically
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [child],
                  )
                : child,
          ),
        );
      },
    );
  }
}
