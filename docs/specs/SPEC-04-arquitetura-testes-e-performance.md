# SPEC-04 — Arquitetura, testes e eficiência operacional

**Prioridade:** P1  
**Plataformas afetadas:** Mobile  
**Impacto no Web:** Não há alteração obrigatória de código Web. Há impacto de alinhamento se o contrato de domínio compartilhado, o schema ou decisões arquiteturais do memory-bank forem modificados; sinalizar a equipe Web antes desses casos.

## Problema

O projeto possui estrutura Feature-First sólida, mas há dependências diretas entre features, entidades de domínio dependentes do SDK Firestore, lacunas de testes unitários em alguns providers/repositórios e streams Firestore duplicados em telas de lista. Esses pontos reduzem aderência à Clean Architecture e podem aumentar custo e complexidade de manutenção.

## Objetivo

Reduzir acoplamento, ampliar a proteção por testes e eliminar leituras reativas redundantes sem alterar comportamento percebido pelo usuário.

## Escopo

### Arquitetura

1. Inventariar todos os imports `features/X -> features/Y`.
2. Classificar cada dependência como:
   - composição legítima em `app/`;
   - port/adaptor existente a ser reutilizado;
   - dívida técnica aceita por ADR;
   - violação a migrar.
3. Migrar comunicação cross-feature para ports em `core/` e adapters em `app/` quando não for simples composição.
4. Remover dependências do Domain em `cloud_firestore`, `Timestamp`, `FieldValue` e outros tipos de infraestrutura:
   - entidades usam `DateTime`, tipos Dart e contratos próprios;
   - mapeamento Firestore fica em Data;
   - interfaces do Domain não importam Firebase/Flutter.
5. Registrar um ADR somente se a estratégia final alterar convenções existentes.

### Testes unitários

1. Completar testes para:
   - `preferences_provider`;
   - `tour_providers`;
   - `notifications_provider`;
   - `login_preferences_provider`;
   - `secure_credential_provider`;
   - `ChangePasswordUseCase`;
   - `FirebaseProfilePhotoStorage`;
   - `LocalBiometricRepository`;
   - `SecureCredentialCache`.
2. Usar mocks/fakes e `ProviderContainer`; não criar testes de widget ou instrumentados.
3. Garantir que erros de repositório geram estado e mensagens seguras.

### Performance e reatividade

1. Eliminar assinaturas concorrentes desnecessárias para `tasks` e `reminders`.
2. Derivar contagens, filtros e previews de um stream fonte quando possível.
3. Preservar atualização em tempo real e filtros server-side previstos no schema.
4. Medir leituras em debug/Emulator antes e depois quando houver instrumentação disponível.

## Fora de escopo

- Reescrever todo o app para uma nova arquitetura.
- Adicionar cache offline, paginação ou novos pacotes sem evidência de necessidade para a entrega.
- Mudar a UX ou schema Firebase apenas para acomodar refactor interno.

## Critérios de aceite

- [ ] Domain não importa Firebase, Flutter ou Presentation/Data.
- [ ] Toda dependência entre features possui justificativa de composição ou passa por port/adaptor.
- [ ] Regras de import de `systemPatterns.md` são atendidas ou exceções estão registradas e aprovadas.
- [ ] Cada camada relevante possui testes unitários de lógica.
- [ ] `flutter analyze` e `flutter test` passam no ambiente e CI.
- [ ] Task List e Reminders não duplicam streams equivalentes sem necessidade.
- [ ] Não há regressão em autenticação, lista, filtros, perfil, histórico ou notificações.

## Plano de execução seguro

1. Criar testes de caracterização para o comportamento atual.
2. Refatorar um módulo por vez.
3. Executar análise/testes após cada módulo.
4. Validar navegação e atualizações Firestore em dispositivo/emulador.
5. Só então remover compatibilidades temporárias.

## Riscos e mitigação

- **Refactor perto da entrega:** priorizar isolamento do Domain e testes; adiar melhorias sem impacto em requisito.
- **Quebra de streams:** manter teste de provider para loading, erro e atualização.
- **Impacto Web indireto:** não alterar entidades conceituais, schema ou ADR compartilhado sem consulta à frente Web.

## Definition of Done

Arquitetura documentada e testável, testes unitários adicionais verdes, streams redundantes eliminados e regressão funcional aprovada.
