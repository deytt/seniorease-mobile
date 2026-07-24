# SPEC-02 — Acessibilidade real e Modo Básico

**Prioridade:** P0  
**Plataformas afetadas:** Mobile  
**Impacto no Web:** Sim, em nível de contrato de experiência. O Web já possui ocultações próprias no Modo Básico; qualquer mudança nos nomes, valores ou semântica das preferências compartilhadas exige alinhamento prévio com a equipe Web. Não alterar schema ou contrato sem essa coordenação.

## Problema

O painel de acessibilidade existe e persiste preferências, mas parte da UI usa tamanhos fixos abaixo dos mínimos documentados, o espaçamento não alcança todas as telas e o Modo Básico reduz pouca complexidade fora de Perfil e Histórico. Isso enfraquece requisitos centrais do Hackathon: legibilidade real, contraste, espaçamento e simplificação da interface.

## Objetivo

Garantir que fonte, contraste, espaçamento, alvos de toque e Modo Básico sejam comportamentos reais, globais e verificáveis no Mobile, preservando o contrato compartilhado de `preferences/{userId}`.

## Requisitos funcionais

### Tipografia e escala

1. Eliminar texto operacional inferior a 14 px na escala base; seguir o mínimo mais conservador de 16 px para conteúdo principal definido em `systemPatterns.md`.
2. Substituir tamanhos `fontSize` fixos por estilos do `ThemeData` ou tokens escaláveis.
3. Aplicar a escala de preferência a badges, metadados, indicadores do modo guiado, filtros, cards e textos auxiliares.
4. Alinhar os multiplicadores a `techContext.md`: 0,875 / 1,0 / 1,125 / 1,25, garantindo mínimo absoluto de 14 px.

### Contraste e toque

1. Expor os três estados exigidos: padrão, alto e máximo, com linguagem simples.
2. Garantir contraste mínimo WCAG AA de 4,5:1 para texto e fundo em todos os temas.
3. Manter alvos mínimos de 44×44 px e botões principais entre 56–72 px.
4. Garantir labels `Semantics` para todos os controles interativos críticos.

### Espaçamento

1. Consumir `SeniorSpacingTheme` em todas as telas, formulários, cards, listas, sheets e modo guiado.
2. O modo Espaçoso deve aplicar fator 1,5 nos espaçamentos internos; Compacto e Confortável devem ter efeitos perceptíveis e seguros.
3. Não deixar padding/margens fixas que anulem o tema dinâmico sem justificativa técnica.

### Modo Básico

1. Ocultar informações secundárias e controles avançados em Home, Tarefas, Lembretes, Histórico, Perfil e Configurações.
2. Preservar sempre a ação principal, o estado da tarefa e a rota de saída.
3. Priorizar: ocultar badges de prioridade/categoria não essenciais, filtros avançados, estatísticas densas, dados opcionais e ações secundárias.
4. Mostrar uma alternativa simples quando um elemento for ocultado; não esconder funções essenciais.
5. Aplicar a alteração após salvar preferências e manter persistência entre sessões/dispositivos.

### Feedback visual

1. Definir explicitamente o comportamento de “feedback visual reforçado”.
2. Se for uma preferência persistida, ela precisa ser independente de áudio/tátil ou documentada como decisão de produto aprovada.
3. Animações devem respeitar a preferência e nunca impedir a conclusão de uma ação.

## Fora de escopo

- Alterar o Design System Web nesta mesma execução.
- Criar novas preferências no Firestore sem spec conjunta Web/Mobile.
- Mudar textos de negócio sem necessidade de acessibilidade.

## Critérios de aceite

- [ ] Nenhum texto operacional usa fonte base inferior a 14 px; conteúdo principal parte de 16 px.
- [ ] Extra Grande usa fator 1,25 e não causa overflow nas telas obrigatórias.
- [ ] Os três níveis de contraste são selecionáveis e visivelmente distintos.
- [ ] Espaçamento muda todas as telas obrigatórias, incluindo Settings, Perfil, criação e modo guiado.
- [ ] Modo Básico reduz elementos não essenciais em pelo menos Home, Tarefas, Lembretes, Histórico, Perfil e Configurações.
- [ ] Nenhuma ação essencial fica inacessível no Modo Básico.
- [ ] Todos os fluxos críticos têm labels semânticos e alvos de toque adequados.
- [ ] Preferências sobrevivem a logout/login e sincronizam pelo Firestore.

## Plano de testes

### Unitários

- Mapas de escala tipográfica e espaçamento.
- Derivação dos modos de contraste.
- Predicados que definem visibilidade em Modo Básico.
- Persistência e leitura de preferências.

### Validação manual obrigatória

1. Android e iOS: padrão, alto e máximo contraste.
2. Android e iOS: fonte Extra Grande e espaçamento Espaçoso nas 13 telas.
3. TalkBack e VoiceOver: ordem de foco, labels, modais, swipe e tours.
4. Verificação de contraste com ferramenta WCAG.
5. Comparação Basic vs Advanced com roteiro por tela.

## Riscos e dependências

- **Web:** valores de `fontSize`, `contrast`, `spacing` e `interfaceMode` são compartilhados. Qualquer mudança de enum/schema deve ser aprovada pela equipe Web antes de codificar.
- **Layout:** fontes maiores podem revelar overflow; correção deve ser feita antes do vídeo.
- **Escopo:** não usar o Modo Básico como justificativa para remover funções obrigatórias.

## Definition of Done

Auditoria manual registrada, testes unitários aprovados, preferências globais funcionando e contrato Web/Mobile preservado.
