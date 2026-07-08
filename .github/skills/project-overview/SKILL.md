---
name: project-overview
description: Apresenta o overview do projeto SeniorEase e o status atual do desenvolvimento. Use quando o utilizador perguntar "qual o status do projeto", "o que já foi feito", "o que falta implementar", "resume o projeto", "overview do projeto" ou variações similares.
---

# Project Overview — SeniorEase

## Instruções

Ao ser invocada, lê obrigatoriamente os dois ficheiros abaixo e apresenta o overview consolidado:

1. `memory-bank/activeContext.md` — fase atual, foco por frente, decisões em aberto
2. `memory-bank/progress.md` — checklist de status por frente (Memory Bank, Firebase, CI/CD, Web, Mobile, Entrega)

## Formato de saída

Apresenta o resultado nesta estrutura:

### Fase atual
Resumo em 1–2 frases da fase atual do projeto (extraído de `activeContext.md`).

### Status por frente
Para cada frente (Firebase, CI/CD, Web, Mobile), mostra:
- Quantos itens foram concluídos vs total
- Lista apenas os itens **pendentes** (não concluídos) para que o dev saiba o que falta

### Foco atual do time
Lista o responsável e próximo passo de cada frente, conforme `activeContext.md`.

### Decisões em aberto
Se existirem, lista-as. Se não houver, indica explicitamente "Nenhuma decisão pendente."

## Regras
- Não inventes informação — usa apenas o que está nos ficheiros
- Se um ficheiro não existir, informa o utilizador que o memory-bank pode não estar inicializado
- Mantém a linguagem simples e directa
