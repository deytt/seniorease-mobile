class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    this.emailVerified = false,
  });

  final String id;
  final String email;
  final String name;
  final DateTime createdAt;

  /// Indica se o e-mail da conta já foi confirmado. Contas criadas via Google
  /// (OAuth) chegam com `true`; contas de e-mail/senha começam `false` até o
  /// utilizador clicar no link de verificação.
  final bool emailVerified;
}
