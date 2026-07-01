import 'package:flutter/material.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/tour/tour_id.dart';

/// Metadados de apresentação de cada tutorial disponível na Central
/// "Guias do aplicativo".
///
/// Vive na camada de **presentation** (não no domínio) porque carrega tipos de
/// UI ([IconData]) e rotas — mantendo o domínio puro.
///
/// Para disponibilizar um novo tutorial na Central, basta acrescentar uma
/// entrada em [kTutorials] — nenhuma outra estrutura precisa de mudar (ADR-013).
class TutorialInfo {
  const TutorialInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    this.isShellTab = false,
  });

  final TourId id;

  /// Título amigável, sem jargão técnico.
  final String title;
  final String description;
  final IconData icon;

  /// Rota da tela onde o tutorial decorre.
  final String route;

  /// `true` se a rota é uma aba da barra inferior (navega com `go`),
  /// `false` se é uma rota full-screen (navega com `push`).
  final bool isShellTab;
}

/// Catálogo dos tutoriais atualmente disponíveis.
const List<TutorialInfo> kTutorials = [
  TutorialInfo(
    id: TourId.home,
    title: 'Conhecer a tela inicial',
    description: 'Veja onde fica cada coisa na sua página de início.',
    icon: Icons.home_outlined,
    route: AppRoutes.home,
    isShellTab: true,
  ),
  TutorialInfo(
    id: TourId.createTask,
    title: 'Como criar uma tarefa',
    description: 'Aprenda passo a passo a criar sua primeira tarefa.',
    icon: Icons.add_task,
    route: AppRoutes.createTask,
  ),
  TutorialInfo(
    id: TourId.taskList,
    title: 'Ver as suas tarefas',
    description: 'Saiba como encontrar, filtrar e abrir as suas tarefas.',
    icon: Icons.check_circle_outline,
    route: AppRoutes.tasks,
    isShellTab: true,
  ),
  TutorialInfo(
    id: TourId.remindersList,
    title: 'Ver os seus lembretes',
    description: 'Saiba como filtrar e acompanhar os seus lembretes.',
    icon: Icons.notifications_none_outlined,
    route: AppRoutes.reminders,
    isShellTab: true,
  ),
  TutorialInfo(
    id: TourId.createReminder,
    title: 'Como criar um lembrete',
    description: 'Aprenda passo a passo a criar o seu primeiro lembrete.',
    icon: Icons.add_alert_outlined,
    route: AppRoutes.createReminder,
  ),
  TutorialInfo(
    id: TourId.accessibility,
    title: 'Ajustar a acessibilidade',
    description: 'Mude o tamanho da letra, as cores e o modo de uso.',
    icon: Icons.settings_accessibility,
    route: AppRoutes.accessibility,
  ),
  TutorialInfo(
    id: TourId.settings,
    title: 'Conhecer as configurações',
    description: 'Veja onde mudar as suas preferências e onde fica cada coisa.',
    icon: Icons.settings_outlined,
    route: AppRoutes.settings,
    isShellTab: true,
  ),
  TutorialInfo(
    id: TourId.profile,
    title: 'Ver e mudar seu perfil',
    description: 'Aprenda a mudar sua foto e seus dados pessoais.',
    icon: Icons.person_outline,
    route: AppRoutes.profile,
  ),
  TutorialInfo(
    id: TourId.security,
    title: 'Proteger a sua conta',
    description: 'Veja as opções de biometria, verificação e palavra-passe.',
    icon: Icons.security_outlined,
    route: AppRoutes.security,
  ),
  TutorialInfo(
    id: TourId.about,
    title: 'Sobre a aplicação',
    description: 'Veja a versão e como abrir o SeniorEase no computador.',
    icon: Icons.info_outline,
    route: AppRoutes.about,
  ),
];
