# SeniorEase Mobile

> Plataforma de inclusão digital para idosos — aplicativo Flutter (Android e iOS).

[![CI/CD Mobile](https://github.com/deytt/seniorease-mobile/actions/workflows/mobile.yml/badge.svg)](https://github.com/deytt/seniorease-mobile/actions/workflows/mobile.yml)
[![Cobertura de Testes](https://img.shields.io/badge/cobertura-ver%20artefato%20CI-blue)](https://github.com/deytt/seniorease-mobile/actions)

---

## Índice

1. [Proposta e público-alvo](#proposta-e-público-alvo)
2. [Funcionalidades e telas](#funcionalidades-e-telas)
3. [Stack e arquitetura](#stack-e-arquitetura)
4. [Pré-requisitos](#pré-requisitos)
5. [Instalação e execução](#instalação-e-execução)
6. [Configuração do Firebase](#configuração-do-firebase)
7. [Comandos úteis](#comandos-úteis)
8. [Cobertura de testes](#cobertura-de-testes)
9. [CI/CD e distribuição](#cicd-e-distribuição)
10. [Estrutura de pastas](#estrutura-de-pastas)
11. [Links do projeto](#links-do-projeto)

---

## Proposta e público-alvo

O **SeniorEase** é uma plataforma de inclusão digital desenvolvida para pessoas idosas que buscam autonomia e confiança no uso da tecnologia. A aplicação mobile (Flutter) oferece um ambiente acessível, com fonte ajustável, modos de contraste, modo guiado passo a passo e lembretes de atividades diárias.

**Público-alvo:** adultos com 60 anos ou mais; cuidadores que auxiliam pessoas idosas.

**Hackathon:** Challenge FIAP 2026 — Módulo Mobile (Flutter) + Web (Next.js).

---

## Funcionalidades e telas

### Módulo de Autenticação
- Login com e-mail/senha e com conta Google (OAuth)
- Cadastro de nova conta
- Recuperação de senha por e-mail
- Bloqueio biométrico (Face ID / impressão digital) com retorno silencioso via Google Sign-In

### Home / Dashboard
- Saudação dinâmica (bom dia / boa tarde / boa noite)
- Próxima atividade pendente (ligada ao Firestore)
- Lembretes de hoje
- Ações rápidas: Nova Tarefa, Acessibilidade, Lembretes, Guias
- Sino de notificações com badge

### Módulo de Tarefas
- Lista de tarefas com filtros (categoria, prioridade, hoje) e pull-to-refresh
- Criação de tarefa com passos dinâmicos, data/hora e categoria
- Detalhes da tarefa com badges de prioridade/categoria
- **Modo Guiado** — "Passo X de Y" com barra de progresso, botão Passo Anterior sempre visível e animação Lottie de celebração ao concluir

### Módulo de Lembretes
- Lista com filtros combináveis (categoria + hoje)
- Swipe bidirecional: arrastar para esquerda exclui, para direita edita
- Categorias: Medicação, Consulta, Hidratação, Alimentação, Contas e Pagamentos
- Criação e edição de lembretes

### Módulo de Histórico
- Registro automático de ações (conclusão de tarefas, lembretes, perfil, autenticação)
- Cards de estatísticas: tarefas da semana e sequência (streak)
- Atividade recente agrupada por dia
- Modo Básico oculta eventos de baixa relevância

### Módulo de Acessibilidade
- Tamanho de fonte (4 níveis: Pequena → Extra Grande)
- Dark Mode e modo de contraste (Padrão / Alto / Máximo)
- Espaçamento ajustável (Compacto / Confortável / Espaçoso)
- **Modo Básico / Avançado** — simplifica a UI ocultando elementos não essenciais
- Feedback de áudio (haptics) e botões maiores (64 × 64 px)
- Persistência no Firestore e sincronização entre dispositivos

### Módulo de Perfil / Definições
- Edição de dados pessoais (nome, telefone, data de nascimento, CPF, endereço)
- Upload de foto de perfil (Firebase Storage)
- Segurança: habilitar biometria, verificar e-mail, alterar senha
- Preferências de notificação push (FCM) com antecedência configurável

### Tour Guiado
- Tutorial automático na 1.ª visita de cada tela (apenas Modo Básico)
- Central "Guias do aplicativo" com catálogo de todos os tours
- Pop-up "Conheça as funções" + botão de ajuda `?` em todas as telas

### Notificações Push (FCM)
- Cloud Functions enviam push para tarefas e lembretes na hora agendada
- Histórico de notificações em `/notifications`

---

## Stack e arquitetura

| Camada | Tecnologia |
|---|---|
| Framework | Flutter 3 (Dart 3.10+) |
| Gerenciamento de estado | Riverpod 3 |
| Roteamento | GoRouter 17 |
| Backend | Firebase (Auth, Firestore, Storage, FCM, Functions) |
| Autenticação social | Google Sign-In v6 |
| Biometria | `local_auth` |
| Armazenamento local | `shared_preferences`, `flutter_secure_storage` |
| Animações | Lottie |
| Tour/Onboarding | `showcaseview` |
| Testes | `flutter_test`, `mocktail`, `fake_cloud_firestore` |
| CI/CD | GitHub Actions + Firebase App Distribution |
| Distribuição iOS | TestFlight |

### Clean Architecture — Feature-First

O projeto segue **Feature-First com Clean Architecture** (ADR-008). Cada feature é autônoma e organizada em três camadas:

```
features/<nome>/
├── domain/        ← entidades, repositórios (contratos), use cases
├── data/          ← implementações Firebase dos repositórios
└── presentation/  ← telas, providers Riverpod, widgets
```

**Regras de dependência invioláveis:**

```
core/                      ← nunca importa de features/
features/X/domain/         ← nunca importa de data/ nem presentation/
features/X/data/           ← implementa contratos de domain/
features/X/presentation/   ← consome domain/ via providers Riverpod
features/X/                ← nunca importa de features/Y/ diretamente
```

A camada Domain não possui dependência de Firebase ou qualquer framework externo — os tipos Dart nativos (`DateTime`) são usados em `toMap()`/`fromMap()`; a conversão de `Timestamp` é feita nos repositórios da camada Data.

---

## Pré-requisitos

| Ferramenta | Versão mínima |
|---|---|
| Flutter SDK | 3.x (canal stable) |
| Dart SDK | 3.10+ |
| Java | 17 |
| Xcode (iOS) | 15+ |
| Android Studio / SDK | API 21+ |
| Firebase CLI | Qualquer versão recente |
| Node.js | 18+ (Cloud Functions) |
| `lcov` | Qualquer (para relatório de cobertura HTML) |

Instale o `lcov` (macOS):
```bash
brew install lcov
```

---

## Instalação e execução

```bash
# 1. Clone o repositório
git clone https://github.com/deytt/seniorease-mobile.git
cd seniorease-mobile

# 2. Inicialize o submódulo memory-bank
git submodule update --init --recursive

# 3. Instale as dependências Flutter
flutter pub get

# 4. Configure o Firebase (veja seção abaixo)

# 5. Execute o app
flutter run
```

### Emulador / Dispositivo físico
```bash
# Listar dispositivos disponíveis
flutter devices

# Executar em um dispositivo específico
flutter run -d <device-id>

# Executar em modo release
flutter run --release
```

---

## Configuração do Firebase

> **Importante:** nunca versione arquivos `.env`, `google-services.json`, `GoogleService-Info.plist` nem qualquer credencial. Esses arquivos estão no `.gitignore`.

### Passo a passo

1. Acesse o [Firebase Console](https://console.firebase.google.com) e crie um projeto (ou use o existente `seniorease-backend`).

2. Registre os aplicativos Android e iOS no console:
   - **Android:** Bundle ID `com.seniorease.mobile`
   - **iOS:** Bundle ID `com.seniorease.mobile`

3. Baixe os arquivos de configuração e coloque-os nos locais corretos:

   | Arquivo | Destino |
   |---|---|
   | `google-services.json` | `android/app/google-services.json` |
   | `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` (adicionar ao target Runner no Xcode) |

4. Execute o FlutterFire CLI para gerar `lib/core/firebase/firebase_options.dart`:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=<seu-projeto-firebase>
   ```

5. No Firebase Console, habilite:
   - **Authentication** → provedores Email/Senha e Google
   - **Firestore** → modo de produção com regras publicadas
   - **Storage** → bucket padrão com regras para `profile_photos/{userId}`
   - **Cloud Messaging** → para push notifications

6. Para Google Sign-In no iOS, adicione o `REVERSED_CLIENT_ID` do `GoogleService-Info.plist` como URL Scheme em `ios/Runner/Info.plist`.

### Serviços Firebase utilizados

| Serviço | Uso |
|---|---|
| Firebase Auth | Autenticação (e-mail + Google OAuth) |
| Cloud Firestore | Armazenamento de dados (usuários, tarefas, lembretes, histórico, preferências) |
| Firebase Storage | Fotos de perfil |
| Firebase Cloud Messaging (FCM) | Push notifications |
| Cloud Functions | Envio automático de notificações + reset de flags |

---

## Comandos úteis

```bash
# Instalar dependências
flutter pub get

# Executar a aplicação
flutter run

# Executar análise estática (deve retornar 0 erros)
flutter analyze

# Executar todos os testes
flutter test

# Executar testes com cobertura
flutter test --coverage

# Formatar código
dart format lib/ test/

# Build APK release
flutter build apk --release

# Build IPA (iOS)
flutter build ipa
```

---

## Cobertura de testes

A suíte atual conta com **300 testes** distribuídos nas três camadas da Clean Architecture (Domain, Data, Presentation).

### Executar localmente

```bash
bash scripts/coverage.sh
```

O relatório HTML é gerado em `coverage/html/index.html`. Abra-o no navegador:

```bash
open coverage/html/index.html    # macOS
xdg-open coverage/html/index.html   # Linux
```

### Dependência: `lcov`

```bash
# macOS
brew install lcov

# Ubuntu / Debian
sudo apt-get install lcov
```

### O que é testado

| Camada | Exemplos de testes |
|---|---|
| **Domain** | Entidades (`Task`, `Reminder`, `UserPreferences`, `HistoryEvent`), use cases (`CreateTask`, `CompleteTask`, `ChangePassword`, `BiometricUseCases`) |
| **Data** | Repositórios Firebase com `fake_cloud_firestore` e `firebase_auth_mocks`; `LocalTutorialStateRepository`; `LocalBiometricRepository`; `SecureCredentialCache`; `FirebaseProfilePhotoStorage` |
| **Presentation** | Controllers Riverpod (`TasksController`, `AuthController`, `AccessibilityController`); providers (`nextPendingTaskProvider`, `tourProviders`, `notificationsProvider`) |

### No CI

O workflow `.github/workflows/mobile.yml` executa `flutter test --coverage` e publica o relatório como artefato (`coverage-report`) em cada push. Acesse a aba **Actions** do repositório para baixar o relatório.

---

## CI/CD e distribuição

### GitHub Actions — `.github/workflows/mobile.yml`

| Job | Gatilho | O que faz |
|---|---|---|
| `ci` | Todos os pushs e PRs | `flutter analyze` + `flutter test --coverage` + publica artefato de cobertura |
| `distribute` | Push na `master` | Build APK release + upload para Firebase App Distribution |

### Firebase App Distribution

Os APKs de release são distribuídos automaticamente para o grupo `seniorease-testers`. Os secrets necessários no repositório GitHub são:

| Secret | Descrição |
|---|---|
| `FIREBASE_APP_ID_ANDROID` | App ID do aplicativo Android no Firebase |
| `FIREBASE_SERVICE_ACCOUNT` | JSON da Service Account com permissão de distribuição |

### TestFlight (iOS)

A versão iOS é distribuída via TestFlight. O Bundle ID é `com.seniorease.mobile`. Para gerar e publicar:

```bash
flutter build ipa
# Em seguida, abrir Xcode Organizer e fazer Upload para o App Store Connect
```

---

## Estrutura de pastas

```
seniorease-mobile/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart               ← MaterialApp + tema dinâmico
│   │   ├── router.dart            ← GoRouter + rotas protegidas
│   │   ├── history/               ← adaptador AppHistoryRecorder
│   │   └── tour/                  ← adaptador AppTourGate
│   ├── core/                      ← código compartilhado por todas as features
│   │   ├── theme/                 ← AppTheme, AppColors, AppSpacing, tokens
│   │   ├── widgets/               ← Design System (SeniorButton, SeniorInput, etc.)
│   │   ├── firebase/              ← firebase_options.dart
│   │   ├── feedback/              ← SeniorFeedback (haptics + áudio)
│   │   ├── history/               ← port HistoryRecorder
│   │   ├── preferences/           ← UserPreferences (domain sem Firebase)
│   │   ├── tour/                  ← port TourGate, SeniorShowcase, TourHelpButton
│   │   └── utils/                 ← input_masks, formatters
│   └── features/
│       ├── auth/                  ← Login, Register, ForgotPassword, biometria
│       ├── home/                  ← Dashboard, notificações
│       ├── accessibility/         ← Acessibilidade, preferências, tema dinâmico
│       ├── tasks/                 ← Tarefas (CRUD, modo guiado, filtros)
│       ├── reminders/             ← Lembretes (CRUD, categorias, swipe)
│       ├── history/               ← Histórico, streak, stats
│       ├── guides/                ← Central de guias, onboarding Firestore
│       ├── notifications/         ← FCM token, histórico de notificações
│       └── profile/               ← Perfil, Definições, Segurança, Sobre
├── test/                          ← espelha lib/ (feature → camada)
├── scripts/
│   ├── coverage.sh                ← gera relatório HTML de cobertura
│   └── update-memory-bank.sh      ← sincroniza memory-bank (Cursor + Copilot)
├── .github/
│   └── workflows/
│       └── mobile.yml             ← CI (analyze + test + coverage) + CD (APK)
├── assets/
│   ├── lottie/                    ← animações (celebração, check)
│   ├── images/                    ← ícones, logos
│   └── sounds/                    ← feedback de áudio
├── memory-bank/                   ← submódulo com contexto do projeto
└── pubspec.yaml
```

### Camadas por feature (padrão)

```
features/<nome>/
├── domain/
│   ├── entities/         ← modelos de dados (sem Firebase)
│   ├── repositories/     ← contratos (interfaces abstratas)
│   └── usecases/         ← lógica de negócio
├── data/
│   └── firebase_<nome>_repository.dart  ← implementação Firebase
└── presentation/
    ├── providers/        ← Riverpod providers e controllers
    ├── screens/          ← telas
    └── widgets/          ← componentes locais da feature
```

---

## Links do projeto

| Recurso | Link |
|---|---|
| Repositório Mobile | https://github.com/deytt/seniorease-mobile |
| Repositório Web | https://github.com/deytt/seniorease-web |
| App Web (Vercel) | https://seniorease-web.vercel.app/ |
| Figma Design (high-fidelity) | https://www.figma.com/design/3avWJD9n4gI9mZHw9dksIy/SeniorEase?node-id=15-6101&p=f |
| Figma Make (protótipo interativo) | https://www.figma.com/make/BDutOHdML1CVduefhokF9n/High-fidelity-design-for-SeniorEase |
| Vídeo de demonstração | _a confirmar_ |
| Memory Bank | [memory-bank/](./memory-bank/) |
| Documentação de specs | [docs/specs/](./docs/specs/) |

---

## Configuração do Memory Bank

O memory bank é um submódulo Git com o contexto arquitetural compartilhado entre Mobile e Web:

```bash
# Inicializar / atualizar
git submodule update --init --recursive

# Sincronizar com a versão mais recente
bash scripts/update-memory-bank.sh
```

---

## Licença

Projeto acadêmico desenvolvido para o Challenge FIAP 2026. Todos os direitos reservados à equipe SeniorEase.
