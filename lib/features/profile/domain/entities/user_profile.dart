import 'package:mobile/features/profile/domain/entities/address.dart';

/// Perfil do utilizador. Mapeia a collection `users/{userId}`, estendendo os
/// campos base (id/name/email) com dados pessoais e endereço (ADR-014).
///
/// O e-mail nunca é editável pelo utilizador (vem do Firebase Auth). Os campos
/// opcionais ([phone], [birthDate], [cpf], [photoUrl]) são `null` quando ainda
/// não foram preenchidos.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.birthDate,
    this.cpf,
    this.photoUrl,
    this.address = Address.empty,
  });

  final String id;
  final String name;
  final String email;

  /// Telefone formatado, ex.: `(19) 9 9999-9999`.
  final String? phone;

  /// Data de nascimento como texto mascarado, ex.: `31/12/1950`.
  final String? birthDate;

  /// CPF formatado (opcional), ex.: `123.456.789-00`.
  final String? cpf;

  /// URL público da foto no Firebase Storage (ou de um provedor OAuth futuro).
  final String? photoUrl;

  final Address address;

  /// Iniciais derivadas do nome (fallback do avatar quando não há foto).
  String get initials {
    final parts = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get hasPhone => phone != null && phone!.trim().isNotEmpty;
  bool get hasPhoto => photoUrl != null && photoUrl!.trim().isNotEmpty;

  factory UserProfile.empty(String id) => UserProfile(id: id, name: '', email: '');

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? birthDate,
    String? cpf,
    String? photoUrl,
    Address? address,
  }) =>
      UserProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        birthDate: birthDate ?? this.birthDate,
        cpf: cpf ?? this.cpf,
        photoUrl: photoUrl ?? this.photoUrl,
        address: address ?? this.address,
      );

  /// Campos editáveis do perfil (não inclui `id`/`createdAt`, preservados via
  /// merge na camada de dados). `email` é incluído para consistência mas nunca
  /// é alterado pela UI.
  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': _orNull(phone),
        'birthDate': _orNull(birthDate),
        'cpf': _orNull(cpf),
        'photoUrl': _orNull(photoUrl),
        'address': address.toMap(),
      };

  factory UserProfile.fromMap(String id, Map<String, dynamic> map) =>
      UserProfile(
        id: id,
        name: map['name'] as String? ?? '',
        email: map['email'] as String? ?? '',
        phone: map['phone'] as String?,
        birthDate: map['birthDate'] as String?,
        cpf: map['cpf'] as String?,
        photoUrl: map['photoUrl'] as String?,
        address: Address.fromMap(map['address'] as Map<String, dynamic>?),
      );

  static String? _orNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
