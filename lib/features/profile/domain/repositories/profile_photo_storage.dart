import 'dart:typed_data';

/// Contrato para o armazenamento da foto de perfil (implementado por Firebase
/// Storage na camada de dados). Mantém o domínio livre de detalhes de
/// infraestrutura.
abstract interface class ProfilePhotoStorage {
  /// Faz upload dos [bytes] da foto do utilizador e devolve o URL público.
  /// [contentType] ex.: `image/jpeg`.
  Future<String> upload(
    String userId,
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  });
}
