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
/// - configura o tooltip "sénior" (botões Anterior/Próximo, semântica ativa,
///   auto-scroll ágil e condicional para trazer o alvo à vista entre passos —
///   ver [startTour]); o botão de fechar (X) vive dentro do próprio balão —
///   ver [SeniorShowcase];
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
      // Scroll de re-centragem entre passos mais curto → arranque mais ágil
      // (o padrão da lib é 300ms). O 1.º passo nem chega a fazer scroll — ver
      // [startTour].
      scrollDuration: const Duration(milliseconds: 150),
      // Ignora passos cujo alvo não está na árvore (ex.: lista de tarefas vazia).
      skipIfTargetNotPresent: true,
      blurValue: 1,
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.spaceBetween,
        actionGap: 8,
        gapBetweenContentAndAction: 16,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      // Apenas navegação: "Anterior" à esquerda (oculto no 1.º passo) e
      // "Próximo" (ação primária) à direita. A saída do tutorial é feita pelo
      // botão X no canto superior do balão (ver [SeniorShowcase]).
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.previous,
          name: 'Anterior',
          backgroundColor: Colors.white.withValues(alpha: 0.18),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          hideActionWidgetForShowcase: [tourKeys.first],
        ),
        const TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'Próximo',
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          textStyle: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
      onFinish: _markSeen,
      // Fechar pelo X também conta como "visto" — não voltamos a oferecer.
      onDismiss: (_) => _markSeen(),
    );

    // Consome o sinal corrente quando a tela é aberta a partir da Central
    // (ex.: rota recém-empurrada). Adiado para depois do build — modificar um
    // provider durante initState/build é proibido pelo Riverpod.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(tourSignalProvider) == tourId) {
        ref.read(tourSignalProvider.notifier).clear();
        startTour();
      }
    });

    // Tela já viva (ex.: aba do IndexedStack): reage a pedidos futuros. O
    // callback corre fora da fase de build, logo é seguro limpar o sinal aqui.
    ref.listenManual<TourId?>(tourSignalProvider, (previous, next) {
      if (next == tourId) {
        ref.read(tourSignalProvider.notifier).clear();
        startTour();
      }
    });
  }

  /// Inicia o tutorial desta tela. Adiado para o próximo frame para garantir que
  /// os alvos já estão renderizados (boa prática do briefing).
  ///
  /// Auto-scroll condicional: o 1.º passo é sempre um elemento do topo da tela
  /// (o botão de ajuda só é alcançável com o topo à vista), por isso saltamos o
  /// scroll de re-centragem que atrasava o arranque do tour. Para os passos
  /// seguintes mantemos o auto-scroll, pois o alvo pode estar fora do ecrã.
  ///
  /// O `enableAutoScroll` é lido de forma síncrona dentro de `startShowCase` (no
  /// arranque do passo 0), logo desligá-lo antes e voltar a ligá-lo a seguir
  /// afeta apenas o 1.º passo. Degradação segura: se a leitura ocorresse mais
  /// tarde, mantinha-se o comportamento atual (scroll também no passo 0).
  void startTour() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final view = ShowcaseView.getNamed(tourScope)..enableAutoScroll = false;
      view.startShowCase(tourKeys);
      view.enableAutoScroll = true;
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
