# SPEC-06 — Animação Lottie de Celebração na Conclusão de Tarefa

**Prioridade:** P1  
**Plataformas afetadas:** Mobile  
**Impacto no Web:** Nenhum — o Web usa `lottie-react` e já exibe `celebration.json` ao concluir tarefa. Esta spec alinha o comportamento Mobile ao Web.

---

## Problema

O briefing do Hackathon exige explicitamente **"avisos de conclusão com feedback positivo (animação Lottie de celebração)"** como requisito do Módulo 2. O arquivo `assets/lottie/celebration.json` existe no projeto, mas **nenhuma tela o utiliza**.

Atualmente, o widget `SeniorFeedbackOverlay` (usado em todos os fluxos de feedback) exibe `assets/lottie/check_animation.json` — um ícone de check/confirmação — para todos os casos: criação de tarefa, criação de lembrete, conclusão de passo intermediário **e** conclusão final da tarefa.

O momento de **concluir a tarefa inteira** (último passo do Modo Guiado ou "Marcar como Concluída" na tela de detalhes) é semanticamente diferente de criar ou editar algo. É o momento de celebração — e é exatamente aí que `celebration.json` (animação tipo confetti/estrelas) deve ser exibido para reforçar o sentimento positivo que o produto promete entregar à persona Margaret.

### Evidência do gap

```
assets/lottie/celebration.json   ← existe, nunca referenciado no código
assets/lottie/check_animation.json ← usado em TODOS os casos
```

Locais que usam `SeniorFeedbackOverlay.show()`:

| Arquivo | Contexto | Animação correta |
|---|---|---|
| `guided_task_screen.dart:81` | **Conclusão da tarefa inteira** | `celebration.json` ← gap |
| `task_details_screen.dart:114` | **Conclusão da tarefa inteira** | `celebration.json` ← gap |
| `create_task_screen.dart:188` | Criação de nova tarefa | `check_animation.json` ✅ |
| `create_reminder_screen.dart` | Criação/edição de lembrete | `check_animation.json` ✅ |

---

## Objetivo

Exibir `celebration.json` nos dois momentos de **conclusão de tarefa inteira** (Modo Guiado e tela de Detalhes), mantendo `check_animation.json` para criação e edição.

---

## Solução técnica

### 1. Adicionar parâmetro `lottiePath` ao `SeniorFeedbackOverlay`

Introduzir um parâmetro opcional no widget e no método estático `.show()`. O valor padrão mantém o comportamento existente (`check_animation.json`) para não quebrar nenhum chamador atual.

```dart
// core/widgets/senior_feedback_overlay.dart

class SeniorFeedbackOverlay extends StatefulWidget {
  const SeniorFeedbackOverlay({
    required this.onDismiss,
    required this.message,
    this.title = 'Parabéns! 🎉',
    this.lottiePath = 'assets/lottie/check_animation.json', // ← novo parâmetro
    super.key,
  });

  final VoidCallback onDismiss;
  final String message;
  final String title;
  final String lottiePath; // ← novo campo

  static Future<void> show(
    BuildContext context, {
    required String message,
    String title = 'Parabéns! 🎉',
    String lottiePath = 'assets/lottie/check_animation.json', // ← novo parâmetro
  }) { ... }
}
```

Usar `widget.lottiePath` na chamada `Lottie.asset(widget.lottiePath, ...)` em vez do caminho fixo.

### 2. Definir a constante em `AppLottie` (ou similar)

Para evitar strings mágicas espalhadas no código, definir as constantes em `core/theme/` ou `core/widgets/`:

```dart
// core/widgets/senior_feedback_overlay.dart (ou core/theme/app_lottie.dart)

abstract final class AppLottie {
  static const String checkAnimation = 'assets/lottie/check_animation.json';
  static const String celebration    = 'assets/lottie/celebration.json';
}
```

### 3. Atualizar os dois chamadores de conclusão de tarefa

**`guided_task_screen.dart`** — ao concluir o último passo:

```dart
await SeniorFeedbackOverlay.show(
  context,
  message: 'Concluiu "${task.title}"!',
  lottiePath: AppLottie.celebration, // ← trocar aqui
);
```

**`task_details_screen.dart`** — ao marcar tarefa como concluída:

```dart
await SeniorFeedbackOverlay.show(
  context,
  message: '...',
  lottiePath: AppLottie.celebration, // ← trocar aqui
);
```

Os outros chamadores (`create_task_screen.dart`, `create_reminder_screen.dart`) **não mudam** — continuam usando o valor padrão `check_animation.json`.

---

## Fora de escopo

- Não criar um widget novo; apenas estender o existente com parâmetro opcional.
- Não alterar a duração do auto-dismiss (4 s permanece).
- Não alterar o Firestore, schema ou regras de segurança.
- Não alterar o comportamento no Web (já usa `celebration.json`).

---

## Critérios de aceite

- [ ] `SeniorFeedbackOverlay` aceita `lottiePath` opcional; valor padrão é `check_animation.json`.
- [ ] `AppLottie.celebration` e `AppLottie.checkAnimation` definidos como constantes (sem strings mágicas).
- [ ] Concluir o **último passo** no Modo Guiado exibe `celebration.json`.
- [ ] Tocar em "Marcar como Concluída" na tela de Detalhes exibe `celebration.json`.
- [ ] Criar/editar tarefa e criar/editar lembrete continuam exibindo `check_animation.json`.
- [ ] `flutter analyze lib/` — 0 erros após a mudança.
- [ ] `flutter test` — todos os testes passam (a mudança é retrocompatível; não deve quebrar testes existentes).

---

## Definition of Done

Implementação commitada, `flutter analyze` e `flutter test` passando, e comportamento validado manualmente no simulador ou dispositivo físico nos dois fluxos de conclusão de tarefa.
