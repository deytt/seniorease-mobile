import 'package:cloud_firestore/cloud_firestore.dart';

enum FontSizeScale {
  small,
  medium,
  large,
  extraLarge;

  /// Factor de escala aplicado ao TextTheme
  double get scale => switch (this) {
        FontSizeScale.small => 0.875,
        FontSizeScale.medium => 1.0,
        FontSizeScale.large => 1.2,
        FontSizeScale.extraLarge => 1.5,
      };

  /// Percentagem exibida na UI (ex: "120%")
  String get label => switch (this) {
        FontSizeScale.small => '87%',
        FontSizeScale.medium => '100%',
        FontSizeScale.large => '120%',
        FontSizeScale.extraLarge => '150%',
      };

  static FontSizeScale fromString(String value) => switch (value) {
        'small' => FontSizeScale.small,
        'large' => FontSizeScale.large,
        'extra_large' => FontSizeScale.extraLarge,
        _ => FontSizeScale.medium,
      };

  String toFirestore() => switch (this) {
        FontSizeScale.small => 'small',
        FontSizeScale.medium => 'medium',
        FontSizeScale.large => 'large',
        FontSizeScale.extraLarge => 'extra_large',
      };
}

enum ContrastMode {
  defaultMode,
  high,
  maximum;

  static ContrastMode fromString(String value) => switch (value) {
        'high' => ContrastMode.high,
        'maximum' => ContrastMode.maximum,
        _ => ContrastMode.defaultMode,
      };

  String toFirestore() => switch (this) {
        ContrastMode.defaultMode => 'default',
        ContrastMode.high => 'high',
        ContrastMode.maximum => 'maximum',
      };
}

enum SpacingMode {
  compact,
  comfortable,
  spacious;

  static SpacingMode fromString(String value) => switch (value) {
        'compact' => SpacingMode.compact,
        'spacious' => SpacingMode.spacious,
        _ => SpacingMode.comfortable,
      };

  String toFirestore() => name;
}

enum InterfaceMode {
  basic,
  advanced;

  static InterfaceMode fromString(String value) =>
      value == 'advanced' ? InterfaceMode.advanced : InterfaceMode.basic;

  String toFirestore() => name;
}

/// Antecedência com que o utilizador recebe a notificação push antes de uma
/// tarefa ou lembrete.
enum NotificationOffset {
  min15,
  min30,
  hour1,
  hour6,
  day1;

  /// Minutos de antecedência usados pelo backend para calcular o horário de envio.
  int get minutes => switch (this) {
        NotificationOffset.min15 => 15,
        NotificationOffset.min30 => 30,
        NotificationOffset.hour1 => 60,
        NotificationOffset.hour6 => 360,
        NotificationOffset.day1 => 1440,
      };

  /// Rótulo exibido na UI de Preferências de Notificação.
  String get label => switch (this) {
        NotificationOffset.min15 => '15 minutos antes',
        NotificationOffset.min30 => '30 minutos antes',
        NotificationOffset.hour1 => '1 hora antes',
        NotificationOffset.hour6 => '6 horas antes',
        NotificationOffset.day1 => '1 dia antes',
      };

  static NotificationOffset fromString(String value) => switch (value) {
        '15m' => NotificationOffset.min15,
        '1h' => NotificationOffset.hour1,
        '6h' => NotificationOffset.hour6,
        '1d' => NotificationOffset.day1,
        _ => NotificationOffset.min30,
      };

  String toFirestore() => switch (this) {
        NotificationOffset.min15 => '15m',
        NotificationOffset.min30 => '30m',
        NotificationOffset.hour1 => '1h',
        NotificationOffset.hour6 => '6h',
        NotificationOffset.day1 => '1d',
      };
}

class UserPreferences {
  const UserPreferences({
    required this.userId,
    required this.fontSize,
    required this.darkMode,
    required this.contrast,
    required this.spacing,
    required this.interfaceMode,
    required this.audioFeedbackEnabled,
    required this.largeTouchTargets,
    required this.tasksNotificationsEnabled,
    required this.taskNotificationOffset,
    required this.remindersNotificationsEnabled,
    required this.reminderNotificationOffset,
    required this.updatedAt,
  });

  final String userId;

  /// Escala tipográfica (small / medium / large / extraLarge)
  final FontSizeScale fontSize;

  /// Tema escuro
  final bool darkMode;

  /// Modo de contraste; 'maximum' é derivado automaticamente quando
  /// darkMode == true && contrast == high
  final ContrastMode contrast;

  /// Modo de espaçamento (aplicado globalmente pelo tema)
  final SpacingMode spacing;

  /// Modo básico ou avançado da interface
  final InterfaceMode interfaceMode;

