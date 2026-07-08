import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/tour/tour_id.dart';

/// Sinal efémero de coordenação entre a Central "Guias do aplicativo" e a tela
/// alvo. Pura coordenação de UI — **sem persistência e sem regra de negócio** —
/// por isso vive em `core/` e pode ser consumido por qualquer feature sem violar
/// o Feature-First (nenhuma feature importa outra).
///
/// Fluxo: a Central faz [TourSignal.request] com o [TourId] desejado e navega
/// para a rota correspondente; a tela alvo (via `TourHost`) observa este provider
/// e inicia o seu showcase quando o sinal corresponde ao seu próprio [TourId].
final tourSignalProvider =
    NotifierProvider<TourSignal, TourId?>(TourSignal.new);

class TourSignal extends Notifier<TourId?> {
  @override
  TourId? build() => null;

  /// Pede para iniciar o tutorial [id] na tela correspondente.
  void request(TourId id) => state = id;

  /// Limpa o sinal (chamado pela tela assim que consome o pedido).
  void clear() => state = null;
}

