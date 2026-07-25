# SPEC-01 — Documentação e entregáveis de submissão

**Prioridade:** P0  
**Plataformas afetadas:** Mobile e documentação compartilhada  
**Impacto no Web:** Sim, nos entregáveis e links. Esta spec não altera o código Web, mas a publicação do repositório, README e Figma deve ser coordenada com a frente Web antes da execução.

## Problema

O `README.md` do mobile não permite que um avaliador execute, teste ou compreenda a arquitetura da aplicação. Além disso, os repositórios, Figma, vídeo e arquivo de submissão ainda são pendências explícitas no `memory-bank/progress.md`.

## Objetivo

Entregar documentação reproduzível e todos os links exigidos no Hackathon, sem expor segredos ou dados de teste sensíveis.

## Escopo

1. Reescrever o README do mobile em português com:
   - proposta e público-alvo;
   - funcionalidades e telas obrigatórias;
   - stack e arquitetura Feature-First/Clean Architecture;
   - pré-requisitos e instruções de instalação;
   - configuração segura do Firebase sem credenciais privadas;
   - comandos para executar, analisar e testar;
   - CI/CD, distribuição e estrutura de pastas;
   - links para Web, Figma, vídeo e memory-bank.
2. Criar ou completar o README equivalente do Web, pela equipe responsável.
3. Confirmar visibilidade pública dos dois repositórios e do arquivo Figma.
4. Criar o arquivo `.txt` ou `.docx` de submissão com links finais.
5. Atualizar `progress.md` apenas depois de cada evidência externa ser confirmada.
6. Configurar medição de cobertura de testes com `flutter test --coverage` + `lcov`:
   - Adicionar o script `scripts/coverage.sh` que executa `flutter test --coverage` e gera o relatório HTML via `genhtml` (pacote `lcov`);
   - Integrar o passo de cobertura no workflow de CI (`.github/workflows/`) para que o relatório seja publicado como artefato a cada push;
   - Incluir no README um badge de cobertura e uma seção "Cobertura de Testes" com o comando local e link para o relatório;
   - Documentar o percentual atual de cobertura no `memory-bank/progress.md` e mencionar no vídeo de apresentação.

## Fora de escopo

- Alterar funcionalidades do app.
- Publicar chaves, service accounts, arquivos `.env` ou credenciais Apple/Google.
- Modificar o schema Firebase.

## Critérios de aceite

- [ ] Um integrante sem contexto consegue preparar o Mobile usando somente o README.
- [ ] O README informa `flutter pub get`, `flutter run`, `flutter analyze` e `flutter test`.
- [ ] O README explica como gerar/configurar Firebase sem versionar segredos.
- [ ] O README apresenta arquitetura, testes e fluxo de CI/CD reais.
- [ ] Links públicos e funcionais para Mobile, Web, Figma e vídeo estão presentes.
- [ ] O arquivo de submissão contém links válidos e identifica o projeto.
- [ ] Nenhuma credencial foi adicionada ao Git.
- [ ] `flutter test --coverage` executa com sucesso e gera `coverage/lcov.info`.
- [ ] O relatório HTML de cobertura é gerado localmente via `scripts/coverage.sh`.
- [ ] O CI publica o relatório de cobertura como artefato a cada push.
- [ ] O README exibe badge de cobertura e seção "Cobertura de Testes" com instruções.
- [ ] O percentual de cobertura está registrado em `memory-bank/progress.md`.

## Plano de validação

1. Executar o guia em um ambiente limpo.
2. Revisar os links em janela anônima.
3. Executar busca por arquivos e padrões sensíveis antes da publicação.
4. Conferir que os comandos documentados correspondem ao workflow CI.
5. Rodar `bash scripts/coverage.sh` e validar que o relatório HTML é gerado em `coverage/html/index.html`.
6. Verificar no CI que o artefato de cobertura é publicado corretamente.

## Riscos e mitigação

- **Repositório público com segredo acidental:** usar revisão por pares e busca de segredos antes de mudar a visibilidade.
- **Link de vídeo/Figma privado:** validar em janela anônima.
- **README prometer recurso inexistente:** basear cada seção na auditoria e no código atual.

## Dependências

- URLs reais do repositório Web, deploy Vercel, Figma e vídeo.
- Aprovação da equipe Web para tornar seus ativos públicos.

## Definition of Done

Documentação revisada, links públicos validados, submissão preparada e checklist de entrega atualizado com evidências.
