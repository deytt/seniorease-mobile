# SPEC-03 — Segurança e contrato compartilhado do Firestore

**Prioridade:** P0  
**Plataformas afetadas:** Mobile, Web, Firebase/Cloud Functions  
**Impacto no Web:** Obrigatório. As Firestore Rules e o schema são compartilhados. Não implementar esta spec nem publicar regras sem validar a compatibilidade da Web e das Cloud Functions.

## Problema

A subcollection legada `tasks/{taskId}/steps/{stepId}` possui regra que permite leitura e escrita a qualquer usuário autenticado. Embora o contrato atual use o array `steps` em `tasks/{taskId}`, manter a regra legada aberta viola o princípio de isolamento por usuário. A documentação também precisa refletir com precisão a última publicação das rules, índices e funções.

## Objetivo

Garantir que nenhum cliente autenticado leia ou escreva dados de outro usuário, eliminar o risco da estrutura legada e manter schema, rules, índices, Mobile, Web e Cloud Functions consistentes.

## Decisão de compatibilidade obrigatória

Antes de qualquer alteração, confirmar qual cenário é seguro:

1. **Remover a subcollection legada:** permitido somente após confirmar que Web, Mobile e Functions não leem nem escrevem `tasks/*/steps`.
2. **Manter temporariamente:** restringir acesso ao proprietário da tarefa pai usando `get()` na rule, com validação de performance e cobertura de teste.
3. **Migrar dados legados:** criar plano idempotente, com backup, métricas e janela de reversão; não executar durante a gravação do vídeo sem necessidade.

## Requisitos

1. Revisar integralmente `firestore.rules`, `storage.rules`, `firestore.indexes.json` e `firebaseSchema.md`.
2. Corrigir a regra legada de steps para negar acesso ou permitir somente ao dono da tarefa pai.
3. Garantir que `users`, `tasks`, `preferences`, `reminders`, `history`, `onboarding`, `notifications` e FCM tokens preservam isolamento por `auth.uid`.
4. Avaliar validação mínima de shape/tipos para documentos sensíveis, incluindo impedir troca indevida de `userId`.
5. Manter escrita de `notifications` exclusiva do Admin SDK.
6. Confirmar que `email` do perfil não é alterável pelo cliente, conforme contrato documentado.
7. Atualizar `firebaseSchema.md` com a data de publicação real, regras alteradas e changelog.
8. Atualizar ou criar ADR caso a remoção/migração da estrutura legada seja uma decisão estrutural.
9. Publicar rules e índices somente após aprovação coordenada e registrar evidência do deploy.

## Fora de escopo

- Criptografia de ponta a ponta ou mudança de provedor backend.
- Trocar o modelo atual `steps` array por outro modelo.
- Alterar dados de produção sem backup e plano de migração.

## Critérios de aceite

- [ ] Usuário A não consegue ler, criar, atualizar ou excluir dados do usuário B.
- [ ] A subcollection legada não está aberta para todo usuário autenticado.
- [ ] Mobile, Web e Functions usam o mesmo contrato `steps` como array ou a exceção legada está formalmente protegida.
- [ ] Rules são validadas em Emulator Suite ou testes automatizados com usuários distintos.
- [ ] `firebaseSchema.md`, `firestore.rules`, índices e ADR estão sincronizados.
- [ ] O deploy no projeto `seniorease-backend` está registrado com data e responsável.
- [ ] Fluxos Mobile e Web de tarefa, lembrete, histórico, perfil e notificações são regressivamente testados.

## Plano de testes

1. Criar matriz de testes de autorização por collection: anônimo, dono e não dono.
2. Testar explicitamente a rota legada `tasks/{taskId}/steps/{stepId}`.
3. Executar testes com Firebase Emulator antes do deploy.
4. Validar criação, edição, conclusão e leitura de tarefas em Mobile e Web.
5. Validar cron de notificações e leitura do sino após a publicação.

## Riscos e mitigação

- **Quebrar usuários/dados legados:** inventariar documentos antes de negar a rota; migrar se necessário.
- **Quebrar a Web:** executar smoke test coordenado no ambiente de homologação antes do deploy.
- **Divergência documental:** a publicação só é concluída quando schema, rules e changelog estiverem no mesmo commit do memory-bank.

## Dependências

- Aprovação da equipe Web.
- Acesso ao projeto Firebase `seniorease-backend`.
- Confirmação do uso atual da subcollection pela Web e Functions.

## Definition of Done

Rules publicadas e validadas, acesso cruzado negado, contrato legado resolvido e documentação compartilhada atualizada.