  /// Feedback visual + háptico + áudio nos botões e acções
  final bool audioFeedbackEnabled;

  /// Touch targets de 64×64px em vez de 48×48px
  final bool largeTouchTargets;

  /// Ativa notificações push para tarefas
  final bool tasksNotificationsEnabled;

  /// Antecedência com que o push de tarefa é enviado
  final NotificationOffset taskNotificationOffset;

  /// Ativa notificações push para lembretes
  final bool remindersNotificationsEnabled;

  /// Antecedência com que o push de lembrete é enviado
  final NotificationOffset reminderNotificationOffset;

  final DateTime updatedAt;

  /// Preferências padrão (usadas offline ou antes do Firestore responder)
  factory UserPreferences.defaults({String userId = ''}) => UserPreferences(
        userId: userId,
        fontSize: FontSizeScale.medium,
        darkMode: false,
        contrast: ContrastMode.defaultMode,
        spacing: SpacingMode.comfortable,
        interfaceMode: InterfaceMode.advanced,
        audioFeedbackEnabled: false,
        largeTouchTargets: false,
        tasksNotificationsEnabled: true,
        taskNotificationOffset: NotificationOffset.min30,
        remindersNotificationsEnabled: true,
        reminderNotificationOffset: NotificationOffset.min30,
        updatedAt: DateTime.now(),
      );

  UserPreferences copyWith({
    String? userId,
    FontSizeScale? fontSize,
    bool? darkMode,
    ContrastMode? contrast,
    SpacingMode? spacing,
    InterfaceMode? interfaceMode,
    bool? audioFeedbackEnabled,
    bool? largeTouchTargets,
    bool? tasksNotificationsEnabled,
    NotificationOffset? taskNotificationOffset,
    bool? remindersNotificationsEnabled,
    NotificationOffset? reminderNotificationOffset,
    DateTime? updatedAt,
  }) =>
      UserPreferences(
        userId: userId ?? this.userId,
        fontSize: fontSize ?? this.fontSize,
        darkMode: darkMode ?? this.darkMode,
        contrast: contrast ?? this.contrast,
        spacing: spacing ?? this.spacing,
        interfaceMode: interfaceMode ?? this.interfaceMode,
        audioFeedbackEnabled: audioFeedbackEnabled ?? this.audioFeedbackEnabled,
        largeTouchTargets: largeTouchTargets ?? this.largeTouchTargets,
        tasksNotificationsEnabled:
            tasksNotificationsEnabled ?? this.tasksNotificationsEnabled,
        taskNotificationOffset:
            taskNotificationOffset ?? this.taskNotificationOffset,
        remindersNotificationsEnabled:
            remindersNotificationsEnabled ?? this.remindersNotificationsEnabled,
        reminderNotificationOffset:
            reminderNotificationOffset ?? this.reminderNotificationOffset,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'fontSize': fontSize.toFirestore(),
        'darkMode': darkMode,
        'contrast': contrast.toFirestore(),
        'spacing': spacing.toFirestore(),
        'interfaceMode': interfaceMode.toFirestore(),
        'audioFeedbackEnabled': audioFeedbackEnabled,
        'largeTouchTargets': largeTouchTargets,
        'tasksNotificationsEnabled': tasksNotificationsEnabled,
        'taskNotificationOffset': taskNotificationOffset.toFirestore(),
        'remindersNotificationsEnabled': remindersNotificationsEnabled,
        'reminderNotificationOffset': reminderNotificationOffset.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory UserPreferences.fromMap(String userId, Map<String, dynamic> map) =>
      UserPreferences(
        userId: userId,
        fontSize: FontSizeScale.fromString(map['fontSize'] as String? ?? ''),
        darkMode: map['darkMode'] as bool? ?? false,
        contrast: ContrastMode.fromString(map['contrast'] as String? ?? ''),
        spacing: SpacingMode.fromString(map['spacing'] as String? ?? ''),
        interfaceMode:
            InterfaceMode.fromString(map['interfaceMode'] as String? ?? ''),
        audioFeedbackEnabled:
            map['audioFeedbackEnabled'] as bool? ?? false,
        largeTouchTargets: map['largeTouchTargets'] as bool? ?? false,
        tasksNotificationsEnabled:
            map['tasksNotificationsEnabled'] as bool? ?? true,
        taskNotificationOffset: NotificationOffset.fromString(
          map['taskNotificationOffset'] as String? ?? '',
        ),
        remindersNotificationsEnabled:
            map['remindersNotificationsEnabled'] as bool? ?? true,
        reminderNotificationOffset: NotificationOffset.fromString(
          map['reminderNotificationOffset'] as String? ?? '',
        ),
        updatedAt:
            (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
