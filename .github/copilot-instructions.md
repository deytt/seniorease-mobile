# SeniorEase — Protocolo do Memory Bank

Este projeto usa um memory-bank centralizado como submódulo em `memory-bank/`. Todo agente DEVE seguir este protocolo antes de executar qualquer tarefa.

Estas instruções aplicam-se ao GitHub Copilot (VS Code Chat / Agent Mode). A versão equivalente para Cursor está em `.cursor/rules/memory-bank.mdc`.

## Leitura obrigatória antes de qualquer tarefa

Leia os seguintes arquivos ANTES de começar qualquer implementação:

1. `memory-bank/projectbrief.md` — requisitos do Hackathon, telas obrigatórias, entregáveis
2. `memory-bank/productContext.md` — persona do usuário, princípios de produto
3. `memory-bank/systemPatterns.md` — Clean Architecture, estrutura de pastas, padrões de código
4. `memory-bank/techContext.md` — stack, tokens do Design System
5. `memory-bank/firebaseSchema.md` — schema Firestore, regras de segurança, changelog de mudanças
6. `memory-bank/activeContext.md` — foco atual do time e próximos passos

## Após concluir uma tarefa

Atualize `memory-bank/progress.md` marcando os itens concluídos com `[x]`.

## Ao iniciar uma nova frente de trabalho

Atualize `memory-bank/activeContext.md` com o que está sendo implementado e por quem.

## Ao tomar uma decisão arquitetural nova

Registre em `memory-bank/decisions.md` seguindo o formato ADR definido no arquivo.

## Ao modificar o schema Firestore ou as Firestore Rules

1. Atualize `memory-bank/firebaseSchema.md` — campo modificado e uma linha no Changelog
2. Atualize `memory-bank/firestore.rules` com as novas regras
3. Publique as rules no Firebase Console (projeto: `seniorease-backend`)
4. Se a mudança for estrutural, crie um ADR em `decisions.md`
5. Commite o submódulo e avise o time: `git submodule update --remote`

## Regras invioláveis de implementação

- **Clean Architecture:** a camada Domain nunca importa de Infrastructure ou Presentation
- **Acessibilidade:** área clicável mínima de 44×44px; contraste mínimo 4.5:1 (WCAG AA)
- **Guided Task Mode:** sempre mostrar "Passo X de Y" com barra de progresso; botão "Passo Anterior" sempre visível; celebração Lottie ao concluir
- **Confirmação de exclusão:** sempre exibir modal de confirmação antes de deletar qualquer item
- **Linguagem:** textos sempre em português, simples e sem jargão técnico
- **Tokens:** usar exclusivamente os tokens de cor, tipografia e espaçamento definidos em `memory-bank/techContext.md`
- **Modo Básico/Avançado:** implementar como lógica real que simplifica a UI (oculta elementos não essenciais no Modo Básico)
