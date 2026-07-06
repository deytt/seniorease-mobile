import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';

void main() {
  group('FontSizeScale', () {
    test('scale e label', () {
      expect(FontSizeScale.medium.scale, 1.0);
      expect(FontSizeScale.large.scale, 1.2);
      expect(FontSizeScale.extraLarge.label, '150%');
    });

    test('fromString/toFirestore (extra_large)', () {
      expect(FontSizeScale.fromString('extra_large'), FontSizeScale.extraLarge);
      expect(FontSizeScale.fromString('?'), FontSizeScale.medium);
      expect(FontSizeScale.extraLarge.toFirestore(), 'extra_large');
    });
  });

  group('ContrastMode', () {
    test('fromString/toFirestore', () {
      expect(ContrastMode.fromString('maximum'), ContrastMode.maximum);
      expect(ContrastMode.fromString('x'), ContrastMode.defaultMode);
      expect(ContrastMode.defaultMode.toFirestore(), 'default');
    });
  });

  group('InterfaceMode', () {
    test('fromString por defeito é basic', () {
      expect(InterfaceMode.fromString('advanced'), InterfaceMode.advanced);
      expect(InterfaceMode.fromString('qualquer'), InterfaceMode.basic);
    });
  });

  group('NotificationOffset', () {
    test('minutes retorna valores corretos', () {
      expect(NotificationOffset.min15.minutes, 15);
      expect(NotificationOffset.min30.minutes, 30);
      expect(NotificationOffset.hour1.minutes, 60);
      expect(NotificationOffset.hour6.minutes, 360);
      expect(NotificationOffset.day1.minutes, 1440);
    });

    test('label em português', () {
      expect(NotificationOffset.min30.label, '30 minutos antes');
      expect(NotificationOffset.hour1.label, '1 hora antes');
      expect(NotificationOffset.day1.label, '1 dia antes');
    });

    test('fromString/toFirestore roundtrip', () {
      for (final v in NotificationOffset.values) {
        expect(NotificationOffset.fromString(v.toFirestore()), v);
      }
    });

    test('fromString com valor desconhecido retorna min30', () {
      expect(NotificationOffset.fromString('?'), NotificationOffset.min30);
    });
  });

  group('UserPreferences', () {
    test('defaults', () {
      final p = UserPreferences.defaults(userId: 'u1');
      expect(p.userId, 'u1');
      expect(p.fontSize, FontSizeScale.medium);
      expect(p.darkMode, isFalse);
      expect(p.interfaceMode, InterfaceMode.advanced);
      expect(p.tasksNotificationsEnabled, isTrue);
      expect(p.remindersNotificationsEnabled, isTrue);
      expect(p.taskNotificationOffset, NotificationOffset.min30);
      expect(p.reminderNotificationOffset, NotificationOffset.min30);
    });

    test('spacing default é comfortable', () {
      expect(
        UserPreferences.defaults(userId: 'u1').spacing,
        SpacingMode.comfortable,
      );
    });

    test('copyWith preserva spacing', () {
      final p = UserPreferences.defaults(userId: 'u1');
      final updated = p.copyWith(spacing: SpacingMode.spacious);
      expect(updated.spacing, SpacingMode.spacious);
      expect(updated.fontSize, p.fontSize);
    });

    test('copyWith', () {
      final p = UserPreferences.defaults(userId: 'u1');
      final updated = p.copyWith(
        darkMode: true,
        contrast: ContrastMode.high,
        interfaceMode: InterfaceMode.basic,
      );
      expect(updated.darkMode, isTrue);
      expect(updated.contrast, ContrastMode.high);
      expect(updated.interfaceMode, InterfaceMode.basic);
      expect(updated.fontSize, p.fontSize);
    });

    test('copyWith altera offsets de notificação', () {
      final p = UserPreferences.defaults(userId: 'u1');
      final updated = p.copyWith(
        tasksNotificationsEnabled: false,
        taskNotificationOffset: NotificationOffset.hour6,
        remindersNotificationsEnabled: false,
        reminderNotificationOffset: NotificationOffset.day1,
      );
      expect(updated.tasksNotificationsEnabled, isFalse);
      expect(updated.taskNotificationOffset, NotificationOffset.hour6);
      expect(updated.remindersNotificationsEnabled, isFalse);
      expect(updated.reminderNotificationOffset, NotificationOffset.day1);
      // outros campos inalterados
      expect(updated.fontSize, p.fontSize);
    });

    test('toMap serializa enums e usa serverTimestamp em updatedAt', () {
      final map = UserPreferences.defaults(userId: 'u1').copyWith(
        fontSize: FontSizeScale.large,
        contrast: ContrastMode.high,
        taskNotificationOffset: NotificationOffset.hour1,
      ).toMap();
      expect(map['fontSize'], 'large');
      expect(map['contrast'], 'high');
      expect(map['interfaceMode'], 'advanced');
      expect(map['taskNotificationOffset'], '1h');
      expect(map['reminderNotificationOffset'], '30m');
      expect(map['updatedAt'], isA<FieldValue>());
    });

    test('toMap/fromMap roundtrip spacing', () {
      final prefs = UserPreferences.defaults(userId: 'u1')
          .copyWith(spacing: SpacingMode.compact);
      final map = Map<String, dynamic>.from(prefs.toMap())
        // FieldValue.serverTimestamp() não pode ser relido como Timestamp
        // em testes unitários — removemos e deixamos o fromMap usar DateTime.now()
        ..remove('updatedAt');
      expect(map['spacing'], 'compact');
      final restored = UserPreferences.fromMap(prefs.userId, map);
      expect(restored.spacing, SpacingMode.compact);
    });

    test('toMap/fromMap roundtrip notificationOffset', () {
      final prefs = UserPreferences.defaults(userId: 'u1').copyWith(
        tasksNotificationsEnabled: false,
        taskNotificationOffset: NotificationOffset.hour6,
        remindersNotificationsEnabled: true,
        reminderNotificationOffset: NotificationOffset.day1,
      );
      final map = Map<String, dynamic>.from(prefs.toMap())..remove('updatedAt');
      final restored = UserPreferences.fromMap(prefs.userId, map);
      expect(restored.tasksNotificationsEnabled, isFalse);
      expect(restored.taskNotificationOffset, NotificationOffset.hour6);
      expect(restored.remindersNotificationsEnabled, isTrue);
      expect(restored.reminderNotificationOffset, NotificationOffset.day1);
    });

    test('fromMap reconstrói com defaults para campos ausentes', () {
      final p = UserPreferences.fromMap('u2', {
        'fontSize': 'large',
        'darkMode': true,
        'contrast': 'maximum',
        'interfaceMode': 'basic',
        'updatedAt': Timestamp.fromDate(DateTime(2026, 3, 3)),
      });
      expect(p.userId, 'u2');
      expect(p.fontSize, FontSizeScale.large);
      expect(p.darkMode, isTrue);
      expect(p.contrast, ContrastMode.maximum);
      expect(p.interfaceMode, InterfaceMode.basic);
      // campos de notificação ausentes → defaults
      expect(p.tasksNotificationsEnabled, isTrue);
      expect(p.taskNotificationOffset, NotificationOffset.min30);
      expect(p.remindersNotificationsEnabled, isTrue);
      expect(p.reminderNotificationOffset, NotificationOffset.min30);
      expect(p.spacing, SpacingMode.comfortable);
      expect(p.updatedAt, DateTime(2026, 3, 3));
    });
  });
}
