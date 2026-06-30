/// Lançada quando o utilizador fecha/cancela o fluxo de login social (Google)
/// sem concluir. A UI deve ignorar silenciosamente (sem toast de erro).
class AuthCancelledException implements Exception {
  const AuthCancelledException();
}
