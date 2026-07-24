# SPEC-05 — Vídeo de entrega e validação final

**Prioridade:** P0, após concluir as correções de produto  
**Plataformas afetadas:** Mobile, Web e documentação  
**Impacto no Web:** Sim. O vídeo deve demonstrar a plataforma Web com comportamento real e coerente com o Mobile. Qualquer divergência de produto identificada deve ser comunicada à equipe Web antes da gravação; esta spec não autoriza modificar o Web.

## Problema

O roteiro atual possui bons diferenciais técnicos, mas contém afirmações que precisam ser alinhadas ao código e ainda não demonstra todos os requisitos obrigatórios do Hackathon. Um vídeo não pode prometer biometria automática, simplificação universal no Modo Básico, tours automáticos universais, `Semantics` em todos os interativos ou paridade 1:1 se isso não estiver comprovado.

## Objetivo

Produzir um vídeo de até 15 minutos, factual e demonstrável, que cubra requisitos obrigatórios, decisões relevantes e coerência entre Mobile e Web.

## Regras de conteúdo

1. Mostrar somente comportamento validado no build final.
2. Usar linguagem simples, focada em autonomia, confiança e inclusão da persona Margaret.
3. Priorizar requisitos do Hackathon; diferenciais técnicos entram como apoio, não substituição.
4. Não afirmar que os requisitos funcionais do antigo app financeiro das fases anteriores fazem parte do SeniorEase.
5. Declarar diferenças legítimas entre Web e Mobile em vez de prometer identidade total.

## Roteiro obrigatório

### 1. Problema e persona — até 1 min

- Barreiras de visão, coordenação e medo de errar.
- Objetivos de autonomia, confiança e clareza.

### 2. Arquitetura e plataforma dupla — até 2 min

- Flutter + Next.js, Firebase compartilhado e memory-bank.
- Clean Architecture como intenção e exemplos reais de ports/adapters.
- CI/CD e testes; não declarar cobertura inexistente.

### 3. Demo Mobile — até 7 min

1. Autenticação: Login, Google e um recorte de cadastro ou recuperação de senha.
2. Home e navegação inferior.
3. Acessibilidade: fonte, três contrastes, espaçamento, botões maiores e Modo Básico. Sempre tocar em **Salvar configurações** antes de demonstrar o efeito.
4. Lista e detalhe de tarefa: filtro, criação, confirmação de exclusão.
5. Modo guiado: “Passo X de Y”, barra de progresso, Anterior, saída segura e Lottie.
6. Lembrete: criação e comportamento real de notificação; usar plano B se o push não chegar.
7. Histórico, Perfil e persistência de preferências.
8. Segurança: biometria como opção, verificação de e-mail e alteração de senha, se o tempo permitir.

### 4. Demo Web — até 2 min

- Login, Dashboard, Acessibilidade, tarefas/lembretes e perfil.
- Mostrar coerência visual/cognitiva e a mesma base Firebase.
- Não demonstrar biometria como recurso Web.

### 5. Diferenciais e encerramento — até 2 min

- FCM/Cloud Functions somente se o fluxo estiver previamente testado.
- Tours e Central de Guias com a oferta automática descrita de forma correta.
- Entregáveis públicos e convite à avaliação.

## Correções obrigatórias no `video-script.md`

- Biometria: descrever o toque no controle biométrico, não auto-disparo, salvo se o build final o implementar.
- Tour: diferenciar boas-vindas, dica de primeiro uso e início manual pelo botão `?`.
- Modo Básico: demonstrar apenas as reduções realmente implementadas.
- Semantics: não prometer cobertura total sem auditoria final.
- Paridade: falar em schema, Design System e intenção de UX compartilhados; mencionar diferenças relevantes se persistirem.
- Remover notas internas como “implementado esta sessão”.
- Validar URL pública única do protótipo e preencher todos os links.

## Critérios de aceite

- [ ] Duração cronometrada de até 15 minutos.
- [ ] Todos os três módulos e as 13 telas obrigatórias são cobertos diretamente ou por montagem clara.
- [ ] Acessibilidade demonstra fonte, contraste, espaçamento, Modo Básico e persistência.
- [ ] Demo inclui confirmação antes de exclusão e feedback positivo de conclusão.
- [ ] Cada afirmação técnica foi validada no build final.
- [ ] Push, Google, biometria e deep links têm plano B de demonstração.
- [ ] Vídeo revisado por ao menos um integrante que não o gravou.
- [ ] Links públicos e arquivo de submissão foram confirmados em janela anônima.

## Checklist de ensaio

1. Usar conta de demonstração com tarefas, passos, lembretes e histórico pré-carregados.
2. Ativar permissões de notificação e biometria previamente.
3. Criar lembrete de teste com antecedência compatível com o offset configurado.
4. Ensaiar o cenário sem internet/push e preparar alternativa visual honesta.
5. Gravar em dispositivo físico e captura Web no mesmo estado de dados.
6. Conferir que nenhum dado pessoal real, token ou segredo aparece na tela.

## Dependências

- Correções aprovadas das SPECS 02 e 03.
- Build final Android/iOS e deploy Web estáveis.
- Links públicos da SPEC-01.

## Definition of Done

Roteiro revisado, ensaio cronometrado aprovado, vídeo final público/enviado e submissão FIAP concluída.
