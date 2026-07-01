import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profile/domain/entities/address.dart';
import 'package:mobile/features/profile/domain/entities/user_profile.dart';

void main() {
  group('Address', () {
    test('fromMap/toMap fazem round-trip', () {
      const address = Address(
        neighborhood: 'Centro',
        street: 'Rua A',
        number: '10',
        zipCode: '13000-000',
        city: 'Campinas',
        state: 'SP',
        country: 'Brasil',
      );

      final restored = Address.fromMap(address.toMap());
      expect(restored, address);
    });

    test('fromMap(null) devolve Address.empty', () {
      expect(Address.fromMap(null), Address.empty);
      expect(Address.empty.isEmpty, isTrue);
    });

    test('copyWith altera apenas o campo indicado', () {
      const address = Address(city: 'Campinas');
      expect(address.copyWith(state: 'SP').city, 'Campinas');
      expect(address.copyWith(state: 'SP').state, 'SP');
    });
  });

  group('UserProfile', () {
    test('initials deriva as iniciais do nome', () {
      expect(const UserProfile(id: 'u1', name: 'Maria Silva', email: 'm@x.pt')
          .initials, 'MS');
      expect(const UserProfile(id: 'u1', name: 'Maria', email: 'm@x.pt')
          .initials, 'M');
      expect(const UserProfile(id: 'u1', name: '', email: 'm@x.pt')
          .initials, '?');
    });

    test('hasPhone/hasPhoto refletem campos preenchidos', () {
      const semDados = UserProfile(id: 'u1', name: 'Maria', email: 'm@x.pt');
      expect(semDados.hasPhone, isFalse);
      expect(semDados.hasPhoto, isFalse);

      final comDados = semDados.copyWith(
        phone: '(19) 9 9999-9999',
        photoUrl: 'http://x/p.jpg',
      );
      expect(comDados.hasPhone, isTrue);
      expect(comDados.hasPhoto, isTrue);
    });

    test('toMap normaliza strings vazias para null e inclui o endereço', () {
      const profile = UserProfile(
        id: 'u1',
        name: 'Maria Silva',
        email: 'm@x.pt',
        phone: '   ',
        cpf: '',
        address: Address(city: 'Campinas'),
      );

      final map = profile.toMap();
      expect(map['name'], 'Maria Silva');
      expect(map['phone'], isNull);
      expect(map['cpf'], isNull);
      expect((map['address'] as Map)['city'], 'Campinas');
      // O id não é escrito (preservado via merge na camada de dados).
      expect(map.containsKey('id'), isFalse);
    });

    test('fromMap reconstrói o perfil e o endereço aninhado', () {
      final profile = UserProfile.fromMap('u1', {
        'name': 'Maria Silva',
        'email': 'm@x.pt',
        'phone': '(19) 9 9999-9999',
        'birthDate': '31/12/1950',
        'photoUrl': 'http://x/p.jpg',
        'address': {'city': 'Campinas', 'state': 'SP'},
      });

      expect(profile.id, 'u1');
      expect(profile.name, 'Maria Silva');
      expect(profile.phone, '(19) 9 9999-9999');
      expect(profile.birthDate, '31/12/1950');
      expect(profile.address.city, 'Campinas');
      expect(profile.address.state, 'SP');
    });

    test('empty cria um perfil vazio com o id dado', () {
      final empty = UserProfile.empty('u1');
      expect(empty.id, 'u1');
      expect(empty.name, isEmpty);
      expect(empty.address, Address.empty);
    });
  });
}
