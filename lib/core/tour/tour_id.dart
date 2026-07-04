/// Identificadores únicos de cada tutorial guiado da aplicação.
///
/// Vive em `core/` (sem regra de negócio) para que tanto as telas das features
/// como a feature `guides` possam referenciá-lo sem que nenhuma feature precise
/// de importar outra (ver ADR-013).
///
/// Para adicionar um novo tutorial no futuro basta acrescentar um valor aqui e
/// registá-lo no catálogo da feature `guides` — nenhuma estrutura existente
/// precisa de mudar.
enum TourId {
  home,
  createTask,
  taskList,
  taskDetails,
  remindersList,
  createReminder,
  history,
  accessibility,
  settings,
  guides,
  about,
  profile,
  security;

  /// Chave estável usada na persistência local (shared_preferences).
  String get storageKey => name;
}
