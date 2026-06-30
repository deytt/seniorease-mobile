/// Endereço do utilizador. Value object imutável guardado como mapa aninhado no
/// documento `users/{userId}` (campo `address`).
class Address {
  const Address({
    this.neighborhood = '',
    this.street = '',
    this.number = '',
    this.zipCode = '',
    this.city = '',
    this.state = '',
    this.country = '',
  });

  final String neighborhood;
  final String street;
  final String number;
  final String zipCode;
  final String city;
  final String state;
  final String country;

  static const Address empty = Address();

  /// `true` quando nenhum campo está preenchido.
  bool get isEmpty =>
      neighborhood.isEmpty &&
      street.isEmpty &&
      number.isEmpty &&
      zipCode.isEmpty &&
      city.isEmpty &&
      state.isEmpty &&
      country.isEmpty;

  Address copyWith({
    String? neighborhood,
    String? street,
    String? number,
    String? zipCode,
    String? city,
    String? state,
    String? country,
  }) =>
      Address(
        neighborhood: neighborhood ?? this.neighborhood,
        street: street ?? this.street,
        number: number ?? this.number,
        zipCode: zipCode ?? this.zipCode,
        city: city ?? this.city,
        state: state ?? this.state,
        country: country ?? this.country,
      );

  Map<String, dynamic> toMap() => {
        'neighborhood': neighborhood,
        'street': street,
        'number': number,
        'zipCode': zipCode,
        'city': city,
        'state': state,
        'country': country,
      };

  factory Address.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Address.empty;
    return Address(
      neighborhood: map['neighborhood'] as String? ?? '',
      street: map['street'] as String? ?? '',
      number: map['number'] as String? ?? '',
      zipCode: map['zipCode'] as String? ?? '',
      city: map['city'] as String? ?? '',
      state: map['state'] as String? ?? '',
      country: map['country'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Address &&
      other.neighborhood == neighborhood &&
      other.street == street &&
      other.number == number &&
      other.zipCode == zipCode &&
      other.city == city &&
      other.state == state &&
      other.country == country;

  @override
  int get hashCode => Object.hash(
        neighborhood,
        street,
        number,
        zipCode,
        city,
        state,
        country,
      );
}
