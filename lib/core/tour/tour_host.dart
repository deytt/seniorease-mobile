import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/tour/tour_gate.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/core/tour/tour_signal_provider.dart';
import 'package:showcaseview/showcaseview.dart';

/// Mixin para o [State] de uma tela que possui um tutorial guiado.
///
/// Responsabilidades (todas genéricas — sem regra de negócio):
/// - regista um scope nomeado do `showcaseview` em [initState] e remove-o em
///   [dispose] (cada tela tem o seu scope porque o `IndexedStack` mantém várias
///   telas vivas em simultâneo);
/// - configura o tooltip "sénior" (botões Anterior/Próximo + Sair, semântica
///   ativa, auto-scroll para garantir que o alvo está visível antes de mostrar);
/// - observa o [tourSignalProvider] e inicia o tutorial quando a Central pede
///   este [tourId];
/// - marca o tutorial como "visto" no fim, através do [TourGate] (port de core).
mixin TourHost<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Scope nomeado único desta tela (ex.: 'home').
  String get tourScope;

  /// Identificador deste tutorial.
  TourId get tourId;

  /// Passos do tutorial, na ordem de exibição.
  List<GlobalKey> get tourKeys;

  @override
  void initState() {
    super.initState();

    ShowcaseView.register(
      scope: tourScope,
      semanticEnable: true,
      enableAutoScroll: true,
      // Ignora passos cujo alvo não está na árvore (ex.: lista de tarefas vazia).
      skipIfTargetNotPresent: true,
      blurValue: 1,
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.spaceBetween,
        actionGap: 12,
        gapBetweenContentAndAction: 14,
      ),
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.previous,
          name: 'Anterior',
          backgroundColor: Colors.white.withValues(alpha: 0.18),
          textStyle: const TextStyle(color: Colors.white),
          hideActionWidgetForShowcase: [tourKeys.first],
        ),
        const TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'Próximo',
          backgroundColor: Colors.white,
          textStyle: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
      globalFloatingActionWidget: (_) => FloatingActionWidget(
        left: 16,
        bottom: 24,
        child: _SkipTourButton(
          onTap: () => ShowcaseView.getNamed(tourScope).dismiss(),
        ),
      ),
      onFinish: _markSeen,
    );

    // Tela acabou de ser construída (ex.: aberta a partir da Central): consome o
    // sinal corrente, se for para nós.
    final current = ref.read(tourSignalProvider);
    if (current == tourId) {
      ref.read(tourSignalProvider.notifier).clear();
      startTour();
    }

    // Tela já viva (ex.: aba do IndexedStack): reage a pedidos futuros.
    ref.listenManual<TourId?>(tourSignalProvider, (previous, next) {
      if (next == tourId) {
        ref.read(tourSignalProvider.notifier).clear();
        startTour();
      }
    });
  }

  /// Inicia o tutorial desta tela. Adiado para o próximo frame para garantir que
  /// os alvos já estão renderizados (boa prática do briefing).
  void startTour() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ShowcaseView.getNamed(tourScope).startShowCase(tourKeys);
    });
  }

  void _markSeen() {
    ref.read(tourGateProvider).markSeen(tourId);
  }

  @override
  void dispose() {
    ShowcaseView.getNamed(tourScope).unregister();
    super.dispose();
  }
}

class _SkipTourButton extends StatelessWidget {
  const _SkipTourButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sair do guia',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Sair do guia',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
